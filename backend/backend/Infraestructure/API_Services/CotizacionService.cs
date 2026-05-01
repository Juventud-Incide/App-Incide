using backend.Data.DataDB;
using backend.Data.Entities;
using backend.Domain.DTOs.Cotizacion;
using backend.Domain.Enum;
using backend.Domain.OutPutDTOs.Cotizacion;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.EntityFrameworkCore;
using NetTopologySuite.Geometries;

namespace backend.Infraestructure.API_Services
{
    public class CotizacionService : ICotizacionService
    {
        private readonly AppDbContext          _context;
        private readonly INotificationService  _notifications;

        public CotizacionService(AppDbContext context, INotificationService notifications)
        {
            _context       = context;
            _notifications = notifications;
        }

        // ── Mappers ──────────────────────────────────────────────────────────

        private static CotizacionOutputDTO ToCotizacionDTO(Cotizacion c) => new()
        {
            Id               = c.Id,
            ServiceRequestId = c.ServiceRequestId,
            ProviderId       = c.ProviderId,
            ProviderName     = $"{c.Provider.User.FirstName} {c.Provider.User.LastName}",
            Amount           = c.Amount,
            Currency         = c.Currency,
            Description      = c.Description,
            EstimatedHours   = c.EstimatedHours,
            ProposedDate     = c.ProposedDate,
            Status           = c.Status.ToString(),
            AcceptedAt       = c.AcceptedAt,
            RejectedAt       = c.RejectedAt,
            RejectReason     = c.RejectReason,
            CreationDate     = c.CreationDate
        };

        private static ServiceRequestOutputDTO ToRequestDTO(ServiceRequest sr) => new()
        {
            Id              = sr.Id,
            ServiceItemId   = sr.ServiceItemId,
            ServiceItemName = sr.ServiceItem.Name,
            CategoryName    = sr.ServiceItem.Category.Name,
            ClientId        = sr.ClientId,
            ClientName      = $"{sr.Client.User.FirstName} {sr.Client.User.LastName}",
            Description     = sr.Description,
            EstimatedBudget = sr.EstimatedBudget,
            PreferredDate   = sr.PreferredDate,
            Lat             = sr.Lat,
            Lng             = sr.Lng,
            Type            = sr.Type.ToString(),
            TargetProviderId = sr.TargetProviderId,
            Status          = sr.Status.ToString(),
            CreationDate    = sr.CreationDate,
            Cotizaciones    = sr.Cotizaciones
                               .Where(c => !c.IsDeleted)
                               .Select(ToCotizacionDTO)
                               .ToList()
        };

        // ── Client ───────────────────────────────────────────────────────────

        public async Task<ServiceRequestOutputDTO> CreateServiceRequestAsync(
            int userId, CreateServiceRequestDTO dto, CancellationToken ct)
        {
            var client = await _context.Clients
                .FirstOrDefaultAsync(c => c.UserId == userId, ct)
                ?? throw new InvalidOperationException("No client profile found for this user.");

            var serviceItem = await _context.ServiceItems
                .Include(s => s.Category)
                .FirstOrDefaultAsync(s => s.Id == dto.ServiceItemId && !s.IsDeleted, ct)
                ?? throw new InvalidOperationException($"Service item {dto.ServiceItemId} not found.");

            if (dto.Type == CotizacionType.Targeted)
            {
                if (dto.TargetProviderId == null)
                    throw new InvalidOperationException("TargetProviderId is required when Type is Targeted.");

                var providerExists = await _context.Providers
                    .AnyAsync(p => p.Id == dto.TargetProviderId && p.Status == ProviderStatus.Affiliated && !p.IsDeleted, ct);

                if (!providerExists)
                    throw new InvalidOperationException("Target provider not found or not affiliated.");
            }

            var request = new ServiceRequest
            {
                ServiceItemId    = dto.ServiceItemId,
                ClientId         = client.Id,
                Description      = dto.Description,
                EstimatedBudget  = dto.EstimatedBudget,
                PreferredDate    = dto.PreferredDate,
                Lat              = dto.Lat,
                Lng              = dto.Lng,
                Location         = new Point((double)dto.Lng, (double)dto.Lat) { SRID = 4326 },
                Type             = dto.Type,
                TargetProviderId = dto.Type == CotizacionType.Targeted ? dto.TargetProviderId : null,
                Status           = CotizacionRequestStatus.Active,
                IsActive         = true,
                CreationDate     = DateTime.UtcNow,
                LastUpdate       = DateTime.UtcNow
            };

            _context.ServiceRequests.Add(request);
            await _context.SaveChangesAsync(ct);

            request.ServiceItem = serviceItem;
            request.Client      = await _context.Clients
                .Include(c => c.User)
                .FirstAsync(c => c.Id == client.Id, ct);

            return ToRequestDTO(request);
        }

