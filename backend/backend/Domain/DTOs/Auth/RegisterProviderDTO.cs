using System.ComponentModel.DataAnnotations;

namespace backend.Domain.DTOs
{
    public class RegisterProviderDTO
    {
        [Required(ErrorMessage = "El nombre es obligatorio.")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "El nombre debe tener entre 2 y 50 caracteres.")]
        public string FirstName { get; set; } = string.Empty;

        [Required(ErrorMessage = "El apellido es obligatorio.")]
        [StringLength(50, MinimumLength = 2, ErrorMessage = "El apellido debe tener entre 2 y 50 caracteres.")]
        public string LastName { get; set; } = string.Empty;

        [Required(ErrorMessage = "El correo es obligatorio.")]
        [EmailAddress(ErrorMessage = "Formato de correo inválido.")]
        [StringLength(120, ErrorMessage = "El correo no puede exceder 120 caracteres.")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "La contraseña es obligatoria.")]
        [MinLength(8, ErrorMessage = "La contraseña debe tener al menos 8 caracteres.")]
        [StringLength(100, ErrorMessage = "La contraseña no puede exceder 100 caracteres.")]
        public string Password { get; set; } = string.Empty;

        [Required(ErrorMessage = "La confirmación de contraseña es obligatoria.")]
        [Compare("Password", ErrorMessage = "Las contraseñas no coinciden.")]
        public string ConfirmPassword { get; set; } = string.Empty;

        [Required(ErrorMessage = "El número de teléfono es obligatorio.")]
        [Phone(ErrorMessage = "Formato de teléfono inválido.")]
        [StringLength(20, MinimumLength = 10, ErrorMessage = "El teléfono debe tener entre 10 y 20 caracteres.")]
        public string PhoneNumber { get; set; } = string.Empty;

        [Required(ErrorMessage = "El CURP es obligatorio.")]
        [StringLength(18, MinimumLength = 18, ErrorMessage = "El CURP debe tener exactamente 18 caracteres.")]
        [RegularExpression(@"^[A-Z]{4}\d{6}[HM][A-Z]{5}[0-9A-Z]\d$",
            ErrorMessage = "Formato de CURP inválido.")]
        public string Curp { get; set; } = string.Empty;

        [Required(ErrorMessage = "El RFC es obligatorio.")]
        [StringLength(13, MinimumLength = 12, ErrorMessage = "El RFC debe tener 12 o 13 caracteres.")]
        [RegularExpression(@"^[A-ZÑ&]{3,4}\d{6}[A-Z0-9]{3}$",
            ErrorMessage = "Formato de RFC inválido.")]
        public string Rfc { get; set; } = string.Empty;

        [Required(ErrorMessage = "La categoría es obligatoria.")]
        [Range(1, int.MaxValue, ErrorMessage = "El categoryId debe ser mayor que 0.")]
        public int CategoryId { get; set; }

        [Required(ErrorMessage = "Los servicios son obligatorios.")]
        [MinLength(1, ErrorMessage = "Debe seleccionar al menos un servicio.")]
        public List<int> ServiceIds { get; set; } = [];

        [Required(ErrorMessage = "Los años de experiencia son obligatorios.")]
        [Range(0, 60, ErrorMessage = "Los años de experiencia deben estar entre 0 y 60.")]
        public int YearsOfExperience { get; set; }

        [StringLength(20, ErrorMessage = "La cédula profesional no puede exceder 20 caracteres.")]
        public string? ProfessionalLicense { get; set; }

        [StringLength(1000, ErrorMessage = "La descripción no puede exceder 1000 caracteres.")]
        public string? Description { get; set; }
    }
}
