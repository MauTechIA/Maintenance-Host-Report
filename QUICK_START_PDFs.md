# 🚀 INSTRUCCIONES RÁPIDAS - PDFs de Reportes de Fauna

## Todo lo que necesitas hacer (en 5 minutos)

### 1️⃣ EJECUTAR SCRIPT SQL (2 minutos)

**En Supabase Dashboard:**
1. SQL Editor → New Query
2. Abre `SETUP_FAUNA_PDF_SAFE.sql` ⭐ (USAR ESTE, no el otro)
3. Copia **TODO** el contenido
4. Pega en SQL Editor
5. **Haz clic en ▶ Run**
6. Espera a que diga "✓ Done"

⚠️ **Nota:** Si recibiste error "column folio does not exist", usa `SETUP_FAUNA_PDF_SAFE.sql` que es más seguro.

---

### 2️⃣ CREAR BUCKETS EN STORAGE (2 minutos)

**Ve a Supabase → Storage → Create new bucket**

#### Bucket 1: `fauna_impact_pdfs`
- **Nombre:** fauna_impact_pdfs
- **Privacidad:** PRIVATE
- **Crear:** Click

#### Agregar Políticas (en el bucket):
Ve a **RLS Policies** → **New policy** (3 veces)

| Nombre | Operación | Roles | USING/WITH CHECK |
|--------|-----------|-------|------------------|
| Allow select for all | SELECT | authenticated, anon | true |
| Allow insert for authenticated | INSERT | authenticated | true |
| Allow delete for authenticated | DELETE | authenticated | true |

#### Bucket 2: `fauna_rescue_pdfs`
- **Nombre:** fauna_rescue_pdfs
- **Privacidad:** PRIVATE
- **Políticas:** Las MISMAS 3 que arriba

---

### 3️⃣ VERIFICAR (30 segundos)

En Supabase Storage, deberías ver:
```
✓ fauna_impact_pdfs    (PRIVATE)
✓ fauna_rescue_pdfs    (PRIVATE)
```

---

### 4️⃣ ¡LISTO! 

El código ya está actualizado. Ahora cuando generes un PDF:

1. El sistema **captura el mapa** con el marker rojo
2. **Genera el PDF** con todos los detalles
3. **Lo sube** a `fauna_impact_pdfs` automáticamente
4. **Guarda el link** en la base de datos

---

## 📌 Cómo Usar

### Generar un PDF:
1. Llena "Registro de Impacto o Posible Impacto"
2. Confirma la ubicación en el mapa
3. Haz clic "Generar reporte"
4. ✅ Se genera y guarda automáticamente

### Ver los PDFs:
1. Ve a "Historial de Impactos" 
2. Verás una columna con "📄 Ver PDF"
3. Haz clic para descargar

---

## ❌ Si algo falla:

**Error: "Bucket not found"**
→ Asegúrate de que creaste los buckets exactamente con esos nombres

**Error: "No se pudo guardar"**
→ Abre F12 → Console y mira los logs

**No aparece PDF en historial**
→ Recarga la página (Ctrl+R o Cmd+R)

---

## 📚 Archivos Generados

```
├── SETUP_FAUNA_PDF_STORAGE.sql    ← Script SQL (ejecutar en Supabase)
├── README_FAUNA_PDFS.md           ← Guía detallada (leer si tienes dudas)
└── index.html                      ← Código actualizado (ya hecho ✓)
```

---

## ✨ Resumen de Cambios en el Código

- ✅ Cambió de bucket `fauna-reports` a `fauna_impact_pdfs`
- ✅ Usa Signed URLs para mayor seguridad (expiran en 7 días)
- ✅ Manejo mejorado de errores con mensajes claros
- ✅ Historial muestra el link "📄 Ver PDF"
- ✅ Compatible con buckets PRIVATE y PUBLIC

---

**¡Eso es todo! Tu sistema de PDFs está listo para usar.** 🎉

Cualquier duda, revisa `README_FAUNA_PDFS.md` para la versión completa.
