-- ================================================================================
-- CONFIGURACIÓN DE ALMACENAMIENTO PARA PDFS DE REPORTES DE FAUNA
-- ================================================================================
-- Este script configura las tablas y políticas necesarias para almacenar PDFs
-- de reportes de fauna (impacto y rescate) en Supabase Storage
-- 
-- EJECUCIÓN:
-- 1. Ir a Supabase Dashboard -> SQL Editor
-- 2. Crear una nueva query
-- 3. Copiar y ejecutar este contenido
-- 4. Luego crear los buckets desde Storage UI (ver instrucciones abajo)
-- ================================================================================

-- PASO 1: Asegurar que la tabla fauna_impact_reports existe y tiene la columna pdf_url
-- Si la tabla no existe, crearla:
CREATE TABLE IF NOT EXISTS fauna_impact_reports (
    id BIGSERIAL PRIMARY KEY,
    folio TEXT UNIQUE,
    fecha_reporte DATE,
    evento TEXT,
    tipo_reporte TEXT,
    ubicacion TEXT,
    responsable TEXT,
    estado TEXT DEFAULT 'pendiente',
    pdf_url TEXT,
    datos_completos JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Si la tabla ya existe, asegurar que tiene la columna pdf_url:
ALTER TABLE fauna_impact_reports ADD COLUMN IF NOT EXISTS pdf_url TEXT;

-- PASO 2: Asegurar que la tabla fauna_rescue_reports existe y tiene la columna pdf_url
CREATE TABLE IF NOT EXISTS fauna_rescue_reports (
    id BIGSERIAL PRIMARY KEY,
    folio TEXT UNIQUE,
    fecha_reporte DATE,
    tipo_reporte TEXT DEFAULT 'Rescate',
    especie TEXT,
    clase TEXT,
    sitio_rescate TEXT,
    ubicacion TEXT,
    responsable TEXT,
    estado TEXT DEFAULT 'pendiente',
    pdf_url TEXT,
    datos_completos JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Si la tabla ya existe, asegurar que tiene la columna pdf_url:
ALTER TABLE fauna_rescue_reports ADD COLUMN IF NOT EXISTS pdf_url TEXT;

-- PASO 3: Crear índices para mejorar performance
CREATE INDEX IF NOT EXISTS idx_fauna_impact_folio ON fauna_impact_reports(folio);
CREATE INDEX IF NOT EXISTS idx_fauna_impact_created_at ON fauna_impact_reports(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_fauna_impact_pdf_url ON fauna_impact_reports(pdf_url) WHERE pdf_url IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_fauna_rescue_folio ON fauna_rescue_reports(folio);
CREATE INDEX IF NOT EXISTS idx_fauna_rescue_created_at ON fauna_rescue_reports(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_fauna_rescue_pdf_url ON fauna_rescue_reports(pdf_url) WHERE pdf_url IS NOT NULL;

-- PASO 4: Habilitar RLS en las tablas (Row Level Security)
ALTER TABLE fauna_impact_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE fauna_rescue_reports ENABLE ROW LEVEL SECURITY;

-- PASO 5: Crear políticas de lectura (permitir que todos lean)
CREATE POLICY fauna_impact_select ON fauna_impact_reports FOR SELECT USING (true);
CREATE POLICY fauna_impact_insert ON fauna_impact_reports FOR INSERT WITH CHECK (true);
CREATE POLICY fauna_impact_update ON fauna_impact_reports FOR UPDATE USING (true);
CREATE POLICY fauna_impact_delete ON fauna_impact_reports FOR DELETE USING (true);

CREATE POLICY fauna_rescue_select ON fauna_rescue_reports FOR SELECT USING (true);
CREATE POLICY fauna_rescue_insert ON fauna_rescue_reports FOR INSERT WITH CHECK (true);
CREATE POLICY fauna_rescue_update ON fauna_rescue_reports FOR UPDATE USING (true);
CREATE POLICY fauna_rescue_delete ON fauna_rescue_reports FOR DELETE USING (true);

-- PASO 6: Crear vista para historial combinado de reportes
CREATE OR REPLACE VIEW fauna_reports_history AS
SELECT 
    id,
    folio,
    fecha_reporte,
    tipo_reporte,
    evento as especie,
    ubicacion,
    responsable,
    estado,
    pdf_url,
    'impacto' as categoria,
    created_at
FROM fauna_impact_reports
UNION ALL
SELECT 
    id,
    folio,
    fecha_reporte,
    tipo_reporte,
    especie,
    ubicacion,
    responsable,
    estado,
    pdf_url,
    'rescate' as categoria,
    created_at
FROM fauna_rescue_reports
ORDER BY created_at DESC;

-- PASO 7: Crear vista para estadísticas
CREATE OR REPLACE VIEW fauna_reports_stats AS
SELECT 
    DATE_TRUNC('month', fecha_reporte)::DATE as mes,
    tipo_reporte,
    COUNT(*) as total,
    COUNT(CASE WHEN pdf_url IS NOT NULL THEN 1 END) as con_pdf
FROM fauna_impact_reports
WHERE fecha_reporte IS NOT NULL
GROUP BY DATE_TRUNC('month', fecha_reporte), tipo_reporte
UNION ALL
SELECT 
    DATE_TRUNC('month', fecha_reporte)::DATE as mes,
    tipo_reporte,
    COUNT(*) as total,
    COUNT(CASE WHEN pdf_url IS NOT NULL THEN 1 END) as con_pdf
FROM fauna_rescue_reports
WHERE fecha_reporte IS NOT NULL
GROUP BY DATE_TRUNC('month', fecha_reporte), tipo_reporte;

-- ================================================================================
-- INSTRUCCIONES PARA CREAR BUCKETS EN SUPABASE STORAGE UI
-- ================================================================================
-- 
-- BUCKET 1: fauna_impact_pdfs (Para PDFs de reportes de impacto)
-- ──────────────────────────────────────────────────────────────
-- 1. Ir a: Supabase Dashboard → Storage → Create new bucket
-- 2. Nombre: fauna_impact_pdfs
-- 3. Privacidad: PRIVATE (recomendado, aunque puede ser PUBLIC para pruebas)
-- 4. Crear el bucket
-- 5. En "Policies", agregar las siguientes políticas:
--
--    Política 1 - Permitir lectura a todos:
--    - Nombre: "Allow select for all"
--    - Operación: SELECT
--    - Roles: authenticated, anon
--    - USING: true
--
--    Política 2 - Permitir insert a usuarios autenticados:
--    - Nombre: "Allow insert for authenticated"
--    - Operación: INSERT
--    - Roles: authenticated
--    - WITH CHECK: true
--
--    Política 3 - Permitir delete a usuarios autenticados:
--    - Nombre: "Allow delete for authenticated"
--    - Operación: DELETE
--    - Roles: authenticated
--    - USING: true
--
-- BUCKET 2: fauna_rescue_pdfs (Para PDFs de reportes de rescate)
-- ──────────────────────────────────────────────────────────────
-- 1. Ir a: Supabase Dashboard → Storage → Create new bucket
-- 2. Nombre: fauna_rescue_pdfs
-- 3. Privacidad: PRIVATE (recomendado, aunque puede ser PUBLIC para pruebas)
-- 4. Crear el bucket
-- 5. Aplicar las MISMAS políticas que en fauna_impact_pdfs
--
-- ================================================================================
-- VERIFICACIÓN POST-INSTALACIÓN
-- ================================================================================

-- Verificar que las tablas se crearon correctamente:
SELECT table_name 
FROM information_schema.tables 
WHERE table_name IN ('fauna_impact_reports', 'fauna_rescue_reports')
AND table_schema = 'public';

-- Verificar que las columnas pdf_url existen:
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name IN ('fauna_impact_reports', 'fauna_rescue_reports')
AND column_name = 'pdf_url';

-- Verificar que los índices fueron creados:
SELECT indexname 
FROM pg_indexes 
WHERE schemaname = 'public' 
AND tablename IN ('fauna_impact_reports', 'fauna_rescue_reports');

-- Ver las vistas creadas:
SELECT table_name 
FROM information_schema.views 
WHERE table_schema = 'public' 
AND table_name LIKE 'fauna_%';

-- ================================================================================
-- EJEMPLOS DE CONSULTAS ÚTILES
-- ================================================================================

-- Reportes de impacto sin PDF (necesitan generarse):
SELECT id, folio, evento, fecha_reporte 
FROM fauna_impact_reports 
WHERE pdf_url IS NULL 
ORDER BY created_at DESC;

-- Historial combinado de todos los reportes con PDF:
SELECT * FROM fauna_reports_history 
WHERE pdf_url IS NOT NULL 
ORDER BY created_at DESC;

-- Estadísticas mensuales:
SELECT * FROM fauna_reports_stats 
ORDER BY mes DESC;

-- Reportes de este mes:
SELECT 
    folio, 
    tipo_reporte, 
    fecha_reporte, 
    responsable,
    CASE WHEN pdf_url IS NOT NULL THEN 'Sí' ELSE 'No' END as tiene_pdf
FROM fauna_reports_history
WHERE DATE_TRUNC('month', fecha_reporte) = DATE_TRUNC('month', NOW())
ORDER BY fecha_reporte DESC;

-- ================================================================================
-- NOTAS IMPORTANTES
-- ================================================================================
-- 
-- 1. PRIVACIDAD:
--    - Si los buckets son PRIVATE, necesitarás generar Signed URLs para descargar
--    - Si son PUBLIC, cualquiera con el URL puede acceder
--    - Recomendación: Usar PRIVATE con políticas RLS bien configuradas
--
-- 2. TAMAÑO:
--    - Los PDFs se almacenan como base64 en la BD durante la generación
--    - El bucket de Storage guarda solo el archivo PDF final
--    - Asegurar que Supabase Storage tiene suficiente espacio configurado
--
-- 3. LIMPIEZA:
--    - Los archivos antiguos en Storage no se eliminan automáticamente
--    - Considerar política de retención o script de limpieza periódica
--
-- 4. VERIFICACIÓN:
--    - Después de ejecutar este script, ir a Supabase Dashboard
--    - Verificar que fauna_impact_reports y fauna_rescue_reports existan en SQL Editor
--    - Verificar que los buckets existan en Storage UI
--    - Probar generando un PDF desde la aplicación
--
-- ================================================================================
