using backend.Domain.Enum;

namespace backend.Data.Entities
{
    public class Provider : Entity
    {
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string? Address { get; set; }
        public string? Website { get; set; }
        public bool IsEmailVerified { get; set; } = false;
        public UserRole UserRoles { get; set; } = UserRole.Provider;
    }
}
