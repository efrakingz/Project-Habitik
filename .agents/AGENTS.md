# Habitik App — Directrices Arquitectónicas de Frontend y Flujos de Sesión

## 1. Restricción Estricta de Backend e Infraestructura
- **Backend & BD Intocables:** Al resolver bugs de persistencia, roles o sincronización, NUNCA modifiques código dentro de `backend/` ni alteres tablas en la base de datos de producción (Railway) a menos que el usuario lo pida explícitamente.
- **Solución en Cliente:** Todas las discrepancias de datos deben resolverse enriqueciendo los modelos de Flutter (`lib/data/models/`) y gestionando caché en `SessionService`.

## 2. Gestión de Sesión y Ruptura de Bucles de Onboarding
- **Evaluación Dinámica de Onboarding:** Al deserializar perfiles de usuario (`UserProfile.fromJson`), evalúa siempre dinámicamente si el atributo `onboarding_answers` contiene respuestas válidas en la base de datos. Si están presentes, asigna `onboardingCompleted = true` y omite cualquier vista de Onboarding para enrutar directo al Dashboard.
- **Caché Inteligente de Integrantes:** Para cuentas con rol `miembro`, persiste siempre en `SharedPreferences` el `familyName` asociado a su `familyId`, de modo que al recargar la app se mantenga la identidad visual del hogar compartido.
- **Cierre de Sesión Limpio:** El método `clearSession()` debe eliminar exclusivamente tokens JWT y credenciales temporales, preservando preferencias de hardware y flags de sesión no intrusivas.

## 3. Estándares Visuales en Pantallas de Resultados y Control
- **Layout Compacto Horizontal:** Las pantallas de resumen de invitación (Onboarding Final) y Panel de Control deben diseñarse sin necesidad de hacer scroll vertical.
- **Código QR Gigante:** El recuadro del código QR de invitación debe tener dimensiones de `200x200 px` con bordes resaltados en color verde esmeralda (`HabitikColors.green600`).
- **Botón Copiar Código QR:** Incluye siempre junto al QR un botón dedicado (`Copiar Código`) que copie al portapapeles estrictamente el UUID plano del `invite_token` (sin textos adicionales ni URLs) para su pegado manual rápido.

## 4. Hardware Nativo (Cámara QR)
- **Permisos Post-Frame:** Al inicializar escáneres de código QR (ej. `QrScannerScreen`), dispara siempre la activación de la cámara dentro de un `WidgetsBinding.instance.addPostFrameCallback` para garantizar que el sistema nativo de iOS/Android/Windows despliegue el diálogo de permisos de hardware sin bloqueos.

## 5. Pruebas Locales en iPhone / Dispositivos Móviles (desde Windows)
- **Comando Web Server Local:** Para probar la app en un iPhone u otro dispositivo de la misma red Wi-Fi, ejecuta en PowerShell:
  `flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080`
- **Acceso desde móvil:** Acceder desde Safari/Chrome a `http://<IP_LOCAL_PC>:8080` (ej. `http://192.168.1.9:8080`).
- **Conectividad:** La app apunta por defecto al backend de producción en Railway (`https://backendhabitik-production.up.railway.app`), por lo que las peticiones y login funcionarán de forma transparente sin requerir reconfiguración de base de datos local.
