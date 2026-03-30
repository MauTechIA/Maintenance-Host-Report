# 🔧 Solución Rápida al Error: "column folio does not exist"

## Problema
Has recibido este error:
```
ERROR: 42703: column "folio" does not exist
```

## Causa
Tus tablas `fauna_impact_reports` y `fauna_rescue_reports` **ya existen** pero les falta la columna `folio`.

## Solución (2 pasos)

### PASO 1: Usa el Script Seguro
1. **Abre:** `SETUP_FAUNA_PDF_SAFE.sql` (nuevo archivo)
2. **Copia TODO** el contenido
3. **Ve a:** Supabase → SQL Editor → New Query
4. **Pega** el contenido
5. **Haz clic:** ▶ RUN

**Este script es seguro porque:**
- Solo AGREGA columnas que faltan
- NO borra nada
- NO recrea tablas
- Conserva tus datos existentes

### PASO 2: Verifica
Después de ejecutar, deberías ver:
```
✓ Query executed successfully
```

Si aún ves errores al final, recopia este comando en una nueva query:

```sql
-- Verificar que folio existe
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'fauna_impact_reports' AND column_name = 'folio';

-- Debería mostrar una fila con "folio"
```

---

## ✨ Después de esto

Ya puedes:
1. Generar PDFs
2. Se guardarán automáticamente con el `folio`
3. Aparecerán en el Historial de Impacto

---

## 📋 Orden Correcto de Ejecución

```
1. SETUP_FAUNA_PDF_SAFE.sql          ← Ejecuta ESTO primero (2 min)
2. Crear buckets en Storage           ← Después (3 min)
3. Generar un PDF de prueba           ← Finalmente
```

---

## ❌ Si Sigues Viendo Errores

### Error: "ERROR: relation "fauna_impact_reports" does not exist"
→ Las tablas no existen. Pide que las creen en Supabase primero.

### Error: "ERROR: 42701: column "folio" already exists"
→ ¡Perfecto! Significa que ya está. Ignoralo.

### Error: "ERROR: 42P07: relation already exists"
→ La columna ya existe. Los índices también. ¡Todo está bien!

---

**¿Qué hacer ahora?**

1. Ejecuta `SETUP_FAUNA_PDF_SAFE.sql` sin miedo
2. Postea en Storage los buckets (ver README_FAUNA_PDFS.md)
3. ¡Listo! Ya funciona
