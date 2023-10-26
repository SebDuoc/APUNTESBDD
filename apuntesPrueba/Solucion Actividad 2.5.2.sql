--  1A  INGRESAR FECHA DE NOVIEMBRE DEl año actual (ddmmyyyy)
SELECT ts.descripcion||','||sa.descripcion SISTEMA_SALUD,
       COUNT(AT.ATE_ID) "TOTAL ATENCIONES",
       CASE 
         WHEN COUNT(AT.ATE_ID) > ROUND((SELECT AVG(COUNT(*)) FROM ATENCION
                                 GROUP BY FECHA_ATENCION)) THEN 'CON DESCUENTO'
         ELSE 'SIN DESCUENTO'
      END "CORRESPONDE DESCUENTO"   
FROM tipo_salud ts LEFT JOIN salud sa ON sa.tipo_sal_id = ts.tipo_sal_id
LEFT JOIN paciente pac ON pac.sal_id = sa.sal_id
LEFT JOIN atencion AT ON AT.pac_run = pac.pac_run
WHERE TO_CHAR(AT.fecha_atencion, 'MM/YYYY') = TO_CHAR(ADD_MONTHS(TO_DATE('&FECHA'), -1), 'MM/YYYY')
OR AT.ATE_ID IS NULL
GROUP BY ts.descripcion, sa.descripcion
ORDER BY ts.descripcion, sa.descripcion;


-- 1B VARIAS ALTERNATIVAS
-- ALTERNATIVA 1
SELECT TO_CHAR(P.PAC_RUN, '09G999G999')||'-'||P.DV_RUN "RUN PACIENTE",
       P.PNOMBRE||' '||P.SNOMBRE||' '||P.APATERNO||' '||P.AMATERNO "NOMBRE PACIENTE",
       ROUND(MONTHS_BETWEEN(SYSDATE, P.FECHA_NACIMIENTO)/12) EDAD,
       'Le corresponde un ' || (SELECT PORCENTAJE_DESCTO * 1 FROM PORC_DESCTO_3RA_EDAD PD 
        WHERE ROUND(MONTHS_BETWEEN(SYSDATE, P.FECHA_NACIMIENTO)/12) 
        BETWEEN PD.ANNO_INI AND PD.ANNO_TER)||'% de descuento en la primera '||
        'consulta medica del año ' || TO_CHAR(TO_CHAR(SYSDATE, 'YYYY') + 1)  "PORCENTAJE DESCUENTO",
        'Beneficio por tercera edad'
FROM PACIENTE P JOIN ATENCION A ON P.PAC_RUN = A.PAC_RUN
WHERE ROUND(MONTHS_BETWEEN(SYSDATE, P.FECHA_NACIMIENTO) /12,1) > 64.5
  AND TO_CHAR(A.FECHA_ATENCION,'yyyy') = TO_CHAR(SYSDATE, 'YYYY')   
GROUP BY P.PAC_RUN, P.DV_RUN, P.PNOMBRE, P.SNOMBRE, P.APATERNO, P.AMATERNO,P.FECHA_NACIMIENTO
HAVING COUNT(*) > 4
UNION
SELECT TO_CHAR(P.PAC_RUN, '09G999G999')||'-'||P.DV_RUN "RUN PACIENTE",
       P.PNOMBRE||' '||P.SNOMBRE||' '||P.APATERNO||' '||P.AMATERNO "NOMBRE PACIENTE",
       ROUND(MONTHS_BETWEEN(SYSDATE, P.FECHA_NACIMIENTO)/12) EDAD,
       'Le corresponde un 2% de descuento en la primera '||
        'consulta medica del año ' || TO_CHAR(TO_CHAR(SYSDATE, 'YYYY') + 1)  "PORCENTAJE DESCUENTO",
        'Beneficio por cantidad de consultas medicas anuales'
FROM PACIENTE P JOIN ATENCION A ON P.PAC_RUN = A.PAC_RUN
WHERE ROUND(MONTHS_BETWEEN(SYSDATE, P.FECHA_NACIMIENTO) /12,1) < 65
  AND TO_CHAR(A.FECHA_ATENCION,'yyyy') = TO_CHAR(SYSDATE, 'YYYY')   
GROUP BY P.PAC_RUN, P.DV_RUN, P.PNOMBRE, P.SNOMBRE, P.APATERNO, P.AMATERNO,P.FECHA_NACIMIENTO
HAVING COUNT(*) >= 5 ;

