TASKS.md — red_de_trabajo (Frontend Flutter)

Tareas atómicas derivadas de plan.md. La extensión de registro con correo y contraseña se realiza con autorización explícita.

Estado consolidado: consultar cada sección y `.specify/testing.md` para distinguir implementación de pruebas end-to-end.

Filtros de búsqueda
 [x] T1: El filtro por categoría/texto ya existía en la UI y el backend responde con resultados reales. La falla real estaba en el backend: el query parameter `featured` era ignorado y los filtros de precio/ubicación no estaban implementados.
 [x] T2: Se corrigió la capa de servicios para que respete `featured`, `minPrice`, `maxPrice` y `location` con validación real en MySQL/Prisma.
Chat en tiempo real
 [x] T3: La dependencia `socket_io_client` ya está instalada y conectada desde el frontend.
 [x] T4: `RepositoryProvider` apunta al repositorio real y no al mock en producción.
 [x] T5: La capa de UI de chat ya consume stream y datos reales del backend.
 [x] T6: La verificación muestra que el servidor Socket.io sigue respondiendo y el flujo de mensajes está integrado junto con Express.
 [x] T13: Evitar duplicación: REST persiste cada mensaje enviado una sola vez; Socket.IO distribuye mensajes entrantes y eventos.
 [x] T14: Completar envío de audio y ubicación actual desde el chat.
 [x] T15: Integrar reseñas, solicitudes, favoritos y compartir servicio en el detalle.
Notificaciones push
 [x] T7: Se agregó Firebase Messaging y registro/revocación de tokens de instalación en `/api/notifications/tokens`.
 [x] T8: Configuración solicita permiso explícito y persiste la preferencia del usuario.
 [x] T9: La API registra tokens en `fcm_tokens` mediante migración Prisma versionada y endpoints protegidos; aplicar con `npx prisma migrate deploy`.
 [x] T10: La API persiste, lista, cuenta y marca notificaciones leídas; FCM se envía para mensajes, solicitudes, reseñas y nuevos favoritos. Web usa VAPID personalizada opcional.
Documentación
 [x] T11: `.specify/testing.md` documenta pruebas ejecutadas y el estado de validación.
 [x] T12: `.specify/changelog.md` incluye el historial de cambios de integración.

Nota de auditoría de las tareas anteriores: el cambio de registro por correo y contraseña fue solicitado expresamente; no se modificaron Firebase Options ni middleware de verificación.

Autenticación
 [x] T16: Habilitar registro por correo y contraseña en Firebase Auth, sincronizar el perfil con la API y guardar la sesión sin cambiar Google Sign-In.

Correcciones de experiencia de usuario — 2026-10-31
 [x] T17: Mostrar el nombre de la sesión autenticada en el saludo del inicio, conservando el saludo cuando no haya nombre.
 [x] T18: Corregir el contraste del audio recibido en la burbuja entrante.
 [x] T19: Mostrar y actualizar el contador de notificaciones no leídas en la campana; permitir activar push web con la clave VAPID predeterminada de Firebase y admitir una clave personalizada opcional.

Fotos en chat y navegación de notificaciones — 2026-10-31
 [x] T20: Permitir seleccionar y subir fotos de chat por `/api/uploads`, enviar el mensaje persistido por REST y renderizarlo en historial y tiempo real.
 [x] T21: Guardar metadatos de destino en `notification.metadata` y abrir chat/solicitudes/reseñas/servicios desde push o bandeja. Aplicar migraciones Prisma en cada entorno.

Notificaciones sonoras y favoritos — 2026-11-08
 [x] T24: Solicitar sonido en FCM Android/APNs y notificaciones locales móviles; respetar la preferencia, abrir chat/servicio favorito desde el aviso y mantener aviso visual en web. Prueba real push/móvil pendiente.

Contador y eliminación de mensajes — 2026-10-31
 [x] T22: Obtener el total real de notificaciones no leídas y actualizar el contador de la campana al recibir avisos y regresar a la app.
 [x] T23: Permitir al autor eliminar un mensaje para ambos participantes, con autorización backend y sincronización Socket.io.

Validación ejecutada el 2026-09-11
 [x] Perfil: API y Prisma confirmados con `PUT /api/users/me`.
 [x] Publicación: API y Prisma confirmados con `POST /api/services`.
 [x] Búsqueda: API confirmada con `GET /api/services?category=Limpieza`.
 [ ] UI autenticada: pendiente; las validaciones automatizadas no sustituyen una interacción autenticada real.

 [x] Runtime: backend y Flutter Web quedaron levantados y comprobados por HTTP.
 [x] Seguridad: el cambio suelto de `auth.js` fue revertido al último commit.

Documentación
 [x] T25: Actualizar README, AGENTS y documentos SDD con el estado vigente y el índice de archivos por funcionalidad.