# Red de Trabajo — aplicación Flutter

Marketplace móvil y web que conecta clientes con personas que ofrecen servicios. Este repositorio contiene el frontend. La API Node.js/Express y Prisma vive en el repositorio hermano `red-de-trabajo-api`.

## Arquitectura

La app usa Material, Firebase Auth para identidad, REST para persistencia, Socket.IO para mensajería en tiempo real y repositorios para separar las pantallas de sus fuentes de datos.

```text
lib/
  config/       URL del backend
  l10n/         textos y localización
  models/       modelos y serialización JSON
  repositories/ interfaces y adaptadores API/mock
  screens/      pantallas por flujo
  services/     API, sesión, Firebase, sockets, preferencias y notificaciones
  theme/        tema, colores y estilos
  utils/        helpers
  widgets/      componentes reutilizables
```

`main.dart` inicializa Firebase, notificaciones y preferencias; `RepositoryProvider.useMock` está desactivado para ejecución normal. Las pantallas consumen interfaces en `lib/repositories/`; las implementaciones reales hacen solicitudes con `ApiService` y `ApiConfig`.

## Índice de funcionalidades

| Funcionalidad | Pantalla / entrada | Lógica frontend | API / persistencia |
|---|---|---|---|
| Inicio y catálogo | `lib/screens/home_screen.dart` | `lib/repositories/api_service_repository.dart` | `GET /api/services` |
| Iniciar sesión con Google | `lib/screens/login_screen.dart` | `lib/services/firebase_auth_service.dart`, `lib/services/google_sign_in_service.dart` | Firebase Auth; sincronización `POST /api/users/sync` |
| Registro e inicio con correo | `lib/screens/register_screen.dart`, `lib/screens/email_auth_screen.dart`, `lib/screens/create_password_screen.dart` | `lib/services/firebase_auth_service.dart`, `lib/repositories/api_auth_repository.dart` | Firebase Auth; API users |
| Mi perfil, perfil público y edición | `lib/screens/my_profile_screen.dart`, `lib/screens/profile_screen.dart`, `lib/screens/edit_profile_screen.dart` | `lib/repositories/api_profile_repository.dart` | `/api/users` y `/api/portfolio` |
| Publicar, editar y administrar servicios | `lib/screens/publish_screen.dart`, `lib/screens/edit_service_screen.dart`, `lib/screens/my_services_screen.dart` | `lib/repositories/api_service_repository.dart` | CRUD `/api/services` |
| Buscar y filtrar | `lib/screens/search_screen.dart` | `lib/repositories/api_service_repository.dart` | `GET /api/services` con texto, categoría, precio y ubicación |
| Detalle, favoritos y solicitudes | `lib/screens/service_detail_screen.dart`, `lib/screens/favorites_screen.dart`, `lib/screens/requests_screen.dart` | `lib/repositories/api_service_repository.dart` y repositorios de perfil/servicios | `/api/favorites`, `/api/services/:id/requests`, `/api/requests` |
| Portafolio | `lib/screens/portfolio_screen.dart` | `lib/repositories/api_profile_repository.dart` | `/api/portfolio` |
| Reseñas y calificaciones | `lib/screens/reviews_screen.dart`, `lib/screens/service_detail_screen.dart` | `lib/repositories/api_profile_repository.dart` | `/api/reviews`; las reseñas recibidas se calculan para el proveedor del servicio |
| Chat de texto, imagen, audio y ubicación | `lib/screens/chat_list_screen.dart`, `lib/screens/chat_detail_screen.dart` | `lib/repositories/api_chat_repository.dart`, `lib/services/socket_service.dart` | REST `/api/chat`; Socket.IO para mensajes en vivo; archivos en `/api/uploads` |
| Eliminar mensajes propios | `lib/screens/chat_detail_screen.dart` | `lib/repositories/api_chat_repository.dart` | `DELETE /api/chat/conversations/:id/messages/:messageId` |
| Notificaciones, campana y preferencias | `lib/screens/notifications_screen.dart`, `lib/screens/settings_screen.dart`, `lib/screens/home_screen.dart` | `lib/services/push_notification_service.dart`, `lib/services/app_navigation.dart`, `lib/repositories/api_notification_repository.dart` | `/api/notifications`; FCM. Móvil usa sonido en foreground y background; web muestra aviso visual |
| Rutas y preferencias de app | `lib/routes.dart`, `lib/services/app_preferences.dart` | `lib/app.dart` | navegación y preferencias locales |
| URL del backend | — | `lib/config/api_config.dart` | web usa `localhost`; Android/iOS usa la IP LAN configurada |

El backend que implementa las rutas está en el repositorio separado; su `README.md` contiene el mapa de controladores y endpoints.

## Configuración

La dirección se define en `lib/config/api_config.dart`. En web se usa `http://localhost:3000`; en dispositivos móviles la app usa la IP LAN de la máquina que ejecuta la API. Cambiar de red o entregar la APK a otra persona no cambia esa IP compilada: la API debe ser accesible desde el dispositivo o se debe cambiar la configuración y compilar de nuevo. Android permite HTTP de desarrollo mediante `android:usesCleartextTraffic` en `android/app/src/main/AndroidManifest.xml`.

Para FCM web se puede proporcionar `FCM_VAPID_KEY` con `--dart-define`; si no se proporciona, se usa la configuración predeterminada de Firebase cuando esté disponible.

## Comandos

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
flutter run -d <device>
flutter build apk --release
```

## Documentación de producto y trabajo

- `.specify/spec.md`: alcance y estado funcional.
- `.specify/plan.md`: decisiones técnicas vigentes.
- `.specify/tasks.md`: tareas e historial de estado.
- `.specify/testing.md`: pruebas ejecutadas y pendientes.
- `.specify/changelog.md`: cambios funcionales.
- `AGENTS.md`: instrucciones de trabajo y restricciones.

El chat y las notificaciones están implementados; la validación real de permisos, entrega push, sonido y navegación en dispositivo físico sigue requiriendo prueba en un teléfono. Consulta `.specify/testing.md` para el estado de validación.
