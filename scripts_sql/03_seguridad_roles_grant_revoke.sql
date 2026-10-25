-- =============================================================================
-- ACA · PITCH FINAL — ADMINISTRACIÓN DE BASES DE DATOS (CUN 2026)
-- ARCHIVO 03: SEGURIDAD, ROLES, Y DEMOSTRACIÓN DE GRANT Y REVOKE
-- Estudiante: Cristian Camilo Tabares Villanueva
-- Docente: Gabriel E. Beltrán
-- =============================================================================

USE agrosilvania_db;

-- 1. DIAGNÓSTICO PREVIO:
-- El sistema operaba con la cuenta 'root' compartida entre desarrolladores y personal
-- de bodega, sin contraseñas robustas, violando el principio de menor privilegio.

-- 2. CREACIÓN DE ROLES EN MYSQL 8 (RBAC - Role-Based Access Control)
DROP ROLE IF EXISTS rol_app_backend;
DROP ROLE IF EXISTS rol_auditor_seguridad;
DROP ROLE IF EXISTS rol_operador_bodega;

CREATE ROLE rol_app_backend;
CREATE ROLE rol_auditor_seguridad;
CREATE ROLE rol_operador_bodega;

-- Asignación de privilegios específicos a cada ROL:
-- ROL 1: Backend de Microservicios Java (Solo DML transaccional, NUNCA DDL destructivo)
GRANT SELECT, INSERT, UPDATE, DELETE ON agrosilvania_db.* TO rol_app_backend;

-- ROL 2: Auditor de Seguridad y Cumplimiento (Solo lectura de auditoría y negocio)
GRANT SELECT ON agrosilvania_db.* TO rol_auditor_seguridad;

-- ROL 3: Operador de Bodega / Logística en Silvania (Solo actualizar estados de despacho)
GRANT SELECT ON agrosilvania_db.pedidos TO rol_operador_bodega;
GRANT SELECT ON agrosilvania_db.detalle_pedidos TO rol_operador_bodega;
GRANT SELECT ON agrosilvania_db.productos TO rol_operador_bodega;
GRANT UPDATE (estado_pedido) ON agrosilvania_db.pedidos TO rol_operador_bodega;

-- 3. CREACIÓN DE USUARIOS INDIVIDUALES CON AUTENTICACIÓN SEGURA
DROP USER IF EXISTS 'usr_backend_java'@'%';
DROP USER IF EXISTS 'usr_auditor_cun'@'%';
DROP USER IF EXISTS 'usr_bodega_silvania'@'%';

CREATE USER 'usr_backend_java'@'%' 
  IDENTIFIED WITH mysql_native_password BY 'JavaSpring2026!BackendToken'
  FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 1;

CREATE USER 'usr_auditor_cun'@'%' 
  IDENTIFIED WITH mysql_native_password BY 'AuditorCUN2026!Inspect'
  PASSWORD EXPIRE INTERVAL 90 DAY;

CREATE USER 'usr_bodega_silvania'@'%' 
  IDENTIFIED WITH mysql_native_password BY 'BodegaSilvania2026!Logistics';

-- 4. VINCULACIÓN DE ROLES A LOS USUARIOS
GRANT rol_app_backend TO 'usr_backend_java'@'%';
GRANT rol_auditor_seguridad TO 'usr_auditor_cun'@'%';
GRANT rol_operador_bodega TO 'usr_bodega_silvania'@'%';

-- Activar los roles por defecto en el momento del inicio de sesión
SET DEFAULT ROLE rol_app_backend TO 'usr_backend_java'@'%';
SET DEFAULT ROLE rol_auditor_seguridad TO 'usr_auditor_cun'@'%';
SET DEFAULT ROLE rol_operador_bodega TO 'usr_bodega_silvania'@'%';

-- =============================================================================
-- 5. DEMOSTRACIÓN DE PERTINENCIA: GESTIÓN DE PRIVILEGIOS CON GRANT Y REVOKE
-- =============================================================================

-- Escenario de prueba: Se solicita temporalmente permiso de ejecución de procedimientos
-- al usuario del backend para pruebas de integración:
GRANT EXECUTE ON PROCEDURE agrosilvania_db.sp_poblar_pedidos_estres TO 'usr_backend_java'@'%';
FLUSH PRIVILEGES;

-- Evidencia de privilegios actuales:
SHOW GRANTS FOR 'usr_backend_java'@'%';

-- Finalizadas las pruebas de laboratorio, el DBA revoca de inmediato el permiso especial:
REVOKE EXECUTE ON PROCEDURE agrosilvania_db.sp_poblar_pedidos_estres FROM 'usr_backend_java'@'%';
FLUSH PRIVILEGES;

-- Evidencia de verificación tras REVOKE (Demuestra que ya no posee el privilegio):
SHOW GRANTS FOR 'usr_backend_java'@'%';
SHOW GRANTS FOR 'usr_auditor_cun'@'%';
SHOW GRANTS FOR 'usr_bodega_silvania'@'%';
