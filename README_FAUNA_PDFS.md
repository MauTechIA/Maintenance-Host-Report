# 📋 Configuración de PDFs para Reportes de Fauna

## Descripción General

Este documento te guía para configurar el almacenamiento de PDFs de reportes de fauna en Supabase Storage. Los PDFs se guardarán en un bucket dedicado `fauna_impact_pdfs` y se mostrarán en el historial de impactos.

---

## ✅ Checklist de Configuración

- [ ] Elegir el script SQL correcto
- [ ] Ejecutar SQL script en Supabase
- [ ] Crear bucket `fauna_impact_pdfs` en Storage
- [ ] Crear bucket `fauna_rescue_pdfs` en Storage
- [ ] Configurar políticas de seguridad
- [ ] Verificar que el código está actualizado
- [ ] Probar generando un PDF

---

## 🔍 ¿Cuál Script SQL Usar?

### Opción A: Si es la PRIMERA VEZ (tablas nuevas)
→ **Usa:** `SETUP_FAUNA_PDF_STORAGE.sql`
- Crea todas las tablas desde cero
- Configura índices y vistas

### Opción B: Si YA TIENES tablas (recomendado)
→ **Usa:** `SETUP_FAUNA_PDF_SAFE.sql` ⭐
- Solo agrega columnas faltantes
- No recrea nada que ya existe
- MÁS SEGURO (no destroza datos)

---

## 🔧 Pasos de Configuración

### PASO 1: Elegir y Ejecutar el Script SQL Correcto

El error "column folio does not exist" significa que tus tablas ya existen pero les falta la columna `folio`. 

**Esto es normal.** Usa el script SAFE:

1. **Abre Supabase Dashboard:**
   - Ve a: https://app.supabase.com/
   - Selecciona tu proyecto
   - Ve a **SQL Editor** en el menú lateral izquierdo

2. **Crea una nueva Query:**
   - Haz clic en **+ New Query**
   - Dale un nombre: `Setup Fauna PDF Storage - Safe Version`

3. **Copia y ejecuta el script SEGURO:**
   - Abre el archivo `SETUP_FAUNA_PDF_SAFE.sql` ⭐
   - Copia **TODO** el contenido
   - Pégalo en el SQL Editor
   - Haz clic en **▶ Run** (botón verde)
   - Espera a que complete (verás ✓ Done)

**¿Qué hace este script?**
- Solo agrega columnas que faltan (`folio`, `pdf_url`, etc.)
- NO recrea tablas (por eso es seguro)
- Crea índices para mejorar velocidad
- Configura políticas RLS
- No borra datos existentes

### Si Aún Así Ves Errores:

Si ves: **ERROR: 42703: column "folio" does not exist**
- Significa las tablas no tienen la estructura correcta
- Opciones:
  1. Ir a Supabase →SQL Editor → Ejecutar consultas individuales para verificar:
  ```sql
  SELECT column_name FROM information_schema.columns 
  WHERE table_name = 'fauna_impact_reports';
  ```
  2. [OPCIÓN NUCLEAR] Borrar las tablas y empezar de cero (perderás datos):
  ```sql
  DROP TABLE fauna_impact_reports CASCADE;
  DROP TABLE fauna_rescue_reports CASCADE;
  ```
  Luego ejecutar `SETUP_FAUNA_PDF_STORAGE.sql` completo

---

### PASO 2: Crear Buckets en Storage

#### Bucket 1: `fauna_impact_pdfs` (PDFs de Impactos)

1. **Ve a Storage:**
   - Dashboard → **Storage** (menú izquierdo) → **Buckets**

2. **Crear bucket:**
   - Haz clic en **+ Create new bucket**
   - Nombre: `fauna_impact_pdfs`
   - Privacidad: **PRIVATE** ⭐ (Recomendado)
   - Haz clic en **Create bucket**

3. **Configurar políticas de seguridad:**
   - Abre el bucket `fauna_impact_pdfs`
   - Ve a la pestaña **RLS Policies**
   - Haz clic en **+ New policy** (o edita la que existe)

4. **Crear estas 3 políticas:**

   **Política 1: SELECT (Lectura - todos)**
   ```
   Nombre: Allow select for all
   Operación: SELECT  
   Roles: authenticated, anon
   USING: true
   ```

   **Política 2: INSERT (Subida - autenticados)**
   ```
   Nombre: Allow insert for authenticated
   Operación: INSERT
   Roles: authenticated
   WITH CHECK: true
   ```

   **Política 3: DELETE (Eliminación - autenticados)**
   ```
   Nombre: Allow delete for authenticated
   Operación: DELETE
   Roles: authenticated
   USING: true
   ```

#### Bucket 2: `fauna_rescue_pdfs` (PDFs de Rescates)

1. **Repetir el proceso anterior pero:**
   - Nombre: `fauna_rescue_pdfs`
   - Aplicar las MISMAS 3 políticas

---

### PASO 3: Verificar la Configuración

#### En SQL Editor:

```sql
-- Ver que las tablas existen y tienen pdf_url
SELECT table_name FROM information_schema.tables 
WHERE table_name IN ('fauna_impact_reports', 'fauna_rescue_reports');

-- Ver que los buckets están listos
-- (Ir a Storage → Buckets para verificar visualmente)
```

#### En Storage:

- [ ] `fauna_impact_pdfs` aparece en la lista de buckets
- [ ] `fauna_rescue_pdfs` aparece en la lista de buckets
- [ ] Ambos muestran "PRIVATE" o tu configuración elegida

---

## 🚀 Uso

### Generar un PDF

