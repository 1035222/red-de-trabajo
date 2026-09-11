# Changelog — red_de_trabajo (Frontend Flutter + Backend API)

Una entrada por cada bloque cerrado. Formato: fecha, tipo, descripción.

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
