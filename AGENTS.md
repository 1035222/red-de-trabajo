# AGENTS.md — red_de_trabajo (frontend Flutter)

README para agentes de IA (Kilo Code y similares) que trabajen en este repositorio. Este archivo es la fuente de verdad de contexto operativo. Las decisiones de producto y arquitectura viven en `.specify/` (ver SDD abajo) — este archivo cubre cómo trabajar en el día a día del código.

## Overview del proyecto

Frontend de Red de Trabajo, un marketplace de servicios que conecta oferentes y clientes. App Flutter que consume el backend API (Node.js + Express, Prisma + MySQL) en un repositorio separado (`red-de-trabajo-api`). Los flujos implementados incluyen autenticación, perfiles, catálogo, servicios, portafolios, reseñas, favoritos, solicitudes, chat (texto/fotos/audio/ubicación) y notificaciones push. El mapa de pantallas y archivos por funcionalidad está en `README.md`.

## Stack

- **Framework**: Flutter (Dart SDK ^3.13.0)
- **HTTP**: `http` ^1.2.0
- **State/persistence**: `shared_preferences` ^2.2.0 (sesión del usuario, tokens)
- **Auth**: `google_sign_in` ^6.2.1, `firebase_auth` ^6.6.1, `firebase_core` ^4.14.0
- **Imágenes**: `cached_network_image` ^3.4.1
- **Chat**: `socket_io_client` ^3.1.0; mensajes y archivos de chat usan REST para persistencia y Socket.IO para entrega en tiempo real.
- **Multimedia y ubicación**: `image_picker`, `record`, `audioplayers`, `geolocator`, `path_provider`.
- **Notificaciones**: `firebase_messaging` ^16.7.1, `flutter_local_notifications` ^22.0.0.
- **Tipografía**: `google_fonts` ^6.2.1
- **Design**: Material Design (uses-material-design: true)

## Estructura del proyecto

```
lib/
  config/      # Configuración del backend
  l10n/        # Localización
  models/      # Modelos de datos (Service, AppUser, Category, etc.)
  repositories/ # Capa de repositorio (abstrae el API service)
  screens/     # Pantallas (UI)
  services/    # API, Firebase, sesión, sockets, notificaciones y preferencias
  theme/       # Tema y estilos visuales
  utils/       # Utilidades y helpers
  widgets/     # Widgets reutilizables
```

## Comandos

```bash
flutter pub get        # instalar dependencias
flutter run -d chrome  # levantar web (API local en localhost:3000)
flutter run -d <device>  # levantar en móvil/emulador (IP LAN para el backend)
flutter build apk --release
flutter analyze        # análisis estático
flutter test           # tests unitarios
```

## Configuración del backend

La URL del backend se gestiona centralmente en `lib/config/api_config.dart`.
- **Web**: `http://localhost:3000/api` (el emulador de Chrome accede al localhost del host)
- **Móvil**: `http://<IP-LAN>-del-host:3000/api` (el dispositivo físico/emulador accede vía IP LAN)

La IP LAN se configura en `ApiConfig._hostIp`. Si cambias de red o de máquina, actualiza esta constante.

La APK usa la dirección que tenía configurada al compilar: si se instala en otra red, el dispositivo debe poder llegar a la API por esa dirección (o se debe cambiar la configuración y compilar otra APK). No hay conexión automática al Wi-Fi de una PC.

Android requiere `android:usesCleartextTraffic="true"` en `AndroidManifest.xml` para permitir conexiones HTTP (no HTTPS) en desarrollo.

## Estilo de código

- Sigue el estilo ya presente en el repo (no reformatees archivos completos sin que se pida).
- `ApiService` separa errores de red (SocketException, TimeoutException) de errores HTTP — los repositorios inspeccionan `statusCode` y `response.body` para mensajes de error detallados.
- Usa `async/await` con manejo explícito de errores.
- Los modelos (`fromJson`/`toJson`) deben manejar relaciones anidadas (ej. `provider` dentro de `Service`).
- Para ubicar controladores, servicios y pantallas, consulta el índice de funcionalidades del `README.md` de este repositorio y el README del backend.

## Testing

- Antes de dar por resuelta cualquier tarea de conectividad, valida end-to-end: ejecuta la app desde el dispositivo/emulador y confirma que la API responde correctamente.
- Usa `flutter analyze` para verificar ausencia de errores de compilación.
- Si agregas logging temporal para depurar, contrólalo con `bool` de entorno o `kDebugMode` y quítalo antes de cerrar la tarea.

## 🚫 Zonas restringidas (NO TOCAR sin autorización explícita)

Todo lo relacionado con autenticación de Google / Firebase Auth:
- Login con Google Sign-In (`google_sign_in`)
- Verificación de tokens Firebase (`firebase_auth`)
- Configuración de Firebase (`firebase_options.dart`, `main.dart` con `Firebase.initializeApp`)
- Envío del token al backend (`Authorization: Bearer <idToken>`)

Este flujo ya funciona en producción y se ha dañado repetidamente al hacer cambios no relacionados. Si detectas algo que "parece" un bug ahí, repórtalo en el resumen de la tarea — no lo edites.

## Reglas de commits / PR

- Un commit por tarea atómica (ver `.specify/tasks.md`), mensaje en español, formato: `tipo: descripción breve` (ej. `fix: corrige URL base en web`).
- No mezclar cambios de auth con cambios de otras funcionalidades en el mismo commit.

## Dónde está la fuente de verdad de producto/arquitectura

Este proyecto sigue Spec-Driven Development (SDD). Antes de implementar cualquier funcionalidad nueva o cambio de comportamiento, consulta y actualiza:

- `.specify/memory/constitution.md` — principios no negociables
- `.specify/spec.md` — qué se construye y por qué
- `.specify/plan.md` — cómo se construye técnicamente
- `.specify/tasks.md` — desglose de tareas ejecutables

No implements nada que contradiga estos documentos sin actualizarlos primero.
