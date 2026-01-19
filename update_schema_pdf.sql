-- 1. Crear bucket de almacenamiento para reportes
-- Nota: Esto debe hacerse desde el Dashboard de Supabase si no tienes permisos de superadmin SQL, 
-- pero aquí está el comando si es posible ejecutarlo.
-- Si no funciona, ve a Storage -> Create new bucket -> Name: 'reports' -> Public: false

insert into storage.buckets (id, name, public)
values ('reports', 'reports', false)
on conflict (id) do nothing;

-- 2. Políticas de seguridad para el bucket 'reports'
-- Permitir lectura a usuarios autenticados (o solo admins, según prefieras)
create policy "Permitir lectura a autenticados"
on storage.objects for select
to authenticated
using ( bucket_id = 'reports' );

-- Permitir subida a usuarios autenticados (inspectores, admins)
create policy "Permitir subida a autenticados"
on storage.objects for insert
to authenticated
with check ( bucket_id = 'reports' );

-- 3. Agregar columna pdf_url a la tabla reports
alter table reports 
add column if not exists pdf_url text;

-- 4. Agregar columna pista a la tabla reports
alter table reports 
add column if not exists pista text;
