# Análisis de estructura de Fauna y propuesta de reestructura

## Hallazgos clave en el código actual

1. El frontend sí inserta un registro por reporte, pero sólo en `fauna_impact_reports` y `fauna_rescue_reports`; no inserta en las tablas detalle (`fauna_impact_items` / `fauna_rescue_photos`) aunque sí construye esos datos para PDF.  
2. El campo `fauna_report_ubicacion` del formulario de impacto representa **zona aeroportuaria** (ej. cabecera/intersección), pero se guardaba en columna `ubicacion`.
3. Las coordenadas se capturan por item (`fauna_details[*][lugar]`) y se usan para renderizar mapa/PDF, pero no quedaban persistidas de forma estructurada.

## Campos detectados en uso real

### Impacto
- `folio`, `fecha_reporte`, `evento`, `fase_vuelo`, `pista`, `responsable`, `cargo`, `aerolinea`, `estado`, `tipo_reporte`, `pdf_url`.
- Nuevo mapeo aplicado:
  - `zona` ← antes `fauna_report_ubicacion`.
  - `ubicacion_texto` / `ubicacion_lat` / `ubicacion_lng` ← tomado del primer detalle de ubicación disponible.
  - `detalle_items` (JSONB) ← arreglo completo de items de fauna que ya se construía para el PDF.

### Rescate
- `fecha_reporte`, `folio`, `responsable`, `cargo`, `institucion_responsable`, `clase`, `especie`, `sitio_reubicacion`, `observaciones`, `estado`, `tipo_reporte`, `pdf_url`.
- Nuevo mapeo aplicado:
  - `ubicacion_texto` ← antes `sitio_rescate`.
  - `ubicacion_lat` / `ubicacion_lng` ← parseo de coordenadas cuando el texto viene como `lat,lng`.

## Modelo objetivo

Se unifica en `public.fauna_reports` con:
- Campos comunes.
- `zona` separado de `ubicacion_*`.
- `detalle_items` y `evidencias` en JSONB para no perder granularidad operativa.
- Índices y constraints mínimos de consistencia (coords completas o nulas).

## Script de base de datos

Se agregó `migration_fauna_unificada.sql` que:
1. Crea `fauna_reports`.
2. Migra data de impacto/rescate y agrega detalle/evidencias a JSONB.
3. Activa RLS con políticas básicas.
4. Elimina las 4 tablas legacy (`fauna_impact_items`, `fauna_rescue_photos`, `fauna_impact_reports`, `fauna_rescue_reports`).

> Recomendación operativa: ejecutar primero en staging, validar conteos y muestras de datos, y después correr en producción.
