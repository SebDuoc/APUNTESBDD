-- RQ1
-- Crea usuarios
-- Ejecutar como SYSTEM
CREATE USER MDY2131_P3_1 IDENTIFIED BY duoc
TEMPORARY TABLESPACE "TEMP";
ALTER USER MDY2131_P3_1 QUOTA UNLIMITED ON USERS;

CREATE USER MDY2131_P3_2 IDENTIFIED BY duoc
TEMPORARY TABLESPACE "TEMP";
ALTER USER MDY2131_P3_2 QUOTA UNLIMITED ON USERS;

-- Asignamos el privilegio para conectarse
-- Ejecutar como SYSTEM
GRANT "CONNECT" TO MDY2131_P3_1, MDY2131_P3_2;

-- Seguimos asignando privilegios de acuerdo con las acciones
-- Ejecutar como SYSTEM
GRANT CREATE TABLE, CREATE SEQUENCE, CREATE ANY INDEX TO MDY2131_P3_1;
GRANT CREATE PROCEDURE, CREATE TRIGGER, CREATE VIEW, CREATE materialized VIEW TO MDY2131_P3_2;

-- Ejecutar como SYSTEM
GRANT "RESOURCE" TO MDY2131_P3_1, MDY2131_P3_2;

-- Para saber que incluye el RESOURCE
-- Ejecutar como SYSTEM
SELECT * FROM DBA_SYS_PRIVS WHERE GRANTEE = 'RESOURCE';

-- Acceso a los datos y objetos
-- Ejecutar como SYSTEM
GRANT SELECT ON MDY2131_P3_1.BOLETA TO MDY2131_P3_2;
GRANT SELECT ON MDY2131_P3_1.VENDEDOR TO MDY2131_P3_2;

GRANT UPDATE, INSERT, DELETE ON MDY2131_P3_1.factura TO MDY2131_P3_2;
GRANT UPDATE, INSERT, DELETE ON MDY2131_P3_1.detalle_factura TO MDY2131_P3_2;

-- Ahora vamos a crear los sinonimos
-- Asignamos privilegios
-- Ejecutamos com SYSTEM
GRANT CREATE SYNONYM, CREATE PUBLIC SYNONYM TO MDY2131_P3_1;

-- Ejecutar con MDY2131_P3_1
CREATE PUBLIC SYNONYM syn_uno FOR vendedor;
CREATE SYNONYM syn_dos FOR boleta;

-- Vamos a asignar los permisos al usuario 2 para ver los sinonimos
-- Ejecutar como SYSTEM
GRANT SELECT ON syn_uno TO MDY2131_P3_2;
GRANT SELECT ON MDY2131_P3_1.syn_dos TO MDY2131_P3_2;

-- Crea el rol y asisgnamos sus privilegios
-- Ejecutar como SYSTEM
CREATE ROLE rol_consultor;

-- ACÁ DEBERIAMOS CREAR PRIMERO SINONIMOS Y LUEGO ASIGNAR EL PERMISO DE CONSULTA DE ESOS SINONIMOS
-- SIN EMBARGO EN HONOR AL TIEMPO LO HARE DIRECTO

-- Ahora si, tal y como dice el enunciado
-- Primero se crean los sinonimos
-- Ejecutar como MDY2131_P3_1
CREATE PUBLIC SYNONYM syn_a FOR cliente;
CREATE PUBLIC SYNONYM syn_b FOR banco;

-- Ahora asignamos los permisos
-- Ejecutar como SYSTEM
GRANT SELECT ON syn_a TO MDY2131_P3_2;
GRANT SELECT ON syn_b TO MDY2131_P3_2;

-- Esto lo habiamos realizado para avanzar ( el enunciado indica que se deben usar sinónimos, por eso esto no cumple requisito)
-- Ejecutar como SYSTEM
GRANT SELECT ON MDY2131_P3_1.cliente TO rol_consultor;
GRANT SELECT ON MDY2131_P3_1.banco TO rol_consultor;

-- RQ2

-- Primero comprobamos si el ususario puede acceder a los sinonimos
-- Ejecutar como MDY2131_P3_2
SELECT * FROM syn_uno;
SELECT * FROM MDY2131_P3_1.syn_dos;

-- Crea la vista
-- Ejecutar como MDY2131_P3_2
CREATE OR REPLACE VIEW vista_rq2 AS
SELECT v.rutvendedor, nombre, TO_CHAR(fecha, 'MM-YYYY') AS "PERIODO", SUM(total) AS "MONTO_TOTAL_BOLETAS",
CASE
  WHEN SUM(total) <= 100000 THEN 'A'
  WHEN SUM(total) BETWEEN 100001 AND 200000 THEN 'B'
  WHEN SUM(total) BETWEEN 200001 AND 400000 THEN 'C'
  ELSE 'D'
END AS "CATEGORIA"
FROM syn_uno v JOIN MDY2131_P3_1.syn_dos b ON(v.rutvendedor = b.rutvendedor)
WHERE TO_CHAR(fecha, 'YYYY') >= TO_CHAR(SYSDATE, 'YYYY')  - 3
GROUP BY v.rutvendedor, nombre, TO_CHAR(fecha, 'MM-YYYY') 
ORDER BY 2
WITH READ ONLY;

-- Verifica que se puede ver la vista
SELECT * FROM vista_rq2;

-- RQ3

-- EJECUTAR COMO MDY2131_P3_1
SELECT LPAD(c.rutcliente,12,' ') "RUT CLIENTE", c.nombre "NOMBRE CLIENTE", 
v.rutvendedor "RUT VENDEDOR", v.nombre "NOMBRE VENDEDOR",
NVL(descripcion, 'SIN FORMA DE PAGO') "TIPO PAGO",
TO_CHAR(total*100/119,'$99g999g999') "MONTO NETO",
TO_CHAR(total,'$99g999g999') "MONTO CON IVA"
FROM boleta b JOIN cliente c ON(c.rutcliente = b.rutcliente)
JOIN vendedor v ON(v.rutvendedor = b.rutvendedor)
LEFT JOIN forma_pago fp ON(fp.codpago = b.codpago)
WHERE total >= 100000
ORDER BY c.nombre, "MONTO NETO" DESC;

-- Creamos el indice, basado en B-TREE
CREATE INDEX IDX_BOLETA ON BOLETA(total);


SELECT descripcion "BANCO", TO_CHAR(AVG(total),'$999G9999') "TOTAL BOLETAS PAGADAS"
FROM banco b JOIN boleta b ON(b.codbanco = b.codbanco)
WHERE UPPER(estado) =  'PA'
GROUP BY descripcion
ORDER BY 1;

-- Creacion de indice basado en funcion
CREATE INDEX idx_boleta_banco ON boleta(UPPER(estado));
