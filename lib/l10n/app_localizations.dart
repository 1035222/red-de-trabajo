import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('es'), Locale('en')];
  static Locale currentLocale = const Locale('es');

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null);
    return localizations!;
  }

  String translate(String source) {
    return translateText(source, locale: locale);
  }

  static String translateText(String source, {Locale? locale}) {
    if ((locale ?? currentLocale).languageCode != 'en') return source;
    final translation = _english[source];
    if (translation != null) return translation;

    final daysAgo = RegExp(r'^Hace (\d+) días$').firstMatch(source);
    if (daysAgo != null) return '${daysAgo.group(1)} days ago';

    final serviceCount = RegExp(r'^(\d+) servicios publicados$')
        .firstMatch(source);
    if (serviceCount != null) {
      final count = int.parse(serviceCount.group(1)!);
      return '$count ${count == 1 ? 'published service' : 'published services'}';
    }

    final projectCount = RegExp(r'^(\d+) proyectos$').firstMatch(source);
    if (projectCount != null) {
      final count = int.parse(projectCount.group(1)!);
      return '$count ${count == 1 ? 'project' : 'projects'}';
    }

    const dynamicPrefixes = {
      'Error al actualizar perfil: ': 'Could not update profile: ',
      'Error al actualizar: ': 'Could not update: ',
      'Error al cargar chat: ': 'Could not load chat: ',
      'Error al cargar datos: ': 'Could not load data: ',
      'Error al cargar servicios: ': 'Could not load services: ',
      'Error al cerrar sesión: ': 'Could not sign out: ',
      'Error al eliminar: ': 'Could not delete: ',
      'Error al enviar audio: ': 'Could not send audio: ',
      'Error al enviar mensaje: ': 'Could not send message: ',
      'Error al eliminar mensaje: ': 'Could not delete message: ',
      'Error al enviar ubicación: ': 'Could not send location: ',
      'Error al publicar: ': 'Could not publish: ',
      'Error al subir imagen: ': 'Could not upload image: ',
      'Error al subir imagen (': 'Could not upload image (',
      'Error al obtener conversaciones (': 'Could not load conversations (',
      'Error al obtener mensajes (': 'Could not load messages (',
      'Error al enviar mensaje (': 'Could not send message (',
      'Error al enviar ubicación (': 'Could not send location (',
      'Error al enviar audio (': 'Could not send audio (',
      'Error al obtener servicios destacados':
          'Could not load featured services',
      'Error al obtener servicios': 'Could not load services',
      'Error al crear servicio': 'Could not create service',
      'Error al actualizar servicio': 'Could not update service',
      'Error al eliminar servicio (': 'Could not delete service (',
      'Error al obtener perfil (': 'Could not load profile (',
      'Error al actualizar perfil (': 'Could not update profile (',
      'Error al obtener notificaciones (': 'Could not load notifications (',
      'Error en la búsqueda: ': 'Search error: ',
      'Enviamos un correo a ': 'We sent an email to ',
      'Envía el primer mensaje a ': 'Send the first message to ',
      'No se pudo iniciar el micrófono: ': 'Could not start the microphone: ',
      'No se pudo reproducir la nota de voz: ':
          'Could not play the voice message: ',
      'No se pudo sincronizar el usuario con el backend (':
          'Could not sync the user with the backend (',
      'No se pudieron activar las notificaciones (':
          'Could not enable notifications (',
      'No se pudieron desactivar las notificaciones (':
          'Could not disable notifications (',
      'No se pudo cargar el contador de notificaciones: ':
          'Could not load the notification count: ',
      'Error al enviar foto: ': 'Could not send photo: ',
      'La foto seleccionada está vacía': 'The selected photo is empty',
      'La foto supera el límite de 15 MB': 'The photo exceeds the 15 MB limit',
      '¡Hola, ': 'Hello, ',
    };
    for (final entry in dynamicPrefixes.entries) {
      if (source.startsWith(entry.key)) {
        return '${entry.value}${source.substring(entry.key.length)}';
      }
    }

    if (source.startsWith('Calificación ')) {
      return source.replaceFirst('Calificación', 'Rating');
    }
    if (source.endsWith(' reseñas)')) {
      return source.replaceFirst(' reseñas)', ' reviews)');
    }
    if (source.startsWith('Mensaje de ')) {
      return source.replaceFirst('Mensaje de ', 'Message from ');
    }
    if (source.startsWith('Tienes una nueva solicitud para ')) {
      return source.replaceFirst(
        'Tienes una nueva solicitud para ',
        'You have a new request for ',
      );
    }
    if (source.endsWith(' dejó una reseña en tu servicio')) {
      return source.replaceFirst(
        ' dejó una reseña en tu servicio',
        ' left a review on your service',
      );
    }
    if (source.startsWith('Estado: ')) {
      final status = source.substring('Estado: '.length);
      return 'Status: ${_english[status] ?? status}';
    }
    if (source.startsWith('Para ') && source.contains('@')) {
      return source.replaceFirst('Para ', 'For ');
    }
    if (source.startsWith('¿Estás seguro de que deseas eliminar "')) {
      return source.replaceFirst(
        '¿Estás seguro de que deseas eliminar "',
        'Are you sure you want to delete "',
      );
    }
    if (source.endsWith(' eliminado')) {
      return '${source.substring(0, source.length - ' eliminado'.length)} deleted';
    }

    return source;
  }

  static const Map<String, String> _english = {
    'Acerca de': 'About',
    'Activa la ubicación del dispositivo': 'Enable device location',
    'Actividad reciente': 'Recent activity',
    'Agrega tus trabajos más destacados': 'Add your best work',
    'Agregar imagen': 'Add image',
    'Actualizar': 'Refresh',
    'Al utilizar Red de Trabajo, aceptas cumplir con estos términos y condiciones. '
            'La plataforma conecta a personas que ofrecen servicios con usuarios que necesitan contratarlos, '
            'pero no se hace responsable de las transacciones o acuerdos entre usuarios.':
        'By using Red de Trabajo, you agree to these terms and conditions. '
        'The platform connects service providers with people who need their services, '
        'but is not responsible for transactions or agreements between users.',
    'Anterior': 'Previous',
    'Aplicar filtros': 'Apply filters',
    'Asocia una contraseña a tu cuenta para iniciar sesión más rápido la próxima vez.':
        'Link a password to your account to sign in faster next time.',
    'Aún no hay comentarios.': 'There are no comments yet.',
    'Aún no tienes reseñas': 'You have no reviews yet',
    'Bienvenido': 'Welcome',
    'Biografía': 'Biography',
    'Ayer': 'Yesterday',
    'Ayuda y soporte': 'Help and support',
    'Buscar': 'Search',
    'Buscar servicios...': 'Search services...',
    'Campo requerido': 'Required field',
    'Calificar servicio': 'Rate service',
    'Cambiar imagen': 'Change image',
    'Cambiar contraseña': 'Change password',
    'Cancelar': 'Cancel',
    'Categoría': 'Category',
    'Categorías': 'Categories',
    'Plomería': 'Plumbing',
    'Electricidad': 'Electrical work',
    'Limpieza': 'Cleaning',
    'Pintura': 'Painting',
    'Carpintería': 'Carpentry',
    'Jardinería': 'Gardening',
    'Cerrar sesión': 'Sign out',
    'Chat': 'Chat',
    'Ciudad de México': 'Mexico City',
    'Comparte tu ubicación actual con este contacto.':
        'Share your current location with this contact.',
    'Compartir': 'Share',
    'Compartir ubicación': 'Share location',
    'Conecta con los mejores profesionales de tu zona de forma rápida y segura.':
        'Connect with the best professionals in your area quickly and safely.',
    'Conecta con profesionales': 'Connect with professionals',
    'Conecta y trabaja': 'Connect and work',
    'Conectando personas que ofrecen servicios con quienes necesitan contratarlos. ':
        'Connecting service providers with people looking to hire them.',
    'Crea un perfil profesional, publica tus servicios y conecta con oportunidades reales.': 'Create a professional profile, publish your services, and connect with real opportunities.',
    'Configuración': 'Settings',
    'Comenzar': 'Get started',
    'Continuar': 'Continue',
    'Confirmar contraseña': 'Confirm password',
    'Continuar con Google': 'Continue with Google',
    'Contraseña': 'Password',
    'Contraseña creada exitosamente': 'Password created successfully',
    'Contraseña incorrecta': 'Incorrect password',
    'Correo electrónico': 'Email address',
    'Crea tu contraseña': 'Create your password',
    'Crea tu cuenta': 'Create your account',
    'Crear cuenta': 'Create account',
    'Cuenta': 'Account',
    'Cuenta creada. ¡Bienvenido!': 'Account created. Welcome!',
    'Código de autorización': 'Authorization code',
    'Código inválido': 'Invalid code',
    'Descripción': 'Description',
    'Editar': 'Edit',
    'Editar perfil': 'Edit profile',
    'Editar servicio': 'Edit service',
    'Ej: 123456': 'e.g. 123456',
    'El navegador no pudo iniciar el micrófono':
        'The browser could not start the microphone',
    'Imagen cargada': 'Image uploaded',
    'El precio mínimo no puede superar al máximo':
        'The minimum price cannot be greater than the maximum',
    'Eliminar': 'Delete',
    'Eliminar servicio': 'Delete service',
    'Eliminar para todos': 'Delete for everyone',
    '¿Eliminar mensaje para todos?': 'Delete message for everyone?',
    'El mensaje desaparecerá para ti y para la otra persona.':
        'The message will disappear for you and the other person.',
    'Encuentra el servicio que necesitas': 'Find the service you need',
    'Encuentra profesionales calificados o clientes ideales. Todo en un solo lugar.':
        'Find qualified professionals or ideal clients, all in one place.',
    'Entendido': 'Got it',
    'Enviar mensaje': 'Send message',
    'Enviar solicitud': 'Send request',
    'Enviar ubicación': 'Send location',
    'Error al cargar el perfil': 'Could not load profile',
    'Error al cargar mensajes': 'Could not load messages',
    'Error al cargar notificaciones': 'Could not load notifications',
    'Error al cargar portafolio': 'Could not load portfolio',
    'Error al cargar reseñas': 'Could not load reviews',
    'Error de conexión': 'Connection error',
    'Error en registro': 'Registration failed',
    'Error de conexión al enviar autorización':
        'Connection error while sending the verification code',
    'Escribe un comentario': 'Write a comment',
    'Escribe un mensaje para el proveedor': 'Write a message to the provider',
    'Escribe un mensaje...': 'Write a message...',
    'Escribir reseña': 'Write a review',
    'Esta nota de voz no tiene archivo': 'This voice message has no audio file',
    'Explora servicios y guarda tus favoritos':
        'Explore services and save your favorites',
    'Favoritos': 'Favorites',
    'Filtrar servicios': 'Filter services',
    'Filtros': 'Filters',
    'Foto': 'Photo',
    'La foto no se pudo cargar': 'The photo could not be loaded',
    '📷 Foto': '📷 Photo',
    '🎵 Nota de voz': '🎵 Voice message',
    'General': 'General',
    'Guardar cambios': 'Save changes',
    'Guardar contraseña': 'Save password',
    'Haz visibles tus habilidades': 'Showcase your skills',
    'Información personal': 'Personal information',
    'Ingresa tu nombre': 'Enter your name',
    'Ingresa un correo válido': 'Enter a valid email address',
    'Ingresá el código de autorización': 'Enter the verification code',
    'Ingresá el código de autorización que recibiste para continuar.':
        'Enter the verification code you received to continue.',
    'Inicia la conversación': 'Start the conversation',
    'Idioma': 'Language',
    'Inicia sesión para continuar': 'Sign in to continue',
    'Iniciar sesión': 'Sign in',
    'Inicio': 'Home',
    'Inicio cancelado': 'Sign-in cancelled',
    'Hoy': 'Today',
    'Las contraseñas no coinciden': 'Passwords do not match',
    'Las reseñas de tus servicios aparecerán aquí':
        'Reviews for your services will appear here',
    'Las solicitudes de servicio aparecerán aquí':
        'Service requests will appear here',
    'Limpiar filtros': 'Clear filters',
    'Los usuarios deben proporcionar información veraz y actualizada. '
            'Está prohibido el uso de la plataforma para actividades ilegales o fraudulentas.':
        'Users must provide accurate and up-to-date information. '
        'Using the platform for illegal or fraudulent activities is prohibited.',
    'Los usuarios son responsables de sus propios actos y acuerdos.':
        'Users are responsible for their own actions and agreements.',
    'Mejor calificados': 'Top rated',
    'Mensajes': 'Messages',
    'Mi perfil': 'My profile',
    'Mis servicios': 'My services',
    'Modo oscuro': 'Dark mode',
    'Mostrar contraseña': 'Show password',
    'Mínimo 6 caracteres': 'At least 6 characters',
    'Ocultar contraseña': 'Hide password',
    'La contraseña debe tener al menos 6 caracteres':
        'The password must contain at least 6 characters',
    'No has iniciado sesión': 'You are not signed in',
    'No hay una sesión autenticada': 'There is no authenticated session',
    'No hay usuario autenticado': 'There is no authenticated user',
    'No hay usuario autenticado para asociar la contraseña':
        'There is no authenticated user to link the password to',
    'No se encontraron resultados': 'No results found',
    'No se encontró el correo de la cuenta actual':
        'The current account email could not be found',
    'No se pudieron cargar favoritos': 'Could not load favorites',
    'No se pudieron cargar solicitudes': 'Could not load requests',
    'No se pudo abrir el chat': 'Could not open chat',
    'No se pudo enviar el correo de autorización':
        'Could not send the verification email',
    'No se pudo enviar el enlace de recuperación':
        'Could not send the password reset link',
    'No se pudo enviar la solicitud': 'Could not send the request',
    'No se pudo publicar la reseña': 'Could not publish the review',
    'No existe una cuenta con ese correo':
        'There is no account associated with this email',
    'No tienes conversaciones': 'You have no conversations',
    'No tienes favoritos guardados': 'You have no saved favorites',
    'No tienes notificaciones': 'You have no notifications',
    'No tienes proyectos en tu portafolio': 'You have no portfolio projects',
    'No tienes servicios publicados': 'You have no published services',
    'No tienes solicitudes pendientes': 'You have no pending requests',
    'Nombre': 'Name',
    'Nombre completo': 'Full name',
    'Nos reservamos el derecho de modificar estos términos en cualquier momento. '
            'Te notificaremos sobre cambios importantes mediante la aplicación.':
        'We reserve the right to modify these terms at any time. '
        'We will notify you about important changes through the app.',
    'Nota de voz': 'Voice message',
    'Notificaciones': 'Notifications',
    'Notificaciones, privacidad, tema': 'Notifications, privacy, theme',
    'Nuestra misión es facilitar el encuentro entre profesionales, trabajadores independientes '
            'y usuarios que buscan servicios de calidad.':
        'Our mission is to connect professionals and freelancers with people looking for quality services.',
    'Para problemas de acceso, verifica tu conexión y que el correo esté habilitado en Firebase. '
            'Si no llegan notificaciones, permite los avisos en el navegador o dispositivo.':
        'For sign-in issues, check your connection and make sure email sign-in is enabled in Firebase. '
        'If notifications do not arrive, allow them in your browser or device settings.',
    'Perfil': 'Profile',
    'Perfil actualizado': 'Profile updated',
    'Permiso de ubicación denegado': 'Location permission denied',
    'Portafolio': 'Portfolio',
    'Precio máximo': 'Maximum price',
    'Precio mínimo': 'Minimum price',
    'Precio: mayor a menor': 'Price: high to low',
    'Precio: menor a mayor': 'Price: low to high',
    'Precio (ej: \$35/hr)': 'Price (e.g. \$35/hr)',
    'Publica tu primer servicio para comenzar':
        'Publish your first service to get started',
    'Publicar': 'Publish',
    'Publicar servicio': 'Publish service',
    'Red de Trabajo actúa como intermediario y no garantiza la calidad de los servicios. '
            'Los usuarios son responsables de sus propios actos y acuerdos.':
        'Red de Trabajo acts as an intermediary and does not guarantee service quality. '
        'Users are responsible for their own actions and agreements.',
    'Reenviar correo': 'Resend email',
    'Regístrate con cualquier correo electrónico':
        'Create an account with any email address',
    'Relevancia': 'Relevance',
    'Reseñas': 'Reviews',
    'Reseña publicada': 'Review published',
    'Saltar': 'Skip',
    'Se requiere permiso para grabar audio':
        'Microphone permission is required to record audio',
    'Servicio actualizado exitosamente': 'Service updated successfully',
    'Servicio publicado exitosamente': 'Service published successfully',
    'Servicios': 'Services',
    'Servicios destacados': 'Featured services',
    'Servicios recientes': 'Recent services',
    'Sesión': 'Session',
    'Solicitar servicio': 'Request service',
    'Solicitud enviada': 'Request sent',
    'Solicitudes': 'Requests',
    'Título del servicio': 'Service title',
    'Ubicación': 'Location',
    'Ubicación compartida': 'Location shared',
    'Ver detalle': 'View details',
    'Ver todo': 'See all',
    'Verifica tu acceso': 'Verify your access',
    'Verificar código': 'Verify code',
    'Versión 1.0.0': 'Version 1.0.0',
    '¡Hola!': 'Hello!',
    '¡Bienvenido!': 'Welcome!',
    '¿No tienes cuenta? Regístrate': 'No account? Sign up',
    '¿Qué servicio necesitas hoy?': 'What service do you need today?',
    '¿Ya tienes cuenta? Inicia sesión': 'Already have an account? Sign in',
    'Privacidad': 'Privacy',
    'Red de Trabajo': 'Red de Trabajo',
    'Términos y condiciones': 'Terms and conditions',
    'Todos': 'All',
    'Usuario no encontrado': 'User not found',
    'El correo ya está registrado': 'This email is already registered',
    'La contraseña es muy débil': 'The password is too weak',
    'Correo electrónico inválido': 'Invalid email address',
    'Cuenta deshabilitada': 'Account disabled',
    'Demasiados intentos, intenta más tarde':
        'Too many attempts. Try again later.',
    'Activa el acceso con correo y contraseña en Firebase Console':
        'Enable email and password sign-in in Firebase Console',
    'No hay conexión. Revisa tu conexión a Internet':
        'No connection. Check your internet connection.',
    'Credenciales inválidas': 'Invalid credentials',
    'Esta cuenta existe con otro método de acceso':
        'This account uses a different sign-in method',
    'Requiere login reciente': 'Please sign in again to continue',
    'Usuario': 'User',
    'Verificado': 'Verified',
    'Error de autenticación': 'Authentication error',
    'Error en autenticación con Google': 'Google sign-in failed',
    'Error en autenticación con correo': 'Email sign-in failed',
    'Firebase no devolvió el usuario creado':
        'Firebase did not return the created user',
    'Firebase no pudo generar el token de acceso':
        'Firebase could not generate an access token',
    'Firebase no pudo generar el token de notificaciones':
        'Firebase could not generate a notification token',
    'La API devolvió datos de usuario inválidos':
        'The API returned invalid user data',
    'El UID no coincide con el usuario autenticado':
        'The UID does not match the authenticated user',
    'El chat no está conectado': 'Chat is not connected',
    'Servicio no encontrado': 'Service not found',
    'Servicio': 'Service',
    'Las notificaciones push no están disponibles en esta plataforma':
        'Push notifications are not available on this platform',
    'Permite las notificaciones en la configuración del dispositivo':
        'Allow notifications in your device settings',
    'La API rechazó el token de Firebase. Verifica que el frontend y el backend usan el proyecto Firebase red-de-trabajo.': 'The API rejected the Firebase token. Make sure the frontend and backend use the red-de-trabajo Firebase project.',
    'Te enviamos un enlace para cambiar la contraseña':
        'We sent you a password reset link',
    'Todavía no hay un canal oficial de soporte configurado. Para problemas de acceso, verifica tu conexión y que el correo esté habilitado en Firebase. Si no llegan notificaciones, permite los avisos en el navegador o dispositivo.': 'An official support channel has not been set up yet. For sign-in issues, check your connection and make sure email sign-in is enabled in Firebase. If notifications do not arrive, allow them in your browser or device settings.',
    'La política de privacidad oficial todavía no está disponible. Se publicará aquí cuando haya sido aprobada.': 'The official privacy policy is not available yet. It will be published here once approved.',
    '1. Uso de la plataforma': '1. Platform use',
    '2. Responsabilidades': '2. Responsibilities',
    '3. Privacidad': '3. Privacy',
    '4. Modificaciones': '4. Changes',
    'English': 'English',
    'Español': 'Spanish',
    'Nueva solicitud de servicio': 'New service request',
    'Nueva reseña': 'New review',
    'Te compartió su ubicación': 'Shared their location with you',
    'Te envió una foto': 'Sent you a photo',
    'pending': 'Pending',
    'accepted': 'Accepted',
    'rejected': 'Declined',
    'completed': 'Completed',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any(
    (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsContext on BuildContext {
  String tr(String source) => AppLocalizations.of(this).translate(source);
}

extension AppLocalizationsString on String {
  String get tr => AppLocalizations.translateText(this);
}

class LocalizedText extends StatelessWidget {
  const LocalizedText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : textSpan = const TextSpan(),
       _usesRichText = false;

  const LocalizedText.rich(
    this.textSpan, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : data = '',
       _usesRichText = true;

  final String data;
  final InlineSpan textSpan;
  final bool _usesRichText;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (_usesRichText) {
      return Text.rich(
        _translateSpan(textSpan, localizations),
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaler: textScaler,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
      );
    }

    return Text(
      localizations.translate(data),
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }

  InlineSpan _translateSpan(InlineSpan span, AppLocalizations localizations) {
    if (span is! TextSpan) return span;
    return TextSpan(
      text: span.text == null ? null : localizations.translate(span.text!),
      children: span.children
          ?.map((child) => _translateSpan(child, localizations))
          .toList(),
      style: span.style,
      recognizer: span.recognizer,
      mouseCursor: span.mouseCursor,
      onEnter: span.onEnter,
      onExit: span.onExit,
      semanticsLabel: span.semanticsLabel,
      locale: span.locale,
      spellOut: span.spellOut,
    );
  }
}
