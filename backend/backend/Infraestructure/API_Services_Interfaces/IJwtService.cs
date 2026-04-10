using backend.Data.Entities;

namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface IJwtService
    {
        string GenerateToken(User user);
    }
}
