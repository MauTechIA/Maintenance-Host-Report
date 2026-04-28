-- Reestructura fauna: unifica reportes en una sola tabla funcional.
-- Versión SIN políticas RLS (solicitado temporalmente).

begin;

create extension if not exists pgcrypto;

-- Tabla nueva unificada
create table if not exists public.fauna_reports (
  id uuid not null default gen_random_uuid(),
  created_at timestamptz not null default now(),
  fecha_reporte date not null default current_date,

  -- Identidad y clasificación del reporte
  folio text not null,
  tipo_reporte text not null,
  estado varchar(50) null default 'pendiente',

  -- Datos comunes
  turno varchar(50) null,
  pista varchar(50) null,
  responsable varchar(255) null,
  cargo varchar(100) null,
  representante_afac varchar(255) null,
  firma_aifa text null,
  firma_afac text null,
  observaciones text null,
  pdf_url text null,

  -- Datos de impacto
  aerolinea varchar(100) null,
  evento text null,
  fase_vuelo text null,

  -- Nuevo modelo de localización
  zona varchar(100) null,
  ubicacion_texto varchar(500) null,
  ubicacion_lat numeric(10, 8) null,
  ubicacion_lng numeric(11, 8) null,

  -- Datos de rescate
  institucion_responsable varchar(255) null,
  clase varchar(100) null,
  clase_otro varchar(255) null,
  especie varchar(255) null,
  sitio_reubicacion varchar(255) null,

  -- Detalle estructurado del evento (impacto/rescate)
  detalle_items jsonb not null default '[]'::jsonb,
  evidencias jsonb not null default '[]'::jsonb,

  constraint fauna_reports_pkey primary key (id),
  constraint fauna_reports_folio_key unique (folio),
  constraint fauna_reports_tipo_chk check (tipo_reporte in ('Impacto', 'Posible Impacto', 'Rescate')),
  constraint fauna_reports_coords_chk check (
    (ubicacion_lat is null and ubicacion_lng is null)
    or
    (ubicacion_lat is not null and ubicacion_lng is not null)
  )
) tablespace pg_default;

create index if not exists idx_fauna_reports_created_at on public.fauna_reports using btree (created_at desc) tablespace pg_default;
create index if not exists idx_fauna_reports_fecha on public.fauna_reports using btree (fecha_reporte) tablespace pg_default;
create index if not exists idx_fauna_reports_tipo on public.fauna_reports using btree (tipo_reporte) tablespace pg_default;
create index if not exists idx_fauna_reports_pista on public.fauna_reports using btree (pista) tablespace pg_default;
create index if not exists idx_fauna_reports_clase on public.fauna_reports using btree (clase) tablespace pg_default;
create index if not exists idx_fauna_reports_folio on public.fauna_reports using btree (folio) tablespace pg_default;
create index if not exists idx_fauna_reports_pdf_url on public.fauna_reports using btree (pdf_url) tablespace pg_default where (pdf_url is not null);
create index if not exists idx_fauna_reports_detalle_items on public.fauna_reports using gin (detalle_items) tablespace pg_default;

-- Migración de data legacy: Impactos
insert into public.fauna_reports (
  id, created_at, fecha_reporte, folio, tipo_reporte, estado,
  turno, pista, responsable, cargo, representante_afac,
  firma_aifa, firma_afac, observaciones, pdf_url,
  aerolinea, evento, fase_vuelo,
  zona, ubicacion_texto, ubicacion_lat, ubicacion_lng,
  detalle_items, evidencias
)
select
  r.id,
  r.created_at,
  coalesce(r.fecha_reporte, current_date),
  coalesce(r.folio, 'LEGACY-IMP-' || to_char(r.created_at, 'YYYYMMDD-HH24MISS') || '-' || left(r.id::text, 8)),
  coalesce(r.tipo_reporte, 'Impacto'),
  r.estado,
  r.turno,
  r.pista,
  r.responsable,
  r.cargo,
  r.representante_afac,
  r.firma_aifa,
  r.firma_afac,
  r.observaciones,
  r.pdf_url,
  r.aerolinea,
  r.evento,
  r.fase_vuelo,
  r.ubicacion,
  null,
  null,
  null,
  coalesce(
    (
      select jsonb_agg(
        jsonb_build_object(
          'id', i.id,
          'tipo_item', i.tipo_item,
          'lugar', i.lugar,
          'especie', i.especie,
          'cantidad', i.cantidad,
          'condicion', i.condicion,
          'observaciones', i.observaciones,
          'prioridad', i.prioridad
        )
      )
      from public.fauna_impact_items i
      where i.report_id = r.id
    ),
    '[]'::jsonb
  ),
  '[]'::jsonb
from public.fauna_impact_reports r
on conflict (folio) do nothing;

-- Migración de data legacy: Rescates
insert into public.fauna_reports (
  id, created_at, fecha_reporte, folio, tipo_reporte, estado,
  turno, pista, responsable, cargo,
  firma_aifa, firma_afac, observaciones, pdf_url,
  institucion_responsable, clase, clase_otro, especie, sitio_reubicacion,
  zona, ubicacion_texto, ubicacion_lat, ubicacion_lng,
  detalle_items, evidencias
)
select
  r.id,
  r.created_at,
  coalesce(r.fecha_reporte, current_date),
  coalesce(r.folio, 'LEGACY-RES-' || to_char(r.created_at, 'YYYYMMDD-HH24MISS') || '-' || left(r.id::text, 8)),
  coalesce(r.tipo_reporte, 'Rescate'),
  r.estado,
  r.turno,
  r.pista,
  r.responsable,
  r.cargo,
  r.firma_aifa,
  r.firma_afac,
  r.observaciones,
  r.pdf_url,
  r.institucion_responsable,
  r.clase,
  r.clase_otro,
  r.especie,
  r.sitio_reubicacion,
  null,
  r.sitio_rescate,
  r.sitio_rescate_lat,
  r.sitio_rescate_lng,
  '[]'::jsonb,
  coalesce(
    (
      select jsonb_agg(
        jsonb_build_object(
          'id', p.id,
          'tipo_foto', p.tipo_foto,
          'photo_url', p.photo_url,
          'nombre_archivo', p.nombre_archivo
        )
      )
      from public.fauna_rescue_photos p
      where p.rescue_report_id = r.id
    ),
    '[]'::jsonb
  )
from public.fauna_rescue_reports r
on conflict (folio) do nothing;

-- Eliminar tablas legacy una vez migrada la información
-- NOTA: este bloque asume que ya validaste conteos y muestras en fauna_reports.
drop table if exists public.fauna_impact_items;
drop table if exists public.fauna_rescue_photos;
drop table if exists public.fauna_impact_reports;
drop table if exists public.fauna_rescue_reports;

commit;
