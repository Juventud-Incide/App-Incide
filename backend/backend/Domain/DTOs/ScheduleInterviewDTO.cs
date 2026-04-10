using System.ComponentModel.DataAnnotations;

namespace backend.Domain.DTOs
{
    public class ScheduleInterviewDTO
    {
        [Required(ErrorMessage = "La fecha de entrevista es obligatoria.")]
        public DateTime InterviewDate { get; set; }
    }
}