-- ALTERNATIVA 2
SELECT TO_CHAR(P.PAC_RUN, '09G999G999')||'-'||P.DV_RUN "RUN PACIENTE",
       P.PNOMBRE||' '||P.SNOMBRE||' '||P.APATERNO||' '||P.AMATERNO "NOMBRE PACIENTE",
       ROUND(MONTHS_BETWEEN(SYSDATE, P.FECHA_NACIMIENTO)/12) EDAD,
       'Le corresponde un ' || PD.PORCENTAJE_DESCTO * 1 ||'% de descuento en la primera '||
        'consulta medica del año ' ||  TO_CHAR(TO_CHAR(SYSDATE, 'YYYY') + 1) "PORCENTAJE DESCUENTO"
FROM PACIENTE P JOIN ATENCION A ON P.PAC_RUN = A.PAC_RUN
JOIN PORC_DESCTO_3RA_EDAD PD ON ROUND(MONTHS_BETWEEN(SYSDATE, P.FECHA_NACIMIENTO) /12) BETWEEN PD.ANNO_INI AND PD.ANNO_TER
WHERE TO_CHAR(A.FECHA_ATENCION,'yyyy') = TO_CHAR(SYSDATE, 'YYYY')
GROUP BY P.PAC_RUN, P.DV_RUN, P.PNOMBRE, P.SNOMBRE, P.APATERNO, P.AMATERNO,P.FECHA_NACIMIENTO, PD.PORCENTAJE_DESCTO
HAVING COUNT(*) > 4
UNION
SELECT TO_CHAR(P.PAC_RUN, '09G999G999')||'-'||P.DV_RUN "RUN PACIENTE",
       P.PNOMBRE||' '||P.SNOMBRE||' '||P.APATERNO||' '||P.AMATERNO "NOMBRE PACIENTE",
       ROUND(MONTHS_BETWEEN(SYSDATE, P.FECHA_NACIMIENTO)/12) EDAD,
       'Le corresponde un 2% de descuento en la primera '||
       'consulta medica del año ' ||  TO_CHAR(TO_CHAR(SYSDATE, 'YYYY') + 1) "PORCENTAJE DESCUENTO"
FROM PACIENTE P JOIN ATENCION A ON P.PAC_RUN = A.PAC_RUN
WHERE TO_CHAR(A.FECHA_ATENCION,'yyyy') = TO_CHAR(SYSDATE, 'YYYY')
  AND ROUND(MONTHS_BETWEEN(SYSDATE, P.FECHA_NACIMIENTO) /12,1) < 65
GROUP BY P.PAC_RUN, P.DV_RUN, P.PNOMBRE, P.SNOMBRE, P.APATERNO, P.AMATERNO,P.FECHA_NACIMIENTO
HAVING COUNT(*) >= 5;

-- 2
SELECT es.nombre especialidad, TO_CHAR(me.med_run, '09g999g999')||'-'||me.dv_run rut, 
       UPPER(me.pnombre||' '||me.snombre||' '||me.apaterno||' '||me.amaterno) medico
       --COUNT(AT.ate_id) 
FROM especialidad es JOIN especialidad_medico EM ON es.esp_id = EM.esp_id  
JOIN atencion AT ON at.esp_id = EM.esp_id
JOIN medico me ON me.med_run = EM.med_run  
WHERE TO_CHAR(AT.fecha_atencion, 'yyyy') = to_char(SYSDATE,'yyyy') 
GROUP BY es.nombre, me.med_run, me.dv_run, me.pnombre,me.snombre,me.apaterno,me.amaterno
HAVING COUNT(AT.ate_id) > 10
ORDER BY es.nombre, me.apaterno;

SELECT es.nombre especialidad, TO_CHAR(me.med_run, '09g999g999')||'-'||me.dv_run rut, 
       UPPER(me.pnombre||' '||me.snombre||' '||me.apaterno||' '||me.amaterno) medico
       --COUNT(AT.ate_id) 
FROM especialidad es LEFT JOIN especialidad_medico EM ON es.esp_id = EM.esp_id   
LEFT JOIN medico me ON me.med_run = EM.med_run  
LEFT JOIN atencion AT ON AT.med_run = EM.med_run AND AT.esp_id = es.esp_id
WHERE TO_CHAR(AT.fecha_atencion, 'yyyy') = to_char(TRUNC(TO_DATE('&fecha'), 'year'),'yyyy') 
GROUP BY es.nombre, me.med_run, me.dv_run, me.pnombre,me.snombre,me.apaterno,me.amaterno
HAVING COUNT(AT.ate_id) > 10
ORDER BY es.nombre, me.apaterno;

