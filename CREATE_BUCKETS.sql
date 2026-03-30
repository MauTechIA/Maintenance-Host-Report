-- ================================================================================
-- CREAR BUCKETS DE STORAGE PARA PDFs
-- ================================================================================
-- Nota: Los buckets de Storage no se crean con SQL directo, pero aquí están
-- las instrucciones para crearlos rápidamente en Supabase
-- 
-- OPCIÓN 1: Via Dashboard Supabase (2 minutos) - MÁS FÁCIL
-- OPCIÓN 2: Via Supabase JavaScript (para automatización)
-- ================================================================================

-- ================================================================================
-- OPCIÓN 1: CREAR BUCKETS VÍA SUPABASE DASHBOARD (RECOMENDADO)
-- ================================================================================

/*
1. VE A: https://app.supabase.com/project/[TU_PROYECTO]/storage
2. HAZ CLIC EN: + Create new bucket

BUCKET 1: fauna_impact_pdfs
──────────────────────────────────
▢ Name: fauna_impact_pdfs
▢ Privacy: PRIVATE (recomendado)
▢ Hacer público: NO
→ Haz clic: [Create bucket]

LUEGO: Abre fauna_impact_pdfs → RLS Policies → + New policy

POLÍTICA 1 (Lectura pública):
─────────────────────────────
- Nombre: allow_select_all
- Operación: SELECT
- Roles: authenticated, anon
- USING: true
→ Haz clic: [Create policy]

POLÍTICA 2 (Subida de autenticados):
────────────────────────────────────
- Nombre: allow_insert_authenticated
- Operación: INSERT
- Roles: authenticated
- WITH CHECK: true
→ Haz clic: [Create policy]

POLÍTICA 3 (Eliminación de autenticados):
──────────────────────────────────────────
- Nombre: allow_delete_authenticated
- Operación: DELETE
- Roles: authenticated
- USING: true
→ Haz clic: [Create policy]


BUCKET 2: fauna_rescue_pdfs
───────────────────────────
Repetir exactamente lo mismo:
▢ Name: fauna_rescue_pdfs
▢ Privacy: PRIVATE
▢ Aplicar LAS MISMAS 3 políticas
*/

-- ================================================================================
-- OPCIÓN 2: CREAR BUCKETS CON JAVASCRIPT (AUTOMATIZADO)
-- ================================================================================

/*
Si quieres automatizar la creación, usa este código JavaScript en la consola:

```javascript
// Crear bucket fauna_impact_pdfs
const { data: bucket1, error: error1 } = await supabaseClient.storage.createBucket('fauna_impact_pdfs', {
  public: false,  // PRIVATE
  fileSizeLimit: 52428800  // 50MB
});
console.log('Bucket 1:', bucket1, error1);

// Crear bucket fauna_rescue_pdfs
const { data: bucket2, error: error2 } = await supabaseClient.storage.createBucket('fauna_rescue_pdfs', {
  public: false,  // PRIVATE
  fileSizeLimit: 52428800  // 50MB
});
console.log('Bucket 2:', bucket2, error2);
```

Pega esto en: Abre tu página del formulario → F12 → Console → Pega todo → Enter
*/

-- ================================================================================
-- VERIFICAR QUE LOS BUCKETS SE CREARON
-- ================================================================================

/*
En Supabase Dashboard:
1. Ve a: Storage → Buckets
2. Deberías ver:
   ✓ fauna_impact_pdfs   (PRIVATE)
   ✓ fauna_rescue_pdfs   (PRIVATE)

O usa JavaScript:
```javascript
const { data: buckets, error } = await supabaseClient.storage.listBuckets();
console.log('Buckets:', buckets);
```
*/

-- ================================================================================
-- CHECKLIST DE CREACIÓN
-- ================================================================================

/*
✓ PASO 1: Ejecutar SETUP_FAUNA_PDF_SAFE.sql en SQL Editor (YA HECHO)
✓ PASO 2: Crear bucket "fauna_impact_pdfs" en Storage
  - [ ] Ir a Storage → + Create new bucket
  - [ ] Nombre: fauna_impact_pdfs
  - [ ] Privacy: PRIVATE
  - [ ] Agregar 3 políticas (SELECT, INSERT, DELETE)
✓ PASO 3: Crear bucket "fauna_rescue_pdfs" en Storage
  - [ ] Ir a Storage → + Create new bucket
  - [ ] Nombre: fauna_rescue_pdfs
  - [ ] Privacy: PRIVATE
  - [ ] Agregar las MISMAS 3 políticas
✓ PASO 4: Verificar que ambos buckets existen
✓ PASO 5: ¡Listo! Ya puedes generar PDFs
*/