        public async Task<List<ServiceRequestOutputDTO>> GetMyRequestsAsync(int userId, CotizacionRequestStatus? status, CancellationToken ct)
        {
            var client = await _context.Clients
                .FirstOrDefaultAsync(c => c.UserId == userId, ct)
                ?? throw new InvalidOperationException("No client profile found for this user.");

            return await _context.ServiceRequests
                .Include(sr => sr.ServiceItem).ThenInclude(s => s.Category)
                .Include(sr => sr.Client).ThenInclude(c => c.User)
                .Include(sr => sr.Cotizaciones).ThenInclude(c => c.Provider).ThenInclude(p => p.User)
                .Where(sr => sr.ClientId == client.Id && !sr.IsDeleted
                          && (status == null || sr.Status == status))
                .OrderByDescending(sr => sr.CreationDate)
                .Select(sr => ToRequestDTO(sr))
                .ToListAsync(ct);
        }

        public async Task<ServiceRequestOutputDTO?> GetRequestByIdAsync(int requestId, int userId, CancellationToken ct)
        {
            var client = await _context.Clients
                .FirstOrDefaultAsync(c => c.UserId == userId, ct);

            var provider = client == null
                ? await _context.Providers.FirstOrDefaultAsync(p => p.UserId == userId, ct)
                : null;

            var query = _context.ServiceRequests
                .Include(sr => sr.ServiceItem).ThenInclude(s => s.Category)
                .Include(sr => sr.Client).ThenInclude(c => c.User)
                .Include(sr => sr.Cotizaciones).ThenInclude(c => c.Provider).ThenInclude(p => p.User)
                .Where(sr => sr.Id == requestId && !sr.IsDeleted);

            // Client can only see their own; provider can see public or targeted to them
            if (client != null)
                query = query.Where(sr => sr.ClientId == client.Id);
            else if (provider != null)
                query = query.Where(sr =>
                    sr.Type == CotizacionType.Public ||
                    (sr.Type == CotizacionType.Targeted && sr.TargetProviderId == provider.Id));

            var request = await query.FirstOrDefaultAsync(ct);
            return request == null ? null : ToRequestDTO(request);
        }

        public async Task<CotizacionOutputDTO> AcceptCotizacionAsync(int cotizacionId, int userId, CancellationToken ct)
        {
            var client = await _context.Clients
                .FirstOrDefaultAsync(c => c.UserId == userId, ct)
                ?? throw new InvalidOperationException("No client profile found for this user.");

            var cotizacion = await _context.Cotizaciones
                .Include(c => c.Provider).ThenInclude(p => p.User)
                .Include(c => c.ServiceRequest)
                .FirstOrDefaultAsync(c => c.Id == cotizacionId && !c.IsDeleted, ct)
                ?? throw new InvalidOperationException("Cotizacion not found.");

            if (cotizacion.ServiceRequest.ClientId != client.Id)
                throw new InvalidOperationException("You are not the owner of this service request.");

            if (cotizacion.ServiceRequest.Status != CotizacionRequestStatus.Active)
                throw new InvalidOperationException("This service request is no longer active.");

            if (cotizacion.Status != CotizacionStatus.Submitted)
                throw new InvalidOperationException("Only submitted cotizaciones can be accepted.");

            // Accept this cotizacion
            cotizacion.Status     = CotizacionStatus.Accepted;
            cotizacion.AcceptedAt = DateTime.UtcNow;
            cotizacion.LastUpdate = DateTime.UtcNow;

            // Reject all other submitted cotizaciones for the same request
            var others = await _context.Cotizaciones
                .Where(c => c.ServiceRequestId == cotizacion.ServiceRequestId
                         && c.Id != cotizacionId
                         && c.Status == CotizacionStatus.Submitted
                         && !c.IsDeleted)
                .ToListAsync(ct);

            foreach (var other in others)
            {
                other.Status     = CotizacionStatus.Rejected;
                other.RejectedAt = DateTime.UtcNow;
                other.LastUpdate = DateTime.UtcNow;
            }

            // Mark request as assigned
            cotizacion.ServiceRequest.Status     = CotizacionRequestStatus.Assigned;
            cotizacion.ServiceRequest.LastUpdate = DateTime.UtcNow;

            await _context.SaveChangesAsync(ct);
            return ToCotizacionDTO(cotizacion);
        }

