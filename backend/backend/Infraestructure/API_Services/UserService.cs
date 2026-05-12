using backend.Data.DataDB;
using backend.Data.Entities;
using backend.Domain.DTOs;
using backend.Domain.Enum;
using backend.Domain.OutPutDTOs;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using NetTopologySuite.Geometries;


namespace backend.Infraestructure.API_Services
{
    public class UserService : IUserService
    {
        private readonly AppDbContext _context;
        private readonly IPasswordHasher<User> _passwordHasher;

        public UserService(AppDbContext context, IPasswordHasher<User> passwordHasher)
        {
            _context = context;
            _passwordHasher = passwordHasher;
        }

        private static UserOutPutDTO ToOutputDTO(User user) => new()
        {
            Id = user.Id,
            FullName = $"{user.FirstName} {user.LastName}",
            Email = user.Email,
            PhoneNumber = user.PhoneNumber,
            UserRole = user.UserRole.ToString(),
        };

        public async Task<User> CreateAsync(UserDTO dto)
        {
            var existingUser = await _context.Users.FirstOrDefaultAsync(u => u.Email == dto.Email);
            if (existingUser != null)
                throw new InvalidOperationException("El correo ya está registrado.");

            var user = new User
            {
                FirstName = dto.FirstName,
                LastName = dto.LastName,
                Email = dto.Email,
                PhoneNumber = dto.PhoneNumber,
                UserRole = dto.UserRole,
                IsActive = true,
                CreationDate = DateTime.UtcNow,
                LastUpdate = DateTime.UtcNow
            };
            user.PasswordHash = _passwordHasher.HashPassword(user, dto.Password);

            _context.Users.Add(user);

            if (dto.UserRole == UserRole.Client)
            {
                var client = new Client
                {
                    User = user,
                    IsActive = true,
                    CreationDate = DateTime.UtcNow,
                    LastUpdate = DateTime.UtcNow
                };
                _context.Clients.Add(client);
            }
            else if (dto.UserRole == UserRole.Provider)
            {
                var provider = new Provider
                {
                    User = user,
                    Status = ProviderStatus.Registered,
                    IsActive = true,
                    CreationDate = DateTime.UtcNow,
                    LastUpdate = DateTime.UtcNow
                };
                _context.Providers.Add(provider);
            }

            await _context.SaveChangesAsync();
            return user;
        }

        public async Task<User> CreateProviderAsync(RegisterProviderDTO dto)
        {
            if (await _context.Users.AnyAsync(u => u.Email == dto.Email))
                throw new InvalidOperationException("El correo ya está registrado.");

            if (await _context.Providers.AnyAsync(p => p.Curp == dto.Curp && !p.IsDeleted))
                throw new InvalidOperationException("El CURP ya está registrado.");

            if (await _context.Providers.AnyAsync(p => p.Rfc == dto.Rfc && !p.IsDeleted))
                throw new InvalidOperationException("El RFC ya está registrado.");

            if (!await _context.Categories.AnyAsync(c => c.Id == dto.CategoryId && !c.IsDeleted))
                throw new InvalidOperationException("La categoría especificada no existe.");

            var validServiceCount = await _context.ServiceItems
                .CountAsync(s => dto.ServiceIds.Contains(s.Id)
                              && s.CategoryId == dto.CategoryId
                              && !s.IsDeleted);

            if (validServiceCount != dto.ServiceIds.Count)
                throw new InvalidOperationException(
                    "Uno o más servicios no pertenecen a la categoría seleccionada o no existen.");

            var user = new User
            {
                FirstName    = dto.FirstName,
                LastName     = dto.LastName,
                Email        = dto.Email,
                PhoneNumber  = dto.PhoneNumber,
                UserRole     = UserRole.Provider,
                IsActive     = true,
                CreationDate = DateTime.UtcNow,
                LastUpdate   = DateTime.UtcNow
            };
            user.PasswordHash = _passwordHasher.HashPassword(user, dto.Password);
            _context.Users.Add(user);

            var provider = new Provider
            {
                User               = user,
                Status             = ProviderStatus.Registered,
                Curp               = dto.Curp,
                Rfc                = dto.Rfc,
                YearsOfExperience  = dto.YearsOfExperience,
                ProfessionalLicense = dto.ProfessionalLicense,
                Description        = dto.Description,
                IsActive           = true,
                CreationDate       = DateTime.UtcNow,
                LastUpdate         = DateTime.UtcNow
            };
            _context.Providers.Add(provider);

            _context.ProviderCategories.Add(new ProviderCategory
            {
                Provider   = provider,
                CategoryId = dto.CategoryId
            });

            foreach (var serviceId in dto.ServiceIds)
            {
                _context.ProviderServiceItems.Add(new ProviderServiceItem
                {
                    Provider      = provider,
                    ServiceItemId = serviceId
                });
            }

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateException ex)
            {
                throw new InvalidOperationException(
                    "No se pudo completar el registro. Verifica que el CURP, RFC o correo no estén duplicados.",
                    ex);
            }

            return user;
        }

        public async Task<UserOutPutDTO?> GetByIdAsync(int id)
        {
            var user = await _context.Users
                .Include(u => u.Provider)
                .FirstOrDefaultAsync(u => u.Id == id);
            if (user == null) return null;

            return ToOutputDTO(user);
        }

        public async Task<List<UserOutPutDTO>> GetAllAsync()
        {
            var users = await _context.Users
                .Include(u => u.Provider)
                .ToListAsync();

            return users.Select(ToOutputDTO).ToList();
        }

        public async Task<UserOutPutDTO?> UpdateAsync(int id, UserDTO dto)
        {
            var user = await _context.Users
                .Include(u => u.Provider)
                .FirstOrDefaultAsync(u => u.Id == id);
            if (user == null) return null;

            user.FirstName = dto.FirstName;
            user.LastName = dto.LastName;
            user.Email = dto.Email;
            user.PasswordHash = _passwordHasher.HashPassword(user, dto.Password);
            user.PhoneNumber = dto.PhoneNumber;
            user.LastUpdate = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return ToOutputDTO(user);
        }

        public async Task<bool> UpdateLocationAsync(int id, UpdateLocationDTO dto, CancellationToken ct)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == id, ct);
            if (user == null) return false;

            user.LastLat = dto.Lat;
            user.LastLng = dto.Lng;
            user.Location = new Point((double)dto.Lng, (double)dto.Lat) { SRID = 4326 };
            user.LocationUpdatedAt = DateTime.UtcNow;
            user.LastUpdate = DateTime.UtcNow;

            await _context.SaveChangesAsync(ct);
            return true;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null) return false;

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();
            return true;
        }

    }
}
