using backend.Domain.Enum;

namespace backend.Data.Entities
{
    public class User : Entity
    {
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string? ProfilePictureUrl { get; set; }
        public bool IsEmailVerified { get; set; } = false;

        public UserRole UserRole { get; set; }

        
        public Client? Client { get; set; }
        public Provider? Provider { get; set; }

    }
}
