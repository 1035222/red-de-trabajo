PLAN.md — red_de_trabajo (Frontend Flutter)

Traduce spec.md a decisiones técnicas del lado Flutter.

Arquitectura actual (ya construida)
Estructura: lib/theme, lib/models, lib/repositories, lib/widgets, lib/screens.
Patrón Repository: abstrae la fuente de datos (mock vs API real) sin tocar la UI.
Repositorios ya conectados a backend real: servicios, perfil, portafolio, reseñas.
Repositorio de chat sigue en mock_repositories.dart.
Autenticación: Firebase Auth admite Google Sign-In y creación/inicio de sesión con correo y contraseña. El registro crea la cuenta y su nombre en Firebase, sincroniza el perfil con `POST /api/users/sync` y guarda la sesión local con SessionService. Las cuentas Google existentes pueden asociar una contraseña con `linkWithCredential`. (Zona restringida — requiere autorización explícita.)
Plan para Chat en tiempo real (Socket.io)
Agregar paquete socket_io_client (o similar) al pubspec.yaml.
Reemplazar mock_repositories.dart (parte de chat) por chat_repository.dart real que se conecte al servidor Socket.io del backend.
UI ya existente (chat_list_screen.dart, chat_detail_screen.dart) — verificar si necesita ajustes para manejar estados de conexión/reconexión y mensajes en tiempo real (stream en vez de lista estática).
Las burbujas de audio entrantes deben usar contraste legible sobre el fondo claro de la conversación.
Las fotos se cargan mediante el endpoint autenticado `/api/uploads` y su URL se persiste en el campo existente `text` de un mensaje Socket.io de tipo `image`; el cliente muestra la misma foto para mensajes históricos y recibidos en tiempo real. El campo `text` contiene URL para mensajes tipo imagen, así que no se requiere una migración de mensajes.
Plan para Notificaciones push (FCM)
El usuario activa permisos desde Configuración. El frontend registra y revoca tokens por `POST/PATCH /api/notifications/tokens`, muestra avisos al recibirlos en foreground y usa el service worker Firebase en web. El backend guarda tokens por instalación, persiste notificaciones y envía FCM para mensajes, solicitudes y reseñas. En web, `FCM_VAPID_KEY` debe suministrarse con `--dart-define`.
La campana consulta la bandeja y muestra el total de notificaciones no leídas; al volver de la bandeja y periódicamente, el contador se actualiza.
FCM web utiliza la clave VAPID predeterminada del SDK Firebase si no se proporciona una propia. `FCM_VAPID_KEY` es opcional para proyectos que necesiten usar una clave personalizada.
La API persiste los datos de destino (`type`, `conversationId`, `serviceId`, `requestId`) junto con cada notificación. La app usa esos metadatos para enrutar avisos push abiertos y elementos de la bandeja a la pantalla correcta; las notificaciones antiguas sin metadatos no fallan al abrirse.
El contador consulta `GET /api/notifications/unread-count` para incluir todas las no leídas (no solo el límite de la bandeja), y se refresca al recibir FCM, volver a primer plano y periódicamente.

Plan para eliminar mensajes
El autor puede eliminar sus propios mensajes para ambos participantes mediante un endpoint REST autenticado. La API verifica la membresía de la conversación y autoría, elimina el mensaje en una transacción, actualiza el mensaje más reciente y transmite el cambio por Socket.io a las sesiones abiertas.
Plan para filtros de ubicación y precio
Revisar search_screen.dart: confirmar si ya existe UI de filtro por precio/ubicación.
Si no existe, agregar controles de filtro y conectar los query params correspondientes en la llamada al repositorio de servicios (dependiente de que el backend los soporte, ver backend tasks T1-T2).
La UI usa REST para persistir texto, audio y ubicación una sola vez; Socket.io solo notifica mensajes creados por otros clientes.

Plan para interacciones de servicios
Agregar endpoints REST protegidos para reseñas, solicitudes y favoritos. Compartir usa la URL del detalle del servicio.

Riesgos identificados
Cambiar el repositorio de chat de mock a real puede requerir ajustar el manejo de estado en las pantallas de chat (de lista estática a stream reactivo).
Pedir permiso de notificaciones push en Android 13+ requiere manejo explícito de permisos en tiempo de ejecución — validar en dispositivo real, no solo Flutter Web.