-- 3
DROP TABLE MEDICOS_SERVICIO_COMUNIDAD;
CREATE TABLE MEDICOS_SERVICIO_COMUNIDAD AS 
SELECT uni.nombre unidad,
       me.pnombre||' '||me.snombre||' '||me.apaterno||' '||me.amaterno medico,
       me.telefono,
       substr(uni.nombre,1,2)||substr(me.apaterno,-3,2)||substr(me.telefono,-3)||
       to_char(me.fecha_contrato,'ddmm')||'@medicocktk.cl' correo, 
       ROUND(MONTHS_BETWEEN(SYSDATE, me.fecha_contrato) /12),
       count(atn.ate_id) "ATENCIONES MEDICAS"
FROM medico me JOIN unidad uni ON uni.uni_id = me.uni_id
left JOIN atencion atn ON me.med_run = atn.med_run
WHERE TO_CHAR(atn.fecha_atencion, 'yyyy') = to_char(trunc(SYSDATE, 'year'),'yyyy') -1
 AND ROUND(MONTHS_BETWEEN(SYSDATE, me.fecha_contrato) /12) >= 10
OR atn.ate_id IS NULL
AND ROUND(MONTHS_BETWEEN(SYSDATE, me.fecha_contrato) /12) >= 10
GROUP BY uni.nombre, me.pnombre, me.snombre, me.apaterno, me.amaterno, me.fecha_contrato, me.telefono
HAVING count(atn.ate_id) < (SELECT MAX(COUNT(*))
                            FROM ATENCION
                            WHERE TO_CHAR(fecha_atencion, 'yyyy') = to_char(sysdate,'yyyy') -1
                            GROUP BY med_run)
ORDER BY uni.nombre, me.apaterno;


-- 4a 
SELECT to_char(fecha_atencion, 'yyyy/mm') "MES Y AÑO",
       COUNT(*) "TOTAL DE ATENCIONES", 
       LPAD(TO_CHAR(sum(COSTO), '$9g999G999'),27) "VALOR TOTAL DE LAS ATENCIONES"
FROM atencion
WHERE TO_CHAR(FECHA_ATENCION, 'YYYY') = to_char(trunc(SYSDATE, 'year'),'yyyy')
GROUP BY to_char(fecha_atencion, 'yyyy/mm') 
HAVING COUNT(*) >= (SELECT AVG(COUNT(*))
                    FROM ATENCION
                    WHERE TO_CHAR(FECHA_ATENCION, 'mm') = to_char(SYSDATE,'mm')
                    and TO_CHAR(FECHA_ATENCION, 'YYYY') = to_char(trunc(SYSDATE, 'year'),'yyyy') 
                    GROUP BY to_char(fecha_atencion, 'mm/yyyy'))
UNION
SELECT to_char(fecha_atencion, 'yyyy/mm') "MES Y AÑO",
       COUNT(*) "TOTAL DE ATENCIONES", 
       LPAD(TO_CHAR(sum(COSTO), '$9g999G999'),27) "VALOR TOTAL DE LAS ATENCIONES"
FROM atencion
WHERE TO_CHAR(FECHA_ATENCION, 'YYYY') = to_char(trunc(SYSDATE, 'year'),'yyyy') - 1
GROUP BY to_char(fecha_atencion, 'yyyy/mm') 
HAVING COUNT(*) >= (SELECT AVG(COUNT(*))
                    FROM ATENCION
                    WHERE TO_CHAR(FECHA_ATENCION, 'mm') = to_char(SYSDATE,'mm')
                    and TO_CHAR(FECHA_ATENCION, 'YYYY') = to_char(trunc(SYSDATE, 'year'),'yyyy') -1 
                    GROUP BY to_char(fecha_atencion, 'mm/yyyy'))
UNION
SELECT to_char(fecha_atencion, 'yyyy/mm') "MES Y AÑO",
       COUNT(*) "TOTAL DE ATENCIONES", 
       LPAD(TO_CHAR(sum(COSTO), '$9g999G999'),27) "VALOR TOTAL DE LAS ATENCIONES"
FROM atencion
WHERE TO_CHAR(FECHA_ATENCION,'YYYY') = to_char(trunc(SYSDATE, 'year'),'yyyy') - 2
GROUP BY to_char(fecha_atencion, 'yyyy/mm') 
HAVING COUNT(*) > 15
ORDER BY 1;

