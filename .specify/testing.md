# Pruebas — Red de Trabajo (Frontend)

El mapa de funcionalidades y sus archivos está en el [README](../README.md). Este documento separa análisis/pruebas automatizadas, evidencia histórica de API y validaciones reales aún pendientes.

## Validación reciente de notificaciones (2026-11-08)

- `flutter analyze`: pasó sin issues.
- `flutter test`: pasó (8 pruebas).
- `flutter build apk --debug`: completó; salida `build/app/outputs/flutter-apk/app-debug.apk`.
- `node --check` en `notificationService.js` y `interactionController.js` del backend pasó.
- No había teléfono ni emulador Android conectado. No se validaron recepción FCM con token real, sonido del sistema ni navegación tocando una notificación en dispositivo.
- Hot restart no se pudo ejecutar: no había una app Flutter de depuración activa conectada al Dart Tooling Daemon.

## Cobertura automatizada existente

- `test/l10n/app_localizations_test.dart`: traducciones/localización y preferencias de idioma.
- `test/models/chat_message_test.dart`: parseo y serialización de mensajes multimedia.
- `test/models/notification_test.dart`: metadatos de destino y compatibilidad con notificaciones sin metadata.
- Ejecutar todo con `flutter test`; la cobertura actual es principalmente de modelos/localización, no E2E de UI ni FCM.

## Funcionalidades implementadas que requieren E2E

| Flujo | Qué falta probar |
|---|---|
| Login/registro Firebase | Sesión real desde UI, sincronización del UID y sesión persistida |
| Perfil y servicios | Guardar/leer desde UI con cuenta Firebase y comprobar datos en API/Prisma |
| Búsqueda y filtros | Resultados reales combinando texto, categoría, precio y ubicación |
| Chat | Dos cuentas/dispositivos para texto, imagen, audio, ubicación, borrado y actualización por Socket.IO |
| Favoritos/solicitudes/reseñas | Persistencia y atribución de reseñas al proveedor correcto |
| Notificaciones | Token real; preferencia habilitada/deshabilitada; foreground/background; sonido y destino de chat/servicio en Android/iOS; aviso visual y destino en web |

No usar `prisma db push` como requisito genérico de prueba; los entornos deben aplicar las migraciones versionadas de la API con `npx prisma migrate deploy`.

## Evidencia histórica de API (2026-09-11)

- Se verificó `PUT /api/users/me`, `POST /api/services` y `GET /api/services?category=Limpieza` mediante la API y Prisma.
- Esas pruebas usaron un usuario de desarrollo y no prueban una sesión Firebase ni la interacción de UI. El bypass de autenticación usado en ese momento fue retirado; las rutas protegidas requieren token Firebase.

## Nota histórica

Las notas de auditoría de UI del 2026-09-10 están archivadas en `audit-ui.md`; reflejan el estado de ese día y no el estado actual del chat, los filtros ni las notificaciones.
