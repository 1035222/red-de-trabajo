# Red de Trabajo

## Documento técnico del proyecto

Red de Trabajo es una aplicación móvil/web desarrollada en Flutter para conectar profesionales y clientes en un marketplace de servicios. La solución permite a los usuarios publicar servicios, gestionar perfiles, explorar ofertas, calificar proveedores y mantener conversaciones dentro de la plataforma.

## 1. Objetivo del sistema

El producto responde a dos necesidades principales:

- Lado de la oferta: los profesionales independientes necesitan visibilidad y una forma clara de mostrar sus servicios y experiencia.
- Lado de la demanda: los clientes buscan contratar personas confiables con perfiles verificables, reseñas y portafolios.

El sistema centraliza estas interacciones en una sola experiencia de usuario con autenticación, catálogo, publicación, comunidad y comunicación.

## 2. Arquitectura

La aplicación frontend corre en Flutter y se comunica con un backend API desarrollado en Node.js + Express + Prisma + MySQL, en un repositorio separado. La lógica se organiza en capas bien definidas:

- `lib/config`: configuración global, endpoints y ajustes de entorno.
- `lib/models`: modelos de dominio para usuarios, servicios, reseñas, chats y notificaciones.
- `lib/repositories`: abstracción de acceso a datos y consumo del backend.
- `lib/services`: cliente HTTP, sesión, chat, autenticación y utilidades de soporte.
- `lib/screens`: pantallas de la aplicación y flujo de navegación.
- `lib/widgets`: componentes reutilizables de UI.
- `lib/utils`: helpers y constantes del sistema.

## 3. Stack tecnológico

- Flutter + Dart SDK ^3.13.0
- Material Design
- HTTP para consumo de API REST
- SharedPreferences para persistencia de sesión
- Google Sign-In + Firebase Auth para autenticación
- Socket.io para chat en tiempo real
- Cached network image para manejo de imágenes
- Google Fonts para tipografía

## 4. Módulos funcionales

### 4.1 Autenticación

El flujo principal de acceso usa Google Sign-In en el primer ingreso y, posteriormente, email/contraseña con credencial vinculada a Firebase. La autenticación es un punto crítico del sistema y no debe ser alterado por cambios no relacionados.

Aspectos relevantes:

- Login con Google en la primera sesión.
- Vínculo con Firebase Auth.
- Persistencia de sesión en local.
- Uso de backend para gestión de usuario y perfil.

### 4.2 Perfiles

Los usuarios pueden:

- Crear y editar su perfil.
- Cargar foto de perfil.
- Definir biografía y ubicación.
- Consultar información pública de otros usuarios.

### 4.3 Servicios

La app permite:

- Publicar servicios con título, descripción, categoría y precio.
- Editar y eliminar publicaciones.
- Asociar imágenes a cada servicio.
- Consultar el catálogo de servicios y detalles de cada oferta.

La imagen se sube desde el frontend y el backend persiste la URL asociada, no el archivo binario.

### 4.4 Portafolio

Los profesionales pueden mostrar proyectos o trabajos previos, con una galería visual que ayuda a generar confianza con el cliente.

### 4.5 Búsqueda y filtrado

El sistema permite encontrar proveedores y servicios mediante:

- Texto libre.
- Categoría.
- Filtros adicionales que deben validarse en la implementación real antes de considerarlos definitivos.

### 4.6 Reseñas y calificaciones

Es posible puntuar a un proveedor y dejar comentarios con valoracion de estrellas y texto. Esto refuerza la confianza y sirve como mecanismo de reputación dentro del marketplace.

### 4.7 Chat

La comunicación directa entre usuarios se gestiona a través de Socket.io. La persistencia se hace por REST y la entrega en tiempo real se distribuye con sockets, evitando duplicación de mensajes en la base de datos.

## 5. Flujo principal de uso

1. El usuario ingresa con Google o con credenciales vinculadas.
2. El sistema crea o recupera el perfil del usuario.
3. El usuario navega el catálogo de servicios o busca por texto/categoría.
4. Puede abrir el perfil del proveedor y revisar reseñas, portafolio y disponibilidad.
5. El cliente puede enviar mensajes, contratar el servicio o consultar más información.
6. El proveedor gestiona su oferta y el sistema almacena cada acción en el backend.

## 6. Configuración del backend

La URL del backend se centraliza en `lib/config/api_config.dart`.

- Web: `http://localhost:3000/api`
- Móvil/emulador: `http://<IP-LAN-del-host>:3000/api`

La IP LAN se almacena en la constante de configuración del proyecto. Si la máquina cambia de red, se debe actualizar esta configuración.

Android requiere `android:usesCleartextTraffic="true"` en `AndroidManifest.xml` para permitir tráfico HTTP en entorno de desarrollo.

## 7. Reglas de implementación y arquitectura

- Se prioriza la separación entre repositorios, servicios y pantallas.
- Los modelos gestionan serialización con `fromJson` y `toJson`.
- Los repositorios manejan errores de red y errores HTTP con mensajes específicos.
- El flujo de autenticación con Google/Firebase está restringido y no debe tocarse salvo que sea una corrección explícita de ese área.
- Las validaciones end-to-end son obligatorias antes de cerrar tareas de persistencia o integración con el backend.

## 8. Restricciones no funcionales

- No modificar el flujo de autenticación de Google/Firebase como efecto colateral de otras tareas.
- El backend usa MySQL, no PostgreSQL.
- Se debe validar la integración real entre frontend, backend y base de datos antes de cerrar la tarea.
- El almacenamiento externo de imágenes no se usa como prioridad; en desarrollo se sube al backend y se persiste solo la URL.

## 9. Alcance actual

### Funcionalidades ya implementadas

- Login y registro con Google/Firebase.
- Gestión de perfil.
- Publicación, edición y eliminación de servicios.
- Portafolio.
- Reseñas y calificaciones.
- Búsqueda básica y filtros de catálogo.
- Chat en tiempo real con Socket.io.

### Funcionalidades pendientes o por aclarar

- Notificaciones push.
- Filtros avanzados de ubicación y precio, confirmados como no definitivos hasta validación real.
- Flujo completo de solicitudes y favoritos.
- Integraciones sociales o verificación de identidad.
- Pagos en línea y reservas automatizadas.

## 10. Estructura del proyecto

```text
lib/
  config/
  models/
  repositories/
  screens/
  services/
  theme/
  utils/
  widgets/
assets/
android/
ios/
linux/
macos/
web/
windows/
test/
```

## 11. Comandos principales

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --web-port=5000
```

Nota: el puerto 5000 se usa porque Google OAuth está autorizado para `http://localhost:5000`.

## 12. Estado del documento

Este contenido reemplaza el documento técnico base como referencia operativa del proyecto. El repo ya incorpora las decisiones vigentes del equipo y refleja el estado real de implementación en la fecha actual.

## 13. Observación de mantenimiento

Si el proyecto cambia de red o de entorno, revisar la constante del host del backend y actualizar la configuración antes de ejecutar pruebas end-to-end. La documentación técnica debe mantenerse sincronizada con la implementación real para evitar inconsistencias entre frontend, API y base de datos.
