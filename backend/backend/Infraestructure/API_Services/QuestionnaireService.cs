using backend.Data.DataDB;
using backend.Data.Entities;
using backend.Domain.DTOs.Questionnaire;
using backend.Domain.OutPutDTOs.Questionnaire;
using backend.Infraestructure.API_Services_Interfaces;
using Microsoft.EntityFrameworkCore;

namespace backend.Infraestructure.API_Services
{
    public class QuestionnaireService : IQuestionnaireService
    {
        private readonly AppDbContext _context;

        public QuestionnaireService(AppDbContext context)
        {
            _context = context;
        }

        private static QuestionOutputDTO ToDTO(Question q) => new()
        {
            Id         = q.Id,
            CategoryId = q.CategoryId,
            Text       = q.Text,
            Type       = q.Type.ToString(),
            IsRequired = q.IsRequired,
            Order      = q.Order,
            Options    = q.Options
                          .Where(o => !o.IsDeleted)
                          .OrderBy(o => o.Order)
                          .Select(o => new QuestionOptionOutputDTO
                          {
                              Id    = o.Id,
                              Text  = o.Text,
                              Order = o.Order
                          })
                          .ToList()
        };

        public async Task<List<QuestionOutputDTO>> GetByCategoryAsync(int categoryId, CancellationToken ct)
        {
            var categoryExists = await _context.Categories
                .AnyAsync(c => c.Id == categoryId && !c.IsDeleted, ct);

            if (!categoryExists)
                throw new KeyNotFoundException($"La categoría con id {categoryId} no existe.");

            return await _context.Questions
                .Where(q => q.CategoryId == categoryId && !q.IsDeleted)
                .Include(q => q.Options)
                .OrderBy(q => q.Order)
                .Select(q => new QuestionOutputDTO
                {
                    Id         = q.Id,
                    CategoryId = q.CategoryId,
                    Text       = q.Text,
                    Type       = q.Type.ToString(),
                    IsRequired = q.IsRequired,
                    Order      = q.Order,
                    Options    = q.Options
                                  .Where(o => !o.IsDeleted)
                                  .OrderBy(o => o.Order)
                                  .Select(o => new QuestionOptionOutputDTO
                                  {
                                      Id    = o.Id,
                                      Text  = o.Text,
                                      Order = o.Order
                                  })
                                  .ToList()
                })
                .ToListAsync(ct);
        }

        public async Task<QuestionOutputDTO> CreateAsync(int categoryId, QuestionDTO dto, CancellationToken ct)
        {
            var categoryExists = await _context.Categories
                .AnyAsync(c => c.Id == categoryId && !c.IsDeleted, ct);

            if (!categoryExists)
                throw new KeyNotFoundException($"La categoría con id {categoryId} no existe.");

            var question = new Question
            {
                CategoryId   = categoryId,
                Text         = dto.Text,
                Type         = dto.Type,
                IsRequired   = dto.IsRequired,
                Order        = dto.Order,
                IsActive     = true,
                CreationDate = DateTime.UtcNow,
                LastUpdate   = DateTime.UtcNow
            };

            if (dto.Type == Domain.Enum.QuestionType.MultipleChoice)
            {
                question.Options = dto.Options.Select((o, i) => new QuestionOption
                {
                    Text         = o.Text,
                    Order        = o.Order > 0 ? o.Order : i + 1,
                    IsActive     = true,
                    CreationDate = DateTime.UtcNow,
                    LastUpdate   = DateTime.UtcNow
                }).ToList();
            }

            _context.Questions.Add(question);
            await _context.SaveChangesAsync(ct);

            return ToDTO(question);
        }

        public async Task<QuestionOutputDTO?> UpdateAsync(int id, QuestionDTO dto, CancellationToken ct)
        {
            var question = await _context.Questions
                .Include(q => q.Options)
                .FirstOrDefaultAsync(q => q.Id == id && !q.IsDeleted, ct);

            if (question == null) return null;

            question.Text       = dto.Text;
            question.Type       = dto.Type;
            question.IsRequired = dto.IsRequired;
            question.Order      = dto.Order;
            question.LastUpdate = DateTime.UtcNow;

            // Replace options
            foreach (var opt in question.Options)
            {
                opt.IsDeleted  = true;
                opt.IsActive   = false;
                opt.LastUpdate = DateTime.UtcNow;
            }

            if (dto.Type == Domain.Enum.QuestionType.MultipleChoice)
            {
                var newOptions = dto.Options.Select((o, i) => new QuestionOption
                {
                    QuestionId   = question.Id,
                    Text         = o.Text,
                    Order        = o.Order > 0 ? o.Order : i + 1,
                    IsActive     = true,
                    CreationDate = DateTime.UtcNow,
                    LastUpdate   = DateTime.UtcNow
                }).ToList();

                _context.QuestionOptions.AddRange(newOptions);
                question.Options = newOptions;
            }
            else
            {
                question.Options = [];
            }

            await _context.SaveChangesAsync(ct);

            return ToDTO(question);
        }

        public async Task<bool> DeleteAsync(int id, CancellationToken ct)
        {
            var question = await _context.Questions
                .Include(q => q.Options)
                .FirstOrDefaultAsync(q => q.Id == id && !q.IsDeleted, ct);

            if (question == null) return false;

            var now = DateTime.UtcNow;

            foreach (var opt in question.Options.Where(o => !o.IsDeleted))
            {
                opt.IsDeleted  = true;
                opt.IsActive   = false;
                opt.LastUpdate = now;
            }

            question.IsDeleted  = true;
            question.IsActive   = false;
            question.LastUpdate = now;

            await _context.SaveChangesAsync(ct);

            return true;
        }
    }
}
