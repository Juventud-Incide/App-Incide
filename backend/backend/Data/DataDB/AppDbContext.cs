using backend.Data.Entities;
using Microsoft.EntityFrameworkCore;

namespace backend.Data.DataDB
{
    public class AppDbContext : DbContext
    {

        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Client> Clients => Set<Client>();
    }
}
