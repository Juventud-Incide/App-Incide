class AppStrings {
  // --- Registro (Paso 1) ---
  static const String registerTitle = 'CREAR CUENTA';
  static const String registerSubtitle =
      'Únete a la red de profesionistas INCIDE.';
  static const String requiredField = 'Requerido';
  static const String personalData = 'INFORMACIÓN PERSONAL';
  static const String nameLabel = 'NOMBRE(S):';
  static const String lastNameLabel = 'APELLIDO(S):';
  static const String accountData = 'DATOS DE CONTACTO';
  static const String emailLabel = 'CORREO ELECTRÓNICO:';
  static const String emailHint = 'ejemplo@correo.com';
  static const String emailInvalid = 'Inserta un correo válido';
  static const String phoneLabel = 'CELULAR (10 DÍGITOS):';
  static const String phoneHint = '662 000 0000';
  static const String phoneInvalid = 'Inserta un celular válido';
  static const String passwordLabel = 'CONTRASEÑA:';
  static const String passwordHint = '*****';
  static const String passwordInvalid = 'Mínimo 8 caracteres';
  static const String legalData = 'IDENTIDAD FISCAL Y LEGAL';
  static const String curpLabel = 'CURP (18 CARACTERES):';
  static const String curpHint = 'Ejemplo: GOML900101HDFRRL09';
  static const String curpInvalid = 'Debe tener 18 caracteres';
  static const String rfcLabel = 'RFC (13 CARACTERES):';
  static const String rfcHint = 'Ejemplo: GOML900101XXX';
  static const String rfcInvalid = 'Personas físicas requieren 13 caracteres';
  static const String invalidFormat = 'Formato inválido';
  static const String termsAndConditions =
      'Acepto los Términos y Condiciones y el aviso de privacidad. Entiendo que mi cuenta debe ser validada por un administrador.';
  static const String termsNotAccepted =
      'Debes aceptar los Términos y Condiciones para continuar.';
  static const String continueBtn = 'Continuar';

  // --- Verificación OTP (Paso 2) ---
  static const String otpTitle = 'VERIFICA TU NÚMERO';
  static const String otpSubtitle1 =
      'Ingresa el código de 4 dígitos que enviamos por SMS a la terminación ';
  static const String otpNotReceived = '¿No recibiste el código?';
  static const String otpResendBtn = 'Reenviar código (00:45)';
  static const String otpVerifyBtn = 'Verificar Código';
  static const String otpSuccess = 'Código verificado correctamente';
  static const String otpError = 'Código incorrecto. Intenta de nuevo.';
  static const String otpIncomplete = 'Por favor, ingresa los 4 dígitos';

  // --- Documentos KYC ---
  static const String docsTitle = 'Documentación Legal';
  static const String docsSubtitle =
      'Para activar tu cuenta, necesitamos validar tu identidad con los siguientes documentos. Asegúrate de que las fotos sean claras y legibles.';
  static const String sendDocsBtn = 'Enviar Documentos a Revisión';
  static const String missingDocsError =
      'Por favor, sube todos los documentos obligatorios.';
  static const String takePhoto = 'Tomar Fotografía';
  static const String chooseFromGallery = 'Elegir de la Galería / Archivos';
  static const String docIne = 'Identificación Oficial (INE)';
  static const String docIneShort = 'INE';
  static const String docIneSubtitle = 'Sube una foto por ambos lados.';
  static const String docDomicilio = 'Comprobante de Domicilio';
  static const String docDomicilioShort = 'Comprobante';
  static const String docDomicilioSubtitle =
      'No mayor a 3 meses (Luz, Agua, Internet).';
  static const String docCedula = 'Cédula Profesional';
  static const String docCedulaShort = 'Cédula';
  static const String docCedulaSubtitle =
      'Documento oficial de tu oficio/profesión.';
  static const String docAntecedentes = 'Carta de No Antecedentes';
  static const String docAntecedentesShort = 'Antecedentes Penales';
  static const String docAntecedentesSubtitle =
      'Documento expedido por el Estado.';
  static const String docFoto = 'Fotografía de Perfil';
  static const String docFotoShort = 'Foto';
  static const String docFotoSubtitle =
      'Foto de frente, clara y sin lentes oscuros.';
}
