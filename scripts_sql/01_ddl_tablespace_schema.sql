-- =============================================================================
-- ACA · PITCH FINAL — ADMINISTRACIÓN DE BASES DE DATOS (CUN 2026)
-- ARCHIVO 01: DDL, CONFIGURACIÓN DE TABLESPACE Y ESQUEMA RELACIONAL (6 TABLAS)
-- Estudiante: Cristian Camilo Tabares Villanueva
-- Docente: Gabriel E. Beltrán
-- Materia: ADMINISTRACION DE BASES DE DATOS / 55526 / PRIMER BLOQUE / 26P05
-- =============================================================================

-- 1. Asegurar base de datos limpia con codificación UTF-8 Multibyte
CREATE DATABASE IF NOT EXISTS agrosilvania_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE agrosilvania_db;

-- 2. Gestión de Recursos Físicos y Lógicos: Creación de TABLESPACE General
-- Permite aislar los datafiles de la aplicación en almacenamiento de alto rendimiento
-- NOTA: En MySQL 8 InnoDB, un General Tablespace permite agrupar múltiples tablas.
CREATE TABLESPACE ts_agrosilvania
  ADD DATAFILE 'ts_agrosilvania.ibd'
  ENGINE = InnoDB;

-- 3. Eliminación de tablas en orden de dependencias referenciales
DROP TABLE IF EXISTS detalle_pedidos;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS categorias;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS productores;

-- =============================================================================
-- CREACIÓN DE LAS 6 TABLAS NORMALIZADAS EN EL TABLESPACE DEDICADO
-- =============================================================================

-- TABLA 1: PRODUCTORES (Campesinos de Silvania, Cundinamarca)
CREATE TABLE productores (
  id_productor INT AUTO_INCREMENT PRIMARY KEY,
  nombre_completo VARCHAR(120) NOT NULL,
  identificacion VARCHAR(20) NOT NULL UNIQUE,
  vereda VARCHAR(80) NOT NULL COMMENT 'Veredas de Silvania: Subia, Yayata, San José, Azafranal, etc.',
  telefono VARCHAR(20) NOT NULL,
  email VARCHAR(100),
  hectareas_cultivo DECIMAL(5,2) DEFAULT 1.00,
  estado ENUM('ACTIVO', 'INACTIVO', 'SUSPENDIDO') DEFAULT 'ACTIVO',
  fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) TABLESPACE ts_agrosilvania ENGINE=InnoDB;

-- TABLA 2: CATEGORIAS (Clasificación de productos agrícolas)
CREATE TABLE categorias (
  id_categoria INT AUTO_INCREMENT PRIMARY KEY,
  nombre_categoria VARCHAR(60) NOT NULL UNIQUE,
  descripcion TEXT,
  activo BOOLEAN DEFAULT TRUE
) TABLESPACE ts_agrosilvania ENGINE=InnoDB;

-- TABLA 3: PRODUCTOS (Cosechas disponibles para venta directa)
CREATE TABLE productos (
  id_producto INT AUTO_INCREMENT PRIMARY KEY,
  id_productor INT NOT NULL,
  id_categoria INT NOT NULL,
  nombre_producto VARCHAR(100) NOT NULL,
  descripcion TEXT,
  unidad_medida VARCHAR(20) DEFAULT 'KILOGRAMO',
  stock_disponible_kg DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  precio_productor_cop DECIMAL(10,2) NOT NULL COMMENT 'Precio directo fijado por el campesino',
  precio_venta_cop DECIMAL(10,2) NOT NULL COMMENT 'Precio final al comprador sin intermediarios',
  estado ENUM('DISPONIBLE', 'AGOTADO', 'PAUSADO') DEFAULT 'DISPONIBLE',
  fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_prod_productor FOREIGN KEY (id_productor) REFERENCES productores(id_productor) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_prod_categoria FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria) ON DELETE RESTRICT ON UPDATE CASCADE
) TABLESPACE ts_agrosilvania ENGINE=InnoDB;

-- TABLA 4: CLIENTES (Compradores urbanos directos en Bogotá y Cundinamarca)
CREATE TABLE clientes (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  nombre_completo VARCHAR(120) NOT NULL,
  identificacion VARCHAR(20) NOT NULL UNIQUE,
  email VARCHAR(100) NOT NULL UNIQUE,
  telefono VARCHAR(20) NOT NULL,
  direccion_entrega VARCHAR(180) NOT NULL,
  ciudad_municipio VARCHAR(80) DEFAULT 'Bogotá D.C.',
  fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  activo BOOLEAN DEFAULT TRUE
) TABLESPACE ts_agrosilvania ENGINE=InnoDB;

-- TABLA 5: PEDIDOS (Órdenes transaccionales de compra)
CREATE TABLE pedidos (
  id_pedido INT AUTO_INCREMENT PRIMARY KEY,
  id_cliente INT NOT NULL,
  fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  estado_pedido ENUM('PENDIENTE', 'PAGADO', 'EN_RUTA', 'ENTREGADO', 'CANCELADO') DEFAULT 'PENDIENTE',
  metodo_pago ENUM('PSE', 'NEQUI', 'DAVIPLATA', 'TRANSFERENCIA_BANCARIA', 'CONTRAENTREGA') NOT NULL,
  subtotal_cop DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  costo_envio_cop DECIMAL(10,2) NOT NULL DEFAULT 12000.00,
  total_cop DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_ped_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE
) TABLESPACE ts_agrosilvania ENGINE=InnoDB;

-- TABLA 6: DETALLE_PEDIDOS (Renglones de productos adquiridos)
CREATE TABLE detalle_pedidos (
  id_detalle INT AUTO_INCREMENT PRIMARY KEY,
  id_pedido INT NOT NULL,
  id_producto INT NOT NULL,
  cantidad_kg DECIMAL(8,2) NOT NULL,
  precio_unitario_cop DECIMAL(10,2) NOT NULL,
  subtotal_linea_cop DECIMAL(12,2) NOT NULL,
  CONSTRAINT fk_det_pedido FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_det_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON DELETE RESTRICT ON UPDATE CASCADE
) TABLESPACE ts_agrosilvania ENGINE=InnoDB;

-- Verificación de estructura y tablas creadas
SELECT 
  TABLE_NAME, 
  ENGINE, 
  TABLE_COLLATION, 
  CREATE_TIME 
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'agrosilvania_db';
