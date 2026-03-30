-- ================================================================================
-- CONFIGURACIÓN SEGURA DE PDFs - SOLO AGREGA LO QUE FALTA
-- ================================================================================
-- Este script es SEGURO: Solo agrega columnas e índices si no existen
-- No intenta recrear tablas que ya existen
-- 
-- Ejecuta esto si ya tienes tablas fauna_impact_reports o fauna_rescue_reports
-- ================================================================================

-- PASO 1: Agregar columna pdf_url si no existe
ALTER TABLE fauna_impact_reports 
ADD COLUMN IF NOT EXISTS pdf_url TEXT;

ALTER TABLE fauna_rescue_reports 
ADD COLUMN IF NOT EXISTS pdf_url TEXT;

-- PASO 2: Agregar columna folio si no existe (IMPORTANTE)
ALTER TABLE fauna_impact_reports 
ADD COLUMN IF NOT EXISTS folio TEXT UNIQUE;

ALTER TABLE fauna_rescue_reports 
ADD COLUMN IF NOT EXISTS folio TEXT UNIQUE;

-- PASO 3: Agregar columna tipo_reporte si no existe
ALTER TABLE fauna_impact_reports 
ADD COLUMN IF NOT EXISTS tipo_reporte TEXT;

ALTER TABLE fauna_rescue_reports 
ADD COLUMN IF NOT EXISTS tipo_reporte TEXT DEFAULT 'Rescate';

-- PASO 4: Agregar columnas de auditoría si no existen
ALTER TABLE fauna_impact_reports 
ADD COLUMN IF NOT EXISTS estado TEXT DEFAULT 'pendiente';

ALTER TABLE fauna_rescue_reports 
ADD COLUMN IF NOT EXISTS estado TEXT DEFAULT 'pendiente';

-- PASO 5: Crear índices para mejorar performance (si no existen)
CREATE INDEX IF NOT EXISTS idx_fauna_impact_folio ON fauna_impact_reports(folio);
CREATE INDEX IF NOT EXISTS idx_fauna_impact_created_at ON fauna_impact_reports(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_fauna_impact_pdf_url ON fauna_impact_reports(pdf_url) WHERE pdf_url IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_fauna_rescue_folio ON fauna_rescue_reports(folio);
CREATE INDEX IF NOT EXISTS idx_fauna_rescue_created_at ON fauna_rescue_reports(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_fauna_rescue_pdf_url ON fauna_rescue_reports(pdf_url) WHERE pdf_url IS NOT NULL;

-- PASO 6: Verificar que las tablas tengan RLS
ALTER TABLE fauna_impact_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE fauna_rescue_reports ENABLE ROW LEVEL SECURITY;

-- PASO 7: Crear políticas si no existen (DROP IF EXISTS primero para no tener conflictos)
DROP POLICY IF EXISTS fauna_impact_select ON fauna_impact_reports;
DROP POLICY IF EXISTS fauna_impact_insert ON fauna_impact_reports;
DROP POLICY IF EXISTS fauna_impact_update ON fauna_impact_reports;
DROP POLICY IF EXISTS fauna_impact_delete ON fauna_impact_reports;

DROP POLICY IF EXISTS fauna_rescue_select ON fauna_rescue_reports;
DROP POLICY IF EXISTS fauna_rescue_insert ON fauna_rescue_reports;
DROP POLICY IF EXISTS fauna_rescue_update ON fauna_rescue_reports;
DROP POLICY IF EXISTS fauna_rescue_delete ON fauna_rescue_reports;

-- Crear nuevas políticas
CREATE POLICY fauna_impact_select ON fauna_impact_reports FOR SELECT USING (true);
CREATE POLICY fauna_impact_insert ON fauna_impact_reports FOR INSERT WITH CHECK (true);
CREATE POLICY fauna_impact_update ON fauna_impact_reports FOR UPDATE USING (true);
CREATE POLICY fauna_impact_delete ON fauna_impact_reports FOR DELETE USING (true);

CREATE POLICY fauna_rescue_select ON fauna_rescue_reports FOR SELECT USING (true);
CREATE POLICY fauna_rescue_insert ON fauna_rescue_reports FOR INSERT WITH CHECK (true);
CREATE POLICY fauna_rescue_update ON fauna_rescue_reports FOR UPDATE USING (true);
CREATE POLICY fauna_rescue_delete ON fauna_rescue_reports FOR DELETE USING (true);

-- ================================================================================
-- VERIFICACIÓN
-- ================================================================================

-- Verificar que todas las columnas existen:
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name IN ('fauna_impact_reports', 'fauna_rescue_reports')
AND column_name IN ('folio', 'pdf_url', 'tipo_reporte', 'estado')
ORDER BY table_name, ordinal_position;

-- Ver todas las columnas de fauna_impact_reports:
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'fauna_impact_reports' 
ORDER BY ordinal_position;

-- Ver todas las columnas de fauna_rescue_reports:
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'fauna_rescue_reports' 
ORDER BY ordinal_position;

-- Verificar índices creados:
SELECT indexname 
FROM pg_indexes 
WHERE schemaname = 'public' 
AND tablename IN ('fauna_impact_reports', 'fauna_rescue_reports')
ORDER BY indexname;

-- ================================================================================
-- ¡LISTO!
-- ================================================================================
-- Si no ves errores rojos arriba, todo está conectado y listo para PDFs.
-- Ahora los reportes se guardarán con folio y pdf_url automáticamente.
-- ================================================================================