-- ================================================================================
-- RESUMEN DE LO QUE TIENES
-- ================================================================================

/*
Después de todo esto, tendrás:

BASE DE DATOS:
✓ Tabla fauna_impact_reports con columnas: id, folio, pdf_url, tipo_reporte, estado...
✓ Tabla fauna_rescue_reports con columnas: id, folio, pdf_url, tipo_reporte, estado...
✓ Índices para búsquedas rápidas
✓ Políticas RLS para seguridad

STORAGE:
✓ Bucket fauna_impact_pdfs (privado, solo autenticados)
✓ Bucket fauna_rescue_pdfs (privado, solo autenticados)

CÓDIGO:
✓ Historial de Reportes mostrará: Folio, Tipo, Especie, Ubicación, Responsable, Estado, [PDF Link]
✓ Al generar PDF → Se guarda automáticamente en fauna_impact_pdfs
✓ El link aparece en el historial como "📄 Ver PDF"
*/

-- ================================================================================
-- ¿QUÉ HACER SI ERES PRINCIPIANTE?
-- ================================================================================

/*
Sigue estos pasos en ORDEN EXACTO:

1. (Ya hecho) Ejecutar SETUP_FAUNA_PDF_SAFE.sql
   ↓
2. Crear bucket fauna_impact_pdfs
   - Ve a Supabase Dashboard
   - Click Storage
   - Click "+ Create new bucket"
   - Nombre: fauna_impact_pdfs
   - Privacy: PRIVATE
   - Click "Create bucket"
   ↓
3. Agregar políticas al bucket fauna_impact_pdfs
   - Abre el bucket
   - Ve a "RLS Policies"
   - Click "+ New policy" (3 VECES)
   - Agrega las 3 políticas (ver OPCIÓN 1 arriba)
   ↓
4. Repetir pasos 2-3 pero con "fauna_rescue_pdfs"
   ↓
5. ¡LISTO! Ya funciona
*/

-- ================================================================================
-- SOLUCIÓN RÁPIDA: SOLO COPLA-PEGA (5 MINUTOS)
-- ================================================================================

-- Paso 1: Ya ejecutaste SETUP_FAUNA_PDF_SAFE.sql ✓

-- Paso 2: Crea los buckets

-- OPCIÓN A (MÁS FÁCIL): Ve a Supabase Dashboard
--   Storage → + Create new bucket
--   Nombre: fauna_impact_pdfs
--   Privacy: PRIVATE
--   Create!

-- OPCIÓN B (AUTOMATIZADA): Pega esto en JavaScript console:
-- (Abre tu página del formulario → F12 → Console → Pega → Enter)

/*
const supabaseClient = window.supabaseClient;

// Crear bucket 1
const { data: b1 } = await supabaseClient.storage.createBucket('fauna_impact_pdfs', { public: false });
console.log('✓ fauna_impact_pdfs creado:', b1);

// Crear bucket 2
const { data: b2 } = await supabaseClient.storage.createBucket('fauna_rescue_pdfs', { public: false });
console.log('✓ fauna_rescue_pdfs creado:', b2);

// Verificar
const { data: buckets } = await supabaseClient.storage.listBuckets();
console.log('✓ Todos los buckets:', buckets);
*/

-- Paso 3: Si usaste OPCIÓN B, ahora agrega las políticas manualmente:
--   Storage → fauna_impact_pdfs → RLS Policies
--   Agrega 3 políticas (SELECT, INSERT, DELETE)

-- Paso 4: ¡LISTO!
--   Ya puedes generar PDFs que se guardarán automáticamente

-- ================================================================================
-- ¡YA TERMINASTE!
-- ================================================================================
-- Ahora el flujo completo funciona:
-- 1. Llena formulario de fauna
-- 2. Confirma ubicación en mapa
-- 3. Click "Generar reporte"
-- 4. PDF se crea y se guarda en fauna_impact_pdfs
-- 5. Link aparece en "Historial de Impactos"
-- ================================================================================