1. **Llena el formulario de "Registro de Impacto o Posible Impacto"**
2. **Selecciona ubicación en el mapa** (confirma la ubicación)
3. **Haz clic en "Generar reporte"**
   - El sistema capturará los mapas
   - Generará el PDF
   - Lo subirá automáticamente a `fauna_impact_pdfs`
   - Guardará la URL en la BD

### Ver los PDFs en el Historial

1. **Ve a "Historial de Impactos"** en la aplicación
2. **La tabla mostrará:**
   - Fecha
   - Tipo (Avistamiento, Presencia, Daño, etc.)
   - Especie
   - Ubicación
   - Responsable
   - Estado
   - **Link "📄 Ver PDF"** (si existe)

3. **Haz clic en "📄 Ver PDF"** para descargar o ver en navegador

---

## 🔒 Seguridad

### Buckets PRIVATE vs PUBLIC

**PRIVATE (Recomendado):**
- ✅ Solo usuarios autenticados pueden acceder
- ✅ URLs firmadas expiran en 7 días
- ✅ Más seguro para datos sensibles
- ⚠️ Requiere regenerar URLs periódicamente

**PUBLIC:**
- ⚠️ Cualquiera con el link puede descargar
- ✅ No requiere reautenticación
- ❌ Menos seguro pero más simple

**El código actual usa PRIVATE con Signed URLs de 7 días.**

---

## 🐛 Troubleshooting

### Error: "Bucket fauna_impact_pdfs not found"

**Solución:**
1. Verifica que creaste el bucket `fauna_impact_pdfs` en Storage
2. Asegúrate de que el nombre es exacto (sin espacios, con guiones bajos)
3. Recarga la página de la aplicación
4. Intenta de nuevo

### Error: "createSignedUrl no disponible"

**Posibles causas:**
- El bucket está marcado como PUBLIC
- Tu versión de Supabase JS es antigua

**Solución:**
1. Cambiar el bucket a PRIVATE si está en PUBLIC
2. O cambiar el código para usar `getPublicUrl()` si está en PUBLIC

### Los PDFs no se guardan pero no hay error

1. Abre la **Consola del navegador** (F12)
2. Busca logs iniciados con "✅" o "⚠️"
3. Verifica que el folio se está generando correctamente
4. Asegúrate de que hay espacio en tu Storage de Supabase

---

## 📊 Consultas SQL Útiles

### Ver todos los reportes que tienen PDF

```sql
SELECT folio, tipo_reporte, fecha_reporte, pdf_url 
FROM fauna_impact_reports 
WHERE pdf_url IS NOT NULL
ORDER BY created_at DESC;
```

### Ver reportes SIN PDF (que necesitan regenerarse)

```sql
SELECT folio, tipo_reporte, fecha_reporte 
FROM fauna_impact_reports 
WHERE pdf_url IS NULL
ORDER BY created_at DESC;
```

### Estadísticas de PDFs

```sql
SELECT 
  COUNT(*) as total_reportes,
  COUNT(CASE WHEN pdf_url IS NOT NULL THEN 1 END) as con_pdf,
  ROUND(100.0 * COUNT(CASE WHEN pdf_url IS NOT NULL THEN 1 END) / COUNT(*), 2) as porcentaje_con_pdf
FROM fauna_impact_reports;
```

### Ver el historial combinado

```sql
SELECT * FROM fauna_reports_history 
ORDER BY created_at DESC
LIMIT 20;
```

---

## 📝 Estructura de Archivos en Storage

Los PDFs se guardan con esta estructura:

```
fauna_impact_pdfs/
├── 1711324589451_20240325-140921.pdf
├── 1711324612789_20240325-141012.pdf
└── 1711324645123_20240325-141045.pdf

fauna_rescue_pdfs/
├── 1711324700456_20240325-141140.pdf
└── ...
```

**Formato del nombre:**
- `[TIMESTAMP]_[FOLIO].pdf`
- Ejemplo: `1711324589451_20240325-140921.pdf`

---

## 🔄 Mantenimiento Periódico

### Limpiar PDFs antiguos (opcional)

Si quieres eliminar PDFs con más de 3 meses:

```sql
-- Listar archivos a eliminar
SELECT folio, pdf_url, created_at 
FROM fauna_impact_reports
WHERE pdf_url IS NOT NULL 
AND created_at < NOW() - INTERVAL '3 months'
ORDER BY created_at DESC;

-- Luego ir a Storage y eliminarlos manualmente
-- O considerar una función automática
```

---

## ✨ Funcionalidades Habilitadas

Con esta configuración ahora tienes:

✅ **PDFs automáticos:**
- Se generan cuando confirmas la ubicación
- Se suben automáticamente a Storage
- Se guardan las URLs en BD

✅ **Historial visual:**
- Ver todos los reportes con sus PDFs
- Links directos para descargar

✅ **Seguridad:**
- URLs firmadas que expiran
- Acceso controlado por políticas RLS
- Base de datos y Storage sincronizados

✅ **Reportes:**
- Vistas SQL para análisis
- Estadísticas de completitud
- Auditoría de cambios

---

## 📞 Soporte

Si tienes problemas:

1. **Abre la Consola del navegador** (F12 → Console)
2. **Copia los logs** que muestran ⚠️ o ❌
3. **Verifica el SQL Editor** de Supabase para errores en las tablas
4. **Checa Storage** para verificar que los buckets existen

---

**¡Listo!** Tu sistema de PDFs está configurado. Ahora puedes generar y guardar reportes con mapas, detalles y ubicaciones completas. 🎉
