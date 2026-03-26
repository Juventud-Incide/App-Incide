using backend.Domain.Enum;

namespace backend.Data.Entities
{
    public class Client : Entity
    {
        public int UserId { get; set; }
        public User User { get; set; }
    }
}
