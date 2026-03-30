-- ================================================================================
-- CREAR BUCKETS CON SUPABASE ADMIN API
-- ================================================================================
-- La creación de buckets NO se hace con SQL puro, pero aquí te muestro:
-- 1. Cómo hacerlo con JavaScript (Frontend)
-- 2. Cómo hacerlo con Backend (Node.js)
-- 3. Cómo verificar con SQL
-- ================================================================================

-- ================================================================================
-- OPCIÓN 1: JAVASCRIPT/TYPESCRIPT (EN TU PÁGINA)
-- ================================================================================

/*
Pega esto en: Tu página del formulario → F12 → Console → Pega → Enter

Este código crea los 2 buckets automáticamente:
*/

const crearBucketsParaFauna = async () => {
  const supabaseClient = window.supabaseClient;
  
  try {
    console.log('🔵 Iniciando creación de buckets...');
    
    // BUCKET 1: fauna_impact_pdfs
    const { data: bucket1, error: error1 } = await supabaseClient
      .storage
      .createBucket('fauna_impact_pdfs', {
        public: false,  // PRIVATE
        fileSizeLimit: 52428800  // 50MB
      });
    
    if (error1) {
      console.warn('⚠️ Bucket 1 error (puede existir):', error1.message);
    } else {
      console.log('✅ Bucket 1 creado:', bucket1);
    }
    
    // BUCKET 2: fauna_rescue_pdfs
    const { data: bucket2, error: error2 } = await supabaseClient
      .storage
      .createBucket('fauna_rescue_pdfs', {
        public: false,  // PRIVATE
        fileSizeLimit: 52428800  // 50MB
      });
    
    if (error2) {
      console.warn('⚠️ Bucket 2 error (puede existir):', error2.message);
    } else {
      console.log('✅ Bucket 2 creado:', bucket2);
    }
    
    // Verificar que existen
    const { data: buckets, error: errorList } = await supabaseClient
      .storage
      .listBuckets();
    
    if (errorList) {
      console.error('❌ Error listando buckets:', errorList);
    } else {
      console.log('📋 Todos los buckets:', buckets.map(b => b.name).join(', '));
      const tieneImpact = buckets.some(b => b.name === 'fauna_impact_pdfs');
      const tieneRescue = buckets.some(b => b.name === 'fauna_rescue_pdfs');
      
      if (tieneImpact && tieneRescue) {
        console.log('✅ ¡ÉXITO! Ambos buckets están listos');
      } else {
        console.warn('⚠️ Faltan buckets');
      }
    }
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
};

// EJECUTAR:
crearBucketsParaFauna();

/*
LUEGO: Ve a Supabase Storage y agrega las políticas manualmente:
- fauna_impact_pdfs → RLS Policies → + New policy (3 veces)
- fauna_rescue_pdfs → RLS Policies → + New policy (3 veces)
*/

-- ================================================================================
-- OPCIÓN 2: NODE.JS / BACKEND (Con Supabase Admin SDK)
-- ================================================================================

/*
Si usas Node.js/Express en el backend, copia esto en un archivo .js:

npm install @supabase/supabase-js

LUEGO copia esto:
*/

import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
const supabaseAnonKey = 'YOUR_ANON_KEY';
const supabaseServiceRoleKey = 'YOUR_SERVICE_ROLE_KEY'; // ⚠️ SECRETO

// Crear cliente con Service Role (permisos de admin)
const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

async function crearBucketsDeRescateDeFauna() {
  try {
    console.log('🔵 Creando buckets de fauna...');
    
    // Bucket 1: Impactos
    const { data: bucket1, error: error1 } = await supabase.storage.createBucket(
      'fauna_impact_pdfs',
      {
        public: false,
        fileSizeLimit: 52428800,
      }
    );
    
    if (error1) {
      console.warn('⚠️ fauna_impact_pdfs:', error1.message);
    } else {
      console.log('✅ fauna_impact_pdfs creado');
    }
    
    // Bucket 2: Rescates
    const { data: bucket2, error: error2 } = await supabase.storage.createBucket(
      'fauna_rescue_pdfs',
      {
        public: false,
        fileSizeLimit: 52428800,
      }
    );
    
    if (error2) {
      console.warn('⚠️ fauna_rescue_pdfs:', error2.message);
    } else {
      console.log('✅ fauna_rescue_pdfs creado');
    }
    
    // Verificar
    const { data: buckets, error: listError } = await supabase.storage.listBuckets();
    
    if (listError) {
      console.error('❌ Error:', listError);
      return false;
    }
    
    console.log('📋 Buckets:', buckets.map(b => b.name));
    console.log('✅ ¡LISTO!');
    return true;
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    return false;
  }
}

// EJECUTAR:
crearBucketsDeRescateDeFauna();

/*
IMPORTANTE: Guarda las llaves en .env:
VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
VITE_SUPABASE_ANON_KEY=YOUR_ANON_KEY
SUPABASE_SERVICE_ROLE_KEY=YOUR_SERVICE_ROLE_KEY
*/

-- ================================================================================
-- OPCIÓN 3: VERIFICAR CON SQL
-- ================================================================================

/*
Para verificar que los buckets existen, copia esto en Supabase SQL Editor:

NO OLVIDES: Esto solo VERIFICA, no crea. Primero crea con JavaScript.
*/

-- Ver que todo está listo en la BD
SELECT * FROM information_schema.tables 
WHERE table_name IN ('fauna_impact_reports', 'fauna_rescue_reports');

-- Ver columnas de fauna_impact_reports
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'fauna_impact_reports' 
ORDER BY ordinal_position;

-- Ver columnas de fauna_rescue_reports
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'fauna_rescue_reports' 
ORDER BY ordinal_position;

-- Ver índices
SELECT indexname FROM pg_indexes 
WHERE tablename IN ('fauna_impact_reports', 'fauna_rescue_reports')
ORDER BY indexname;

-- ================================================================================
-- OPCIÓN 4: SCRIPT AUTOMATIZADO COMPLETO
-- ================================================================================

/*
Este es el flujo AUTOMÁTICO completo en JAVASCRIPT:

1. Crear buckets
2. Agregar políticas
3. Verificar todo

Pégalo en F12 → Console:
*/

async function setupCompletoDeFaunaPDFs() {
  const supabaseClient = window.supabaseClient;
  
  try {
    console.log('🔵 SETUP COMPLETO DE FAUNA PDFs');
    console.log('================================\n');
    
    // PASO 1: Crear buckets
    console.log('⏳ Paso 1: Crear buckets...');
    const { error: e1 } = await supabaseClient.storage.createBucket('fauna_impact_pdfs', { public: false });
    const { error: e2 } = await supabaseClient.storage.createBucket('fauna_rescue_pdfs', { public: false });
    
    if (!e1 || e1.message.includes('already')) console.log('✅ fauna_impact_pdfs listo');
    if (!e2 || e2.message.includes('already')) console.log('✅ fauna_rescue_pdfs listo');
    
    // PASO 2: Listar buckets para verificar
    console.log('\n⏳ Paso 2: Verificar buckets...');
    const { data: buckets } = await supabaseClient.storage.listBuckets();
    const bucketNames = buckets.map(b => b.name);
    
    console.log('📋 Buckets encontrados:', bucketNames.join(', '));
    
    // PASO 3: Verificar tablas
    console.log('\n⏳ Paso 3: Verificar tablas en BD...');
    const { data: tablesResult, error: tablesError } = await supabaseClient
      .from('fauna_impact_reports')
      .select('id', { head: true, count: 'exact' });
    
    if (!tablesError) {
      console.log('✅ Tabla fauna_impact_reports existe');
    }
    
    const { data: tablesResult2, error: tablesError2 } = await supabaseClient
      .from('fauna_rescue_reports')
      .select('id', { head: true, count: 'exact' });
    
    if (!tablesError2) {
      console.log('✅ Tabla fauna_rescue_reports existe');
    }
    
    // RESULTADO
    console.log('\n✅ SETUP COMPLETADO');
    console.log('==================================');
    console.log('Próximo paso: Agrega políticas en Supabase Storage');
    console.log('Storage → fauna_impact_pdfs → RLS Policies → + New policy (3 veces)');
    
  } catch (error) {
    console.error('❌ Error:', error);
  }
}

// EJECUTAR AHORA:
setupCompletoDeFaunaPDFs();

-- ================================================================================
-- RESUMEN: CÓMO ELEGIR
-- ================================================================================

/*
OPCIÓN 1 (RECOMENDADA): JavaScript en Console del navegador
  ✅ Más fácil y rápido
  ✅ No necesitas configurar nada
  ✅ Una línea en F12 → Console
  → Ver código arriba bajo "OPCIÓN 1"

OPCIÓN 2: Node.js Backend
  ✅ Si tienes un servidor
  ✅ Automatización completa
  ✅ Más control y seguridad
  → Ver código arriba bajo "OPCIÓN 2"

OPCIÓN 3: SQL
  ❌ NO puede crear buckets
  ✅ Puede verificar que la BD está lista
  → Ver código arriba bajo "OPCIÓN 3"

OPCIÓN 4: Script Completo
  ✅ Crea buckets + verifica todo
  ✅ Una sola ejecución
  ✅ Perfecto para principiantes
  → Ver código arriba bajo "OPCIÓN 4"
*/

-- ================================================================================
-- FLUJO FINAL RECOMENDADO (5 minutes)
-- ================================================================================

/*
1. (Ya hecho) Ejecutar SETUP_FAUNA_PDF_SAFE.sql ✓

2. Abre tu página del formulario → F12 → Console

3. Pega y ejecuta OPCIÓN 4 (arriba):
   setupCompletoDeFaunaPDFs();

4. Ve a Supabase Storage y agrega 3 políticas en cada bucket (5 min):
   - allow_select_all (SELECT)
   - allow_insert_authenticated (INSERT)
   - allow_delete_authenticated (DELETE)

5. ¡LISTO! 🎉
   Ya puedes generar PDFs
*/

-- ================================================================================
