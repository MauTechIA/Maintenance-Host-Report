# Solución: Corrección del tipo de reporte en Historial de Fauna

## Problema
En el Historial de Reportes de Fauna, el campo **"Tipo"** mostraba "Rescate" para todos los reportes, incluso cuando el reporte fue llenado como "Impacto" o "Posible Impacto".

## Solución Aplicada

He realizado cambios en dos áreas clave:

### 1. **Base de Datos (SQL)**
Se agregaron columnas `tipo_reporte` a ambas tablas para almacenar explícitamente el tipo de reporte:

- `fauna_impact_reports.tipo_reporte` - Almacena "Impacto" o "Posible Impacto"
- `fauna_rescue_reports.tipo_reporte` - Almacena "Rescate"

### 2. **Código JavaScript**
Se actualizó el código para:

- Guardar el campo `tipo_reporte` en cada reporte (tanto impactos como rescates)
- Leer y usar el campo `tipo_reporte` al mostrar reportes en la tabla
- Incluir fallbacks inteligentes si el campo no existe

## Pasos para Implementar

### Paso 1: Ejecutar Migración SQL en Supabase

1. Abre tu proyecto Supabase (https://supabase.com)
2. Ve a **SQL Editor** en el panel izquierdo
3. Copia y ejecuta todo el contenido del archivo `migration_add_tipo_reporte.sql`:

```sql
-- ====================================================================
-- Agregar columna tipo_reporte a fauna_impact_reports
-- ====================================================================
ALTER TABLE fauna_impact_reports
ADD COLUMN IF NOT EXISTS tipo_reporte TEXT DEFAULT 'Impacto';

UPDATE fauna_impact_reports 
SET tipo_reporte = COALESCE(evento, 'Impacto')
WHERE tipo_reporte = 'Impacto' OR tipo_reporte IS NULL;

-- ====================================================================
-- Agregar columna tipo_reporte a fauna_rescue_reports
-- ====================================================================
ALTER TABLE fauna_rescue_reports
ADD COLUMN IF NOT EXISTS tipo_reporte TEXT DEFAULT 'Rescate';

UPDATE fauna_rescue_reports
SET tipo_reporte = 'Rescate'
WHERE tipo_reporte = 'Rescate' OR tipo_reporte IS NULL;
```

4. Presiona **Ejecutar** (botón azul)
5. Deberías ver un mensaje confirman do que la operación fue exitosa

### Paso 2: Actualizar la aplicación

Los cambios en el código JavaScript ya están incluidos:
- El archivo `index.html` ha sido actualizado
- Asegúrate de hacer un **git commit y push** de los cambios
- Si tienes la aplicación abierta en el navegador, recarga la página (Ctrl+F5 o Cmd+Shift+R)

### Paso 3: Probar la solución

1. **Crear un reporte de Impacto:**
   - Ve a la pestaña "Fauna"
   - Selecciona la pestaña del formulario "📊 Registro de Impacto o Posible Impacto"
   - Rellena los campos (Evento, Fase de Vuelo, Pista, etc.)
   - Haz clic en "Generar reporte"
   - Deberías ver un mensaje: "✓ Reporte de impacto guardado exitosamente."

2. **Ver el Historial:**
   - Ve a la pestaña "Historial-Fauna"
   - Busca tu reporte reciente
   - Verifica que en la columna **"Tipo"** aparezca "Impacto" o "Posible Impacto"
   - El color debería ser **rojo** para impactos (en lugar de verde)

3. **Crear un reporte de Rescate:**
   - Repite el paso 1 pero selecciona la pestaña "🛟 Registro de Fauna Rescatada y Reubicada"
   - Llena los datos de rescate
   - En el Historial, debería aparecer con tipo "Rescate" en **verde**

## Cambios Realizados en el Código

### En `fauna_impact_reports` (guardado)
```javascript
var impactPayload = {
    // ... otros campos ...
    tipo_reporte: evento || 'Impacto'  // ← Nuevo campo
};
```

### En `fauna_rescue_reports` (guardado)
```javascript
var rescatePayload = {
    // ... otros campos ...
    tipo_reporte: 'Rescate'  // ← Nuevo campo
};
```

### En `loadFaunaReports` (lectura y visualización)
El código ahora:
1. Lee el campo `tipo_reporte` de la base de datos (si existe)
2. Si no existe, intenta detectar el tipo usando `evento` para impactos
3. Usa el tipo para determinar el color (rojo para impactos, verde para rescates)

## Validación

Abre la consola del navegador (F12 → Console) para ver logs de debug:

```
DEBUG: Creating impacto records from fauna_impact_reports
Added IMPACTO with tipoReporte=Impacto, evento=Impacto
```

Esto indica que los registros están siendo procesados correctamente.

## Reversión (si es necesario)

Si necesitas revertir los cambios en Supabase:

```sql
-- Eliminar las columnas tipo_reporte
ALTER TABLE fauna_impact_reports
DROP COLUMN IF EXISTS tipo_reporte;

ALTER TABLE fauna_rescue_reports
DROP COLUMN IF EXISTS tipo_reporte;
```

Luego actualiza el código JavaScript a la versión anterior.

---

**Nota:** Los cambios son totalmente retrocompatibles. Los registros guardados sin el campo `tipo_reporte` seguirán funcionando gracias a los fallbacks inteligentes en el código.
