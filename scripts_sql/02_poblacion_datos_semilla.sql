-- =============================================================================
-- ACA · PITCH FINAL — ADMINISTRACIÓN DE BASES DE DATOS (CUN 2026)
-- ARCHIVO 02: POBLACIÓN DE DATOS SEMILLA (SILVANIA, CUNDINAMARCA)
-- Estudiante: Cristian Camilo Tabares Villanueva
-- Docente: Gabriel E. Beltrán
-- =============================================================================

USE agrosilvania_db;

-- 1. Insertar Productores Campesinos de Silvania
INSERT INTO productores (nombre_completo, identificacion, vereda, telefono, email, hectareas_cultivo) VALUES
('Don Pedro Alcántara Guzmán', '19456789', 'Vereda Subia', '3115487920', 'pedro.guzman@agrosilvania.co', 3.5),
('Doña Rosalba Méndez Peñaloza', '51890234', 'Vereda Yayata', '3128904512', 'rosalba.mendez@agrosilvania.co', 2.0),
('Efraín Cárdenas Beltrán', '79845120', 'Vereda San José', '3204561234', 'efrain.cardenas@agrosilvania.co', 4.2),
('María Esmeralda Tique Forero', '1032456789', 'Vereda Agua Bonita', '3149876543', 'esmeralda.tique@agrosilvania.co', 1.8),
('Jorge Hernán Rodríguez Castro', '80123987', 'Vereda Azafranal', '3157890123', 'jorge.rodriguez@agrosilvania.co', 5.0);

-- 2. Insertar Categorías Agrícolas
INSERT INTO categorias (nombre_categoria, descripcion) VALUES
('Café Especial y Pergamino', 'Café arábico de altura cultivado entre 1600 y 1900 msnm con notas florales y frutales.'),
('Frutas y Moras de Altura', 'Mora de Castilla, uchuva ecotipo Colombia y tomate de árbol seleccionados.'),
('Hortalizas y Verduras Frescas', 'Cilantro, lechuga Batavia y espinaca producidos bajo buenas prácticas agrícolas sin pesticidas químicos.'),
('Tubérculos y Plátanos', 'Yuca campesina, papa criolla dorada y plátano hartón cultivado en el valle de Silvania.');

-- 3. Insertar Catálogo de Productos
INSERT INTO productos (id_productor, id_categoria, nombre_producto, descripcion, stock_disponible_kg, precio_productor_cop, precio_venta_cop) VALUES
(1, 1, 'Café Pergamino Seco Variedad Castillo (Libra)', 'Café de especialidad con 84 puntos SCA, secado al sol en camas africanas.', 450.00, 18000.00, 24000.00),
(1, 2, 'Mora de Castilla Seleccionada Grado A', 'Mora fresca de corte diario, tamaño mediano a grande, ideal para pulpas y consumo directo.', 800.00, 3800.00, 5200.00),
(2, 2, 'Uchuva con Capacho Ecotipo Colombia', 'Fruta dorada rica en antioxidantes con empaque natural de capacho protector.', 320.00, 5500.00, 7800.00),
(3, 2, 'Tomate de Árbol Criollo Anaranjado', 'Tomate carnoso de acidez equilibrada, recolectado en punto óptimo de maduración.', 600.00, 3200.00, 4600.00),
(4, 3, 'Lechuga Batavia Hidropónica (Unidad)', 'Hojas crujientes cultivadas en agua de manantial con nutrientes orgánicos.', 250.00, 1800.00, 2800.00),
(4, 3, 'Cilantro Criollo de Hoja Ancha (Atado 500g)', 'Aroma intenso y frescura garantizada del campo a la cocina.', 180.00, 1200.00, 2000.00),
(5, 4, 'Papa Criolla Amarilla de Primera', 'Papa limpia sin lavado químico, piel delgada y excelente textura para sopas.', 1200.00, 2800.00, 4000.00);

