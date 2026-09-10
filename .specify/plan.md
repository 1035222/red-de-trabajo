PLAN.md — red_de_trabajo (Frontend Flutter)

Traduce spec.md a decisiones técnicas del lado Flutter.

Arquitectura actual (ya construida)
Estructura: lib/theme, lib/models, lib/repositories, lib/widgets, lib/screens.
Patrón Repository: abstrae la fuente de datos (mock vs API real) sin tocar la UI.
Repositorios ya conectados a backend real: servicios, perfil, portafolio, reseñas.
Repositorio de chat sigue en mock_repositories.dart.
Login: Firebase Auth, Google Sign-In primero + linkWithCredential para email/contraseña, SessionService para sesión local. (Zona restringida — no tocar sin autorización.)
Plan para Chat en tiempo real (Socket.io)
Agregar paquete socket_io_client (o similar) al pubspec.yaml.
Reemplazar mock_repositories.dart (parte de chat) por chat_repository.dart real que se conecte al servidor Socket.io del backend.
UI ya existente (chat_list_screen.dart, chat_detail_screen.dart) — verificar si necesita ajustes para manejar estados de conexión/reconexión y mensajes en tiempo real (stream en vez de lista estática).
Plan para Notificaciones push (FCM)
Agregar firebase_messaging al pubspec.yaml (ya se usa firebase_core/firebase_auth).
Solicitar permiso de notificaciones en el flujo post-login.
Obtener el fcmToken del dispositivo y enviarlo en la llamada existente a POST /api/users/sync (requiere que el backend acepte el campo — ver backend tasks T7-T8).
Manejar notificaciones en foreground/background/terminated según los ejemplos oficiales del paquete firebase_messaging.
Plan para filtros de ubicación y precio
Revisar search_screen.dart: confirmar si ya existe UI de filtro por precio/ubicación.
Si no existe, agregar controles de filtro y conectar los query params correspondientes en la llamada al repositorio de servicios (dependiente de que el backend los soporte, ver backend tasks T1-T2).
Riesgos identificados
Cambiar el repositorio de chat de mock a real puede requerir ajustar el manejo de estado en las pantallas de chat (de lista estática a stream reactivo).
Pedir permiso de notificaciones push en Android 13+ requiere manejo explícito de permisos en tiempo de ejecución — validar en dispositivo real, no solo Flutter Web.