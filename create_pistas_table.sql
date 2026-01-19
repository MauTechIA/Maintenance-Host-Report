-- Script SQL para crear la tabla de pistas en Supabase
-- Ejecutar en el SQL Editor de Supabase (Dashboard → SQL Editor)

-- Crear tabla de pistas
CREATE TABLE IF NOT EXISTS pistas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insertar pistas iniciales
INSERT INTO pistas (nombre, codigo, descripcion) VALUES
('RWY 04C-22C', '04C-22C', 'Pista central 04C-22C'),
('RWY 04L-22R', '04L-22R', 'Pista lateral izquierda 04L-22R')
ON CONFLICT (nombre) DO NOTHING;

-- Crear política RLS (Row Level Security) para permitir lectura pública
ALTER TABLE pistas ENABLE ROW LEVEL SECURITY;

-- Política para permitir lectura a usuarios autenticados y anónimos
CREATE POLICY "Pistas son públicas para lectura" ON pistas
    FOR SELECT USING (true);

-- Política para permitir inserción/edición solo a usuarios autenticados (opcional)
-- Descomenta las siguientes líneas si quieres restringir la escritura:
-- CREATE POLICY "Solo usuarios autenticados pueden modificar pistas" ON pistas
--     FOR ALL USING (auth.role() = 'authenticated');

-- Crear índice para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_pistas_codigo ON pistas(codigo);
CREATE INDEX IF NOT EXISTS idx_pistas_activo ON pistas(activo);

-- Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_pistas_updated_at
    BEFORE UPDATE ON pistas
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();