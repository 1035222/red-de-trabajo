# Constitution — red_de_trabajo (frontend Flutter)

Fase 0 de Spec-Driven Development. Estas son las reglas no negociables del proyecto. Ningún agente de IA puede generar código, spec, plan o tarea que las viole.

## Principios de arquitectura

El frontend es una app Flutter (Dart SDK ^3.13.0) que consume el backend API REST en `http://<host>:3000/api`. La estructura del código sigue este orden:

```
lib/
  config/      # Configuración centralizada (api_config.dart, tema)
  models/      # Modelos de datos (Service, AppUser, Category, etc.)
  repositories/ # Capa de repositorio (interface abstracta + implementación)
  screens/     # Pantallas/UI (una por funcionalidad)
  services/    # Servicios: ApiService (cliente HTTP), SessionService (tokens)
  theme/       # Tema y estilos visuales
  utils/       # Utilidades y helpers
  widgets/     # Widgets reutilizables
```

- Los repositorios definen una interfaz abstracta (`ServiceRepository`, etc.) y una implementación concreta (`ApiServiceRepository`). Para testing, se pueden crear implementaciones mock sin tocar el código de producción.
- Los modelos deben implementar `fromJson` / `toJson` manejando relaciones anidadas (ej. `provider` dentro de `Service`).
- `ApiConfig.baseUrl` gestiona la URL del backend: `localhost` para web, IP LAN para dispositivos móviles. Ver `AndroidManifest.xml` para `cleartextTraffic`.

## Seguridad y zonas intocables

**Autenticación de Google / Firebase Auth es zona restringida.** Ningún agente debe modificar el siguiente código como efecto colateral de otra tarea:
- Login con `google_sign_in` (login Google, `signIn`, `signOut`)
- Verificación de tokens en el frontend (`firebase_auth` — `getIdToken`, `onAuthStateChanged`)
- Configuración de Firebase (`firebase_options.dart`, `main.dart` con `Firebase.initializeApp`)
- `SessionService` (guardado/borrado de tokens en `shared_preferences`)
- Envío del token al backend (`Authorization: Bearer <idToken>`)

Este flujo ya funciona en producción y se ha dañado repetidamente al hacer cambios no relacionados. Si detectas algo que "parece" un bug ahí, repórtalo en el resumen de la tarea — no lo edites.

## Estándares de calidad

- `flutter analyze` debe pasar sin errores ni warnings antes de cerrar cualquier tarea.
- Los cambios de UI se validan en Flutter Web (Chrome) como entorno principal de pruebas actual:
  ```bash
  flutter analyze
  flutter run -d chrome
  ```
- Cualquier funcionalidad de guardado (crear/editar/eliminar) debe validarse end-to-end: interactuar desde la app y confirmar que el backend persiste el dato (ver `GET` posterior o Prisma Studio del backend).
- Si agregas logging temporal para depurar, contrólalo con `kDebugMode` y quítalo antes de cerrar la tarea.

## Convenciones técnicas

- **Stack fijo**: Flutter + Dart. Dependencias del `pubspec.yaml`:
  - `http` ^1.2.0 (cliente HTTP)
  - `shared_preferences` ^2.2.0 (sesión/tokens)
  - `google_sign_in` ^6.2.1 (login Google)
  - `firebase_auth` ^6.6.1 (auth)
  - `firebase_core` ^4.14.0 (init Firebase)
  - `cached_network_image` ^3.4.1 (imágenes)
  - `google_fonts` ^6.2.1 (tipografía)
- No se introducen gestores de estado (como `provider`, `riverpod`, `bloc`) ni paquetes nuevos sin actualizar esta constitución primero.
- `ApiService` separa errores de red (`SocketException`, `TimeoutException`) de errores HTTP: los repositorios inspeccionan `statusCode` y `response.body` para mensajes de error detallados.
- El proyecto usa Material Design (`uses-material-design: true`).

## Proceso de cambio

Si un requisito cambia o una funcionalidad nueva se propone:
1. Se actualiza `.specify/spec.md` (qué se construye y por qué).
2. Se actualiza `.specify/plan.md` (cómo se construye técnicamente).
3. Se actualiza `.specify/tasks.md` (desglose de tareas ejecutables).
4. Solo entonces se toca el código. Nunca al revés.

No implementes nada que contradiga estos documentos sin actualizarlos primero.
