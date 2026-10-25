# ACA · Pitch Final — Administración de Bases de Datos
## Diseño de una Estrategia de Administración, Seguridad, Respaldo y Monitoreo
**Caso de Aplicación Práctica: Comercializadora AgroSilvania Market (MySQL 8.0)**

* **Estudiante / DBA:** Cristian Camilo Tabares Villanueva
* **Institución:** Corporación Unificada Nacional de Educación Superior (CUN) — Facultad de Ingeniería de Sistemas
* **Asignatura:** ADMINISTRACION DE BASES DE DATOS
* **Grupo / Bloque / Ciclo:** 55526 / PRIMER BLOQUE / 26P05
* **Docente Tutor:** Gabriel E. Beltrán
* **Repositorio Remoto en GitHub:** [Universidad_Administracion_Base_Datos](https://github.com/soycamiloypunto/Universidad_Administracion_Base_Datos.git)
* **Sitio Web de Diapositivas (GitHub Pages):** [https://soycamiloypunto.github.io/Universidad_Administracion_Base_Datos/](https://soycamiloypunto.github.io/Universidad_Administracion_Base_Datos/)
* **🎥 Video de Sustentación Oficial en YouTube (Pitch DBA):** [https://youtu.be/l8UXRyq_z0I](https://youtu.be/l8UXRyq_z0I)

---

## 📺 Sustentación Oral y Demostración Práctica (Pitch DBA)

[![Ver Sustentación Pitch DBA en YouTube](https://img.shields.io/badge/YouTube-Video_de_Sustentación_Pitch_DBA-red?style=for-the-badge&logo=youtube)](https://youtu.be/l8UXRyq_z0I)
[![Ver Presentación Web Interactiva](https://img.shields.io/badge/GitHub_Pages-Diapositivas_Interactivas-blue?style=for-the-badge&logo=github)](https://soycamiloypunto.github.io/Universidad_Administracion_Base_Datos/)

> **Enlace directo al Video:** [https://youtu.be/l8UXRyq_z0I](https://youtu.be/l8UXRyq_z0I)  
> **Duración:** 8 a 10 minutos (Estructurado en los 9 momentos oficiales de la rúbrica).  
> **Expositor y DBA:** Cristian Camilo Tabares Villanueva.

---

## 📌 Resumen del Reto Profesional DBA
La base de datos relacional de **AgroSilvania Market** (6 tablas en MySQL 8) en Silvania, Cundinamarca, enfrentaba problemas críticos: uso indiscriminado de la cuenta de superusuario `root`, ausencia de auditoría en pedidos alterados, consultas lentas con *Full Table Scan* sobre +5.000 pedidos, fragmentación de espacio y carencia de una política de respaldo probada.

Este proyecto implementa una solución técnica completa, integral y 100% reproducible:
1. **Recursos Físicos:** Creación de un **General Tablespace dedicado** (`ts_agrosilvania.ibd`) en motor InnoDB.
2. **Seguridad RBAC:** Roles diferenciados (`rol_app_backend`, `rol_auditor_seguridad`, `rol_operador_bodega`) y demostración en vivo de `GRANT` y `REVOKE`.
3. **Auditoría Forense:** Tabla inmutable `auditoria_pedidos` y Trigger automático `trg_audit_pedidos_update` ante cambios de estado o montos capturando usuario y conexión.
4. **Automatización:** Procedimiento `sp_mantenimiento_semanal_agro` con `ANALYZE` y `OPTIMIZE`, registrando métricas en milisegundos, y programación semanal en el `EVENT SCHEDULER`.
5. **Optimización Demostrada:** Análisis comparativo con `EXPLAIN ANALYZE` e índice compuesto B-Tree (`idx_pedidos_estado_fecha`) que reduce en un **85%** el uso de CPU.
6. **Respaldo y Recuperación:** Copia consistente en caliente con `mysqldump --single-transaction`, simulación de fallo destructivo (`DROP TABLE`) y restauración verificada con integridad transaccional al 100%.

---

## 📂 Inventario de Entregables en este Repositorio

| Archivo / Entregable | Formato | Descripción |
| :--- | :---: | :--- |
| **[`ACA_Administracion_Bases_Datos_Cristian_Tabares.pdf`](./ACA_Administracion_Bases_Datos_Cristian_Tabares.pdf)** | PDF Oficial | **Documento técnico formal listo para calificación** bajo Normas APA 7, con diagnóstico, justificación, desarrollo de los 9 momentos, evidencias y resultados. |
| **[`ACA_Administracion_Bases_Datos_Cristian_Tabares.docx`](./ACA_Administracion_Bases_Datos_Cristian_Tabares.docx)** | Word APA 7 | Documento editable con portada oficial, tabla de contenidos, estructura modular de responsabilidades y anexos. |
| **[`index.html`](./index.html)** | Web / Pages | Presentación interactiva del Pitch organizada en 8 diapositivas con temporizador regresivo y enlace directo al repositorio y video. |
| **[`docker-compose.yml`](./docker-compose.yml)** | Docker Compose | Despliegue de MySQL 8.0 en contenedor preconfigurado en puerto 3306 con tablespace y volumen persistente. |
| **[`backups/backup_full_agrosilvania_db.sql`](./backups/backup_full_agrosilvania_db.sql)** | Backup SQL | Volcado completo consistente de la base de datos (con datos maestros, +5.000 pedidos, triggers, roles y rutinas). |
| **[`scripts_sql/`](./scripts_sql/)** | Carpeta SQL | Colección de scripts SQL modulares, reproducibles y ampliamente documentados. |

### Detalle de los Scripts SQL (`scripts_sql/`):
* **[`01_ddl_tablespace_schema.sql`](./scripts_sql/01_ddl_tablespace_schema.sql):** Creación de base de datos UTF-8mb4, tablespace dedicado `ts_agrosilvania` y las 6 tablas relacionales normalizadas.
* **[`02_poblacion_datos_semilla.sql`](./scripts_sql/02_poblacion_datos_semilla.sql):** Inserción de catálogo campesino de Silvania y procedimiento generador de estrés (+5.000 pedidos).
* **[`03_seguridad_roles_grant_revoke.sql`](./scripts_sql/03_seguridad_roles_grant_revoke.sql):** Configuración RBAC con 3 roles, usuarios dedicados y ciclo de prueba `GRANT` / `REVOKE`.
* **[`04_auditoria_triggers.sql`](./scripts_sql/04_auditoria_triggers.sql):** Tabla de auditoría inmutable y disparadores automáticos a nivel de fila (`AFTER UPDATE` y `BEFORE DELETE`).
* **[`05_automatizacion_procedimientos.sql`](./scripts_sql/05_automatizacion_procedimientos.sql):** Stored Procedure de optimización/desfragmentación y Event Scheduler semanal desatendido.
* **[`06_optimizacion_explain_indices.sql`](./scripts_sql/06_optimizacion_explain_indices.sql):** Diagnóstico con `EXPLAIN ANALYZE` antes y después del índice compuesto B-Tree sobre pedidos.
* **[`07_backup_y_recuperacion.sql`](./scripts_sql/07_backup_y_recuperacion.sql):** Comandos de respaldo consistente en caliente, simulación de desastre y restauración con integridad referencial.

---

## ⚡ Guía Rápida de Reproducción del Laboratorio (< 3 Minutos)

### Con Docker Desktop (Recomendado):
1. **Levantar el contenedor de MySQL 8.0:**
   ```bash
   docker compose up -d
   ```
2. **Restaurar la base de datos completa desde el backup incluido:**
   * En **PowerShell (Windows)**:
     ```powershell
     Get-Content "backups/backup_full_agrosilvania_db.sql" | docker exec -i mysql-agrosilvania-db mysql -u dba_admin -pDbaPassword2026! agrosilvania_db
     ```
   * En **Linux / macOS / Bash**:
     ```bash
     docker exec -i mysql-agrosilvania-db mysql -u dba_admin -pDbaPassword2026! agrosilvania_db < backups/backup_full_agrosilvania_db.sql
     ```
3. **Conexión desde DBeaver o MySQL Workbench:**
   * **Host:** `localhost` (o `127.0.0.1`) | **Puerto:** `3306`
   * **Base de Datos:** `agrosilvania_db`
   * **Usuario:** `dba_admin` | **Contraseña:** `DbaPassword2026!`

---

## 🌐 Despliegue en GitHub Pages
Para visualizar las diapositivas interactivas en línea sin instalar nada, accede a:  
👉 **[https://soycamiloypunto.github.io/Universidad_Administracion_Base_Datos/](https://soycamiloypunto.github.io/Universidad_Administracion_Base_Datos/)**

---
**Autor y DBA:** Cristian Camilo Tabares Villanueva  
*Ingeniería de Sistemas — Corporación Unificada Nacional de Educación Superior (CUN) 2026*
