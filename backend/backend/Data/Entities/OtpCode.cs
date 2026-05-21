namespace backend.Data.Entities
{
    public class OtpCode : Entity
    {
        public string   PhoneNumber { get; set; } = string.Empty;
        public string   CodeHash    { get; set; } = string.Empty;
        public DateTime ExpiresAt   { get; set; }
        public bool     IsVerified  { get; set; } = false;
        public bool     IsConsumed  { get; set; } = false;
        public int      Attempts    { get; set; } = 0;
    }
}
