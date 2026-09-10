TESTING.md — red_de_trabajo (Frontend Flutter)

Documenta las pruebas ejecutadas para cada funcionalidad, siguiendo la estrategia del documento técnico original (unitarias, widgets, integración, rendimiento).

Estado actual
Sin pruebas automatizadas documentadas todavía para las funcionalidades ya conectadas a backend real (servicios, perfil, portafolio, reseñas). Pendiente: agregar al menos pruebas de widget para las pantallas críticas (publicar servicio, login, búsqueda).
Plan de pruebas — Filtros de búsqueda (pendiente, tarea T1-T2)
 Widget test: los controles de filtro se renderizan correctamente.
 Integration test: aplicar filtro de precio/ubicación devuelve resultados coherentes con lo que responde el backend.
Plan de pruebas — Chat en tiempo real (pendiente, tareas T3-T6)
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
TC-09	Edición de perfil	Media	Pendiente de documentar
TC-10	Navegación entre pantallas	Alta	Pendiente de documentar