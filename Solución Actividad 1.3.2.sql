-- Caso 1
SELECT numrun_cli || '-' || dvrun_cli "run cliente",
       LOWER(pnombre_cli) || ' ' || initcap(snombre_cli) || ' ' || appaterno_cli || ' ' || apmaterno_cli "nombre completo cliente",
       fecha_nac_cli "fecha nacimiento"
FROM cliente
WHERE TO_CHAR(fecha_nac_cli, 'MMDD') = TO_CHAR(SYSDATE +1, 'MMDD')
ORDER BY appaterno_cli;

UNDEFINE FECHA;
SELECT numrun_cli || '-' || dvrun_cli "run cliente",
       LOWER(pnombre_cli) || ' ' || initcap(snombre_cli) || ' ' || appaterno_cli || ' ' || apmaterno_cli "nombre completo cliente",
       fecha_nac_cli "fecha nacimiento"
FROM cliente
WHERE TO_CHAR(fecha_nac_cli, 'MMDD') = TO_CHAR(TO_DATE('&fecha')+1, 'MMDD') 
ORDER BY appaterno_cli;

-- Caso 2
SELECT numrun_emp || ' ' || dvrun_emp  "run empleado",
       pnombre_emp || ' ' || snombre_emp || ' ' || appaterno_emp || ' ' || apmaterno_emp "nombre completo empleado",
       sueldo_base "sueldo base",
       TRUNC(sueldo_base / 100000) "porcentaje movilizacion",
       ROUND(sueldo_base * TRUNC(sueldo_base / 100000) / 100 ) "valor movilizacion"
FROM empleado
ORDER BY "porcentaje movilizacion" DESC;

-- 3 
SELECT numrun_emp || ' ' || dvrun_emp  "run empleado",
       pnombre_emp || ' ' || snombre_emp || ' ' || appaterno_emp || ' ' || apmaterno_emp "nombre completo empleado",
       sueldo_base "SUELDO BASE", fecha_nac "FECHA NACIMIENTO",
       SUBSTR(pnombre_emp,1,3)||length(pnombre_emp)||'*'||SUBSTR(sueldo_base,-1)
         ||dvrun_emp||TO_CHAR(extract(year from sysdate) - extract(year from fecha_contrato)) "NOMBRE USUARIO",
         SUBSTR(numrun_emp,3,1)||extract(year from fecha_nac)+2
           || substr(sueldo_base,-3) -1 || SUBSTR(appaterno_emp,-2) 
           || EXTRACT(MONTH FROM SYSDATE) clave
FROM empleado
ORDER BY appaterno_emp;

-- Caso 4
CREATE TABLE hist_rebaja_arriendo AS
SELECT EXTRACT(YEAR FROM sysdate) anio_proceso,
       nro_patente, valor_arriendo_dia "valor_arriendo_dia_sr",
       valor_garantia_dia "valor_garantia_sr",
       EXTRACT(YEAR FROM sysdate) - anio "años antiguedad",
       valor_arriendo_dia * (1 -(EXTRACT(YEAR FROM sysdate) - anio) / 100) "valor_arriendo_dia_cr", 
       valor_garantia_dia * (1 -(EXTRACT(YEAR FROM sysdate) - anio) / 100) "valor_garantia_dia_cr"
FROM camion
WHERE EXTRACT(YEAR FROM sysdate) - anio > 5;

-- 5
SELECT to_char(sysdate, 'MM/YYYY') mes_anno_proceso,
       nro_patente, fecha_ini_arriendo,
       dias_solicitados, fecha_devolucion,
       fecha_devolucion - (fecha_ini_arriendo + dias_solicitados) dias_atraso,
       (fecha_devolucion - (fecha_ini_arriendo + dias_solicitados)) * &v_multa 
FROM arriendo_camion
WHERE EXTRACT(MONTH FROM fecha_devolucion) = EXTRACT(MONTH FROM sysdate) - 1
AND EXTRACT(YEAR FROM fecha_devolucion) = EXTRACT(YEAR FROM sysdate)
AND fecha_devolucion - (fecha_ini_arriendo + dias_solicitados) > 0
ORDER BY fecha_ini_arriendo, nro_patente;

SELECT to_char(sysdate, 'MM/YYYY') mes_anno_proceso,
       nro_patente, fecha_ini_arriendo,
       dias_solicitados, fecha_devolucion,
       fecha_devolucion - (fecha_ini_arriendo + dias_solicitados) dias_atraso,
       (fecha_devolucion - (fecha_ini_arriendo + dias_solicitados)) * &v_multa 
FROM arriendo_camion
WHERE TO_CHAR(fecha_devolucion, 'YYYYMM') = TO_CHAR(ADD_MONTHS(SYSDATE,-1), 'YYYYMM')
AND fecha_devolucion - (fecha_ini_arriendo + dias_solicitados) > 0
ORDER BY fecha_ini_arriendo, nro_patente;

