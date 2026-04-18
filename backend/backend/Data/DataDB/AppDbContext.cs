using backend.Data.Entities;
using Microsoft.EntityFrameworkCore;

namespace backend.Data.DataDB
{
    public class AppDbContext : DbContext
    {

        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User>             Users              => Set<User>();
        public DbSet<Client>           Clients            => Set<Client>();
        public DbSet<Provider>         Providers          => Set<Provider>();
        public DbSet<RevokedToken>     RevokedTokens      => Set<RevokedToken>();
        public DbSet<Document>         Documents          => Set<Document>();
        public DbSet<Category>         Categories         => Set<Category>();
        public DbSet<ServiceItem>      ServiceItems       => Set<ServiceItem>();
        public DbSet<ProviderCategory> ProviderCategories => Set<ProviderCategory>();
        public DbSet<ServiceRequest>   ServiceRequests    => Set<ServiceRequest>();
        public DbSet<Cotizacion>       Cotizaciones       => Set<Cotizacion>();
        public DbSet<Question>         Questions          => Set<Question>();
        public DbSet<QuestionOption>   QuestionOptions    => Set<QuestionOption>();
        public DbSet<ChatRoom>         ChatRooms          => Set<ChatRoom>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // User
            modelBuilder.Entity<User>(e =>
            {
                e.HasKey(u => u.Id);
                e.HasIndex(u => u.Email).IsUnique();
                e.Property(u => u.Email).IsRequired().HasMaxLength(256);
                e.Property(u => u.FirstName).IsRequired().HasMaxLength(100);
                e.Property(u => u.LastName).IsRequired().HasMaxLength(100);
                e.Property(u => u.PasswordHash).IsRequired();

                e.Property(u => u.LastLat).HasColumnType("decimal(9,6)");
                e.Property(u => u.LastLng).HasColumnType("decimal(9,6)");
                e.Property(u => u.Location).HasColumnType("geography (Point, 4326)");
                e.HasIndex(u => u.Location).HasMethod("GIST");
            });

            modelBuilder.Entity<Client>(e =>
            {
                e.HasKey(c => c.Id);
                e.HasOne(c => c.User)
                 .WithOne(u => u.Client)
                 .HasForeignKey<Client>(c => c.UserId)
                 .OnDelete(DeleteBehavior.Cascade);
            });

            modelBuilder.Entity<Provider>(e =>
            {
                e.HasKey(p => p.Id);
                e.HasOne(p => p.User)
                 .WithOne(u => u.Provider)
                 .HasForeignKey<Provider>(p => p.UserId)
                 .OnDelete(DeleteBehavior.Cascade);
            });

            modelBuilder.Entity<RevokedToken>(e =>
            {
                e.HasKey(rt => rt.Id);
                e.Property(rt => rt.Jti).IsRequired().HasMaxLength(64);
                e.HasIndex(rt => rt.Jti).IsUnique();
            });

            modelBuilder.Entity<Document>(e =>
            {
                e.HasKey(d => d.Id);
                e.Property(d => d.FileUrl).IsRequired().HasMaxLength(500);
                e.Property(d => d.OriginalFileName).IsRequired().HasMaxLength(255);
                e.Property(d => d.ContentType).IsRequired().HasMaxLength(100);

                e.HasOne(d => d.Provider)
                 .WithMany()
                 .HasForeignKey(d => d.ProviderId)
                 .OnDelete(DeleteBehavior.Cascade);

                e.HasIndex(d => new { d.ProviderId, d.DocumentType })
                 .IsUnique()
                 .HasFilter("\"IsDeleted\" = false");
            });

            // ProviderCategory (join table, composite PK)
            modelBuilder.Entity<ProviderCategory>(e =>
            {
                e.HasKey(pc => new { pc.ProviderId, pc.CategoryId });
                e.HasOne(pc => pc.Provider)
                 .WithMany(p => p.Categories)
                 .HasForeignKey(pc => pc.ProviderId)
                 .OnDelete(DeleteBehavior.Cascade);
                e.HasOne(pc => pc.Category)
                 .WithMany(c => c.Providers)
                 .HasForeignKey(pc => pc.CategoryId)
                 .OnDelete(DeleteBehavior.Cascade);
            });

