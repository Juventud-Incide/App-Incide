using backend.Data.Entities;
using backend.Domain.Enum;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using NetTopologySuite.Geometries;

namespace backend.Data.DataDB
{
    public static class DataSeeder
    {
        public static async Task SeedAsync(IServiceProvider services)
        {
            using var scope = services.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            var hasher  = scope.ServiceProvider.GetRequiredService<IPasswordHasher<User>>();

            // Evitar re-seed si ya hay datos
        if (await context.Users.AnyAsync()) return;

            // ── Usuarios ──────────────────────────────────────────────────────────
            var now = DateTime.UtcNow;

            var adminUser = new User
            {
                FirstName       = "Admin",
                LastName        = "INCIDE",
                Email           = "admin@incide.com",
                UserRole        = UserRole.Admin,
                IsEmailVerified = true,
                IsActive        = true,
                CreationDate    = now,
                LastUpdate      = now
            };
            adminUser.PasswordHash = hasher.HashPassword(adminUser, "Admin123!");

            var providerUser = new User
            {
                FirstName       = "Carlos",
                LastName        = "Ramírez",
                Email           = "proveedor@incide.com",
                PhoneNumber     = "5551234567",
                UserRole        = UserRole.Provider,
                IsEmailVerified = true,
                IsActive        = true,
                CreationDate    = now,
                LastUpdate      = now
            };
            providerUser.PasswordHash = hasher.HashPassword(providerUser, "Provider123!");

            var clientUser = new User
            {
                FirstName       = "Ana",
                LastName        = "López",
                Email           = "cliente@incide.com",
                PhoneNumber     = "5559876543",
                UserRole        = UserRole.Client,
                IsEmailVerified = true,
                IsActive        = true,
                CreationDate    = now,
                LastUpdate      = now
            };
            clientUser.PasswordHash = hasher.HashPassword(clientUser, "Client123!");

            context.Users.AddRange(adminUser, providerUser, clientUser);
            await context.SaveChangesAsync();

            // ── Perfiles Client / Provider ────────────────────────────────────────
            var client = new Client
            {
                UserId       = clientUser.Id,
                IsActive     = true,
                CreationDate = now,
                LastUpdate   = now
            };

            // Provider location: Zócalo CDMX
            const decimal providerLat = 19.4326m;
            const decimal providerLng = -99.1332m;

            providerUser.LastLat          = providerLat;
            providerUser.LastLng          = providerLng;
            providerUser.Location         = new Point((double)providerLng, (double)providerLat) { SRID = 4326 };
            providerUser.LocationUpdatedAt = now;

            var provider = new Provider
            {
                UserId              = providerUser.Id,
                Status              = ProviderStatus.Affiliated,
                Available           = true,
                AvailableUpdatedAt  = now,
                IsActive            = true,
                CreationDate        = now,
                LastUpdate          = now
            };

            context.Clients.Add(client);
            context.Providers.Add(provider);
            await context.SaveChangesAsync();

            // ── Categorías ────────────────────────────────────────────────────────
            var catPlomeria     = new Category { Name = "Plomería",      Icon = "plomeria",     IsActive = true, CreationDate = now, LastUpdate = now };
            var catElectricidad = new Category { Name = "Electricidad",  Icon = "electricidad", IsActive = true, CreationDate = now, LastUpdate = now };
            var catCarpinteria  = new Category { Name = "Carpintería",   Icon = "carpinteria",  IsActive = true, CreationDate = now, LastUpdate = now };
            var catLimpieza     = new Category { Name = "Limpieza",      Icon = "limpieza",     IsActive = true, CreationDate = now, LastUpdate = now };

            context.Categories.AddRange(catPlomeria, catElectricidad, catCarpinteria, catLimpieza);
            await context.SaveChangesAsync();

            // ── Servicios ─────────────────────────────────────────────────────────
            var svcTuberias    = new ServiceItem { Name = "Reparación de tuberías",   Description = "Reparación y mantenimiento de tuberías.",     Icon = "tuberia",    CategoryId = catPlomeria.Id,     IsActive = true, CreationDate = now, LastUpdate = now };
            var svcLlaves      = new ServiceItem { Name = "Instalación de llaves",    Description = "Instalación y cambio de llaves y regaderas.",  Icon = "llave",      CategoryId = catPlomeria.Id,     IsActive = true, CreationDate = now, LastUpdate = now };
            var svcElectrica   = new ServiceItem { Name = "Instalación eléctrica",    Description = "Instalación de contactos, apagadores y más.",  Icon = "electrica",  CategoryId = catElectricidad.Id, IsActive = true, CreationDate = now, LastUpdate = now };
            var svcApagadores  = new ServiceItem { Name = "Reparación de apagadores", Description = "Reparación de apagadores e interruptores.",    Icon = "apagador",   CategoryId = catElectricidad.Id, IsActive = true, CreationDate = now, LastUpdate = now };
            var svcMuebles     = new ServiceItem { Name = "Instalación de muebles",   Description = "Armado e instalación de muebles a domicilio.", Icon = "mueble",     CategoryId = catCarpinteria.Id,  IsActive = true, CreationDate = now, LastUpdate = now };
            var svcLimpieza    = new ServiceItem { Name = "Limpieza de hogar",         Description = "Servicio de limpieza profunda del hogar.",     Icon = "limpieza",   CategoryId = catLimpieza.Id,     IsActive = true, CreationDate = now, LastUpdate = now };

            context.ServiceItems.AddRange(svcTuberias, svcLlaves, svcElectrica, svcApagadores, svcMuebles, svcLimpieza);
            await context.SaveChangesAsync();

            // ── Proveedor ↔ Categorías ────────────────────────────────────────────
            context.ProviderCategories.AddRange(
                new ProviderCategory { ProviderId = provider.Id, CategoryId = catPlomeria.Id },
                new ProviderCategory { ProviderId = provider.Id, CategoryId = catElectricidad.Id }
            );
            await context.SaveChangesAsync();

            // ── Solicitudes (para poblar /populares) ──────────────────────────────
            // Coordinates near provider (Zócalo CDMX area) so they appear on the map
            Point DefaultLocation(decimal lat, decimal lng) =>
                new Point((double)lng, (double)lat) { SRID = 4326 };

            var requests = new List<ServiceRequest>();

            // 5 solicitudes de "Reparación de tuberías" → más popular
            // Status = Completed: solo sirven para contar popularidad, no deben aparecer en el mapa
            for (int i = 0; i < 5; i++)
                requests.Add(new ServiceRequest
                {
                    ServiceItemId = svcTuberias.Id, ClientId = client.Id,
                    Lat = 19.4310m + i * 0.001m, Lng = -99.1340m + i * 0.001m,
                    Location = DefaultLocation(19.4310m + i * 0.001m, -99.1340m + i * 0.001m),
                    Type = CotizacionType.Public, Status = CotizacionRequestStatus.Completed,
                    IsActive = true, CreationDate = now.AddDays(-i), LastUpdate = now
                });

            // 3 solicitudes de "Instalación eléctrica"
            for (int i = 0; i < 3; i++)
                requests.Add(new ServiceRequest
                {
                    ServiceItemId = svcElectrica.Id, ClientId = client.Id,
                    Lat = 19.4350m + i * 0.001m, Lng = -99.1300m + i * 0.001m,
                    Location = DefaultLocation(19.4350m + i * 0.001m, -99.1300m + i * 0.001m),
                    Type = CotizacionType.Public, Status = CotizacionRequestStatus.Completed,
                    IsActive = true, CreationDate = now.AddDays(-i - 1), LastUpdate = now
                });

            // 1 solicitud de "Limpieza de hogar"
            requests.Add(new ServiceRequest
            {
                ServiceItemId = svcLimpieza.Id, ClientId = client.Id,
                Lat = 19.4290m, Lng = -99.1360m,
                Location = DefaultLocation(19.4290m, -99.1360m),
                Type = CotizacionType.Public, Status = CotizacionRequestStatus.Completed,
                IsActive = true, CreationDate = now, LastUpdate = now
            });

            context.ServiceRequests.AddRange(requests);
            await context.SaveChangesAsync();

            // ── Solicitudes para pruebas del módulo cotizaciones ──────────────────

            // Solicitud pública a 500m del proveedor (debe aparecer en el mapa)
            var publicRequest = new ServiceRequest
            {
                ServiceItemId   = svcTuberias.Id,
                ClientId        = client.Id,
                Description     = "Se necesita reparar una tubería rota en la cocina.",
                EstimatedBudget = 800m,
                Lat             = 19.4370m,
                Lng             = -99.1350m,
                Location        = DefaultLocation(19.4370m, -99.1350m),
                Type            = CotizacionType.Public,
                Status          = CotizacionRequestStatus.Active,
                IsActive        = true,
                CreationDate    = now,
                LastUpdate      = now
            };

            // Solicitud especial dirigida al proveedor seed
            var targetedRequest = new ServiceRequest
            {
                ServiceItemId    = svcElectrica.Id,
                ClientId         = client.Id,
                Description      = "Instalación de 4 contactos en sala y comedor.",
                EstimatedBudget  = 1500m,
                PreferredDate    = now.AddDays(3),
                Lat              = 19.4300m,
                Lng              = -99.1310m,
                Location         = DefaultLocation(19.4300m, -99.1310m),
                Type             = CotizacionType.Targeted,
                Status           = CotizacionRequestStatus.Active,
                IsActive         = true,
                CreationDate     = now,
                LastUpdate       = now
            };

            context.ServiceRequests.AddRange(publicRequest, targetedRequest);
            await context.SaveChangesAsync();

            // Asignar TargetProviderId ahora que tenemos provider.Id
            targetedRequest.TargetProviderId = provider.Id;
            await context.SaveChangesAsync();

            // Cotizacion enviada sobre la solicitud pública (para probar accept/reject)
            var seedCotizacion = new Cotizacion
            {
                ServiceRequestId = publicRequest.Id,
                ProviderId       = provider.Id,
                Amount           = 950m,
                Currency         = "MXN",
                Description      = "Incluye mano de obra y materiales básicos.",
                EstimatedHours   = 3,
                ProposedDate     = now.AddDays(2),
                Status           = CotizacionStatus.Submitted,
                IsActive         = true,
                CreationDate     = now,
                LastUpdate       = now
            };

            context.Cotizaciones.Add(seedCotizacion);
            await context.SaveChangesAsync();
        }
    }
}
