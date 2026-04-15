using backend.Data.Entities;
using backend.Domain.Enum;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

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

            var provider = new Provider
            {
                UserId       = providerUser.Id,
                Status       = ProviderStatus.Affiliated,
                IsActive     = true,
                CreationDate = now,
                LastUpdate   = now
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
            var requests = new List<ServiceRequest>();

            // 5 solicitudes de "Reparación de tuberías" → debe ser el más popular
            for (int i = 0; i < 5; i++)
                requests.Add(new ServiceRequest { ServiceItemId = svcTuberias.Id,  ClientId = client.Id, IsActive = true, CreationDate = now.AddDays(-i),    LastUpdate = now });

            // 3 solicitudes de "Instalación eléctrica"
            for (int i = 0; i < 3; i++)
                requests.Add(new ServiceRequest { ServiceItemId = svcElectrica.Id, ClientId = client.Id, IsActive = true, CreationDate = now.AddDays(-i - 1), LastUpdate = now });

            // 1 solicitud de "Limpieza de hogar"
            requests.Add(new ServiceRequest { ServiceItemId = svcLimpieza.Id, ClientId = client.Id, IsActive = true, CreationDate = now, LastUpdate = now });

            context.ServiceRequests.AddRange(requests);
            await context.SaveChangesAsync();
        }
    }
}
