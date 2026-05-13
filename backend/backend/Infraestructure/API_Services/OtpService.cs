using System.Security.Cryptography;
using System.Text;
using backend.Data.DataDB;
using backend.Data.Entities;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Infraestructure.API_Services
{
    public class OtpService : IOtpService
    {
        private readonly AppDbContext _context;
        private readonly ISmsService  _sms;
        private readonly byte[]       _hashKey;

        private const int OtpExpiryMinutes = 10;
        private const int MaxAttempts      = 3;

        public OtpService(AppDbContext context, ISmsService sms, IConfiguration configuration)
        {
            _context = context;
            _sms     = sms;

            var keyValue = configuration["Otp:HashKey"]
                ?? throw new InvalidOperationException(
                    "OTP hash key is not configured. Set 'Otp:HashKey' via User Secrets (development) " +
                    "or the environment variable 'Otp__HashKey' (production).");
            _hashKey = Encoding.UTF8.GetBytes(keyValue);
        }

        public async Task SendOtpAsync(string phoneNumber, CancellationToken ct = default)
        {
            // Invalidar OTPs pendientes anteriores del mismo teléfono
            var pending = await _context.OtpCodes
                .Where(o => o.PhoneNumber == phoneNumber && !o.IsConsumed && !o.IsVerified)
                .ToListAsync(ct);

            foreach (var old in pending)
            {
                old.IsConsumed = true;
                old.LastUpdate = DateTime.UtcNow;
            }

            var code = RandomNumberGenerator.GetInt32(0, 1_000_000).ToString("D6");

            var otp = new OtpCode
            {
                PhoneNumber  = phoneNumber,
                CodeHash     = HashCode(code),
                ExpiresAt    = DateTime.UtcNow.AddMinutes(OtpExpiryMinutes),
                IsVerified   = false,
                IsConsumed   = false,
                Attempts     = 0,
                IsActive     = true,
                IsDeleted    = false,
                CreationDate = DateTime.UtcNow,
                LastUpdate   = DateTime.UtcNow
            };

            _context.OtpCodes.Add(otp);
            await _context.SaveChangesAsync(ct);

            try
            {
                await _sms.SendAsync(phoneNumber, $"Tu código de verificación INCIDE es: {code}", ct);
            }
            catch
            {
                otp.IsConsumed = true;
                otp.LastUpdate = DateTime.UtcNow;
                await _context.SaveChangesAsync(ct);
                throw;
            }
        }

        public async Task<bool> VerifyOtpAsync(string phoneNumber, string code, CancellationToken ct = default)
        {
            var otp = await _context.OtpCodes
                .Where(o => o.PhoneNumber == phoneNumber
                         && !o.IsConsumed
                         && !o.IsVerified
                         && o.ExpiresAt > DateTime.UtcNow)
                .OrderByDescending(o => o.CreationDate)
                .FirstOrDefaultAsync(ct);

            if (otp is null) return false;

            if (otp.Attempts >= MaxAttempts)
            {
                otp.IsConsumed = true;
                otp.LastUpdate = DateTime.UtcNow;
                await _context.SaveChangesAsync(ct);
                return false;
            }

            if (otp.CodeHash != HashCode(code))
            {
                otp.Attempts++;
                if (otp.Attempts >= MaxAttempts)
                    otp.IsConsumed = true;
                otp.LastUpdate = DateTime.UtcNow;
                await _context.SaveChangesAsync(ct);
                return false;
            }

            otp.IsVerified = true;
            otp.LastUpdate = DateTime.UtcNow;
            await _context.SaveChangesAsync(ct);
            return true;
        }

        public async Task<bool> ConsumeVerifiedOtpAsync(string phoneNumber, CancellationToken ct = default)
        {
            var affected = await _context.OtpCodes
                .Where(o => o.PhoneNumber == phoneNumber
                         && o.IsVerified
                         && !o.IsConsumed
                         && o.ExpiresAt > DateTime.UtcNow)
                .ExecuteUpdateAsync(s => s
                    .SetProperty(o => o.IsConsumed, true)
                    .SetProperty(o => o.LastUpdate, DateTime.UtcNow), ct);

            return affected > 0;
        }

        private string HashCode(string code) =>
            Convert.ToHexString(HMACSHA256.HashData(_hashKey, Encoding.UTF8.GetBytes(code)));
    }
}
