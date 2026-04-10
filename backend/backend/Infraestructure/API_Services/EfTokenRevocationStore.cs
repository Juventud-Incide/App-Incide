using backend.Data.DataDB;
using backend.Data.Entities;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Infraestructure.API_Services
{
    public class EfTokenRevocationStore : ITokenRevocationStore
    {
        private readonly AppDbContext _context;

        public EfTokenRevocationStore(AppDbContext context)
        {
            _context = context;
        }

        public async Task RevokeAsync(string jti, DateTime expiresAtUtc, CancellationToken ct)
        {
            if (string.IsNullOrWhiteSpace(jti))
                return;

            var alreadyRevoked = await _context.RevokedTokens
                .AnyAsync(rt => rt.Jti == jti, ct);

            if (alreadyRevoked)
                return;

            var now = DateTime.UtcNow;
            _context.RevokedTokens.Add(new RevokedToken
            {
                Jti = jti,
                ExpiresAt = expiresAtUtc,
                RevokedAt = now,
                CreationDate = now,
                LastUpdate = now,
                IsActive = true,
                IsDeleted = false
            });

            await _context.SaveChangesAsync(ct);
        }

        public Task<bool> IsRevokedAsync(string jti, CancellationToken ct)
        {
            if (string.IsNullOrWhiteSpace(jti))
                return Task.FromResult(false);

            return _context.RevokedTokens.AnyAsync(rt => rt.Jti == jti, ct);
        }
    }
}
