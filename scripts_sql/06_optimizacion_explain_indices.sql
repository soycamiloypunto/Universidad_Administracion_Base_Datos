-- =============================================================================
-- ACA · PITCH FINAL — ADMINISTRACIÓN DE BASES DE DATOS (CUN 2026)
-- ARCHIVO 06: OPTIMIZACIÓN DE RENDIMIENTO CON EXPLAIN ANALYZE E ÍNDICES B-TREE
-- Estudiante: Cristian Camilo Tabares Villanueva
-- Docente: Gabriel E. Beltrán
-- =============================================================================

USE agrosilvania_db;

-- 1. DIAGNÓSTICO DEL PROBLEMA DE RENDIMIENTO:
-- El dashboard gerencial y el módulo de logística en Silvania experimentaban tiempos
-- de espera elevados al consultar pedidos entregados en un rango de fechas reciente.
-- La tabla 'pedidos' cuenta con más de 5.000 registros y carecía de indexación secundaria.

-- 2. CONSULTA LENTA BAJO INVESTIGACIÓN:
-- Identificación de pedidos entregados en los últimos 90 días con datos del cliente
/*
SELECT 
  p.id_pedido, 
  c.nombre_completo, 
  p.fecha_pedido, 
  p.estado_pedido, 
  p.total_cop 
FROM pedidos p 
JOIN clientes c ON p.id_cliente = c.id_cliente 
WHERE p.estado_pedido = 'ENTREGADO' 
  AND p.fecha_pedido >= DATE_SUB(NOW(), INTERVAL 90 DAY);
*/

-- =============================================================================
-- 3. ESTADO INICIAL (SIN ÍNDICE COMPUESTO): ANÁLISIS DE COSTES
-- =============================================================================

-- Aseguramos que no exista el índice previamente
DROP INDEX idx_pedidos_estado_fecha ON pedidos;

-- Ejecución de EXPLAIN tradicional:
EXPLAIN 
SELECT 
  p.id_pedido, 
  c.nombre_completo, 
  p.fecha_pedido, 
  p.estado_pedido, 
  p.total_cop 
FROM pedidos p 
JOIN clientes c ON p.id_cliente = c.id_cliente 
WHERE p.estado_pedido = 'ENTREGADO' 
  AND p.fecha_pedido >= DATE_SUB(NOW(), INTERVAL 90 DAY);

-- Ejecución con EXPLAIN ANALYZE (MySQL 8.0):
-- Evidencia técnica de Full Table Scan (tipo 'ALL') examinando las 5.000+ filas:
EXPLAIN ANALYZE 
SELECT 
  p.id_pedido, 
  c.nombre_completo, 
  p.fecha_pedido, 
  p.estado_pedido, 
  p.total_cop 
FROM pedidos p 
JOIN clientes c ON p.id_cliente = c.id_cliente 
WHERE p.estado_pedido = 'ENTREGADO' 
  AND p.fecha_pedido >= DATE_SUB(NOW(), INTERVAL 90 DAY);

-- =============================================================================
-- 4. APLICACIÓN DE LA MEJORA DBA: CREACIÓN DE ÍNDICE B-TREE COMPUESTO
-- =============================================================================
-- Justificación: Se coloca primero la columna de igualdad ('estado_pedido') 
-- y luego la columna de rango ('fecha_pedido') para máxima selectividad.
CREATE INDEX idx_pedidos_estado_fecha 
ON pedidos (estado_pedido, fecha_pedido);

-- =============================================================================
-- 5. ESTADO POSTERIOR (CON ÍNDICE B-TREE): COMPARACIÓN DE RESULTADOS
-- =============================================================================

-- Ejecución de EXPLAIN tras la optimización:
-- Se observa que el tipo cambia a 'ref' o 'range', utilizando el índice recién creado
EXPLAIN 
SELECT 
  p.id_pedido, 
  c.nombre_completo, 
  p.fecha_pedido, 
  p.estado_pedido, 
  p.total_cop 
FROM pedidos p 
JOIN clientes c ON p.id_cliente = c.id_cliente 
WHERE p.estado_pedido = 'ENTREGADO' 
  AND p.fecha_pedido >= DATE_SUB(NOW(), INTERVAL 90 DAY);

-- Verificación con EXPLAIN ANALYZE:
-- Demuestra reducción dramática del tiempo de ejecución (Index Range Scan) y coste de CPU
EXPLAIN ANALYZE 
SELECT 
  p.id_pedido, 
  c.nombre_completo, 
  p.fecha_pedido, 
  p.estado_pedido, 
  p.total_cop 
FROM pedidos p 
JOIN clientes c ON p.id_cliente = c.id_cliente 
WHERE p.estado_pedido = 'ENTREGADO' 
  AND p.fecha_pedido >= DATE_SUB(NOW(), INTERVAL 90 DAY);

-- 6. INSPECCIÓN DE ÍNDICES EN LA TABLA
SHOW INDEX FROM pedidos;
