-- 1. Crear bucket de almacenamiento para reportes (PDFs)
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

-- ─────────────────────────────────────────────────────────────
-- 5. Bucket de almacenamiento para evidencias fotográficas
-- ─────────────────────────────────────────────────────────────
-- Si no puedes ejecutarlo aquí, ve a:
--   Supabase Dashboard → Storage → Create new bucket
--   Name: 'photos'  |  Public: false

insert into storage.buckets (id, name, public)
values ('photos', 'photos', false)
on conflict (id) do nothing;

-- Políticas del bucket 'photos'
create policy "Permitir lectura fotos a autenticados"
on storage.objects for select
to authenticated
using ( bucket_id = 'photos' );

create policy "Permitir subida fotos a autenticados"
on storage.objects for insert
to authenticated
with check ( bucket_id = 'photos' );

-- ─────────────────────────────────────────────────────────────
-- 6. Tabla item_photos: almacena las evidencias fotográficas
--    vinculadas a cada ítem de un reporte
-- ─────────────────────────────────────────────────────────────
create table if not exists item_photos (
    id              uuid primary key default gen_random_uuid(),
    report_id       uuid not null references reports(id) on delete cascade,
    item_id         text not null,          -- id del checkbox del item (ej. "tipo_area_movimiento")
    item_categoria  text not null,          -- nombre legible del item (ej. "Area de Movimiento")
    item_numero     integer not null,       -- número de ítem en el reporte (1, 2, 3…)
    photo_url       text not null,          -- path en el bucket 'photos'
    photo_name      text,                   -- nombre original del archivo
    created_at      timestamptz default now()
);

-- Índice para consultas por reporte
create index if not exists item_photos_report_id_idx on item_photos(report_id);

-- Row Level Security
alter table item_photos enable row level security;

create policy "Autenticados pueden ver fotos"
on item_photos for select
to authenticated
using (true);

create policy "Autenticados pueden insertar fotos"
on item_photos for insert
to authenticated
with check (true);