        public async Task<CotizacionOutputDTO> RejectCotizacionAsync(
            int cotizacionId, int userId, RejectCotizacionDTO dto, CancellationToken ct)
        {
            var client = await _context.Clients
                .FirstOrDefaultAsync(c => c.UserId == userId, ct)
                ?? throw new InvalidOperationException("No client profile found for this user.");

            var cotizacion = await _context.Cotizaciones
                .Include(c => c.Provider).ThenInclude(p => p.User)
                .Include(c => c.ServiceRequest)
                .FirstOrDefaultAsync(c => c.Id == cotizacionId && !c.IsDeleted, ct)
                ?? throw new InvalidOperationException("Cotizacion not found.");

            if (cotizacion.ServiceRequest.ClientId != client.Id)
                throw new InvalidOperationException("You are not the owner of this service request.");

            if (cotizacion.Status != CotizacionStatus.Submitted)
                throw new InvalidOperationException("Only submitted cotizaciones can be rejected.");

            cotizacion.Status       = CotizacionStatus.Rejected;
            cotizacion.RejectedAt   = DateTime.UtcNow;
            cotizacion.RejectReason = dto.RejectReason;
            cotizacion.LastUpdate   = DateTime.UtcNow;

            await _context.SaveChangesAsync(ct);
            return ToCotizacionDTO(cotizacion);
        }

        // ── Provider ─────────────────────────────────────────────────────────

        public async Task<List<ServiceRequestMapOutputDTO>> GetMapAsync(
            int userId, CotizacionesMapQueryDTO query, CancellationToken ct)
        {
            var provider = await _context.Providers
                .FirstOrDefaultAsync(p => p.UserId == userId && !p.IsDeleted, ct)
                ?? throw new InvalidOperationException("No provider profile found for this user.");

            if (provider.Status != ProviderStatus.Affiliated)
                throw new InvalidOperationException("Only affiliated providers can access the map.");

            if (!provider.Available)
                throw new InvalidOperationException("You must be available to access the cotizaciones map.");

            var origin         = new Point((double)query.Lng, (double)query.Lat) { SRID = 4326 };
            var maxDistMeters  = query.MaxDistanceKm * 1000;

            var requests = await _context.ServiceRequests
                .Include(sr => sr.ServiceItem).ThenInclude(s => s.Category)
                .Where(sr =>
                    !sr.IsDeleted &&
                    sr.Status == CotizacionRequestStatus.Active &&
                    (sr.Type == CotizacionType.Public ||
                     (sr.Type == CotizacionType.Targeted && sr.TargetProviderId == provider.Id)) &&
                    sr.Location.Distance(origin) <= maxDistMeters &&
                    (query.CategoryId == null || sr.ServiceItem.CategoryId == query.CategoryId))
                .OrderBy(sr => sr.Location.Distance(origin))
                .Take(100)
                .ToListAsync(ct);

            return requests.Select(sr => new ServiceRequestMapOutputDTO
            {
                Id              = sr.Id,
                ServiceItemId   = sr.ServiceItemId,
                ServiceItemName = sr.ServiceItem.Name,
                CategoryName    = sr.ServiceItem.Category.Name,
                Description     = sr.Description,
                EstimatedBudget = sr.EstimatedBudget,
                PreferredDate   = sr.PreferredDate,
                Lat             = sr.Lat,
                Lng             = sr.Lng,
                DistanceKm      = (decimal)(sr.Location.Distance(origin) / 1000.0),
                Type            = sr.Type.ToString(),
                CreationDate    = sr.CreationDate
            }).ToList();
        }

