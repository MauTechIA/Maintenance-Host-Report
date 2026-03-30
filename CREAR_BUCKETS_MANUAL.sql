----------------- ================================================================================
-- SOLUCIÓN MANUAL: CREAR BUCKETS SIN CODE
-- ================================================================================
-- Si el HTML no funcionó, hazlo manualmente desde Supabase Dashboard
-- (5 minutos, sin necesidad de código)
-- ================================================================================

-- PASO 1: VE A SUPABASE DASHBOARD
-- https://app.supabase.com/projects

-- Selecciona tu proyecto de fauna

-- PASO 2: VE A STORAGE
-- En el menú izquierdo, haz clic en "Storage"

-- PASO 3: CREAR BUCKET 1: fauna_impact_pdfs
/*
1. Haz clic en: [+ Create new bucket]
2. Nombre: fauna_impact_pdfs
3. Privacy: PRIVATE ✓
4. Haz clic: [Create bucket]
5. ESPERA a que se cree (verás "✓ Created")
*/

-- PASO 4: CREAR BUCKET 2: fauna_rescue_pdfs
/*
1. Haz clic en: [+ Create new bucket]
2. Nombre: fauna_rescue_pdfs
3. Privacy: PRIVATE ✓
4. Haz clic: [Create bucket]
5. ESPERA a que se cree
*/

-- PASO 5: AGREGAR POLÍTICAS A fauna_impact_pdfs
/*
1. En la lista de buckets, encontrarás: fauna_impact_pdfs
2. Haz clic en él para abrirlo
3. Ve a la pestaña: "RLS Policies" (arriba)
4. Haz clic en: [+ New policy]

POLÍTICA 1: allow_select_all (LECTURA PÚBLICA)
──────────────────────────────────────────────
- Nombre: allow_select_all
- Operación: SELECT (SELECT)
- Roles: "authenticated" y "anon"
- USING condition: true
→ Click: [Create policy]

POLÍTICA 2: allow_insert_authenticated (SUBIDA)
─────────────────────────────────────────────────
- Nombre: allow_insert_authenticated
- Operación: INSERT (INSERT)
- Roles: "authenticated"
- WITH CHECK condition: true
→ Click: [Create policy]

POLÍTICA 3: allow_delete_authenticated (ELIMINACIÓN)
──────────────────────────────────────────────────────
- Nombre: allow_delete_authenticated
- Operación: DELETE (DELETE)
- Roles: "authenticated"
- USING condition: true
→ Click: [Create policy]
*/

-- PASO 6: AGREGAR LAS MISMAS 3 POLÍTICAS A fauna_rescue_pdfs
/*
Repite EXACTAMENTE lo que hiciste en PASO 5
pero para el bucket: fauna_rescue_pdfs
*/

-- ================================================================================
-- VERIFICAR QUE LOS BUCKETS EXISTEN
-- ================================================================================

-- En Supabase Dashboard → Storage → Buckets
-- Deberías ver:

/*
✓ fauna_impact_pdfs   (PRIVATE)
✓ fauna_rescue_pdfs   (PRIVATE)

Si ves esto, ¡YA ESTÁ HECHO!
*/

-- ================================================================================
-- ALTERNATIVA: USAR SUPABASE CLI (Si tienes experiencia con terminal)
-- ================================================================================

/*
Si tienes Supabase CLI instalado:

npm install -g supabase

Luego en terminal:

supabase login
supabase projects list
supabase storage create fauna_impact_pdfs
supabase storage create fauna_rescue_pdfs

Pero NO recomiendo si es la primera vez.
*/

-- ================================================================================
-- ALTERNATIVA 2: USAR LA EXTENSIÓN DE VS CODE
-- ================================================================================

/*
¿Tienes VS Code?

1. Instala: "Supabase" extension (por Supabase)
2. Ve a la pestaña de Supabase en VS Code
3. Conecta tu proyecto
4. Storage → Click derecho → Create Bucket

Pero esto también es más complicado.
*/

-- ================================================================================
-- ALTERNATIVA 3: USAR CURL EN TERMINAL (RÁPIDO - RECOMENDADO)
-- ================================================================================

