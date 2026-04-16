using backend.Data.Entities;
using Microsoft.EntityFrameworkCore;

namespace backend.Data.DataDB
{
    public class AppDbContext : DbContext
    {

        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users => Set<User>();
        public DbSet<Client> Clients => Set<Client>();
        public DbSet<Provider> Providers => Set<Provider>();
        public DbSet<RevokedToken> RevokedTokens => Set<RevokedToken>();
        public DbSet<Document> Documents => Set<Document>();

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
        }
    }
}
