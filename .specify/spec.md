# SPEC — Red de Trabajo (Frontend Flutter)

Estado del producto y alcance del cliente Flutter. El mapa de pantallas y archivos por funcionalidad está en el [README](../README.md); las decisiones técnicas están en [plan.md](./plan.md).

## Producto

Red de Trabajo conecta personas que ofrecen servicios con clientes. Una cuenta puede contratar y ofrecer servicios.

## Funcionalidades implementadas

- Autenticación con Google o correo/contraseña usando Firebase Auth; las cuentas se sincronizan con el backend usando el UID de Firebase.
- Inicio, catálogo de servicios destacados y búsqueda por texto, categoría, precio y ubicación.
- Perfiles públicos y propios, edición de biografía/ubicación/foto, portafolios y reseñas recibidas.
- Publicación, edición, eliminación y consulta de servicios.
- Detalle de servicio, solicitudes, favoritos y compartir.
- Chat REST/Socket.IO: mensajes de texto, imagen, audio y ubicación; el autor puede eliminar sus mensajes para los dos participantes.
- Notificaciones persistidas y push FCM; ajustes de preferencia del usuario, contador, sonido móvil y navegación al destino en chats, solicitudes, reseñas/servicios y favoritos.
- Tema e idioma configurables.

## Criterios de experiencia y datos

- Las operaciones autenticadas envían el token Firebase a la API; el cliente no suplanta identidad.
- La reseña recibida y sus métricas se atribuyen al proveedor del servicio reseñado, no a quien escribió la reseña.
- Desactivar notificaciones suprime su presentación en la app y revoca el token registrado en la API.
- Los mensajes se persisten una sola vez por REST; Socket.IO distribuye mensajes de otros participantes.
- Las notificaciones antiguas que no tengan metadatos de navegación continúan mostrándose.

## Restricciones

- No alterar Google Sign-In, Firebase Auth, la configuración Firebase ni el envío del token como efecto colateral de otros cambios.
- La URL para móvil está incorporada en la configuración al compilar. Un cambio de Wi-Fi/host que haga inaccesible esa dirección requiere reconfigurar o alojar la API y generar una nueva compilación.
- En desarrollo, la API sirve archivos subidos localmente; producción requiere un host accesible y persistente para la API y sus archivos.
- Pagos, reservas automáticas, verificación documental e integraciones sociales no forman parte del alcance actual.

## Validación pendiente

`flutter analyze`, pruebas automatizadas y compilación APK se han ejecutado. Sigue pendiente validar en dispositivo real la entrega push con token Firebase, el sonido y la apertura del destino al tocar la notificación; ver [testing.md](./testing.md).
