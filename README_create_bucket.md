Instrucciones para crear el bucket `reports` usando la Service Role Key

1) ¿Dónde está la Service Role Key?
- Entra a https://app.supabase.com → tu proyecto → Settings → API.
- Busca "Service Role Key" y cópiala. Es una clave secreta: NO la pongas en código cliente ni en el archivo HTML.
- No, la `anon` key NO es la Service Role key. `anon` tiene permisos limitados y no sirve para operaciones administrativas.

2) Opción rápida (Dashboard):
- Dashboard → Storage → Create new bucket → Nombre: `reports` → Public: marca `true` para pruebas (o `false` si quieres privado).

3) Opción B (script Node.js) — ejecuta localmente en máquina segura
- Requisitos: Node.js instalado y paquete `@supabase/supabase-js`.

Pasos (PowerShell):
```powershell
# instalar dependencia (una sola vez)
npm init -y
npm install @supabase/supabase-js

# definir variables de entorno temporales (PowerShell)
$env:SUPABASE_URL = "https://TU_PROYECTO.supabase.co"
$env:SUPABASE_SERVICE_ROLE_KEY = "eyJ...."

# ejecutar script
node create_bucket.js
```

4) SQL alternativo (puede requerir permisos):
```sql
-- crear bucket (si tu rol lo permite)
insert into storage.buckets (id, name, public)
values ('reports', 'reports', true)
on conflict (id) do nothing;
```

5) Políticas recomendadas iniciales (SQL Editor):
```sql
-- permitir uploads a usuarios autenticados
create policy "Permitir subida a autenticados"
on storage.objects for insert
to authenticated
with check ( bucket_id = 'reports' );

-- permitir lectura pública (si bucket public=true)
create policy "Permitir lectura a todos"
on storage.objects for select
to public
using ( bucket_id = 'reports' );
```

6) Después de crear el bucket
- Reintenta generar un reporte desde la app. Si el PDF se sube correctamente, el registro `reports.pdf_url` se llenará.

7) Seguridad
- La Service Role Key es extremadamente potente: úsala solo en servidor o en tu máquina local en scripts administrativos.
- Nunca incluyas la Service Role Key en `Maintenance Host Report.html` ni en código que se envíe al navegador.

8) Para buckets privados (opcional)
- Si quieres mantener el bucket privado, añade la Service Role Key al código HTML (línea ~2248, reemplaza 'TU_SERVICE_ROLE_KEY_AQUI' con tu clave real).
- ⚠️ ADVERTENCIA: Esto expone la clave secreta al navegador. Úsala solo para pruebas. Para producción, crea una Edge Function en Supabase para generar signed URLs de forma segura.
- Con la clave añadida, el admin podrá ver PDFs en buckets privados mediante signed URLs temporales (válidas 1 hora).

Si quieres, ejecuto aquí mismo un script de creación (necesitaría que pegues la Service Role Key y URL —pero no es recomendable compartir claves secretas públicamente). En su lugar, ejecútalo localmente con las instrucciones anteriores y dime el resultado; yo te guío en los siguientes pasos.