-- 5  SOLUCION SIGUIENDO LA IMAGEN 
-- 5 SOLUCION SIGUIENDO EL ENUNCIADO 
-- SI SE DIVIDE EL MONTO INGRESADO POR EL NUMERO DE MEDICOS TAMPOCO RESULTA
-- ASI QUE LO DIVIDÍ TAMBIEN POR LAS ATENCIONES
-- EL NUMERO DE MEDICOS EN CADA CASO LO OBTUVE CON ESTAS SUBCONSULTAS

-- EN EL CASO DE MAS DE 7 ATENCIONES
SELECT COUNT(*) FROM ( SELECT me.med_run FROM medico me JOIN atencion atn ON me.med_run = atn.med_run AND TO_CHAR(fecha_atencion, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY') GROUP BY me.med_run HAVING count(atn.ate_id) > 7);
-- EN EL CASO DE IGUAL O MENOS QUE 7  ATENCIONES
SELECT COUNT(*) FROM ( SELECT me.med_run FROM medico me JOIN atencion atn ON me.med_run = atn.med_run AND TO_CHAR(fecha_atencion, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY') GROUP BY me.med_run HAVING count(atn.ate_id) <=7);

-- AL APLICAR ESTA SOLUCION APARECEN ALGUNAS COINCIDENCIAS CON LA IMAGEN 
-- COMO EN EL CASO DE MANUEL ARAVENA FUENTEALBA


SELECT 'MEDICO CON BONIFICACION DEL 5% DE LAS GANANCIAS' "BONIFICACION GANANCIAS",
       TO_CHAR(me.med_run, '09G999G999')||'-'||me.dv_run "RUN MEDICO",
       me.pnombre||' '||me.snombre||' '||me.apaterno||' '||me.amaterno medico,
       TO_CHAR(me.sueldo_base, '$9g999g999') "SUELDO BASE",
       count(atn.ate_id) "ATENCIONES MEDICAS",
       TO_CHAR(ROUND((2250000000 * 0.005)  / (SELECT COUNT(*) FROM ( SELECT me.med_run FROM medico me JOIN atencion atn ON me.med_run = atn.med_run AND TO_CHAR(fecha_atencion, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY') GROUP BY me.med_run HAVING count(atn.ate_id) > 7))), '$99G999G999') "BONIFICACION POR GANANCIAS", 
       TO_CHAR(me.sueldo_base + ROUND((2250000000*0.005) / (SELECT COUNT(*) FROM ( SELECT me.med_run FROM medico me JOIN atencion atn ON me.med_run = atn.med_run AND TO_CHAR(fecha_atencion, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY') GROUP BY me.med_run HAVING count(atn.ate_id) > 7))), '$999G999G999') "TOTAL SUELDOS"
FROM medico me JOIN atencion atn ON me.med_run = atn.med_run
AND TO_CHAR(fecha_atencion, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY') 
GROUP BY me.med_run, me.dv_run, me.pnombre,me.snombre,me.apaterno,me.amaterno,me.sueldo_base
HAVING count(atn.ate_id) > 7
UNION
SELECT 'MEDICO CON BONIFICACION DEL 2% DE LAS GANANCIAS' "BONIFICACION GANANCIAS",
       TO_CHAR(me.med_run, '09G999G999')||'-'||me.dv_run "RUN MEDICO",
       me.pnombre||' '||me.snombre||' '||me.apaterno||' '||me.amaterno medico,
       TO_CHAR(me.sueldo_base, '$9g999g999') "SUELDO BASE",
       count(atn.ate_id) "ATENCIONES MEDICAS",
       TO_CHAR(ROUND((2250000000 * 0.002) / (SELECT COUNT(*) FROM ( SELECT me.med_run FROM medico me JOIN atencion atn ON me.med_run = atn.med_run AND TO_CHAR(fecha_atencion, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY') GROUP BY me.med_run HAVING count(atn.ate_id) <= 7))), '$99G999G999') "BONIFICACION POR GANANCIAS", 
       TO_CHAR(me.sueldo_base + ROUND((2250000000 * 0.002) / (SELECT COUNT(*) FROM ( SELECT me.med_run FROM medico me JOIN atencion atn ON me.med_run = atn.med_run AND TO_CHAR(fecha_atencion, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY') GROUP BY me.med_run HAVING count(atn.ate_id) <= 7))), '$999G999G999') "TOTAL SUELDOS"
FROM medico me JOIN atencion atn ON me.med_run = atn.med_run
AND TO_CHAR(fecha_atencion, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY') 
GROUP BY me.med_run, me.dv_run, me.pnombre,me.snombre,me.apaterno,me.amaterno,me.sueldo_base
HAVING count(atn.ate_id) <= 7
ORDER BY "RUN MEDICO";

