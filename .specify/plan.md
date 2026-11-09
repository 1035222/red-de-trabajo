# PLAN — red_de_trabajo (Frontend Flutter)

Decisiones técnicas vigentes. Para localizar una función en pantalla, repositorio, servicio y API, consulta el índice del [README](../README.md).

## Capas

- `lib/screens/`: presentación y acciones del usuario.
- `lib/repositories/`: contratos y adaptadores API/mock. `RepositoryProvider.useMock` es `false` en `main.dart`.
- `lib/services/api_service.dart`: transporte HTTP y manejo de errores de red.
- `lib/services/socket_service.dart`: conexión autenticada Socket.IO.
- `lib/services/session_service.dart`: persistencia local de sesión.
- `lib/config/api_config.dart`: origen del backend (web en localhost; móvil con dirección configurada).
- `lib/models/`: modelos y serialización.

## Decisiones de integración

### Identidad

Firebase Auth administra identidad. `FirebaseAuthService` inicia sesión, obtiene el ID token y sincroniza el usuario mediante `POST /api/users/sync`. No editar esta ruta de autenticación fuera de solicitudes explícitas.

### Servicios, perfiles y reseñas

Las pantallas usan repositorios API; perfiles, servicios, portafolio, reseñas, categorías y solicitudes se persisten por REST. Los archivos se cargan a `POST /api/uploads`; la API devuelve URL, que el modelo correspondiente conserva. El backend determina las reseñas recibidas por el proveedor de cada servicio.

### Chat

REST recupera conversaciones e historial y persiste mensajes enviados. Socket.IO transmite mensajes creados por otros clientes. Fotos y audios se suben a `/api/uploads`; audio y ubicación usan modelos/campos de mensaje apropiados. La API autoriza al participante antes de ver o eliminar mensajes; borrar propio sincroniza la eliminación en tiempo real.

### Notificaciones

`PushNotificationService` gestiona FCM, permiso, tokens, preferencia persistida y notificaciones locales sonoras en foreground móvil. En web se conserva el aviso visual. El backend configura sonido para Android/APNs. `AppNavigation` resuelve destinos desde los metadatos FCM/locales y `NotificationsScreen` usa los mismos destinos desde la bandeja. Android usa el canal `red_de_trabajo_notifications`; mantener el ID alineado con el manifiesto y backend.

### Preferencias y navegación

`AppPreferences` guarda preferencias de idioma/tema. `AppRoutes` declara las rutas principales; `AppNavigation` recibe eventos de notificación cuando se trata de abrir un destino desde FCM.

## Configuración de ejecución

- Web: `http://localhost:3000` para API.
- Móvil: dirección LAN configurada en `ApiConfig`; debe ser accesible desde el dispositivo y permitida por el firewall.
- Si cambia la dirección del servidor móvil, actualizarla y volver a compilar/instalar la app.
- Web FCM acepta `FCM_VAPID_KEY` por `--dart-define` cuando el proyecto requiere clave personalizada; la clave predeterminada de Firebase puede usarse si está configurada.

## Calidad y limitaciones

Ejecutar `flutter analyze` y `flutter test`; para cambios móviles generar APK y validar en dispositivo. El entorno de esta actualización no tiene dispositivo Android conectado, por lo que la entrega push, sonido, permisos y navegación deben confirmarse en un móvil con Firebase configurado.
