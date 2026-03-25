namespace backend.Domain.OutPutDTOs
{
    public class ClientOutPutDTO
    {

        public int Id { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string UserRole { get; set; } = string.Empty;
        public string Token { get; set; } = string.Empty;
    }
}
