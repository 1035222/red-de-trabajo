# Audit UI – Red de Trabajo

Fecha: 2026-09-10

> Este documento conserva un diagnóstico histórico de esa fecha, no el estado actual. Sus hallazgos de filtros, backend y chat fueron superados por correcciones posteriores y no deben usarse como guía de implementación. El estado vigente y el mapa por archivos están en [README.md](../README.md), [spec.md](./spec.md) y [testing.md](./testing.md).

## Objetivo

Registrar el estado real de los flujos de frontend y backend en la app actual, con evidencia de qué endpoint responde, qué error devuelve y qué parte del flujo queda pendiente.

## Resumen ejecutivo

- La app sigue usando el backend real (`useMock = false`) en la capa de repositorios, pero no todas las pantallas están sincronizadas con la API real.
- El backend sí responde en `GET /api/services` con `200 OK` y devuelve una lista real desde MySQL/Prisma.
- La causa raíz más clara detectada es la desalineación de filtros entre frontend y backend: Home usa `featured`, y el backend ignoraba ese parámetro; además el endpoint no validaba `minPrice`, `maxPrice` ni `location`.
- El perfil no se puede actualizar sin un `uid` real del usuario autenticado; si el usuario no existe en DB, el backend responde `404` con `Usuario no encontrado en la base de datos`.
- El flujo de Google/Firebase quedó intacto: no se toca ninguna zona restringida del auth.

## Pantallas revisadas

### 1) Home

- Ruta principal: `HomeScreen`
- Repositorio usado: `ApiServiceRepository`
- Endpoint verificado: `GET /api/services`
- Resultado real: `200 OK`
- Evidencia: el backend responde con una lista real de servicios desde Prisma.
- Observación: `HomeScreen._loadData` llama a `getFeaturedServices()`, que a su vez hace `GET /api/services?featured=true`.
- Problema detectado: el backend ignoraba el query param `featured`, por lo que la UI podía quedar vacía o inconsistente si la lista destacada no estaba correctamente filtrada.

### 2) Buscar

- Ruta principal: `SearchScreen`
- Repositorio usado: `ApiServiceRepository.searchServices()`
- Endpoint verificado: `GET /api/services?search=...&category=...`
- Resultado real: `200 OK` cuando la consulta coincide con categorías/servicios reales.
- Observación: `category` se compara con `categoryName` y el backend sí soporta texto + categoría.
- Problema detectado: filtros avanzados no estaban implementados; `minPrice`, `maxPrice` y `location` no eran considerados, por lo que la UI no podía devolver un conjunto real y consistente.

### 3) Perfil

- Ruta principal: `ProfileScreen` / `EditProfileScreen`
- Repositorio usado: `ApiProfileRepository`
- Endpoint verificado: `PUT /api/users/me` con `x-test-user-id` y `Authorization`
- Resultado real: `404` cuando el usuario no existe en la base de datos.
- Error observado: `{"message":"Usuario no encontrado en la base de datos"}`
- Causa raíz comprobada: el backend valida `req.user.uid` y hace `prisma.user.update()`; si la fila no existe, Prisma lanza `P2025` y el controlador responde `404`.
- Observación: la app luego de sincronizar el usuario con el backend puede guardar cambios sin problema, siempre que exista el registro y el UID real de Firebase coincida.

### 4) Publicar servicio

- Ruta principal: `PublishScreen`
- Repositorio usado: `ApiServiceRepository.createService()`
- Endpoint verificado: `POST /api/services`
- Resultado real: `201 Created` cuando `title`, `price`, `description` y `category` son válidos.
- Observación: la creación depende de que la categoría exista en MySQL y de que el usuario esté autenticado con un `uid` válido.
- Error típico si falla: `Categoría "..." no encontrada` o `Token no proporcionado`.

### 5) Chat

- Ruta principal: `ChatListScreen` / `ChatDetailScreen`
- Repositorio usado: `ApiChatRepository`
- Endpoint verificado: `GET /api/chat/conversations` y `POST /api/chat/conversations/:id/messages`
- Resultado real: las rutas existen y el backend responde con datos reales del modelo de conversaciones.
- Observación: el flujo de chat ya queda integrado con Socket.io en el servidor Express y la UI se conecta al socket para mensajes en vivo.
- Estado actual: la parte real del backend está lista, pero no se hizo validación de extremo a extremo con dos sesiones reales de usuario en este diagnóstico rápido.

## Errores reales observados

### GET /api/services

- Código HTTP: `200 OK`
- Payload: JSON con servicios reales, incluida `provider` y `categoryName`.

### PUT /api/users/me

- Código HTTP: `404 Not Found`
- Body: `{ "message": "Usuario no encontrado en la base de datos" }`
- Esto explica el fallo de guardar cambios del perfil cuando el usuario no existe o no está sincronizado en DB.

### GET /api/services?featured=true

- El controlador recibía el parámetro, pero la lógica no lo consideraba en la respuesta final.
- Resultado: el Home puede mostrar una lista vacía o inconsistente si se basa en esa bandera.

## Estado por funcionalidad

### funcionalidad | estado

- Home / servicios destacados: parcialmente corregido
- Buscar por texto y categoría: funcional con datos reales
- Buscar por filtros avanzados: corregido en backend, validación pendiente más profunda
- Editar perfil: corregido en la causa raíz del usuario no sincronizado y la lógica de actualización
- Publicar servicio: funcionando cuando la categoría y el usuario existen en BD
- Chat en tiempo real: integrado en backend, validación UI pendiente
- Google/Firebase Auth: intacto / no tocado

## Archivos clave consultados

- [lib/screens/home_screen.dart](../lib/screens/home_screen.dart)
- [lib/screens/search_screen.dart](../lib/screens/search_screen.dart)
- [lib/screens/edit_profile_screen.dart](../lib/screens/edit_profile_screen.dart)
- [lib/repositories/api_service_repository.dart](../lib/repositories/api_service_repository.dart)
- [lib/repositories/api_profile_repository.dart](../lib/repositories/api_profile_repository.dart)
- [src/controllers/serviceController.js](../../red-de-trabajo-api/src/controllers/serviceController.js)
- [src/controllers/profileController.js](../../red-de-trabajo-api/src/controllers/profileController.js)
- [src/server.js](../../red-de-trabajo-api/src/server.js)

## Conclusión

La integración real está bastante avanzada, pero no está 100% cerrada ni validada end-to-end en todos los flujos solicitados. La mayor evidencia de corrección en este avance es que el backend de servicios responde con datos reales y que la causa principal del perfil y búsqueda está claramente aislada y documentada.
