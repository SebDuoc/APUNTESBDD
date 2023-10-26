--  CASO 1
SELECT ts.descripcion||','||sa.descripcion,
       COUNT(*) ATENCIONES
FROM tipo_salud ts JOIN salud sa ON sa.tipo_sal_id = ts.tipo_sal_id
JOIN paciente pac ON pac.sal_id = sa.sal_id
JOIN atencion AT ON AT.pac_run = pac.pac_run
WHERE TO_CHAR(fecha_atencion, 'MMYYYY') = TO_CHAR(ADD_MONTHS(sysdate,0), 'MMYYYY') 
GROUP BY ts.descripcion||','||sa.descripcion
HAVING COUNT(*) > (SELECT ROUND(AVG(COUNT(*)))
                   FROM atencion 
                   WHERE TO_CHAR(fecha_atencion, 'MMYYYY') = TO_CHAR(ADD_MONTHS(sysdate,-1), 'MMYYYY') 
                   GROUP BY fecha_atencion)
ORDER BY ts.descripcion||','||sa.descripcion;

-- 1B VARIAS ALTERNATIVAS (LA PRIMERA CON SUBCONSULTA)
SELECT TO_CHAR(P.PAC_RUN, '09G999G999')||'-'||P.DV_RUN "RUN PACIENTE",
       P.PNOMBRE||' '||P.SNOMBRE||' '||P.APATERNO||' '||P.AMATERNO "NOMBRE PACIENTE",
       ROUND(MONTHS_BETWEEN(SYSDATE, P.FECHA_NACIMIENTO)/12) EDAD,
       'Le corresponde un ' || (SELECT PORCENTAJE_DESCTO * 1 FROM PORC_DESCTO_3RA_EDAD PD 
        WHERE ROUND(MONTHS_BETWEEN(SYSDATE, P.FECHA_NACIMIENTO)/12) 
        BETWEEN PD.ANNO_INI AND PD.ANNO_TER)||'% de descuento en la primera '||
        'consulta medica del año ' || TO_CHAR(TO_CHAR(SYSDATE, 'YYYY') + 1)  "PORCENTAJE DESCUENTO"
FROM PACIENTE P JOIN ATENCION A ON P.PAC_RUN = A.PAC_RUN
WHERE ROUND(MONTHS_BETWEEN(SYSDATE, P.FECHA_NACIMIENTO) /12,1) > 65.5
  AND TO_CHAR(A.FECHA_ATENCION,'yyyy') = TO_CHAR(SYSDATE, 'YYYY')  
GROUP BY P.PAC_RUN, P.DV_RUN, P.PNOMBRE, P.SNOMBRE, P.APATERNO, P.AMATERNO,P.FECHA_NACIMIENTO
HAVING COUNT(*) > 4
ORDER BY p.apaterno;

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
ORDER BY p.apaterno;

-- 2
SELECT es.nombre especialidad, to_char(M.med_run, '09g999g999')||'-'||M.dv_run rut,
       UPPER(M.pnombre||' '||M.snombre||' '||M.apaterno||' '||M.amaterno) medico,
       COUNT(ate.ate_id)
FROM medico M LEFT JOIN atencion ate ON M.med_run = ate.med_run 
JOIN especialidad_medico EM ON EM.med_run = M.med_run 
JOIN especialidad es ON es.esp_id = EM.esp_id AND es.esp_id = ate.esp_id
WHERE to_char(ate.fecha_atencion, 'yyyy') = to_char(sysdate,'yyyy') -1
OR ate.ate_id IS NULL
GROUP BY es.nombre, M.med_run,M.dv_run,M.pnombre,M.snombre,M.apaterno,M.amaterno
HAVING COUNT(ate.ate_id) IN (SELECT COUNT(*)
                             FROM atencion
                             WHERE to_char(fecha_atencion, 'yyyy') = to_char(sysdate,'yyyy') -1
                             GROUP BY esp_id
                             HAVING COUNT(*) < 10)
ORDER BY es.nombre, M.apaterno;

-- 3
DROP TABLE MEDICOS_SERVICIO_COMUNIDAD;
CREATE TABLE MEDICOS_SERVICIO_COMUNIDAD AS 
SELECT uni.nombre unidad,
       me.pnombre||' '||me.snombre||' '||me.apaterno||' '||me.amaterno medico,
       substr(uni.nombre,1,2)||substr(me.apaterno,-3,2)||substr(me.telefono,-3)||
       to_char(me.fecha_contrato,'ddmm')||'@medicocktk.cl' correo, 
       count(atn.ate_id) "ATENCIONES MEDICAS"
