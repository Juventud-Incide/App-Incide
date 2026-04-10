namespace backend.Domain.OutPutDTOs
{
    public class AuthOutPutDTO
    {
        public UserOutPutDTO User { get; set; }
        public string Token { get; set; } = string.Empty;
    }
}
