# Prioridad 0 aplicada: seguridad + preparación para siguientes fases

## Cambios implementados en código

1. **Eliminada la `SUPABASE_SERVICE_KEY` del frontend**.
   - Ya no existe cliente privilegiado en navegador.
   - El frontend opera solo con `anon key`.

2. **Resolución de links de PDF endurecida** con estrategia de 3 capas:
   - **Capa 1 (recomendada):** Edge Function `mhr-signed-url` (configurable) que responde `{ signedUrl }`.
   - **Capa 2:** `createSignedUrl` con cliente autenticado y políticas RLS.
   - **Capa 3:** `getPublicUrl` para buckets públicos.

3. **Validación básica de paths de storage** (`isSafeStoragePath`) para evitar rutas inseguras.

4. **Configuración preparada para evolución** vía `window.__MHR_CONFIG`:
   - `supabaseUrl`
   - `supabaseAnonKey`
   - `signedUrlFunction`
   - `signedUrlExpiresIn`

## Qué deja listo para prioridades siguientes

- **Prioridad 1 (arquitectura):** el bloque `APP_CONFIG` y `resolvePdfUrl` ya actúan como núcleo de un futuro módulo `config.js` / `storage.js`.
- **Prioridad 2 (rendimiento):** el helper centralizado evita repetir lógica de URLs en múltiples vistas.
- **Prioridad 3 (calidad):** la estrategia declarativa facilita pruebas unitarias sobre resolución de URL y validación de rutas.

## Recomendaciones inmediatas de operación

1. Crear Edge Function `mhr-signed-url` en Supabase (server-side, con service role solo en backend).
2. Definir `window.__MHR_CONFIG` por ambiente (dev/staging/prod).
3. Revisar políticas RLS de `reports`, `fauna_impact_pdfs`, `fauna_rescue_pdfs`.
4. Rotar credenciales sensibles si alguna vez estuvieron expuestas.