/*
Necesitas:
1. Tu URL de Supabase: https://xxxxx.supabase.co
2. Tu Service Role Key (PRIVADA, en Supabase Dashboard → Settings → API)

LUEGO, abre Terminal/Powershell y ejecuta:

PARA WINDOWS (PowerShell):
───────────────────────────

$supabaseUrl = "https://TU_PROYECTO.supabase.co"
$serviceRoleKey = "TU_SERVICE_ROLE_KEY"

# Crear bucket 1
curl -X POST `
  "$supabaseUrl/storage/v1/buckets" `
  -H "Authorization: Bearer $serviceRoleKey" `
  -H "Content-Type: application/json" `
  -d @"{`
    `"name`": `"fauna_impact_pdfs`",`
    `"public`": false,`
    `"file_size_limit`": 52428800`
  }"

# Crear bucket 2
curl -X POST `
  "$supabaseUrl/storage/v1/buckets" `
  -H "Authorization: Bearer $serviceRoleKey" `
  -H "Content-Type: application/json" `
  -d @"{`
    `"name`": `"fauna_rescue_pdfs`",`
    `"public`": false,`
    `"file_size_limit`": 52428800`
  }"


PARA MAC/LINUX:
───────────────

export SUPABASE_URL="https://TU_PROYECTO.supabase.co"
export SERVICE_ROLE_KEY="TU_SERVICE_ROLE_KEY"

# Crear bucket 1
curl -X POST \
  "$SUPABASE_URL/storage/v1/buckets" \
  -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "fauna_impact_pdfs",
    "public": false,
    "file_size_limit": 52428800
  }'

# Crear bucket 2
curl -X POST \
  "$SUPABASE_URL/storage/v1/buckets" \
  -H "Authorization: Bearer $SERVICE_ROLE_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "fauna_rescue_pdfs",
    "public": false,
    "file_size_limit": 52428800
  }'

Ver respuesta: Si ves "name": "fauna_impact_pdfs" → ¡LISTO! ✅
*/

-- ================================================================================
-- ¿DÓNDE ENCONTRAR TU SERVICE ROLE KEY?
-- ================================================================================

/*
1. Ve a: Supabase Dashboard
2. Proyecto → Settings (esquina inferior izquierda)
3. Ve a: API
4. Encontrarás dos llaves:
   - anon public key (pública, sin peligro)
   - service_role key (PRIVADA, ¡NUNCA compartirla!)
5. Copia service_role key
6. Pégala en el curl de arriba
*/

-- ================================================================================
-- CHECKLIST: ¿CUÁL MÉTODO ELEGIR?
-- ================================================================================

/*
┌─────────────────────────────────────────────────┐
│ RECOMENDACION POR NIVEL                         │
├─────────────────────────────────────────────────┤
│ PRINCIPIANTE                                    │
│ → Método 1: Manual en Dashboard (paso a paso)   │
│   (Lo más visual y fácil)                       │
│                                                 │
│ INTERMEDIO                                      │
│ → Método 3: cURL en Terminal (rápido)           │
│   (Si sabes usar terminal)                      │
│                                                 │
│ AVANZADO                                        │
│ → Supabase CLI o extensión VS Code              │
│   (Si has usado estas herramientas antes)       │
└─────────────────────────────────────────────────┘
*/

-- ================================================================================
-- PASO A PASO VISUAL (MÉTODO 1 - RECOMENDADO PARA TI)
-- ================================================================================

/*
MINUTO 1-2: Crear bucket 1

1. Abre: https://app.supabase.com/projects
2. Selecciona tu proyecto
3. En el menú izquierdo: Click en "Storage"
4. Arriba a la derecha: Click en "+ Create new bucket"
   ├─ Nombre: fauna_impact_pdfs
   ├─ Privacy: PRIVATE (radio button)
   └─ Click: "Create bucket"
5. Espera a que se cree (verás una animación)
6. ✓ Listo


MINUTO 2-3: Crear bucket 2

1. Click en "+ Create new bucket"
   ├─ Nombre: fauna_rescue_pdfs
   ├─ Privacy: PRIVATE
   └─ Click: "Create bucket"
2. Espera a que se cree
3. ✓ Listo


MINUTO 3-5: Agregar políticas

1. En la lista, encontrarás: fauna_impact_pdfs
2. Haz click en el nombre (se abre el bucket)
3. Ve a la pestaña "RLS Policies" (arriba)
4. Click en "+ New policy" (3 VECES)

Política 1/3:
   ├─ Nombre: allow_select_all
   ├─ Operación: SELECT
   ├─ Roles: [x] authenticated, [x] anon
   ├─ USING: true
   └─ Click: "Create policy"

Política 2/3:
   ├─ Nombre: allow_insert_authenticated
   ├─ Operación: INSERT
   ├─ Roles: [x] authenticated
   ├─ WITH CHECK: true
   └─ Click: "Create policy"

Política 3/3:
   ├─ Nombre: allow_delete_authenticated
   ├─ Operación: DELETE
   ├─ Roles: [x] authenticated
   ├─ USING: true
   └─ Click: "Create policy"

5. Repetir EXACTO para fauna_rescue_pdfs
6. ✓ ¡LISTO!


TOTAL: 5 minutos
*/

-- ================================================================================
-- ¿LISTO?
-- ================================================================================

/*
Después de crear los buckets y políticas:

1. Los buckets aparecerán en Storage
2. Ya puedes generar PDFs
3. Los PDFs se guardarán automáticamente
4. Links aparecerán en "Historial de Impactos"
*/
