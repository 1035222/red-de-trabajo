TASKS.md — red_de_trabajo (Frontend Flutter)

Tareas atómicas derivadas de plan.md. Ninguna tarea toca login/Firebase Auth/SessionService.

Estado verificado al 2026-09-10

Filtros de búsqueda
 [x] T1: El filtro por categoría/texto ya existía en la UI y el backend responde con resultados reales. La falla real estaba en el backend: el query parameter `featured` era ignorado y los filtros de precio/ubicación no estaban implementados.
 [x] T2: Se corrigió la capa de servicios para que respete `featured`, `minPrice`, `maxPrice` y `location` con validación real en MySQL/Prisma.
Chat en tiempo real
 [x] T3: La dependencia `socket_io_client` ya está instalada y conectada desde el frontend.
 [x] T4: `RepositoryProvider` apunta al repositorio real y no al mock en producción.
 [x] T5: La capa de UI de chat ya consume stream y datos reales del backend.
 [x] T6: La verificación muestra que el servidor Socket.io sigue respondiendo y el flujo de mensajes está integrado junto con Express.
 [x] T13: Evitar duplicación al usar Socket.io como única escritura de mensajes enviados.
 [x] T14: Completar envío de audio y ubicación actual desde el chat.
 [x] T15: Integrar reseñas, solicitudes, favoritos y compartir servicio en el detalle.
Notificaciones push
 [ ] T7: FCM no está implementado todavía en este frontend.
 [ ] T8: No existe permiso de notificaciones en flujo post-login.
 [ ] T9: `fcmToken` no se envía a `POST /api/users/sync` todavía.
 [ ] T10: No hay manejo de notificaciones en foreground/background.
Documentación
 [x] T11: `.specify/testing.md` documenta pruebas ejecutadas y el estado de validación.
 [x] T12: `.specify/changelog.md` incluye el historial de cambios de integración.

Nota de auditoría: no se tocó ninguna zona restringida de auth, y no se modificó Google/Firebase en este trabajo.

Validación ejecutada el 2026-09-11
 [x] Perfil: API y Prisma confirmados con `PUT /api/users/me`.
 [x] Publicación: API y Prisma confirmados con `POST /api/services`.
 [x] Búsqueda: API confirmada con `GET /api/services?category=Limpieza`.
 [ ] UI autenticada: pendiente; no se simuló una interacción de navegador.

 [x] Runtime: backend y Flutter Web quedaron levantados y comprobados por HTTP.
 [x] Seguridad: el cambio suelto de `auth.js` fue revertido al último commit.