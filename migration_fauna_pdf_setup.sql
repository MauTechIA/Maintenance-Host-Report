-- ====================================================================
-- Configuración de Almacenamiento y BD para PDFs de Fauna
-- ====================================================================

-- 1. Crear bucket para PDFs de fauna
-- NOTA: Si esto falla en SQL, lo haces desde Dashboard > Storage > Create bucket
--       Name: fauna-reports, Public: false
insert into storage.buckets (id, name, public)
values ('fauna-reports', 'fauna-reports', false)
on conflict (id) do nothing;

-- 2. Políticas de acceso para el bucket fauna-reports
-- Permitir lectura a usuarios autenticados
create policy "Lectura fauna-reports autenticados"
on storage.objects for select
to authenticated
using ( bucket_id = 'fauna-reports' );

-- Permitir subida a usuarios autenticados
create policy "Escritura fauna-reports autenticados"
on storage.objects for insert
to authenticated
with check ( bucket_id = 'fauna-reports' );

-- Permitir actualización a usuarios autenticados
create policy "Actualización fauna-reports autenticados"
on storage.objects for update
to authenticated
using ( bucket_id = 'fauna-reports' )
with check ( bucket_id = 'fauna-reports' );

-- Permitir eliminación a usuarios autenticados
create policy "Eliminación fauna-reports autenticados"
on storage.objects for delete
to authenticated
using ( bucket_id = 'fauna-reports' );

-- 3. Agregar columna pdf_url a fauna_impact_reports (si no existe)
alter table fauna_impact_reports
add column if not exists pdf_url text;

-- 4. Agregar columna pdf_url a fauna_rescue_reports (si no existe)
alter table fauna_rescue_reports
add column if not exists pdf_url text;

-- 5. Crear índice en pdf_url para búsquedas rápidas (opcional pero recomendado)
create index if not exists idx_fauna_impact_pdf_url on fauna_impact_reports(pdf_url);
create index if not exists idx_fauna_rescue_pdf_url on fauna_rescue_reports(pdf_url);