        public async Task<CotizacionOutputDTO> SubmitCotizacionAsync(
            int requestId, int userId, SubmitCotizacionDTO dto, CancellationToken ct)
        {
            var provider = await _context.Providers
                .Include(p => p.User)
                .FirstOrDefaultAsync(p => p.UserId == userId && !p.IsDeleted, ct)
                ?? throw new InvalidOperationException("No provider profile found for this user.");

            if (provider.Status != ProviderStatus.Affiliated)
                throw new InvalidOperationException("Only affiliated providers can submit cotizaciones.");

            var request = await _context.ServiceRequests
                .FirstOrDefaultAsync(sr => sr.Id == requestId && !sr.IsDeleted, ct)
                ?? throw new InvalidOperationException($"Service request {requestId} not found.");

            if (request.Status != CotizacionRequestStatus.Active)
                throw new InvalidOperationException("This service request is no longer active.");

            if (request.Type == CotizacionType.Targeted && request.TargetProviderId != provider.Id)
                throw new InvalidOperationException("This service request is targeted to a different provider.");

            // Upsert: update existing cotizacion or create a new one
            var existing = await _context.Cotizaciones
                .Include(c => c.Provider).ThenInclude(p => p.User)
                .FirstOrDefaultAsync(c =>
                    c.ServiceRequestId == requestId &&
                    c.ProviderId == provider.Id &&
                    !c.IsDeleted, ct);

            if (existing != null)
            {
                if (existing.Status != CotizacionStatus.Submitted)
                    throw new InvalidOperationException("Cannot update a cotizacion that is no longer submitted.");

                existing.Amount         = dto.Amount;
                existing.Currency       = dto.Currency;
                existing.Description    = dto.Description;
                existing.EstimatedHours = dto.EstimatedHours;
                existing.ProposedDate   = dto.ProposedDate;
                existing.LastUpdate     = DateTime.UtcNow;

                await _context.SaveChangesAsync(ct);
                return ToCotizacionDTO(existing);
            }

            var cotizacion = new Cotizacion
            {
                ServiceRequestId = requestId,
                ProviderId       = provider.Id,
                Amount           = dto.Amount,
                Currency         = dto.Currency,
                Description      = dto.Description,
                EstimatedHours   = dto.EstimatedHours,
                ProposedDate     = dto.ProposedDate,
                Status           = CotizacionStatus.Submitted,
                IsActive         = true,
                CreationDate     = DateTime.UtcNow,
                LastUpdate       = DateTime.UtcNow
            };

            _context.Cotizaciones.Add(cotizacion);
            await _context.SaveChangesAsync(ct);

            cotizacion.Provider = provider;
            return ToCotizacionDTO(cotizacion);
        }

        public async Task<List<CotizacionOutputDTO>> GetMyCotizacionesAsync(int userId, CancellationToken ct)
        {
            var provider = await _context.Providers
                .FirstOrDefaultAsync(p => p.UserId == userId, ct)
                ?? throw new InvalidOperationException("No provider profile found for this user.");

            return await _context.Cotizaciones
                .Include(c => c.Provider).ThenInclude(p => p.User)
                .Where(c => c.ProviderId == provider.Id && !c.IsDeleted)
                .OrderByDescending(c => c.CreationDate)
                .Select(c => ToCotizacionDTO(c))
                .ToListAsync(ct);
        }

