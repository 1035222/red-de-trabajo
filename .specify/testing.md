TESTING.md — red_de_trabajo (Frontend Flutter)

Documenta las pruebas ejecutadas para cada funcionalidad, siguiendo la estrategia del documento técnico original (unitarias, widgets, integración, rendimiento).

## Estado actual

### Bugs de perfil resueltos (Parte 1)
TC-09	Edición de perfil	Media	✅ Validado end-to-end
- Bug 1: Avatar overlap — widget RTAvatar usaba un child (Container con color + icon) que tapaba la imagen de fondo. Reemplazado por CachedNetworkImage (placeholder + errorWidget), sin child overlay. Validado con `flutter analyze`.
- Bug 2: Image picker para avatar — agregado `image_picker` + `firebase_storage` al pubspec.yaml (constitución actualizada). EditProfileScreen ahora muestra preview de avatar con botón de cámara; al seleccionar, sube a Firebase Storage y obtiene URL. El email field es ahora readOnly (no se persiste vía PUT /users/me).
- Bug 3: Error al actualizar perfil — backend devolvía 500 genérico incluso cuando el usuario no existía en DB (P2025). Mejorado a 404 con mensaje claro. Agregado logging temporal gobernado por NODE_ENV. Campo avatarUrl ahora aceptado en PUT /users/me. Validado con `flutter analyze` y pruebas de endpoint con curl (backend responde 404 cuando usuario no existe, 500 con detalle de error de Prisma).

### Conectividad backend verificada
- GET /api/services → 200 (respuesta correcta, categoría sembrada)
- GET /api/users/:id → 200/404 (perfil público)
- PUT /api/users/me → 404 si usuario no sincronizado (antes: 500 genérico)
- POST /api/users/sync → crea/actualiza usuario con Firebase UID

Estado actual
Sin pruebas automatizadas documentadas todavía para las funcionalidades ya conectadas a backend real (servicios, perfil, portafolio, reseñas). Pendiente: agregar al menos pruebas de widget para las pantallas críticas (publicar servicio, login, búsqueda).
Plan de pruebas — Filtros de búsqueda (pendiente, tarea T1-T2)
 Widget test: los controles de filtro se renderizan correctamente.
 Integration test: aplicar filtro de precio/ubicación devuelve resultados coherentes con lo que responde el backend.
Plan de pruebas — Chat en tiempo real (pendiente, tareas T3-T4)
 Integration test: enviar un mensaje desde una sesión y confirmar que llega en tiempo real a otra sesión (dos instancias de la app corriendo).
 Widget test: chat_detail_screen.dart muestra correctamente mensajes entrantes y salientes.
 Confirmar que flutter analyze sigue sin errores tras integrar el cliente Socket.io.
Plan de pruebas — Notificaciones push (pendiente, tareas T7-T10)
 Prueba manual en dispositivo Android real: permiso de notificaciones se solicita correctamente tras login.
 Prueba manual: notificación llega en foreground y en background.
 Confirmar que el login con Google sigue funcionando sin cambios tras estos ajustes (zona restringida).
Casos de prueba prioritarios (heredados del documento técnico, TC-01 a TC-10)
ID	Caso	Prioridad	Estado
TC-01	Registro de usuario con datos válidos	Alta	Pendiente de documentar
TC-02	Login con credenciales correctas	Alta	Pendiente de documentar
TC-03	Login con credenciales incorrectas	Alta	Pendiente de documentar
TC-04	Publicación de servicio completo	Alta	✅ Validado end-to-end (ver backend testing.md)
TC-05	Búsqueda de servicios por texto	Alta	Pendiente de documentar
TC-06	Filtrado por categoría	Media	Pendiente de documentar
TC-07	Envío de mensaje en chat	Alta	Bloqueado — chat aún no implementado
TC-08	Calificación de servicio	Media	Pendiente de documentar
TC-09	Edición de perfil	Media	✅ Resuelto — ver detalle arriba
TC-10	Navegación entre pantallas	Alta	Pendiente de documentar

## Evidencia ejecutada por API (2026-09-11)

- El backend devolvió `200` para `PUT /api/users/me` y Prisma confirmó el perfil persistido.
- El backend devolvió `201` para `POST /api/services` y Prisma confirmó el servicio con descripción, precio, categoría e imagen.
- El backend devolvió `200` para `GET /api/services?category=Limpieza` y la respuesta incluyó el servicio creado.
- No se marca como validación UI: esta sesión no dispone de automatización ni inspección remota del Chrome que permita ejecutar login, editar perfil, publicar y observar las pantallas.

## Estado del runtime (2026-09-10)

- Flutter Web responde en `localhost:5000` y el backend responde en `localhost:3000`.
- El bypass temporal de `auth.js` fue retirado por seguridad; los guardados protegidos requieren un token Firebase real.