-- ###########################################################################################################################
-- ################################################  SOLUCION  ###############################################################
-- ###########################################################################################################################
-- PREGUNTA 1
SELECT  to_char(substr(rutcliente,1,instr(rutcliente,'-')-1),'99g999g999')||'-'||substr(rutcliente,-1) "RUT CLIENTE",
        --to_char(substr(rutcliente,1,length(rutcliente)-2),'99g999g999')||'-'||substr(rutcliente,-1) "RUT CLIENTE",
        nombre,
        CASE 
        WHEN saldo <= 0 THEN 'SUSPENDIDO'
        ELSE 'VIGENTE'
        END "SITUACION CREDITO",
        codcomuna,
        estado,
        to_char(credito,'$99g999g999') "CREDITO",
        to_char(saldo,'$99g999g999') "SALDO"
FROM cliente
WHERE estado = 'A' AND saldo <= (credito*0.5)
OR saldo <= 0;

-- PREGUNTA 2
SELECT codproducto,
       descripcion,
       CASE codunidad
       WHEN 'UN' THEN 'UNITARIO'
       WHEN 'LT' THEN 'LITRO'
       END "UNIDAD",
       nvl(to_char(totalstock),'SIN STOCK') "STOCK ACTUAL",
       codpais,
       CASE codpais
       WHEN 1 THEN 'CHILE'
       WHEN 3 THEN 'INGLATERRA'
       WHEN 4 THEN 'ALEMANIA'
       WHEN 5 THEN 'FRANCIA'
       WHEN 6 THEN 'CANADA'
       WHEN 7 THEN 'ARGENTINA'
       WHEN 8 THEN 'BRASIL'
       END "PAIS"
FROM producto
WHERE totalstock IS NULL OR 
totalstock < 50 AND codpais != 2
ORDER BY pais;

-- PREGUNTA 3
-- ingresa la fecha cuando se te solicite
SELECT numboleta "NUMERO BOLETA",
       to_char(substr(rutcliente,1,instr(rutcliente,'-')-1),'99g999g999')||'-'||substr(rutcliente,-1) "RUT CLIENTE",
       to_char(substr(rutvendedor,1,instr(rutvendedor,'-')-1),'99g999g999')||'-'||substr(rutvendedor,-1) "RUT VENDEDOR",
       fecha,
       to_char(total,'$999g999') "total",
       to_char(TRUNC(total*(0.75)),'$99g999g999') rebaja, 
       nvl(num_docto_pago,'NO POSEE') "DOCUMENTO"
FROM boleta
WHERE estado = 'EM' AND num_docto_pago IS NULL
AND to_char(fecha, 'YYYYMM') = to_char(add_months(TO_DATE('&FECHA'), -1), 'YYYYMM')
ORDER BY numboleta DESC;

-- PREGUNTA 4
SELECT numboleta "NUMERO BOLETA",
       to_char(substr(rutcliente,1,instr(rutcliente,'-')-1),'99g999g999')||'-'||substr(rutcliente,-1) "RUT CLIENTE",
       to_char(substr(rutvendedor,1,instr(rutvendedor,'-')-1),'99g999g999')||'-'||substr(rutvendedor,-1) "RUT VENDEDOR",
       fecha,
       to_char(total,'$999g999') "TOTAL",
       TRUNC(MONTHS_BETWEEN(SYSDATE,fecha)) "ANTIGUEDAD",
       TO_CHAR(CASE
       WHEN TRUNC(MONTHS_BETWEEN(SYSDATE,fecha)) > 5 THEN TRUNC(total*0.9)
       WHEN TRUNC(MONTHS_BETWEEN(SYSDATE,fecha)) BETWEEN 3 AND 5 THEN TRUNC(total*0.85)
       WHEN TRUNC(MONTHS_BETWEEN(SYSDATE,fecha)) BETWEEN 1 AND 2 THEN TRUNC(total*0.8)
       ELSE TRUNC(total*1)
       END,'$99g999g999') "TOTAL CON RABAJA",
       nvl(num_docto_pago,'NO POSEE') "DOCUMENTO"
FROM boleta
WHERE estado = 'EM' AND num_docto_pago IS NULL
and fecha BETWEEN TO_DATE('&fecha_1') AND TO_DATE('&fecha_2') ;

