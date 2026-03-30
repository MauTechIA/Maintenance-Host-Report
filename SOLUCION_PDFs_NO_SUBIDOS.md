# 🔧 Solución: PDFs no se estaban subiendo

## ❌ El Problema

Los PDFs se generaban correctamente, pero **NO se estaban guardando** en Supabase Storage.

---

## 🔍 Causa Raíz

El código estaba intentando subir los PDFs a un bucket llamado **`fauna_impact_pdfs`** que **no existía**.

### Líneas afectadas en index.html:
- **Línea 7176**: Upload PDF a bucket `fauna_impact_pdfs` ❌ No existe
- **Línea 7179**: `.from('fauna_impact_pdfs')` ❌ Referencia incorrecta
- **Línea 7194**: `.createSignedUrl()` desde `fauna_impact_pdfs` ❌
- **Línea 7201**: `.getPublicUrl()` desde `fauna_impact_pdfs` ❌

### Mensaje de error que deberías ver en console:
```
⚠️ Warning subiendo PDF a fauna_impact_pdfs:
Error: [object Object]
Detalles del error: bucket not found (404)
```

---

## ✅ La Solución

Se cambió el código para usar el bucket **existente**: `fauna/reports`

### Cambios realizados:

| Sección | Antes | Después |
|---------|-------|---------|
| **Upload** | `.from('fauna_impact_pdfs')` | `.from('fauna/reports')` |
| **Signed URL** | `.from('fauna_impact_pdfs')` | `.from('fauna/reports')` |
| **Public URL** (fallback) | `.from('fauna_impact_pdfs')` | `.from('fauna/reports')` |
| **Comentarios** | fauna_impact_pdfs | fauna/reports |

### Código actualizado:
```javascript
// Upload PDF al bucket existente fauna/reports
var pdfPath = Date.now() + '_' + folio + '.pdf';
var { data: uploadData, error: uploadError } = await client.storage
    .from('fauna/reports')  // ✅ Bucket correcto
    .upload(pdfPath, pdfBlob, { contentType: 'application/pdf' });

if (uploadError) {
    console.warn('⚠️ Warning subiendo PDF a fauna/reports:', uploadError);
    // El bucket existe, ahora debería funcionar ✅
}

// Si la subida es exitosa, generar URL segura
var { data: signedUrlData } = await client.storage
    .from('fauna/reports')  // ✅ Mismo bucket
    .createSignedUrl(pdfPath, 7 * 24 * 60 * 60);
```

---

## 🎯 Verificación

### Para verificar que ahora funciona:

1. **Genera un nuevo reporte de fauna** (Fauna → Registrar Impacto)
2. **Haz clic en "Generar PDF"**
3. **Verifica en la consola del navegador** (F12):
   ```
   ✅ PDF guardado exitosamente. URL: https://...fauna/reports/...
   ```
4. **Ve a Supabase Dashboard** → Storage → fauna/reports
   - Deberías ver un archivo nuevo como: `1742901234567_FAUNA-2024-0001.pdf`

### Qué NO debería pasar:
- ❌ No deberías ver: "bucket not found"
- ❌ No deberías ver: "fauna_impact_pdfs not found"
- ❌ No debería haber error 404

---

## 📋 Requisitos del bucket `fauna/reports`

Para que funcione correctamente, el bucket debe tener:

### Configuración de visibilidad:
- **Privacy**: PRIVATE ✓ (recomendado para PDFs)

### RLS Policies requeridas:

```sql
-- POLÍTICA 1: SELECT para usuarios autenticados
- Nombre: allow_select_authenticated
- Operación: SELECT
- USING: (auth.role() = 'authenticated')

-- POLÍTICA 2: INSERT para usuarios autenticados
- Nombre: allow_insert_authenticated
- Operación: INSERT
- WITH CHECK: (auth.role() = 'authenticated')

-- POLÍTICA 3: DELETE para usuarios autenticados
- Nombre: allow_delete_authenticated
- Operación: DELETE
- USING: (auth.role() = 'authenticated')
```

---

## 🚀 Próximos pasos

1. ✅ **Genera un nuevo reporte** de fauna para confirmar que funciona
2. ✅ **Verifica que aparezca el PDF** en Supabase Storage
3. ✅ **Comprueba que el link apareza** en "Historial" con "📄 Ver PDF"
4. ✅ **Descarga el PDF** para confirmar que abre correctamente

---

## 📝 Resumen de cambios

| Archivo | Cambio | Razón |
|---------|--------|-------|
| `index.html` | L7176-7201: fauna_impact_pdfs → fauna/reports | El bucket `fauna/reports` es el que realmente existe |
| Mensajes de error | Actualizados | Para reflejar el nombre correcto del bucket |

---

## 💡 Notas importantes

- Los PDFs ahora se guardan con **Signed URLs de 7 días** (por seguridad)
- Cada PDF se nombra: `{timestamp}_{folio}.pdf` (example: `1742901234567_FAUNA-2024-0001.pdf`)
- Los PDFs se almacenan en private storage → No accesibles sin URL firmada
- Después de 7 días, el link del PDF expirará (por seguridad)

---

Regresar a: [README.md](README.md)