            // ServiceItem → Category
            modelBuilder.Entity<ServiceItem>(e =>
            {
                e.HasKey(s => s.Id);
                e.Property(s => s.Name).IsRequired().HasMaxLength(150);
                e.HasOne(s => s.Category)
                 .WithMany(c => c.Services)
                 .HasForeignKey(s => s.CategoryId)
                 .OnDelete(DeleteBehavior.Restrict);
            });

            // ServiceRequest
            modelBuilder.Entity<ServiceRequest>(e =>
            {
                e.HasKey(sr => sr.Id);
                e.HasOne(sr => sr.ServiceItem)
                 .WithMany(s => s.Requests)
                 .HasForeignKey(sr => sr.ServiceItemId)
                 .OnDelete(DeleteBehavior.Cascade);
                e.HasOne(sr => sr.Client)
                 .WithMany()
                 .HasForeignKey(sr => sr.ClientId)
                 .OnDelete(DeleteBehavior.Cascade);
                e.HasOne(sr => sr.TargetProvider)
                 .WithMany()
                 .HasForeignKey(sr => sr.TargetProviderId)
                 .OnDelete(DeleteBehavior.SetNull);

                e.Property(sr => sr.Lat).HasColumnType("decimal(9,6)");
                e.Property(sr => sr.Lng).HasColumnType("decimal(9,6)");
                e.Property(sr => sr.Location).HasColumnType("geography (Point, 4326)");
                e.HasIndex(sr => sr.Location).HasMethod("GIST");

                e.HasIndex(sr => sr.CreationDate);
                e.HasIndex(sr => new { sr.Status, sr.Type, sr.TargetProviderId });
            });

            // Cotizacion
            modelBuilder.Entity<Cotizacion>(e =>
            {
                e.HasKey(c => c.Id);
                e.HasOne(c => c.ServiceRequest)
                 .WithMany(sr => sr.Cotizaciones)
                 .HasForeignKey(c => c.ServiceRequestId)
                 .OnDelete(DeleteBehavior.Cascade);
                e.HasOne(c => c.Provider)
                 .WithMany(p => p.Cotizaciones)
                 .HasForeignKey(c => c.ProviderId)
                 .OnDelete(DeleteBehavior.Restrict);

                e.Property(c => c.Amount).HasColumnType("decimal(18,2)");
                e.Property(c => c.Currency).HasMaxLength(3);

                // One cotizacion per provider per request (ignoring soft-deleted)
                e.HasIndex(c => new { c.ServiceRequestId, c.ProviderId })
                 .IsUnique()
                 .HasFilter("\"IsDeleted\" = false");

                e.HasIndex(c => new { c.ProviderId, c.Status, c.CreationDate });
            });

            // ChatRoom → ServiceRequest + Provider
            modelBuilder.Entity<ChatRoom>(e =>
            {
                e.HasKey(cr => cr.Id);
                e.HasOne(cr => cr.ServiceRequest)
                 .WithMany(sr => sr.ChatRooms)
                 .HasForeignKey(cr => cr.ServiceRequestId)
                 .OnDelete(DeleteBehavior.Cascade);
                e.HasOne(cr => cr.Provider)
                 .WithMany()
                 .HasForeignKey(cr => cr.ProviderId)
                 .OnDelete(DeleteBehavior.Restrict);
                e.HasIndex(cr => new { cr.ServiceRequestId, cr.ProviderId })
                 .IsUnique();
            });

            // Question → Category
            modelBuilder.Entity<Question>(e =>
            {
                e.HasKey(q => q.Id);
                e.Property(q => q.Text).IsRequired().HasMaxLength(500);
                e.HasOne(q => q.Category)
                 .WithMany(c => c.Questions)
                 .HasForeignKey(q => q.CategoryId)
                 .OnDelete(DeleteBehavior.Restrict);
                e.HasIndex(q => new { q.CategoryId, q.Order });
            });

            // QuestionOption → Question
            modelBuilder.Entity<QuestionOption>(e =>
            {
                e.HasKey(o => o.Id);
                e.Property(o => o.Text).IsRequired().HasMaxLength(200);
                e.HasOne(o => o.Question)
                 .WithMany(q => q.Options)
                 .HasForeignKey(o => o.QuestionId)
                 .OnDelete(DeleteBehavior.Cascade);
                e.HasIndex(o => new { o.QuestionId, o.Order });
            });
        }
    }
}
