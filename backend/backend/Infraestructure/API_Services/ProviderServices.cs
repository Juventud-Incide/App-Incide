using backend.Data.DataDB;
using backend.Data.Entities;
using backend.Domain.DTOs;
using backend.Domain.Enum;
using backend.Domain.OutPutDTOs;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Infraestructure.API_Services
{
    public class ProviderServices : IProviderServices
    {
        private readonly AppDbContext _context;

        public ProviderServices(AppDbContext context)
        {
            _context = context;
        }

        private static ProviderOutPutDTO ToOutputDTO(Provider provider) => new()
        {
            Id = provider.Id,
            FullName = $"{provider.User.FirstName} {provider.User.LastName}",
            Email = provider.User.Email,
            PhoneNumber = provider.User.PhoneNumber,
            UserRole = provider.User.UserRole.ToString(),
            Status = provider.Status.ToString(),
            InterviewDate = provider.InterviewDate,
            Token = string.Empty
        };

        public async Task<ProviderOutPutDTO?> ScheduleInterviewAsync(int id, ScheduleInterviewDTO dto)
        {
            var provider = await _context.Providers
                .Include(p => p.User)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (provider == null) return null;

            if (provider.Status != ProviderStatus.Registered)
                throw new InvalidOperationException(
                    $"No se puede agendar entrevista: el proveedor está en estado '{provider.Status}'. Solo se permite desde 'Registered'.");

            if (dto.InterviewDate <= DateTime.UtcNow)
                throw new InvalidOperationException("La fecha de la entrevista debe ser en el futuro.");

            provider.InterviewDate = dto.InterviewDate;
            provider.Status = ProviderStatus.InterviewPending;
            provider.LastUpdate = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return ToOutputDTO(provider);
        } 
    }
}