FROM medico me LEFT JOIN atencion atn ON me.med_run = atn.med_run
LEFT JOIN unidad uni ON uni.uni_id = me.uni_id
WHERE TO_CHAR(atn.fecha_atencion, 'yyyy') = to_char(trunc(SYSDATE, 'year'),'yyyy') - 1
OR atn.ate_id IS NULL
GROUP BY uni.nombre, me.pnombre, me.snombre, me.apaterno, me.amaterno, me.fecha_contrato, me.telefono
HAVING count(atn.ate_id) < (SELECT MAX(count(*))
                            FROM atencion
                            WHERE TO_CHAR(fecha_atencion, 'yyyy') = to_char(trunc(SYSDATE, 'year'),'yyyy') - 1 
                            GROUP BY med_run)
ORDER BY uni.nombre, me.apaterno;

select * from medicos_servicio_comunidad;

-- 4a 
SELECT to_char(fecha_atencion, 'yyyy/mm') "MES Y AÑO",
       COUNT(*) "TOTAL DE ATENCIONES", 
       LPAD(TO_CHAR(sum(COSTO), '$9g999G999'),27) "VALOR TOTAL DE LAS ATENCIONES"
FROM atencion
WHERE TO_CHAR(FECHA_ATENCION, 'YYYY') <= to_char(SYSDATE,'yyyy')  
GROUP BY to_char(fecha_atencion, 'yyyy/mm') 
HAVING COUNT(*) > (SELECT AVG(COUNT(*))
                   FROM ATENCION
                   WHERE TO_CHAR(FECHA_ATENCION, 'YYYY') = to_char(SYSDATE,'yyyy') -1  
                   GROUP BY to_char(fecha_atencion, 'mm'))
ORDER BY to_char(fecha_atencion, 'yyyy/mm');

--4b
SELECT pa.pac_run "RUN PACIENTE",
       pa.apaterno||' '||pa.amaterno||' '||pa.pnombre||' '||pa.snombre "NOMBRE PACIENTE",
       AT.ate_id "ID ATENCION",
       pg.fecha_venc_pago "FECHA VENCIMIENTO",
       pg.fecha_pago "FECHA PAGO",
       pg.fecha_pago - pg.fecha_venc_pago "DIAS MOROSIDAD",
       to_char((pg.fecha_pago - pg.fecha_venc_pago) * 2000, '$9g999g999') "VALOR MULTA"
FROM atencion AT JOIN paciente pa ON pa.pac_run = AT.pac_run
JOIN pago_atencion pg ON pg.ate_id = AT.ate_id
WHERE pg.fecha_pago - pg.fecha_venc_pago > 
                        (SELECT AVG(count(pg.fecha_pago - pg.fecha_venc_pago))
                         FROM pago_atencion pg
                         WHERE TO_CHAR(pg.fecha_venc_pago, 'YYYY') < to_char(SYSDATE,'yyyy') 
                         AND pg.fecha_pago - pg.fecha_venc_pago > 0
                         GROUP BY TO_CHAR(pg.fecha_venc_pago, 'YYYY'))
AND TO_CHAR(pg.fecha_venc_pago, 'YYYY') <= to_char(SYSDATE,'yyyy')   
ORDER BY pg.fecha_venc_pago, pg.fecha_pago - pg.fecha_venc_pago DESC;

-- 5
-- ingresa el monto de las ganancias 2250000000
SELECT TO_CHAR(me.med_run, '09G999G999')||'-'||me.dv_run "RUN MEDICO",
       me.pnombre||' '||me.snombre||' '||me.apaterno||' '||me.amaterno medico,
       TO_CHAR(me.sueldo_base, '$99G999G999') "SUELDO BASE",
       count(atn.ate_id) "ATENCIONES MEDICAS",
       LPAD(TO_CHAR(ROUND((&&v_ganancias * 0.005) / (SELECT COUNT(*) FROM ( SELECT me.med_run FROM medico me JOIN atencion atn ON me.med_run = atn.med_run AND TO_CHAR(fecha_atencion, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY') GROUP BY me.med_run HAVING count(atn.ate_id) > 7))), '$99G999G999'), 16, ' ') "BONIFICACION POR GANANCIAS", 
       TO_CHAR(me.sueldo_base + ROUND((&v_ganancias * 0.005) / (SELECT COUNT(*) FROM ( SELECT me.med_run FROM medico me JOIN atencion atn ON me.med_run = atn.med_run AND TO_CHAR(fecha_atencion, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY') GROUP BY me.med_run HAVING count(atn.ate_id) > 7))), '$999G999G999') "TOTAL SUELDOS"       
FROM medico me JOIN atencion atn ON me.med_run = atn.med_run
AND TO_CHAR(fecha_atencion, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY')
GROUP BY me.med_run, me.dv_run, me.pnombre,me.snombre,me.apaterno,me.amaterno,me.sueldo_base
HAVING count(atn.ate_id) > 7
ORDER BY me.med_run, me.apaterno;

undefine v_ganancias;


