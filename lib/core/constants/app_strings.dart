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
  static const String confirmPasswordLabel = 'CONFIRMAR CONTRASEÑA:';
  static const String confirmPasswordHint = '*****';
  static const String passwordMismatch = 'Las contraseñas no coinciden';
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
  static const String termsAndConditionsCliente =
      'Acepto los Términos y Condiciones y el aviso de privacidad.';
  static const String termsNotAccepted =
      'Debes aceptar los Términos y Condiciones para continuar.';
  static const String orSignInWith = 'O regístrate con';
  static const String googleSignIn = 'Registrarte con Google';
  static const String continueBtn = 'Continuar';

  // --- Verificación OTP SMS (Paso 2 - Profesionista) ---
  static const String otpTitle = 'VERIFICA TU NÚMERO';
  static const String otpSubtitle1 =
      'Ingresa el código de 4 dígitos que enviamos por SMS a la terminación ';
  static const String otpNotReceived = '¿No recibiste el código?';
  static const String otpResendBtn = 'Reenviar código ';
  static const String otpVerifyBtn = 'Verificar Código';
  static const String otpSuccess = 'Código verificado correctamente';
  static const String otpError = 'Código incorrecto. Intenta de nuevo.';
  static const String otpIncomplete = 'Por favor, ingresa los 4 dígitos';

  // --- Verificación de Correo (Paso 2 - Cliente) ---
  static const String emailOtpTitle = 'VERIFICA TU CORREO';
  static const String emailOtpSubtitle1 =
      'Ingresa el código de 6 dígitos que enviamos a ';
  static const String emailOtpNotReceived = '¿No recibiste el código?';
  static const String emailOtpResendBtn = 'Reenviar código (00:45)';
  static const String emailOtpIncomplete = 'Por favor, ingresa los 6 dígitos';

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
  static const String docAntecedentesShort = 'Carta';
  static const String docAntecedentesSubtitle =
      'Documento expedido por el Estado.';
  static const String docFoto = 'Fotografía de Perfil';
  static const String docFotoShort = 'Foto';
  static const String docFotoSubtitle =
      'Foto de frente, clara y sin lentes oscuros.';

  static const String docUploaded = 'Documento adjuntado';

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

  // --- Pantalla de Activación de Cuenta ---
  static const String activationTitle = '¡Cuenta Activada!';
  static const String activationSubtitle =
      'Tus documentos han sido validados exitosamente. Ya formas parte de la red de proveedores oficiales de INCIDE.';
  static const String activationNextStepsTitle = 'Siguiente paso';
  static const String activationNextStepsSubtitle =
      'Para enviarte oportunidades de trabajo, necesitaremos que configures tu ubicación en la siguiente pantalla.';
  static const String activationNextStepsBtn = 'Comenzar';

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
  static const String noOpportunities =
      'No hay oportunidades disponibles en este momento.';
  static const String viewMapBtn = 'Ver Mapa';
  static const String filterAll = 'Todas';
  static const String filterExclusive = 'Exclusivas';
  static const String filterOpen = 'Abiertas';
  static const String discardBtn = 'Descartar';
  static const String interestedBtn = 'Me Interesa';
  static const String distancePrefix = 'a';
  static const String opportunityTypeExclusive = 'Exclusiva';
  static const String opportunityTypeOpen = 'Abierta';
  static const String proposalTitle = 'Enviar Propuesta';
  static const String proposalSubtitle =
      'El cliente recibirá tu mensaje y podrá decidir si contactarte para afinar detalles.';
  static const String messageLabel = 'Mensaje para el cliente';
  static const String messageHint =
      '¡Hola! Vi tu solicitud y estoy interesado en el proyecto.';
  static const String priceLabel = 'Precio estimado (Opcional)';
  static const String sendProposalBtn = 'Enviar Propuesta';
  static const String opportunityDiscarded = 'Oportunidad descartada';
  static const String undoDiscard = 'Deshacer';
  static const String invalidPriceError = 'Por favor, ingresa un precio válido';
  static const String proposalSentTitle = '¡Propuesta enviada con éxito!';
  static const String chatDefaultMessage =
      '¡Hola! Vi tu solicitud para {opportunityTitle} y estoy interesado en el proyecto.';

  // --- Pantalla de Detalle de Oportunidad ---
  static const String detailTitle = 'Detalle de la Solicitud';
  static const String clientAnswers = 'Especificaciones del Cliente';
  static const String estimatedPrice = 'Presupuesto Estimado';
  static const String systemCalculated = 'Calculado por el sistema';
  static const String attachedPhotos = 'Fotos Adjuntas';
  static const String descriptionTitle = 'Descripción';
  // --- Pantalla de Recuperación de Contraseña ---
  static const String forgotPassTitle = 'RECUPERAR CUENTA';
  static const String forgotPassSubtitle =
      'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.';
  static const String sendLinkBtn = 'Enviar Enlace';
  static const String emailNotFound =
      'No encontramos una cuenta con este correo.';

  // --- Pantalla de Cotizaciones ---
  static const String quoteAcceptedTitle = 'ACEPTADA / EN PROGRESO';
  static const String quotePendingTitle = 'EN ESPERA';
  static const String quotePriceNotDefined = 'Por definir';
  static const String quoteOpenChatBtn = 'Abrir Chat';
  static const String quoteRemoveBtn = 'Retirar Propuesta';
  static const String quoteCompletedTitle = 'COMPLETADA';
  static const String quoteRejectedTitle = 'RECHAZADA';
  static const String quoteCancelledTitle = 'CANCELADA';
  static const String quoteSentTitle =
      'Enviaste tu propuesta recientemente. Esperando respuesta del cliente.';
  static const String quoteExclusiveBadge = 'EXCLUSIVA';

  static const String quoteTitle = 'Mis Cotizaciones';
  static const String quoteNoQuotes = 'No tienes cotizaciones en esta sección.';
  static const String quoteAlertTitle = '¿Retirar Propuesta?';
  static const String quoteAlertContent =
      'Esta acción cancelará tu postulación y no podrá deshacerse.';
  static const String quoteCancelLbl = 'Cancelar';
  static const String quoteRetiredLbl = 'Propuesta retirada con éxito';
  static const String quoteRetireLbl = 'Sí, retirar';

  static const String quoteDetailTitle = 'Detalles del Trabajo';
  static const String quoteDescription = 'Descripción del Problema';
  static const String quoteClientSpecs = 'Especificaciones del Cliente';
  static const String quoteDetailClientTitle = 'Información del Cliente';
  static const String quoteDetailClientNameProtected = 'Nombre protegido';
  static const String quoteDetailClientProtected = 'Número protegido';

  // --- Pantalla de Billetera ---
  static const String walletWithdrawalTitle =
      'Retiro a {bankName} ***{lastFourDigits}';
  static const String walletReleasedTitle = 'Pago Liberado';
  static const String walletInProcessTitle = 'En proceso';

  static const String walletMyWalletTitle = 'Mi Billetera';
  static const String walletRecentTransactionsTitle = 'Movimientos Recientes';
  static const String walletAccumulatedThisMonth =
      'Acumulado en {month}:\n{amount}';
  static const String walletNonIdentifiableBank = 'Banco no reconocido';
  static const String walletAnotherBank = 'Otro Banco';
  static const String walletPleaseFillBankInfo =
      'Por favor, llena todos los campos.';
  static const String walletClabeLengthError =
      'La CLABE debe tener exactamente 18 dígitos.';
  static const String walletAddedBankSuccess =
      'Cuenta bancaria agregada exitosamente.';
  static const String walletAddBankTitle = 'Agregar Cuenta Bancaria';
  static const String walletAccountHolderLbl = 'Titular de la Cuenta:';
  static const String walletClabeLbl = 'CLABE Interbancaria (18 dígitos)';
  static const String walletSaveBankBtn = 'Guardar Cuenta';

  static const String walletNoTransactionsTitle = 'Sin movimientos recientes';
  static const String walletNoTransactionsSubtitle =
      'Aquí aparecerán tus ingresos por servicios completados y el historial de tus retiros.';

  static const String walletRetainedBalanceTitle =
      'En Garantía (Trabajos Activos)';
  static const String walletRetainedBalanceValue = '{amount} MXN';

  static const String walletPendingReleaseTitle = 'Pendiente de Liberación';
  static const String walletWithdrawalReleaseTitle = 'Retiro completado';
  static const String walletReleased = 'Liberado';

  static const String walletDestinationTitle = 'Cliente / Destino';
  static const String walletSubtitleTitle = 'Concepto';
  static const String walletDateTitle = 'Fecha y Hora';
  static const String walletTransactionIdTitle = 'ID de Transacción';
  static const String walletCloseDetailBtn = 'Cerrar Detalles';

  static const String walletPrivacyOnBalance = '**** MXN';
  static const String walletPrivacyOffBalance = '{amount} MXN';
  static const String walletAvailableBalanceTitle = 'Saldo Disponible';
  static const String walletWithdrawBtn = 'Retirar a Banco';

  static const String walletInvalidAmountError =
      'Por favor, ingresa un monto válido.';
  static const String walletInsufficientFundsError =
      'Monto supera tu saldo disponible';
  static const String walletWithdrawalSuccess =
      'Retiro en proceso. Lo verás reflejado pronto.';
  static const String walletWithdrawFundsTitle = 'Retirar Fondos';
  static const String walletAvailableBalance = 'Saldo Disponible: {amount} MXN';
  static const String walletSuffix = ' MXN';
  static const String walletWithdrawLabel = 'Monto a retirar';
  static const String walletMaxLbl = 'MAX';
  static const String walletAdjustedAmountTitle =
      'Monto ajustado al máximo disponible';
  static const String walletBankAccount = 'Cuenta Bancaria';
  static const String walletBankAccountHolderAndLastDigits =
      '{bankName} •••• {lastFourDigits}';
  static const String walletChangeAccountBtn = 'Cambiar';
  static const String walletNoBankAccount =
      'Necesitas una cuenta bancaria para retirar';
  static const String walletAddBankAccountBtn = 'Agregar Cuenta';
  static const String walletConfirmWithdrawalTitle = 'Confirmar Retiro';
  // --- Pantalla de Chat de Proveedor ---
  static const String chatStartTitle = 'INICIO DEL CHAT';
  static const String chatProviderCompleted =
      'Has marcado este servicio como completado. A la espera de confirmación del cliente.';
  static const String chatClientCompleted =
      'El cliente ha marcado como completado el servicio. A la espera de tu confirmación.';
  static const String chatCompletionConfirmed =
      'Ambas partes han aceptado. El servicio ha sido cerrado. Gracias por tu trabajo.';
  static const String chatCancelCompletion =
      'Has cancelado la finalización. El servicio vuelve a estar en curso.';
  static const String chatToday = 'Hoy';
  static const String chatYesterday = 'Ayer';
  static const String chatFinishedTitle = 'Servicio Completado';
  static const String chatReadOnlyTitle =
      'Este chat ha sido archivado y es de solo lectura.';
  static const String chatClientNameProtected = 'Nombre protegido';
  static const String chatClientInitialsProtected = 'CL';
  static const String chatCancelCompletionBtn = 'Cancelar Completado';
  static const String chatConfirmCompletionBtn = 'Marcar como Completado';
  static const String chatReportIssueBtn = 'Reportar un problema';
  static const String chatImageError = 'Error al seleccionar imagen: ';
  static const String chatDocumentError = 'Error al seleccionar documento: ';
  static const String chatPhotoGallery = 'Galería de fotos';
  static const String chatDocuments = 'Documentos';
  static const String chatHintText = 'Escribe un mensaje...';
  static const String chatSetNewPrice = 'Establecer Precio';
  static const String chatSetNewPriceHint =
      'Ingresa el nuevo precio propuesto para esta cotización:';
  static const String chatPriceLabel = 'Precio (\$)';
  static const String chatCancelPriceChange = 'Cancelar';
  static const String chatPriceChangedAlertTitle =
      'El proveedor ha actualizado la propuesta a \${newPrice} MXN.';
  static const String chatSetNewPriceInvalid =
      'Por favor, ingresa un precio válido.';
  static const String chatUpdatePriceBtn = 'Actualizar';

  // --- Pantallas de Dialogo ---
  static const String dialogCurrentlyCompletedTitle =
      '¿Marcar como completado?';
  static const String dialogCurrentlyCompletedContent =
      'Se enviará una notificación al cliente para que confirme que el trabajo ha finalizado.';
  static const String dialogCancelCompletionTitle = '¿Cancelar completado?';
  static const String dialogCancelCompletionContent =
      'El servicio volverá a estar en curso y el cliente ya no podrá confirmarlo.';
  static const String dialogCurrentlyCompletedConfirm = 'Sí, completar';
  static const String dialogCancelCompletionConfirm = 'Sí, cancelar';
  static const String dialogGoBackLbl = 'Volver';

  /// --- Pantalla de Vista Previa de Adjuntos ---
  static const String attachmentPreviewTitle = 'Vista Previa';
  static const String attachmentCaptionHint = 'Añade un comentario...';

  // --- Pantalla de Envío de Enlace de Recuperación ---
  static const String linkSentTitle = '¡Enlace enviado!';
  static const String linkSentSubtitle1 = 'Hemos enviado las instrucciones a';
  static const String linkSentSubtitle2 =
      'Por favor, revisa tu bandeja de entrada o la carpeta de Spam.';
  static const String backToHomeBtn = 'Volver al Inicio';
  static const String didNotReceiveEmail = '¿No recibiste el correo?';
  static const String resendIn = 'Reenviar en';
  static const String resendNow = 'Reenviar código ahora';
  static const String newLinkSent = 'Nuevo enlace enviado';

  // --- Pantalla de Escribir Nueva Contraseña ---
  static const String newPasswordTitle = 'NUEVA CONTRASEÑA';
  static const String newPasswordSubtitle =
      'Crea una nueva contraseña segura para tu cuenta de INCIDE.';
  static const String newPasswordLabel = 'NUEVA CONTRASEÑA:';
  static const String updatePasswordBtn = 'Actualizar Contraseña';
  static const String passwordsDoNotMatch = 'Las contraseñas no coinciden';
  static const String passwordUpdatedTitle = '¡Contraseña Actualizada!';
  static const String passwordUpdatedSubtitle =
      'Tu contraseña ha sido actualizada correctamente. Ahora puedes iniciar sesión con tu nueva contraseña.';
  static const String goToLoginBtn = 'Ir a Iniciar Sesión';

  // --- Pantalla de Solicitud de Permisos de Ubicación ---
  static const String locationTitle = 'Encuentra trabajo en tu zona';
  static const String locationSubtitle =
      'Para enviarte cotizaciones y solicitudes de clientes cercanos a ti, necesitamos acceso a tu ubicación.';
  static const String allowLocationBtn = 'Permitir Ubicación';
  static const String denyLocationBtn =
      'Ingresar mi Código Postal'; // Plan B por si rechazan
  static const String locationDeniedMessage =
      'Debes habilitar la ubicación en la configuración de tu teléfono para continuar.';
  static const String locationDeniedTitle = 'Ubicación Obligatoria';
  static const String locationDeniedSubtitle =
      'Para poder conectarte con clientes y enviarte oportunidades de trabajo cerca de ti, es estrictamente necesario que compartas tu ubicación. Sin este permiso, la aplicación no podrá funcionar.';
  static const String understandBtn = 'Entendido';
  static const String locationWhyRequired = '¿Por qué es obligatorio?';

  // --- Pantalla de Permiso de Ubicación (Cliente) – Tarea #76 ---
  static const String clientLocationTitle = 'Profesionistas cerca de ti';
  static const String clientLocationSubtitle =
      'Necesitamos tu ubicación para mostrarte los mejores profesionistas disponibles en tu zona.';

  // Modal explicativo previo a la solicitud del sistema
  static const String clientLocationModalTitle = 'Tu ubicación, tu ventaja';
  static const String clientLocationModalBody =
      'Necesitamos tu ubicación para mostrarte profesionistas cerca de ti y calcular distancias en tus cotizaciones.';
  static const String clientLocationModalContinueBtn = 'Entendido, continuar';
  static const String clientLocationModalLaterBtn = 'Ahora no';

  // Caso 2: Denegado una vez
  static const String clientLocationDeniedOnceTitle = 'Sin ubicación por ahora';
  static const String clientLocationDeniedOnceBody =
      'Sin tu ubicación no podremos mostrarte profesionistas cercanos. Puedes habilitar el permiso cuando quieras.';
  static const String clientLocationRetryBtn = 'Reintentar';
  static const String clientLocationLaterBtn = 'Más tarde';

  // Caso 3: Denegado permanentemente
  static const String clientLocationPermanentDeniedBody =
      'El permiso de ubicación fue bloqueado. Para continuar, habilítalo manualmente desde la Configuración de tu dispositivo.';
  static const String clientLocationOpenSettingsBtn = 'Abrir Configuración';
  static const String clientLocationCancelBtn = 'Cancelar';
}
