// Script para crear un bucket 'reports' en Supabase usando la Service Role Key
// Uso: definir variables de entorno SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY y ejecutar: node create_bucket.js

const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SERVICE_KEY) {
  console.error('Define SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY como variables de entorno antes de ejecutar.');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SERVICE_KEY, {
  auth: { persistSession: false }
});

async function createBucket() {
  try {
    const bucketId = 'reports';
    console.log('Creando bucket:', bucketId);
    const { data, error } = await supabase.storage.createBucket(bucketId, { public: true });
    if (error) {
      console.error('Error al crear bucket:', error);
      // Si existe ya, la API puede devolver error; fetch info
      const { data: existing, error: e2 } = await supabase.storage.listBuckets();
      if (e2) console.error('No se pudo listar buckets:', e2);
      else console.log('Buckets existentes:', existing.map(b => b.id).join(', '));
      process.exit(1);
    }
    console.log('Bucket creado:', data);
    process.exit(0);
  } catch (e) {
    console.error('Excepción:', e);
    process.exit(1);
  }
}

createBucket();
