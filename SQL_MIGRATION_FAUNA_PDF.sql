-- ────────────────────────────────────────────────────────────────
-- MIGRACIÓN: Habilitar PDF para Reportes de Fauna
-- ────────────────────────────────────────────────────────────────
-- IMPORTANTE: Ejecutar esta SQL en Supabase SQL Editor
-- ────────────────────────────────────────────────────────────────

-- 1. Crear bucket para almacenar PDFs de fauna
-- (Ejecutar una sola vez)
INSERT INTO storage.buckets (id, name, public)
VALUES ('fauna-reports', 'fauna-reports', false)
ON CONFLICT (id) DO NOTHING;

-- 2. Agregar columna pdf_url a tabla de impacto
-- (Si la columna ya existe, no hará nada)
ALTER TABLE fauna_impact_reports 
ADD COLUMN IF NOT EXISTS pdf_url TEXT;

-- 3. Agregar columna pdf_url a tabla de rescate
-- (Si la columna ya existe, no hará nada)
ALTER TABLE fauna_rescue_reports 
ADD COLUMN IF NOT EXISTS pdf_url TEXT;

-- 4. Verificar que las columnas existan (debugging)
-- (Ejecutar para verificar que todo está correcto)
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns
WHERE table_name IN ('fauna_impact_reports', 'fauna_rescue_reports')
AND column_name = 'pdf_url';

-- ────────────────────────────────────────────────────────────────
-- INSTRUCCIONES DE EJECUCIÓN:
-- ────────────────────────────────────────────────────────────────
-- 1. Ve a Supabase Dashboard → SQL Editor
-- 2. Copia y pega TODO este contenido
-- 3. Haz click en "Run" (ejecutar)
-- 4. Verifica que todos los comandos completaron sin errores
-- 5. Opcional: Ejecuta el comando SELECT para verificar
-- ────────────────────────────────────────────────────────────────

-- NOTA: Si todo funciona, deberías ver:
-- - Mensaje: "INSERT 0 0" (bucket ya existe o creado)
-- - Mensaje: "ALTER TABLE" (columnas agregadas)
-- - En el SELECT: Dos filas con column_name = 'pdf_url'
