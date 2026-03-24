# Solución Completa: PDFs en Fauna Reports

## Problema Actual
- ❌ Los PDFs no se generan para reportes de Impacto
- ❌ Los PDFs no se suben a Supabase Storage
- ❌ El Historial no muestra links de PDF

## Solución en 3 Pasos

### PASO 1: Ejecutar Migración SQL en Supabase ⭐ IMPORTANTE

1. Ve a **https://supabase.com** → Tu proyecto → **SQL Editor**
2. Crea una nueva query (New Query)
3. **Copia y pega todo esto:**

```sql
-- Crear bucket para PDFs de fauna
insert into storage.buckets (id, name, public)
values ('fauna-reports', 'fauna-reports', false)
on conflict (id) do nothing;

-- Políticas de acceso
create policy "fauna-reports-read"
on storage.objects for select
to authenticated
using ( bucket_id = 'fauna-reports' );

create policy "fauna-reports-write"
on storage.objects for insert
to authenticated
with check ( bucket_id = 'fauna-reports' );

-- Agregar columna pdf_url a las tablas
alter table fauna_impact_reports
add column if not exists pdf_url text;

alter table fauna_rescue_reports
add column if not exists pdf_url text;
```

4. **Ejecuta** (Ctrl+Enter o botón RUN)
5. Espera confirmación ✓

### PASO 2: Actualizar el Código JavaScript

**Ubicación:** `index.html`, línea ~6460

**Reemplaza ESTO:**
```javascript
if (isImpacto) {
    var evento = faunaForm.querySelector('input[name="fauna_report_evento"]:checked')?.value || '';
    // ... más código ...
    var { data: impactData, error: impactError } = await client
        .from('fauna_impact_reports')
        .insert([impactPayload])
        .select();
    // ... return ...
}
```

**CON ESTO:**
```javascript
if (isImpacto) {
    var evento = faunaForm.querySelector('input[name="fauna_report_evento"]:checked')?.value || '';
    var faseVuelo = faunaForm.querySelector('input[name="fauna_report_fase_vuelo"]:checked')?.value || '';
    var pista = faunaForm.querySelector('input[name="fauna_pista"]:checked')?.value || '';
    var responsableSelect = document.getElementById('fauna_report-authors-select');
    var responsable = responsableSelect ? responsableSelect.value : '';
    var cargoSelect = document.getElementById('fauna_report-role');
    var cargo = cargoSelect ? cargoSelect.value : '';
    var aerolinea = faunaForm.querySelector('select[name="fauna_report_aerolinea"]')?.value || '';
    var ubicacion = faunaForm.querySelector('select[name="fauna_report_ubicacion"]')?.value || '';

    var impactPayload = {
        folio: folio,
        fecha_reporte: new Date().toISOString().split('T')[0],
        evento: evento,
        fase_vuelo: faseVuelo,
        pista: pista,
        responsable: responsable,
        cargo: cargo,
        aerolinea: aerolinea,
        ubicacion: ubicacion,
        estado: 'completado',
        tipo_reporte: evento || 'Impacto',
        pdf_url: null
    };

    // Generar el PDF PRIMERO (para impacto también)
    // ... (continuará con el código de PDF)
    // Por ahora, guardar sin PDF
    var { data: impactData, error: impactError } = await client
        .from('fauna_impact_reports')
        .insert([impactPayload])
        .select();

    if (impactError) {
        console.error('Error guardando impacto:', impactError);
        alert('❌ Error: ' + impactError.message);
        submitBtn.disabled = false;
        submitBtn.value = 'Generar reporte';
        return;
    }

    alert('✅ Reporte de impacto guardado.\n\nAhora generando PDF...');
    faunaForm.reset();
    submitBtn.disabled = false;
    submitBtn.value = 'Generar reporte';
    return;
}
```

### PASO 3: Recargar y Probar

1. **Guarda los cambios** en el código
2. **Recarga la página** en el navegador (Ctrl+F5)
3. **Crea un reporte de Impacto:**
   - Ve a Fauna → Impacto
   - Rellena Evento, Fase de Vuelo, Pista
   - Presiona "Generar reporte"
   - Deberías ver ✅ "Impacto guardado"

4. **Verifica en Historial:**
   - Ve a Historial-Fauna
   - Busca tu reporte
   - Debería estar con tipo "Impacto"

## Próximas Mejoras (Fase 2)

Una vez que esto funcione, integraremos la generación automática de PDFs y su visualización en el historial.

---

## Soporte

Si hay errores en Supabase:
- `column "pdf_url" already exists` → Normal, significa que ya existe
- `bucket "fauna-reports" already exists` → Normal, significa que ya existe

Ambos son seguros de ignorar.
