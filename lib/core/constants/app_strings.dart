class AppStrings {
  // --- Pantalla de Bienvenida ---
  static const String welcomeTitle = '¡Bienvenido a INCIDE!';
  static const String welcomeSubtitle = '¿Cómo deseas usar la plataforma hoy?';
  static const String roleClient = 'Soy Cliente';
  static const String roleClientDesc =
      'Busco profesionistas certificados para realizar un trabajo o proyecto.';
  static const String roleProfessional = 'Soy Profesionista';
  static const String roleProfessionalDesc =
      'Quiero ofrecer mis servicios, recibir cotizaciones y gestionar mis trabajos.';
  static const String roleSelectionFooter =
      'Podrás cambiar de perfil más adelante desde\ntu configuración.';

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
  static const String uploadText = 'Subir ';
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

  // --- Revisión de Documentos ---
  static const String reupload = 'Re-subir ';
  static const String takeNewPhoto = 'Tomar nueva Fotografía';
  static const String requiredAction = 'Acción Requerida';
  static const String reviewTitle = 'Revisión de Documentos';
  static const String reviewSubtitle =
      'Hemos revisado tu documentación y encontramos algunos detalles. Por favor, corrige los archivos marcados en rojo para continuar con tu activación.';
  static const String correctionFiles = 'ARCHIVOS A CORREGIR:';
  static const String approvedDocs =
      'DOCUMENTOS APROBADOS (No requieren acción):';
  static const String resendDocs = 'Volver a Enviar Documentos';
  static const String correctedFile = 'Corregido. Listo para enviar.';
  static const String requiredUpdate = 'Requiere actualización';
  static const String docIneFeedback =
      'La fotografía trasera está borrosa y no se distinguen los datos. Por favor, tómala con mejor iluminación.';
  static const String docAntecedentesFeedback =
      'El documento que subiste expiró hace 2 meses. Necesitamos uno vigente.';

  // --- Pantalla de Aprobación de Entrevista---
  static const String approvalTitle = '¡Entrevista Aprobada!';
  static const String approvalSubtitle =
      'Nos encantó conocerte. Ya casi eres parte oficial de la red de profesionistas INCIDE.';
  static const String finalStepTitle = 'Último paso: Verificación Legal';
  static const String finalStepSubtitle =
      'Para garantizar la seguridad de nuestros clientes, necesitamos que subas fotografías legibles de tus documentos oficiales. Tenlos a la mano.';
  static const String uploadDocsBtn = 'Subir Documentos Ahora';
  static const String uploadDocsLaterBtn = 'Lo haré en otro momento';

  // --- Pantalla de Envío de Documentos ---
  static const String docsSentTitle = 'Documentos Recibidos';
  static const String docsSentSubtitle =
      'Tus archivos se han cargado correctamente y los estamos derivando a nuestro departamento legal para su revisión.';
  static const String nextStepsTitle = '¿Qué sigue?';
  static const String nextStepsSubtitle =
      'Revisaremos que las fotografías sean legibles y coincidan con tu perfil. Te notificaremos al terminar.';
  static const String seeStatusBtn = 'Ver estado de mi cuenta';

  // --- Pantalla de Experiencia Profesional ---
  static const String experienceTitle = 'TU EXPERIENCIA';
  static const String experienceSubtitle =
      'Cuéntanos sobre tu oficio para conectarte con los mejores clientes.';
  static const String specialtyLabel = 'ESPECIALIDAD PRINCIPAL:';
  static const String specialtyHint = 'Seleccione un oficio...';
  static const String selectSpecialtyError = 'Selecciona una especialidad';
  static const String yearsExperienceLabel = 'AÑOS EXP.';
  static const String yearsExperienceHint = 'Ej. 5';
  static const String requiredFieldShort = 'Req.';
  static const String descriptionLabel = 'DESCRIPCIÓN DE LOS SERVICIOS:';
  static const String descriptionHint =
      'Describe brevemente qué tipo de trabajos realizas...';
  static const String descriptionError = 'Cuéntanos un poco sobre tu trabajo';
  static const String descriptionTooShortError =
      'Por favor escribe al menos 20 caracteres';
  static const String cedulaLabel = 'CÉDULA PROFESIONAL:';
  static const String cedulaHint = 'Número (Opcional)';
  static const String sendBtn = 'Enviar Solicitud';

  // --- Pantalla de Inicio de Sesión ---
  static const String loginTitle = '¡Bienvenido, Proveedor!';
  static const String loginSubtitle = 'Ingresa para ver tus cotizaciones';
  static const String emailLoginLabel = 'CORREO ELECTRÓNICO:';
  static const String emailLoginHint = 'ejemplo@correo.com';
  static const String emailLoginEmpty =
      'Por favor ingresa tu correo electrónico';
  static const String emailLoginError = 'Inserta un correo válido';
  static const String passwordLoginLabel = 'CONTRASEÑA:';
  static const String passwordLoginHint = '*****';
  static const String passwordLoginEmpty = 'Por favor ingresa tu contraseña';
  static const String passwordLoginError =
      'La contraseña debe tener al menos 8 caracteres';
  static const String forgotPassword = '¿Olvidaste tu contraseña?';
  static const String loginBtn = 'Iniciar Sesión';
  static const String loginSuccessMessage = '¡Bienvenido a INCIDE!';
  static const String continueWith = 'O continúa con';
  static const String googleLogin = 'Google';
  static const String notRegistered = '¿No tienes cuenta? ';
  static const String registerNow = 'Regístrate ahora';

  // --- Pantalla de Rechazo de Solicitud ---
  static const String rejectedTitle = 'Proceso Detenido';
  static const String rejectedSubtitle1 =
      'Agradecemos mucho tu interés y el tiempo invertido en tu solicitud de registro.';
  static const String rejectedSubtitle2 =
      'Lamentablemente, en esta ocasión tu perfil no cumple con los requisitos actuales para unirte a la red de profesionistas INCIDE.';
  static const String logoutBtn = 'Cerrar Sesión';

  // --- Pantalla de Cuenta en Revisión ---
  static const String underReviewTitle = 'Cuenta en Revisión';
  static const String underReviewSubtitle1 =
      'Gracias por completar tu solicitud. Actualmente estamos revisando tu información y documentos para validar tu cuenta. Este proceso puede tardar algunos días hábiles. Te notificaremos una vez que tengamos una actualización sobre el estado de tu cuenta.';
  static const String interviewScheduledTitle = 'Entrevista Programada';
  static const String interviewScheduledSubtitle1 =
      '¡Excelente noticia! Tu cuenta ha pasado la revisión inicial y hemos programado una entrevista para conocerte mejor. Te esperamos en nuestras oficinas para discutir tu experiencia y cómo podemos colaborar juntos. Por favor, asegúrate de asistir puntualmente a la entrevista. ¡Nos vemos pronto!';
  static const String documentValidationTitle = 'Documentos en Validación';
  static const String documentValidationSubtitle1 =
      'Estamos revisando tus documentos para asegurarnos de que todo esté en orden. Este proceso es crucial para garantizar la seguridad y confianza en nuestra plataforma. Te contactaremos una vez que hayamos concluido la revisión. Agradecemos tu paciencia y comprensión durante este tiempo.';
  static const String sentTimelineStep = 'Solicitud Enviada';
  static const String reviewTimelineStep = 'Revisión de INCIDE';
  static const String interviewTimelineStep = 'Entrevista Presencial';
  static const String reviewDocsTimelineStep = 'Revisión de Documentos';
  static const String activatedTimelineStep = 'Activación de cuenta';

  // --- Pantalla de Envío de Solicitud ---
  static const String submissionTitle = '¡Solicitud Recibida!';
  static const String submissionSubtitle1 =
      'Gracias por enviar tu solicitud. Estamos emocionados de revisar tu perfil y potencialmente darte la bienvenida a la red de profesionistas INCIDE. Tus datos han sido guardados de forma segura.';
  static const String submissionSubtitle2 =
      'El equipo de Recursos Humanos de INCIDE revisará tu perfil. Mantente atento, ya que te contactaremos para agendar tu Entrevista Presencial.';
  static const String estimatedTime = 'Tiempo estimado de respuesta:';
  static const String estimatedTimeValue = '1 a 2 días hábiles';
  static const String seeUpdateBtn = 'Ver estado de mi solicitud';

  // --- Pantalla de Shell de Dashboard de proveedores ---
  static const String shellHome = 'Inicio';
  static const String shellQuotes = 'Cotizaciones';
  static const String shellWallet = 'Billetera';
  static const String shellProfile = 'Perfil';

  // --- Pantalla de Inicio del Dashboard de proveedores ---
  static const String welcomeText = 'Bienvenido,';
  static const String radarTitleOn = 'Recibiendo Solicitudes';
  static const String radarSubtitleOn = 'Estás visible en el radar de clientes';
  static const String radarTitleOff = 'Modo Ocupado';
  static const String radarSubtitleOff =
      'Pausaste la recepción de nuevas solicitudes';
  static const String waitingQuotesTitle = 'Cotizaciones en Espera';
  static const String acceptedQuotesTitle = 'Cotizaciones Aceptadas';
  static const String opportunitiesTitle = 'Oportunidades Cerca';
  static const String viewMapBtn = 'Ver Mapa';
  static const String filterAll = 'Todas';
  static const String filterExclusive = 'Exclusivas';
  static const String filterOpen = 'Abiertas';
}
