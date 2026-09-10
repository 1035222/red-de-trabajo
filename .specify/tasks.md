TASKS.md — red_de_trabajo (Frontend Flutter)

Tareas atómicas derivadas de plan.md. Ninguna tarea toca login/Firebase Auth/SessionService.

Filtros de búsqueda
 T1: Verificar si search_screen.dart ya tiene UI de filtro por precio/ubicación. Documentar el hallazgo aquí.
 T2 (si falta): Agregar controles de filtro (rango de precio, ubicación) y conectar al repositorio de servicios real. Depende de backend T1-T2.
Chat en tiempo real
 T3: Agregar dependencia de cliente Socket.io a pubspec.yaml.
 T4: Implementar chat_repository.dart real (reemplaza la parte de chat de mock_repositories.dart), conectado al servidor definido en backend plan.md.
 T5: Adaptar chat_list_screen.dart y chat_detail_screen.dart para consumir streams en tiempo real en vez de datos mock estáticos.
 T6: Probar en Flutter Web (Chrome, entorno principal actual) el envío/recepción de mensajes en tiempo real entre dos sesiones.
Notificaciones push
 T7: Agregar firebase_messaging a pubspec.yaml.
 T8: Solicitar permiso de notificaciones tras el login.
 T9: Obtener fcmToken y enviarlo en la llamada a POST /api/users/sync (depende de backend T7-T8).
 T10: Manejar notificación entrante en foreground/background.
Documentación
 T11: Crear .specify/testing.md (aún no existe en este repo) documentando las pruebas ejecutadas para cada bloque de tareas anterior.
 T12: Crear .specify/changelog.md (aún no existe en este repo) con una entrada por cada bloque cerrado (filtros, chat, notificaciones).