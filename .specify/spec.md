SPEC.md — Red de Trabajo

Fuente: Documento Técnico y de Proyecto (materia Programación Móvil, IUE — Juan José Zabala y Miguel Ángel Valencia), reconciliado con el estado real de implementación al 10/09/2026.

⚠️ Este spec reemplaza el documento técnico original como fuente de verdad operativa. El documento técnico sigue siendo válido como contexto académico/histórico del proyecto, pero donde haya conflicto, este archivo manda.

Problema
Lado de la oferta: trabajadores independientes y profesionales tienen dificultad para darse a conocer y conseguir clientes.
Lado de la demanda: quienes necesitan contratar no encuentran fácilmente personas confiables por falta de referencias y un espacio centralizado.
Usuarios
Profesionales independientes (diseñadores, programadores, fotógrafos).
Trabajadores de oficios (plomeros, electricistas, carpinteros, pintores, panaderos, etc.).
Personas/empresas que buscan contratar esos servicios.
Un mismo usuario puede ofrecer y contratar simultáneamente.
Flujos clave (ya implementados)
Registro/login: Google Sign-In obligatorio en el primer acceso; login posterior con email/contraseña vía linkWithCredential. (Difiere del doc: no es JWT/bcrypt propio.)
Gestión de perfil: crear/editar perfil, foto, biografía, ubicación — conectado a backend real.
Publicar/editar/eliminar servicio: título, descripción, categoría, precio, imágenes (la imagen se sube desde el frontend; el backend solo persiste la URL).
Portafolio: galería de trabajos anteriores — conectado a backend real.
Búsqueda y filtrado: por texto, categoría (ubicación y precio: confirmar si ya están implementados o siguen en el documento como aspiracionales — [NEEDS CLARIFICATION]).
Calificaciones y reseñas: sistema de estrellas + comentario — conectado a backend real.
Flujos clave (pendientes)
Chat en tiempo real: integrado con Socket.io; se amplía con texto, audio y ubicación.
Interacción de servicios: reseñas, solicitudes, favoritos y compartir desde el detalle.
Notificaciones: push (Firebase Cloud Messaging) — no confirmado si está implementado; [NEEDS CLARIFICATION].
Criterios de éxito
Un usuario puede publicar un servicio con foto y descripción, y verlo persistido y consultable por otros usuarios.
Un usuario puede encontrar un trabajador por búsqueda/filtro y ver su perfil, portafolio y calificaciones reales.
El login con Google funciona de forma estable en cada iteración (zona restringida, ver AGENTS.md).
Restricciones no funcionales
No modificar el flujo de autenticación con Google/Firebase como efecto colateral de otras tareas.
Backend en MySQL (no PostgreSQL, a diferencia del documento técnico original).
Validación end-to-end obligatoria antes de cerrar cualquier tarea de guardado (frontend → backend → Prisma Studio).
Explícitamente fuera de alcance (por ahora)
Pagos en línea.
Reservas con confirmación automática.
Verificación de identidad con documentos.
Integración con redes sociales (más allá de Google Sign-In para login).
Almacenamiento externo de imágenes — en desarrollo se usa subida local al backend y se persiste la URL en MySQL.
Resuelto (respuestas del equipo, 10/09/2026)
Filtros de ubicación y precio: estado no confirmado — antes de dar por hecha esta funcionalidad, verificar en el código real (frontend search_screen.dart / backend serviceController) si ya existen o solo está el filtro por categoría/texto.
Chat en tiempo real: se mantiene la decisión de implementarlo con Socket.io. REST persiste cada mensaje una sola vez y Socket.io distribuye los mensajes entrantes.
Notificaciones push (FCM): siguen en el roadmap del MVP — no se excluyen.
[NEEDS CLARIFICATION] — pendiente
La subida local al backend se usa en desarrollo para evitar facturación de Firebase Storage.