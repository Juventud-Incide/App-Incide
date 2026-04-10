namespace backend.Data.Entities
{
    public class RevokedToken : Entity
    {
        public string Jti { get; set; } = string.Empty;
        public DateTime ExpiresAt { get; set; }
        public DateTime RevokedAt { get; set; }
    }
}
