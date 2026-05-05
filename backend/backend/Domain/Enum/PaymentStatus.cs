namespace backend.Domain.Enum
{
    public enum PaymentStatus
    {
        Pending   = 0,
        Succeeded = 1,
        Failed    = 2,
        Released  = 3,
        Refunded  = 4,
        Cancelled = 5
    }
}
