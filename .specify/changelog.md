# Changelog — red_de_trabajo (Frontend Flutter + Backend API)

Una entrada por cada bloque cerrado. Formato: fecha, tipo, descripción.

## 2026-10-31 — fix: sincroniza cuentas Google y activa notificaciones

- El acceso con Google ya no obliga a crear una contraseña antes de entrar; el perfil se sincroniza con el backend antes de habilitar la sesión.
- Los errores de sincronización ya no producen una sesión local incompleta. El backend toma UID y correo del token verificado.
- Se añadió FCM con gestión de permisos/tokens y avisos para mensajes, solicitudes y reseñas; la bandeja permite actualizar y marcar notificaciones como leídas.
- Se redujo el control de grabación de audio y se ajustó el contenido del temporizador para evitar desbordes.

## 2026-10-31 — fix: personaliza bienvenida y corrige avisos

- El inicio muestra el nombre guardado en la sesión y la campana indica notificaciones pendientes, actualizando el conteo periódicamente y al regresar de la bandeja.
- Se mejoró el contraste de los controles de audio para mensajes recibidos.
- En web, se permite activar FCM con la clave VAPID predeterminada del SDK; `FCM_VAPID_KEY` queda opcional para proyectos con una clave propia.

## 2026-10-31 — fix: corrige error 500 en bandeja de notificaciones

- La base MySQL local no tenía la columna `notification.metadata`, que Prisma consulta como `Notification.data`; se añadió la columna JSON nullable y se reinició la API.

## 2026-10-31 — feat: envía fotos y navega desde notificaciones

- El chat permite seleccionar una foto, cargarla al backend autenticado y enviarla como mensaje Socket.io; las fotos se muestran en el historial y se pueden ampliar.
- Al tocar una notificación push, foreground o de la bandeja, se abre el chat, las solicitudes o el servicio relacionado con la reseña.
- La API persiste los metadatos de destino en `notification.metadata`; el despliegue requiere aplicar el esquema Prisma actualizado.

## 2026-10-31 — feat: actualiza contador y elimina mensajes

- La campana consulta el total real de notificaciones no leídas y actualiza el contador al recibir FCM, regresar a primer plano y periódicamente.
- El autor puede eliminar sus propios mensajes para todos; la API verifica autoría, actualiza el mensaje más reciente y sincroniza la eliminación en tiempo real.

## 2026-10-31 — feat: agrega registro con correo y contraseña en Firebase

- Se habilitó el formulario para crear cuentas Firebase con nombre, correo y contraseña, validación de campos y manejo de errores de Firebase.
- El perfil nuevo se sincroniza con la API y la sesión queda guardada localmente; si falla la sincronización, se informa al usuario y se conserva la sesión Firebase.
- Se agregó el acceso al registro desde el login. Google Sign-In y el enlace de contraseña para cuentas Google permanecen sin cambios.

## 2026-09-10 — fix: corrige bugs de perfil (Parte 1)

## 2026-09-10 — validación: perfil, publicación y búsqueda

- Se confirmó por API y Prisma la persistencia del perfil de prueba y de un servicio publicado.
- Se confirmó que la búsqueda por categoría devuelve el servicio persistido.
- Se retiró el bypass temporal de `auth.js`; no se modificó el flujo Google/Firebase.
- La prueba de UI autenticada requiere una sesión Firebase válida disponible en el entorno.

### Frontend
- **Avatar overlap**: El widget `RTAvatar` (`lib/widgets/avatar.dart`) mostraba un `CircleAvatar` con un `child` (Container coloreado + ícono de persona) que tapaba la imagen de fondo. Reemplazado por `CachedNetworkImage` con placeholder y manejo de errores. El avatar ahora se muestra sin superposición.
- **Image picker para avatar**: Agregado `image_picker` ^1.0.0 y `firebase_storage` ^13.5.0 a `pubspec.yaml` (constitución actualizada). `EditProfileScreen` ahora muestra preview de avatar con botón de cámara; al seleccionar una imagen se sube a Firebase Storage y se obtiene la URL de descarga. El campo de email se marcó como `readOnly` (no se persiste vía `PUT /users/me`).
- **Fallback 'user_1' eliminado**: `ProfileScreen` y `MyProfileScreen` ya no usan `userId = session?.user?.id ?? 'user_1'`. Cuando no hay sesión válida, se muestra explícitamente "No has iniciado sesión" en lugar de cargar datos de un usuario falso.
- **Form validation**: `EditProfileScreen` ahora usa `Form` + `GlobalKey<FormState>` con `validate()` antes de guardar. Los validators declarativos ahora se aplican efectivamente.
- **avatarUrl en updatePerfil**: `ApiProfileRepository.updateUserProfile` ahora incluye `avatarUrl` en el cuerpo de `PUT /users/me`.

### Backend (`red-de-trabajo-api`)
- **Error handling en updateProfile**: El controlador `profileController.js` ahora devuelve 404 cuando el usuario no existe en la base de datos (antes devolvía 500 genérico). Agregado `select` para limitar campos devueltos.
- **Campo avatarUrl**: `updateProfile` ahora acepta `avatarUrl` en el body del request y lo persiste.
- **Logging temporal**: Agregado logging de diagnóstico gobernado por `NODE_ENV` (`[DEBUG updateProfile]`) para capturar userId, body recibido, resultado exitoso y errores con código Prisma.

### Zonas restringidas
- **Auth NO tocado**: `main.dart`, `firebase_options.dart`, `session_service.dart`, `firebase_auth_service.dart`, `login_screen.dart`, y todos los archivos relacionados con Google Sign-In / Firebase Auth permanecen sin cambios.
