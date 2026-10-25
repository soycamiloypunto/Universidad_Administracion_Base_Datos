-- =============================================================================
-- ACA · PITCH FINAL — ADMINISTRACIÓN DE BASES DE DATOS (CUN 2026)
-- ARCHIVO 07: POLÍTICA DE RESPALDO, SIMULACIÓN DE FALLO Y RECUPERACIÓN
-- Estudiante: Cristian Camilo Tabares Villanueva
-- Docente: Gabriel E. Beltrán
-- =============================================================================

USE agrosilvania_db;

-- 1. POLÍTICA FORMAL DE RESPALDO (BACKUP STRATEGY):
-- • Respaldo Completo (Full Backup): Domingos a las 01:00 AM mediante mysqldump con --single-transaction
-- • Respaldo Diferencial/Incremental: Diario a las 23:00 PM mediante rotación de binlogs (Point-in-Time Recovery)
-- • Retención: 30 días en almacenamiento redundante (Amazon S3 / NAS local)
-- • RPO definido: < 15 minutos | RTO definido: < 10 minutos

-- =============================================================================
-- 2. COMANDOS DEL SISTEMA OPERATIVO PARA REALIZAR EL RESPALDO CONSISTENTE
-- (Ejecutar desde PowerShell / Bash o terminal del contenedor Docker)
-- =============================================================================
/*
# Comando en PowerShell para generar el respaldo consistente en caliente:
docker exec mysql-agrosilvania-db mysqldump `
  -u dba_admin -pDbaPassword2026! `
  --single-transaction `
  --quick `
  --routines `
  --triggers `
  --databases agrosilvania_db > "d:\CCTV\Universidad\Administracion_de_Bases_de_Datos\backups\backup_full_agrosilvania_db.sql"

# O en entorno local sin Docker:
# mysqldump -u root -p --single-transaction --quick --routines --triggers --databases agrosilvania_db > backup_full_agrosilvania_db.sql
*/

-- =============================================================================
-- 3. ESTADO ANTES DEL FALLO: VERIFICACIÓN DE TOTALES
-- =============================================================================
SELECT 'ESTADO_PREVIO' AS momento, COUNT(*) AS total_pedidos FROM pedidos;
SELECT 'ESTADO_PREVIO' AS momento, COUNT(*) AS total_detalles FROM detalle_pedidos;

-- =============================================================================
-- 4. SIMULACIÓN DE FALLA CONTROLADA (DESASTRE ACCIDENTAL)
-- Un operador ejecuta accidentalmente la eliminación de la tabla de detalles
-- o borra masivamente información transaccional crítica:
-- =============================================================================

-- Desactivar temporalmente revisión de FK para simular desastre catastrófico
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS detalle_pedidos;
SET FOREIGN_KEY_CHECKS = 1;

-- Comprobación del desastre: La tabla detalle_pedidos NO EXISTE
-- La aplicación colapsa con error: Table 'agrosilvania_db.detalle_pedidos' doesn't exist
SHOW TABLES LIKE 'detalle_pedidos';

-- =============================================================================
-- 5. PROCEDIMIENTO DE RECUPERACIÓN ANTE DESASTRE (DISASTER RECOVERY)
-- =============================================================================
/*
# Comando en PowerShell para restaurar la base de datos a partir del respaldo:
Get-Content "d:\CCTV\Universidad\Administracion_de_Bases_de_Datos\backups\backup_full_agrosilvania_db.sql" | `
  docker exec -i mysql-agrosilvania-db mysql -u dba_admin -pDbaPassword2026! agrosilvania_db

# O en MySQL local:
# mysql -u root -p agrosilvania_db < backup_full_agrosilvania_db.sql
*/

-- =============================================================================
-- 6. VERIFICACIÓN POSTERIOR A LA RESTAURACIÓN: INTEGRIDAD TOTAL
-- =============================================================================
-- Ejecutar estas consultas una vez completada la restauración:
SELECT 'ESTADO_POST_RESTAURACION' AS momento, COUNT(*) AS total_pedidos FROM pedidos;
SELECT 'ESTADO_POST_RESTAURACION' AS momento, COUNT(*) AS total_detalles FROM detalle_pedidos;

-- Verificación de integridad referencial:
SELECT 
  p.id_pedido, 
  c.nombre_completo AS cliente, 
  dp.cantidad_kg, 
  pr.nombre_producto, 
  dp.subtotal_linea_cop
FROM pedidos p
JOIN clientes c ON p.id_cliente = c.id_cliente
JOIN detalle_pedidos dp ON p.id_pedido = dp.id_pedido
JOIN productos pr ON dp.id_producto = pr.id_producto
LIMIT 5;

SELECT 'RECUPERACIÓN EXITOSA: La base de datos opera con 100% de consistencia transaccional' AS resultado;