        public async Task<bool> WithdrawCotizacionAsync(int cotizacionId, int userId, CancellationToken ct)
        {
            var provider = await _context.Providers
                .FirstOrDefaultAsync(p => p.UserId == userId, ct)
                ?? throw new InvalidOperationException("No provider profile found for this user.");

            var cotizacion = await _context.Cotizaciones
                .FirstOrDefaultAsync(c => c.Id == cotizacionId && c.ProviderId == provider.Id && !c.IsDeleted, ct);

            if (cotizacion == null) return false;

            if (cotizacion.Status != CotizacionStatus.Submitted)
                throw new InvalidOperationException("Only submitted cotizaciones can be withdrawn.");

            cotizacion.Status     = CotizacionStatus.Withdrawn;
            cotizacion.LastUpdate = DateTime.UtcNow;

            await _context.SaveChangesAsync(ct);
            return true;
        }

        public async Task<ChatRoomOutputDTO> ExpressInterestAsync(int serviceRequestId, int userId, CancellationToken ct)
        {
            var provider = await _context.Providers
                .Include(p => p.User)
                .FirstOrDefaultAsync(p => p.UserId == userId && !p.IsDeleted, ct)
                ?? throw new InvalidOperationException("No provider profile found for this user.");

            if (provider.Status != ProviderStatus.Affiliated)
                throw new InvalidOperationException("Only affiliated providers can express interest.");

            if (!provider.Available)
                throw new InvalidOperationException("Provider must be available to express interest.");

            var request = await _context.ServiceRequests
                .Include(sr => sr.Client).ThenInclude(c => c.User)
                .FirstOrDefaultAsync(sr => sr.Id == serviceRequestId && !sr.IsDeleted, ct)
                ?? throw new KeyNotFoundException($"Service request {serviceRequestId} not found.");

            if (request.Status != CotizacionRequestStatus.Active)
                throw new InvalidOperationException("Service request is no longer active.");

            if (request.Type == CotizacionType.Targeted && request.TargetProviderId != provider.Id)
                throw new InvalidOperationException("This request is directed to a different provider.");

            var existingRoom = await _context.ChatRooms
                .FirstOrDefaultAsync(cr => cr.ServiceRequestId == serviceRequestId && cr.ProviderId == provider.Id, ct);

            if (existingRoom != null)
                throw new InvalidOperationException("You already expressed interest in this request.");

            var room = new ChatRoom
            {
                ServiceRequestId = serviceRequestId,
                ProviderId       = provider.Id,
                IsActive         = true,
                CreationDate     = DateTime.UtcNow,
                LastUpdate       = DateTime.UtcNow
            };

            _context.ChatRooms.Add(room);
            await _context.SaveChangesAsync(ct);

            await _notifications.NotifyClientProviderInterestedAsync(request.Client, request, provider, ct);

            return new ChatRoomOutputDTO
            {
                Id               = room.Id,
                ServiceRequestId = room.ServiceRequestId,
                ProviderId       = room.ProviderId,
                CreationDate     = room.CreationDate
            };
        }

        public async Task CancelServiceRequestAsync(int serviceRequestId, int userId, CancellationToken ct)
        {
            var client = await _context.Clients
                .Include(c => c.User)
                .FirstOrDefaultAsync(c => c.UserId == userId, ct)
                ?? throw new InvalidOperationException("No client profile found for this user.");

            var request = await _context.ServiceRequests
                .Include(sr => sr.Cotizaciones)
                .FirstOrDefaultAsync(sr => sr.Id == serviceRequestId && sr.ClientId == client.Id && !sr.IsDeleted, ct)
                ?? throw new KeyNotFoundException($"Service request {serviceRequestId} not found.");

            if (request.Status != CotizacionRequestStatus.Active)
                throw new InvalidOperationException("Only active service requests can be cancelled.");

            var now = DateTime.UtcNow;

            foreach (var c in request.Cotizaciones.Where(c => c.Status == CotizacionStatus.Submitted && !c.IsDeleted))
            {
                c.Status     = CotizacionStatus.Withdrawn;
                c.LastUpdate = now;
            }

            request.Status     = CotizacionRequestStatus.Cancelled;
            request.IsActive   = false;
            request.LastUpdate = now;

            await _context.SaveChangesAsync(ct);

            await _notifications.NotifyClientRequestCancelledAsync(client, request, ct);
        }
    }
}
