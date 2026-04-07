namespace backend.Domain.Enum
{
    public enum DocumentType
    {
        None = 0,
        INE = 1,
        Certificado = 2,
        CV = 3,
        ComprobanteDomicilio = 4,
        CedulaProfesional = 5,
        CartaNoAntecedentesPenales = 6,
        FotoPerfil = 7,
    }

    public static class RequiredProviderDocuments
    {
        public static readonly DocumentType[] All = new[]
        {
            DocumentType.INE,
            DocumentType.ComprobanteDomicilio,
            DocumentType.CedulaProfesional,
            DocumentType.CartaNoAntecedentesPenales,
            DocumentType.FotoPerfil,
        };
    }
}
