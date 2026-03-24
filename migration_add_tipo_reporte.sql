-- ====================================================================
-- Agregar columna tipo_reporte a fauna_impact_reports
-- ====================================================================
-- Esta migración agrega un campo explícito para almacenar el tipo de reporte.
-- Esto hace que sea más fácil y confiable determinar si un registro es un 
-- 'Impacto' o 'Posible Impacto'

ALTER TABLE fauna_impact_reports
ADD COLUMN IF NOT EXISTS tipo_reporte TEXT DEFAULT 'Impacto';

-- Para reportes existentes, rellenar tipo_reporte basado en el campo evento
UPDATE fauna_impact_reports 
SET tipo_reporte = COALESCE(evento, 'Impacto')
WHERE tipo_reporte = 'Impacto' OR tipo_reporte IS NULL;

-- ====================================================================
-- Agregar columna tipo_reporte a fauna_rescue_reports
-- ====================================================================
ALTER TABLE fauna_rescue_reports
ADD COLUMN IF NOT EXISTS tipo_reporte TEXT DEFAULT 'Rescate';

-- Para reportes existentes, establecer el tipo
UPDATE fauna_rescue_reports
SET tipo_reporte = 'Rescate'
WHERE tipo_reporte = 'Rescate' OR tipo_reporte IS NULL;
