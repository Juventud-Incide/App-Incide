using backend.Infraestructure.API_Services_Interfaces;

namespace backend.Infraestructure.API_Services
{
    public class LocalFileStorageService : IFileStorageService
    {
        private readonly string _webRoot;

        public LocalFileStorageService(IWebHostEnvironment env)
        {
            _webRoot = string.IsNullOrWhiteSpace(env.WebRootPath)
                ? Path.Combine(env.ContentRootPath, "wwwroot")
                : env.WebRootPath;

            if (!Directory.Exists(_webRoot))
                Directory.CreateDirectory(_webRoot);
        }

        public async Task<string> SaveAsync(IFormFile file, string subPath, CancellationToken ct)
        {
            var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
            var fileName = $"{Guid.NewGuid():N}{extension}";

            var normalizedSubPath = subPath.Replace('\\', '/').Trim('/');
            var fullDir = Path.Combine(_webRoot, normalizedSubPath.Replace('/', Path.DirectorySeparatorChar));
            Directory.CreateDirectory(fullDir);

            var fullPath = Path.Combine(fullDir, fileName);
            await using var fs = File.Create(fullPath);
            await file.CopyToAsync(fs, ct);

            return $"{normalizedSubPath}/{fileName}";
        }

        public Task DeleteAsync(string relativePath, CancellationToken ct)
        {
            if (string.IsNullOrWhiteSpace(relativePath))
                return Task.CompletedTask;

            var normalized = relativePath.Replace('\\', '/').Trim('/');
            var fullPath = Path.Combine(_webRoot, normalized.Replace('/', Path.DirectorySeparatorChar));

            if (File.Exists(fullPath))
                File.Delete(fullPath);

            return Task.CompletedTask;
        }
    }
}
