# ⚙️ Configuración Requerida del Bucket fauna/reports

## Problema
`pdf_url: null` = El bucket existe pero no tiene RLS Policies correctas

## Solución: Agregar Políticas RLS

### Paso 1: Ve a Supabase Dashboard
```
https://app.supabase.com/projects
```

### Paso 2: Haz clic en Storage

### Paso 3: Busca el bucket "fauna/reports"

### Paso 4: Abre el bucket y ve a "RLS Policies"

---

## Políticas Requeridas (SON 3)

**Copia y pega EXACTAMENTE estas 3 políticas:**

### POLÍTICA 1: SELECT (Lectura)

- **Nombre**: `allow_select_authenticated`
- **Operación**: SELECT
- **Targeting**: `Authenticated only` (o roles: `authenticated`)
- **USING expression**: `true`

```sql
true
```

---

### POLÍTICA 2: INSERT (Subida)

- **Nombre**: `allow_insert_authenticated`
- **Operación**: INSERT
- **Targeting**: `Authenticated and Anonymous` (o roles: `authenticated, anon`)
- **WITH CHECK expression**: `true`

```sql
true
```

---

### POLÍTICA 3: DELETE (Eliminación)

- **Nombre**: `allow_delete_authenticated`
- **Operación**: DELETE
- **Targeting**: `Authenticated only` (o roles: `authenticated`)
- **USING expression**: `true`

```sql
true
```

---

## Cómo Agregar una Política en Supabase Dashboard

1. Abre el bucket `fauna/reports`
2. Haz clic en tab **"RLS Policies"**
3. Haz clic en **"+ New policy"**
4. Selecciona la operación (SELECT, INSERT, o DELETE)
5. Dale un nombre (ejemplo: `allow_select_authenticated`)
6. En "Targeting", elige los roles
7. En "USING" o "WITH CHECK", escribe: `true`
8. Haz clic en **"Save policy"**
9. **Repite para las 3 políticas**

---

## Verificación

Después de agregar las 3 políticas:

✅ El bucket aparecerá con un **candado** (🔒) indicando que está protegido  
✅ Verás las 3 políticas listadas en "RLS Policies"  
✅ Intenta generar un PDF nuevamente  
✅ **Debería aparecer** `✅ URL firmada generada correctamente` en consola  
✅ El `pdf_url` **ya no será `null`**

---

## Si Aún No Funciona

**Ejecuta esto en la Consola (F12):**

```javascript
// Verificar bucket
await window.supabaseClient.storage.listBuckets().then(r => {
  console.log('Buckets:', r.data.map(b => b.name));
});

// Ver políticas del bucket
await window.supabaseClient.rpc('get_bucket_policies', {
  bucket_name: 'fauna/reports'
}).then(r => console.log('Políticas:', r));
```

---

## Posibles Errores

| Error | Causa | Solución |
|-------|-------|----------|
| `❌ Error al generar Signed URL` | No hay RLS Policies | Agregar las 3 políticas |
| `policy violation` | Roles incorrectos | Usar `authenticated` o `anon` |
| `bucket not found` | El bucket no existe | Crear bucket primero |
| `permission denied` | No tienes permisos en Supabase | Verifica tu rol en el proyecto |

---

## 🚀 Próximos Pasos Después de Agregar Políticas

1. ✅ Recarga la aplicación (F5)
2. ✅ Genera un PDF nuevo
3. ✅ Abre Consola (F12)
4. ✅ Deberías ver: `✅ URL firmada generada correctamente`
5. ✅ Ve al Historial
6. ✅ **Verifica que aparezca** `📄 Ver PDF`

---

## Configuración Alternativa (Más Permisiva)

Si queremos que TODOS (incluso anónimos) puedan leer los PDFs:

```
POLICY: allow_select_all
- Operación: SELECT
- Targeting: TODOS (no selecciones roles)
- USING: true
```

Pero es MENOS seguro. Recomendamos mantener `authenticated`.

