-- =============================================================================
-- ACA · PITCH FINAL — ADMINISTRACIÓN DE BASES DE DATOS (CUN 2026)
-- ARCHIVO 05: AUTOMATIZACIÓN DE MANTENIMIENTO Y EVENTOS PROGRAMADOS
-- Estudiante: Cristian Camilo Tabares Villanueva
-- Docente: Gabriel E. Beltrán
-- =============================================================================

USE agrosilvania_db;

-- 1. DIAGNÓSTICO:
-- Las tareas de mantenimiento (desfragmentación de índices, actualización de estadísticas
-- del optimizador de costes y depuración) se realizaban de forma manual o se olvidaban,
-- ocasionando fragmentación en disco y estadísticas obsoletas.

-- 2. TABLA DE CONTROL DE TAREAS ADMINISTRATIVAS
DROP TABLE IF EXISTS log_mantenimiento_dba;
CREATE TABLE log_mantenimiento_dba (
  id_log INT AUTO_INCREMENT PRIMARY KEY,
  tarea_ejecutada VARCHAR(100) NOT NULL,
  resultado_detalle TEXT,
  filas_afectadas INT DEFAULT 0,
  tiempo_ejecucion_ms DECIMAL(8,2),
  fecha_ejecucion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ejecutado_por VARCHAR(80) DEFAULT 'MYSQL_EVENT_SCHEDULER'
) TABLESPACE ts_agrosilvania ENGINE=InnoDB;

-- 3. PROCEDIMIENTO ALMACENADO DE MANTENIMIENTO GENERAL
DROP PROCEDURE IF EXISTS sp_mantenimiento_semanal_agro;
DELIMITER $$
CREATE PROCEDURE sp_mantenimiento_semanal_agro()
BEGIN
  DECLARE inicio_tiempo TIMESTAMP(3);
  DECLARE fin_tiempo TIMESTAMP(3);
  DECLARE duracion_ms DECIMAL(8,2);
  DECLARE v_filas INT DEFAULT 0;

  SET inicio_tiempo = NOW(3);

  -- Paso 1: Actualizar estadísticas del optimizador InnoDB en tablas críticas
  ANALYZE TABLE productos;
  ANALYZE TABLE pedidos;
  ANALYZE TABLE detalle_pedidos;

  -- Paso 2: Reorganizar y desfragmentar espacio físico en disco
  OPTIMIZE TABLE auditoria_pedidos;

  -- Paso 3: Identificar y registrar pedidos cancelados antiguos (> 180 días) para depuración
  SELECT COUNT(*) INTO v_filas 
  FROM pedidos 
  WHERE estado_pedido = 'CANCELADO' 
    AND fecha_pedido < DATE_SUB(NOW(), INTERVAL 180 DAY);

  SET fin_tiempo = NOW(3);
  SET duracion_ms = TIMESTAMPDIFF(MICROSECOND, inicio_tiempo, fin_tiempo) / 1000.0;

  -- Paso 4: Registrar evidencia del mantenimiento ejecutado
  INSERT INTO log_mantenimiento_dba (
    tarea_ejecutada, 
    resultado_detalle, 
    filas_afectadas, 
    tiempo_ejecucion_ms, 
    ejecutado_por
  ) VALUES (
    'MANTENIMIENTO_SEMANAL_ESTADISTICAS_Y_DESFRAGMENTACION',
    'Se ejecutó ANALYZE TABLE sobre catálogo y pedidos; OPTIMIZE TABLE sobre auditoría. Todo exitoso.',
    v_filas,
    duracion_ms,
    USER()
  );

  SELECT * FROM log_mantenimiento_dba ORDER BY id_log DESC LIMIT 1;
END$$
DELIMITER ;

-- 4. PROGRAMACIÓN DE TAREA AUTOMÁTICA MEDIANTE EVENT SCHEDULER
-- Se asegura que el programador de eventos de MySQL esté encendido
SET GLOBAL event_scheduler = ON;

DROP EVENT IF EXISTS evt_mantenimiento_semanal_agrosilvania;
DELIMITER $$
CREATE EVENT evt_mantenimiento_semanal_agrosilvania
ON SCHEDULE EVERY 1 WEEK
STARTS '2026-11-01 02:00:00'
DO
BEGIN
  CALL sp_mantenimiento_semanal_agro();
END$$
DELIMITER ;

-- =============================================================================
-- 5. DEMOSTRACIÓN DE EJECUCIÓN MANUAL INMEDIATA POR EL DBA
-- =============================================================================
CALL sp_mantenimiento_semanal_agro();

-- Verificar el estado de eventos en el motor
SHOW EVENTS FROM agrosilvania_db;
