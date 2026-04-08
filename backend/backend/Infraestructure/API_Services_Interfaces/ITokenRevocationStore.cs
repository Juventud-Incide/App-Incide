namespace backend.Infraestructure.API_Services_Interfaces
{
    // Abstracción del almacén de tokens revocados (blacklist).
    // Implementación actual: EfTokenRevocationStore (SQL Server vía EF Core).
    // Para migrar a Redis en el futuro: crear RedisTokenRevocationStore que
    // implemente esta misma interfaz usando IDistributedCache o StackExchange.Redis
    // (SET key EX ttl en RevokeAsync, EXISTS key en IsRevokedAsync) y cambiar
    // únicamente el binding DI en Program.cs. No se debe modificar nada más.
    public interface ITokenRevocationStore
    {
        Task RevokeAsync(string jti, DateTime expiresAtUtc, CancellationToken ct);
        Task<bool> IsRevokedAsync(string jti, CancellationToken ct);
    }
}