-- PREGUNTA 5
SELECT to_char(substr(RUTVENDEDOR,1,instr(RUTVENDEDOR,'-')-1),'99g999g999')||'-'||substr(RUTVENDEDOR,-1) "RUT VENDEDOR",
       SUBSTR(NOMBRE,INSTR(NOMBRE, ' ')) || ' ' || SUBSTR(NOMBRE,1, INSTR(NOMBRE, ' ')) NOMBRE,   
       TO_CHAR(SUELDO_BASE,'$999g999') "BASE",
       LPAD('%'||NVL((COMISION*100),0),7,' ') "% COMISION",
       TO_CHAR((SUELDO_BASE*NVL(COMISION,0)),'$999g999g999') COMISION,
       TO_CHAR(((SUELDO_BASE+(SUELDO_BASE*NVL(COMISION,0)))*0.37),'$999g999') ASIGNACION,
       TO_CHAR((SUELDO_BASE+(SUELDO_BASE*NVL(COMISION,0))+((SUELDO_BASE+(SUELDO_BASE*NVL(COMISION,0)))*0.37)),'$999G999') "SUELDO IMPONIBLE",
       TO_CHAR(TRUNC((SUELDO_BASE+(SUELDO_BASE*NVL(COMISION,0))+((SUELDO_BASE+(SUELDO_BASE*NVL(COMISION,0)))*0.37))*0.13 ),'$999G999')  prevision,
       TO_CHAR((TRUNC(SUELDO_BASE+(SUELDO_BASE*NVL(COMISION,0))+((SUELDO_BASE+(SUELDO_BASE*NVL(COMISION,0)))*0.37))*0.07),'$9999G999') SALUD,
       TO_CHAR(SUELDO_BASE+(SUELDO_BASE*NVL(COMISION,0))+((SUELDO_BASE+(SUELDO_BASE*NVL(COMISION,0)))*0.37)  - (((SUELDO_BASE+(SUELDO_BASE*NVL(COMISION,0))+((SUELDO_BASE+(SUELDO_BASE*NVL(COMISION,0)))*0.37))*0.13) + ((SUELDO_BASE+(SUELDO_BASE*NVL(COMISION,0))+((SUELDO_BASE+(SUELDO_BASE*NVL(COMISION,0)))*0.37))*0.07)),'$999G999') "SUELO LIQUIDO"
FROM VENDEDOR
ORDER BY nombre;

SELECT run_vendedor, nombre, base, "% COMISION", COMISION, ASIGNACION, TO_CHAR(IMPONIBLE, '$999G999') "SUELDO IMPONIBLE",
 
       TO_CHAR(ROUND(IMPONIBLE * 0.13), '$999G999') PREVISION,
       TO_CHAR(ROUND(IMPONIBLE * 0.07), '$999G999') SALUD,
       TO_CHAR(IMPONIBLE - ROUND(IMPONIBLE * 0.13) - ROUND(IMPONIBLE * 0.07), '$999G999')  "SUELDO LIQUIDO"
FROM (
    SELECT to_char(substr(RUTVENDEDOR,1,instr(RUTVENDEDOR,'-')-1),'99g999g999')||'-'||substr(RUTVENDEDOR,-1) RUn_VENDEDOR,
           SUBSTR(NOMBRE,INSTR(NOMBRE, ' ')) || ' ' || SUBSTR(NOMBRE,1, INSTR(NOMBRE, ' ')) NOMBRE,   
           TO_CHAR(SUELDO_BASE,'$999g999') BASE,
           LPAD('%'||NVL((COMISION*100),0),7,' ') "% COMISION",
           TO_CHAR((SUELDO_BASE*NVL(COMISION,0)),'$999g999g999') COMISION,
           TO_CHAR(((SUELDO_BASE+(SUELDO_BASE*NVL(COMISION,0)))*0.37),'$999g999g999') ASIGNACION,
           (SUELDO_BASE+(SUELDO_BASE*NVL(COMISION,0))+((SUELDO_BASE+(SUELDO_BASE*NVL(COMISION,0)))*0.37)) IMPONIBLE
    FROM VENDEDOR
    )
ORDER BY nombre;