-- 4. Insertar Clientes Urbanos
INSERT INTO clientes (nombre_completo, identificacion, email, telefono, direccion_entrega, ciudad_municipio) VALUES
('Alejandro Restrepo Gómez', '80765432', 'alejandro.restrepo@gmail.com', '3109876543', 'Calle 127 # 15-32 Apto 402', 'Bogotá D.C.'),
('Camila Andrea Vargas Ruiz', '1018987456', 'camila.vargas@outlook.com', '3167894561', 'Carrera 7 # 67-45', 'Bogotá D.C.'),
('Gustavo Adolfo Pinzón', '79456123', 'gustavo.pinzon@yahoo.com', '3174561238', 'Transversal 39 # 26-10 Sur', 'Bogotá D.C.'),
('Restaurante El Sabor Sabanero (NIT)', '901234567', 'compras@elsaborsabanero.com', '3182345678', 'Av. Las Palmas # 12-04', 'Fusagasugá');

-- 5. Insertar Pedidos Iniciales
INSERT INTO pedidos (id_cliente, fecha_pedido, estado_pedido, metodo_pago, subtotal_cop, costo_envio_cop, total_cop) VALUES
(1, '2026-09-01 09:30:00', 'ENTREGADO', 'PSE', 72000.00, 12000.00, 84000.00),
(2, '2026-09-02 11:15:00', 'ENTREGADO', 'NEQUI', 46000.00, 12000.00, 58000.00),
(3, '2026-09-05 14:20:00', 'PAGADO', 'DAVIPLATA', 52000.00, 12000.00, 64000.00),
(4, '2026-09-07 08:00:00', 'PENDIENTE', 'TRANSFERENCIA_BANCARIA', 184000.00, 25000.00, 209000.00);

-- 6. Insertar Detalles de Pedidos
INSERT INTO detalle_pedidos (id_pedido, id_producto, cantidad_kg, precio_unitario_cop, subtotal_linea_cop) VALUES
(1, 1, 3.00, 24000.00, 72000.00),
(2, 2, 5.00, 5200.00, 26000.00),
(2, 4, 4.00, 4600.00, 18400.00),
(3, 2, 10.00, 5200.00, 52000.00),
(4, 7, 30.00, 4000.00, 120000.00),
(4, 4, 10.00, 4600.00, 46000.00),
(4, 1, 1.00, 24000.00, 24000.00);

-- =============================================================================
-- PROCEDIMIENTO PARA POBLACIÓN MASIVA DE DATOS HISTÓRICOS (PRUEBAS DE ESTRÉS Y EXPLAIN)
-- Inserta 5.000 pedidos adicionales para evidenciar la degradación de consultas sin índice
-- =============================================================================
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_poblar_pedidos_estres$$
CREATE PROCEDURE sp_poblar_pedidos_estres(IN cantidad_registros INT)
BEGIN
  DECLARE i INT DEFAULT 0;
  DECLARE v_cliente INT;
  DECLARE v_fecha DATETIME;
  DECLARE v_estado VARCHAR(20);
  DECLARE v_total DECIMAL(12,2);
  DECLARE v_estados VARCHAR(100) DEFAULT 'PENDIENTE,PAGADO,EN_RUTA,ENTREGADO,CANCELADO';

  WHILE i < cantidad_registros DO
    SET v_cliente = FLOOR(1 + (RAND() * 4));
    -- Generar fechas aleatorias de los últimos 180 días
    SET v_fecha = DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 180) DAY);
    SET v_estado = ELT(FLOOR(1 + (RAND() * 5)), 'PENDIENTE', 'PAGADO', 'EN_RUTA', 'ENTREGADO', 'CANCELADO');
    SET v_total = ROUND(25000 + (RAND() * 250000), 2);

    INSERT INTO pedidos (id_cliente, fecha_pedido, estado_pedido, metodo_pago, subtotal_cop, costo_envio_cop, total_cop)
    VALUES (v_cliente, v_fecha, v_estado, 'PSE', v_total - 12000, 12000, v_total);

    SET i = i + 1;
  END WHILE;
END$$
DELIMITER ;

-- Ejecutar la población de 5.000 registros para contar con volumen analítico realista
CALL sp_poblar_pedidos_estres(5000);

SELECT COUNT(*) AS total_pedidos_cargados FROM pedidos;
