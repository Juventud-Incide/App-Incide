namespace backend.Infraestructure.API_Services_Interfaces
{
    public interface IFileStorageService
    {
        Task<string> SaveAsync(IFormFile file, string subPath, CancellationToken ct);
        Task DeleteAsync(string relativePath, CancellationToken ct);
    }
}
