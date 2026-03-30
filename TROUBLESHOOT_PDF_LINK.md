# 🔍 Troubleshooting: "No aparece Ver PDF"

## ¿Por qué no aparece el botón "📄 Ver PDF"?

El botón "Ver PDF" solo aparece si:
1. ✅ El PDF se subió exitosamente a Supabase
2. ✅ Se generó una URL válida  
3. ✅ Esa URL se guardó en la base de datos

Si no aparece, uno de estos 3 pasos falló.

---

## 🔧 Cómo Diagnosticar

### PASO 1: Abre la Consola (F12)

**Windows/Chrome**: `F12` → tab "Console"  
**Firefox**: `F12` → tab "Console"  

### PASO 2: Genera un nuevo reporte de Fauna

1. Ve a "Fauna" en tu app
2. Haz clic en "Registrar Impacto"
3. Llena el formulario
4. Haz clic en **"Generar PDF"**

### PASO 3: Observa los logs en la consola

Busca estos mensajes en orden:

```
📤 Intentando subir PDF a fauna/reports con ruta: [timestamp]_FAUNA-XXXX.pdf
✅ PDF subido exitosamente al storage
🔗 Generando URL firmada para: [ruta]
✅ URL firmada generada correctamente ← ¡IMPORTANTE!
💾 Guardando reporte en fauna_impact_reports con pdf_url: https://...
✅ Reporte guardado exitosamente
✅ Verificación - pdf_url guardado correctamente: https://...
```

---

## ❌ Escenarios de Error

### Escenario 1: Error "bucket not found"

```
❌ ERROR al subir PDF a fauna/reports:
Error: [object Object]
Error reason: bucket not found
```

**Causa**: El bucket `fauna/reports` no existe o no tienes permisos  
**Solución**:
1. Ve a Supabase Dashboard
2. Storage → Verifica que `fauna/reports` exista
3. Si no existe, créalo como PRIVATE
4. Verifica que tengas RLS Policies configuradas

### Escenario 2: Error generando URL

```
⚠️ Error generando Signed URL: ...
```

**Causa**: El bucket existe pero las RLS Policies no permiten acceso  
**Solución**: Agrega estas 3 políticas al bucket `fauna/reports`:

```sql
POLICY 1 - allow_select
  Operación: SELECT
  USING: true

POLICY 2 - allow_insert  
  Operación: INSERT
  WITH CHECK: true

POLICY 3 - allow_delete
  Operación: DELETE
  USING: true
```

### Escenario 3: El PDF se guarda pero sin URL

```
⚠️ ADVERTENCIA: El reporte se guardó pero sin pdf_url
```

**Causa**: La variable `pdfUrl` es `null` (no se generó URL)  
**Problema**: El PDF se guardó SIN URL → No aparece en historial

**Solución**: Revisa los logs anteriores para ver dónde falló el proceso

---

## ✅ Verificación Final

Una vez que veas todos esos logs ✅, sigue estos pasos:

1. **Ve al Historial** de reportes de Fauna
2. **Busca tu reporte** recién creado
3. **Debería aparecer** "📄 Ver PDF" en la última columna

Si aún no aparece:
- Actualiza la página (F5)
- Espera 2 segundos
- Recarga el historial

Si después de actualizar AÚN no aparece:
- El `pdf_url` no se está guardando en BD
- Revisa los logs: ¿dice `✅ Verificación - pdf_url guardado`?

---

## 🐛 Posibles Problemas

| Problema | Síntoma | Solución |
|----------|---------|----------|
| RLS Policies no configuradas | "bucket not found" | Agregar las 3 políticas |
| Bucket privado sin Signed URL | Error al generar URL | Usar Signed URL correctamente |
| URL null en base de datos | Reporte sin PDF | Revisar logs de URL |
| Historial no actualiza | PDF guardado pero no se ve | Recargar página |
| Edad de la URL | Link funciona solo 7 días | Crear PDF nuevo después |

---

## 🆘 Si aún no funciona

**Para obtener ayuda, copia estos logs:**

1. Abre la consola (F12)
2. Busca TODOS los mensajes con `PDF` o `Error`
3. Copia desde `📤 Intentando subir...` hasta `✅ Verificación...`
4. Envía los logs completos

Ejemplo de logs a enviar:
```
📤 Intentando subir PDF a fauna/reports con ruta: 1743022345_FAUNA-2024-0001.pdf
✅ PDF subido exitosamente al storage.
🔗 Generando URL firmada para: 1743022345_FAUNA-2024-0001.pdf
❌ Error generando Signed URL: ... [ENVÍA ESTO]
```

---

## 📋 Checklist

- [ ] Consola abierta (F12)
- [ ] Generé un PDF nuevo desde la app
- [ ] Vi el mensaje "✅ PDF subido exitosamente"
- [ ] Vi el mensaje "✅ URL firmada generada"
- [ ] Vi el mensaje "✅ Reporte guardado"
- [ ] Recargué la página
- [ ] El "📄 Ver PDF" ahora aparece

Si todos todos estos están marcados y aún no funciona, ejecuta esto en la consola:

```javascript
// Verificar que Supabase existe
console.log('Supabase client:', window.supabaseClient ? 'OK' : 'FAIL');

// Ver último reporte con PDF
await window.supabaseClient.from('fauna_impact_reports')
  .select('folio, pdf_url')
  .order('created_at', { ascending: false })
  .limit(1)
  .then(r => console.log('Último reporte:', r.data[0]));
```

