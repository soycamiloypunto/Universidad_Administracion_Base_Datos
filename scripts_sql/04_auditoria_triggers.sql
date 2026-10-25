-- =============================================================================
-- ACA · PITCH FINAL — ADMINISTRACIÓN DE BASES DE DATOS (CUN 2026)
-- ARCHIVO 04: AUDITORÍA DE DATOS CRÍTICOS Y TRIGGERS AUTOMÁTICOS
-- Estudiante: Cristian Camilo Tabares Villanueva
-- Docente: Gabriel E. Beltrán
-- =============================================================================

USE agrosilvania_db;

-- 1. DIAGNÓSTICO:
-- Existían discrepancias en pedidos y quejas de clientes por cobros alterados,
-- pero el motor no registraba quién modificaba los estados de pago o montos.

-- 2. TABLA DE AUDITORÍA INMUTABLE
DROP TABLE IF EXISTS auditoria_pedidos;
CREATE TABLE auditoria_pedidos (
  id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT NOT NULL,
  tipo_accion VARCHAR(20) NOT NULL COMMENT 'UPDATE, DELETE, CANCELACION',
  estado_anterior VARCHAR(30),
  estado_nuevo VARCHAR(30),
  total_anterior DECIMAL(12,2),
  total_nuevo DECIMAL(12,2),
  usuario_modificador VARCHAR(100) NOT NULL,
  conexion_id BIGINT,
  fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  motivo_cambio VARCHAR(255) DEFAULT 'Actualización transaccional del sistema'
) TABLESPACE ts_agrosilvania ENGINE=InnoDB;

-- 3. TRIGGER DE AUDITORÍA: trg_audit_pedidos_update (AFTER UPDATE)
DROP TRIGGER IF EXISTS trg_audit_pedidos_update;
DELIMITER $$
CREATE TRIGGER trg_audit_pedidos_update
AFTER UPDATE ON pedidos
FOR EACH ROW
BEGIN
  -- Solo auditar si hubo alteración en estado o valor económico del pedido
  IF (OLD.estado_pedido <> NEW.estado_pedido) OR (OLD.total_cop <> NEW.total_cop) THEN
    INSERT INTO auditoria_pedidos (
      id_pedido,
      tipo_accion,
      estado_anterior,
      estado_nuevo,
      total_anterior,
      total_nuevo,
      usuario_modificador,
      conexion_id,
      fecha_modificacion,
      motivo_cambio
    ) VALUES (
      OLD.id_pedido,
      'UPDATE',
      OLD.estado_pedido,
      NEW.estado_pedido,
      OLD.total_cop,
      NEW.total_cop,
      USER(),
      CONNECTION_ID(),
      NOW(),
      CONCAT('Transición de estado de ', OLD.estado_pedido, ' a ', NEW.estado_pedido)
    );
  END IF;
END$$
DELIMITER ;

-- 4. TRIGGER PREVENTIVO ANTE BORRADOS: trg_audit_pedidos_delete (BEFORE DELETE)
DROP TRIGGER IF EXISTS trg_audit_pedidos_delete;
DELIMITER $$
CREATE TRIGGER trg_audit_pedidos_delete
BEFORE DELETE ON pedidos
FOR EACH ROW
BEGIN
  INSERT INTO auditoria_pedidos (
    id_pedido,
    tipo_accion,
    estado_anterior,
    estado_nuevo,
    total_anterior,
    total_nuevo,
    usuario_modificador,
    conexion_id,
    fecha_modificacion,
    motivo_cambio
  ) VALUES (
    OLD.id_pedido,
    'DELETE_CRITICO',
    OLD.estado_pedido,
    'ELIMINADO',
    OLD.total_cop,
    0.00,
    USER(),
    CONNECTION_ID(),
    NOW(),
    'ALERTA DBA: Intento de borrado de registro de pedido'
  );
END$$
DELIMITER ;

-- =============================================================================
-- 5. DEMOSTRACIÓN DE AUDITORÍA EN VIVO (SIMULACIÓN DE CAMBIO DE ESTADO)
-- =============================================================================

-- Modificar el estado del pedido 4 de PENDIENTE a PAGADO
UPDATE pedidos 
SET estado_pedido = 'PAGADO', total_cop = 215000.00 
WHERE id_pedido = 4;

-- Modificar el estado del pedido 3 de PAGADO a EN_RUTA
UPDATE pedidos 
SET estado_pedido = 'EN_RUTA' 
WHERE id_pedido = 3;

-- Consultar la tabla de auditoría para verificar la trazabilidad forense
SELECT 
  id_auditoria,
  id_pedido,
  tipo_accion,
  CONCAT(estado_anterior, ' ➔ ', estado_nuevo) AS cambio_estado,
  total_anterior,
  total_nuevo,
  usuario_modificador,
  fecha_modificacion,
  motivo_cambio
FROM auditoria_pedidos
ORDER BY id_auditoria DESC;
