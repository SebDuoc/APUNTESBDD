--1
SELECT TO_CHAR(cl.numrun, '09G999G999') ||'-'||cl.dvrun "RUN CLIENTE",
       initcap(cl.pnombre||' '||cl.snombre||' '||cl.appaterno||' '||cl.apmaterno) "NOMBRE CLIENTE",
       TO_CHAR(cl.fecha_nacimiento, 'dd "de" fmMonth') "DIA DE CUMPLEAÑOS",
       sr.direccion || '/' || UPPER(r.nombre_region)
FROM sucursal_retail sr JOIN region r
on sr.cod_region = r.cod_region
join cliente cl on (cl.cod_region = sr.cod_region and 
    cl.cod_comuna = sr.cod_comuna and cl.cod_provincia = sr.cod_provincia)
WHERE TO_CHAR(cl.fecha_nacimiento, 'MM') = to_char(add_months(SYSDATE, 1),'MM')
AND r.nombre_region = 'Metropolitana de Santiago'
ORDER BY EXTRACT(DAY FROM cl.fecha_nacimiento), cl.appaterno;

--2
SELECT TO_CHAR(cl.numrun, '09G999G999') ||'-'||cl.dvrun "RUN CLIENTE",
       upper(initcap(cl.pnombre||' '||cl.snombre||' '||cl.appaterno||' '||cl.apmaterno)) "NOMBRE CLIENTE",
       LPAD(to_char(sum(ttc.monto_transaccion), '$9G999G999'),19, ' ') "MONTO COMPRAS/AVANCES/S.AVANCES",
       LPAD(TO_CHAR(ROUND(SUM(ttc.monto_transaccion) / 10000 * 250), '9g999G999'), 16, ' ') "TOTAL PUNTOS ACUMULADOS"
FROM cliente cl JOIN tarjeta_cliente ta on ta.numrun = cl.numrun
JOIN transaccion_tarjeta_cliente ttc on ttc.nro_tarjeta = ta.nro_tarjeta
join tipo_transaccion_tarjeta ttt on ttt.cod_tptran_tarjeta = ttc.cod_tptran_tarjeta
join producto p on p.cod_producto = ttt.cod_producto
WHERE p.nombre_producto = 'Tarjeta CATB'
--AND TO_CHAR(ttc.fecha_transaccion, 'YYYY') = TO_CHAR(TRUNC(SYSDATE, 'YEAR'),'YYYY') - 1
AND TO_CHAR(ttc.fecha_transaccion, 'YYYY') = TO_CHAR(SYSDATE,'YYYY') - 1
GROUP BY cl.numrun, cl.dvrun, cl.pnombre, cl.snombre, cl.appaterno, cl.apmaterno
ORDER BY "TOTAL PUNTOS ACUMULADOS", cl.appaterno; 

--3 
-- solucion buscando el monto total de la transaccion en la tabla aporte_sbif 
SELECT TO_CHAR(tc.fecha_transaccion, 'MMYYYY') "MES TRANSACCION", 
       tt.nombre_tptran_tarjeta "TIPO TRANSACCION", 
       SUM(tc.monto_total_transaccion) "MONTO AVANCES/SUPER AVANCES",
       TO_CHAR(SUM(tc.monto_total_transaccion * (asb.porc_aporte_sbif / 100)), '$9G999G999') "APORTE A LA SBIF"
FROM tipo_transaccion_tarjeta tt JOIN transaccion_tarjeta_cliente tc ON tc.cod_tptran_tarjeta = tt.cod_tptran_tarjeta
JOIN aporte_sbif asb ON tc.monto_total_transaccion 
BETWEEN asb.monto_inf_av_sav and asb.monto_sup_av_sav
WHERE TO_CHAR(tc.fecha_transaccion, 'YYYY') = TO_CHAR(sysdate,'YYYY')
AND tt.nombre_tptran_tarjeta like '%Avance%'
group by TO_CHAR(tc.fecha_transaccion, 'MMYYYY'), tt.nombre_tptran_tarjeta
ORDER BY "MES TRANSACCION", "TIPO TRANSACCION";

-- solucion buscando la suma del monto total de la transaccion en la tabla aporte_sbif
-- caso en que se requiere una subconsulta 
SELECT T."MES TRANSACCION", "TIPO TRANSACCION", 
        TO_CHAR(T.MONTO, '$99G999G999') "MONTO AVANCES/SUPER AVANCES",
        TO_CHAR(T.MONTO * (asb.porc_aporte_sbif / 100), '$9G999G999') "APORTE A LA SBIF"
FROM (
    SELECT TO_CHAR(tc.fecha_transaccion, 'MMYYYY') "MES TRANSACCION", 
           tt.nombre_tptran_tarjeta "TIPO TRANSACCION", 
           SUM(tc.monto_total_transaccion) MONTO
    FROM tipo_transaccion_tarjeta tt JOIN transaccion_tarjeta_cliente tc ON tc.cod_tptran_tarjeta = tt.cod_tptran_tarjeta
    WHERE TO_CHAR(tc.fecha_transaccion, 'YYYY') = TO_CHAR(sysdate,'YYYY')  
    AND tt.nombre_tptran_tarjeta like '%Avance%'
    group by TO_CHAR(tc.fecha_transaccion, 'MMYYYY'), tt.nombre_tptran_tarjeta
) T
JOIN aporte_sbif asb ON T.MONTO 
BETWEEN asb.monto_inf_av_sav and asb.monto_sup_av_sav
ORDER BY "MES TRANSACCION", "TIPO TRANSACCION";

-- 4
SELECT TO_CHAR(cl.numrun, '09G999G999') ||'-'||cl.dvrun "RUN CLIENTE",
       UPPER(initcap(cl.pnombre||' '||cl.snombre||' '||cl.appaterno||' '||cl.apmaterno)) "NOMBRE CLIENTE",
       TO_CHAR(NVL(SUM(ttc.monto_total_transaccion),0), '$9G999G999G999') "MONTO COMPRAS/AVANCES/S.AVANCES",
       CASE
           WHEN SUM(ttc.monto_total_transaccion) > 15000000 THEN 'PLATINUM'
           WHEN SUM(ttc.monto_total_transaccion) BETWEEN 8000001 AND 15000000 THEN 'GOLD'
           WHEN SUM(ttc.monto_total_transaccion) BETWEEN 4000001 AND 8000000 THEN 'SILVER'
           WHEN SUM(ttc.monto_total_transaccion) BETWEEN 1000001 AND 4000000 THEN 'PLATA'
           WHEN SUM(ttc.monto_total_transaccion) BETWEEN 100001 AND 1000000 THEN 'BRONCE'
           ELSE 'SIN CATEGORIZACION'
       END "CATEGORIA CLIENTE"
FROM cliente cl LEFT JOIN tarjeta_cliente ta on ta.numrun = cl.numrun
LEFT JOIN transaccion_tarjeta_cliente ttc on ttc.nro_tarjeta = ta.nro_tarjeta
GROUP BY cl.numrun, cl.dvrun, cl.pnombre, cl.snombre, cl.appaterno, cl.apmaterno
ORDER BY cl.appaterno, "MONTO COMPRAS/AVANCES/S.AVANCES" DESC; 

--5
SELECT TO_CHAR(cl.numrun, '09G999G999') ||'-'||cl.dvrun "RUN CLIENTE",
       UPPER(initcap(cl.pnombre||' '||cl.snombre||' '||cl.appaterno||' '||cl.apmaterno)) "NOMBRE CLIENTE",
       COUNT(*) "TOTAL SUPER AVANCE VIGENTES",
       LPAD(TO_CHAR(SUM(tc.monto_TOTAL_transaccion),'$9g999g999'), 17, ' ') "MONTO TOTAL SUPER AVANCES"       
FROM tipo_transaccion_tarjeta tt join transaccion_tarjeta_cliente tc on tc.cod_tptran_tarjeta = tt.cod_tptran_tarjeta
JOIN tarjeta_cliente ta on ta.nro_tarjeta = tc.nro_tarjeta
JOIN cliente CL ON CL.numrun = ta.numrun
WHERE TO_CHAR(tc.fecha_transaccion, 'YYYY') = TO_CHAR(sysdate ,'YYYY')
AND tt.nombre_tptran_tarjeta like '%Súper Avance%'
GROUP BY cl.numrun, cl.dvrun, cl.pnombre, cl.snombre, cl.appaterno, cl.apmaterno
ORDER BY  cl.appaterno;

-- 6A AMBOS INFORMES SOLICITAN EL INGRESO DEL AÑO PERO LAS IMAGENES 
-- MUESTRAN CALCULOS QUE NO CONSIDERAN EL AÑO, POR ESO COMENTO ESAS CLAUSULAS 
SELECT TO_CHAR(CL.numrun, '09G999G999') ||'-'||CL.dvrun "RUN CLIENTE",
       UPPER(initcap(cl.pnombre||' '||SUBSTR(cl.snombre,1,1)||'. '||cl.appaterno||' '||cl.apmaterno)) "NOMBRE CLIENTE",
       cl.direccion, pr.nombre_provincia, r.nombre_region,
       COUNT(distinct CASE WHEN ttc.cod_tptran_tarjeta = 101 THEN ttc.nro_tarjeta END) "COMPRAS VIGENTES",
       TO_CHAR(NVL(SUM(DISTINCT CASE WHEN ttc .cod_tptran_tarjeta = 101 THEN ttc.monto_total_transaccion END),0), '$99G999G999') "MONTO TOTAL COMPRAS",
       COUNT(distinct CASE WHEN ttc.cod_tptran_tarjeta = 102 THEN ttc.nro_tarjeta END) "AVANCES VIGENTES",
       TO_CHAR(NVL(SUM(DISTINCT CASE WHEN ttc .cod_tptran_tarjeta = 102 THEN ttc.monto_total_transaccion END),0), '$99G999G999') "MONTO TOTAL AVANCES",
       COUNT(distinct CASE WHEN ttc.cod_tptran_tarjeta = 103 THEN ttc.nro_tarjeta END) "SUPER AVANCES VIGENTES",
       TO_CHAR(NVL(SUM(DISTINCT CASE WHEN ttc .cod_tptran_tarjeta = 103 THEN ttc.monto_total_transaccion END),0), '$99G999G999') "MONTO TOTAL SUPER AVANCES"
FROM cliente cl LEFT JOIN tarjeta_cliente tc on tc.numrun = cl.numrun
JOIN comuna co ON co.cod_comuna = CL.cod_comuna
JOIN provincia pr ON pr.cod_provincia = CL.cod_provincia
JOIN region R ON R.cod_region = pr.cod_region
AND CL.cod_provincia = pr.cod_provincia AND CL.cod_region = R.cod_region
LEFT JOIN transaccion_tarjeta_cliente ttc ON ttc.nro_tarjeta = tc.nro_tarjeta
LEFT JOIN tipo_transaccion_tarjeta ttt ON ttt.cod_tptran_tarjeta = ttc.cod_tptran_tarjeta
LEFT JOIN producto prod ON prod.cod_producto = ttt.cod_producto
LEFT JOIN cuota_transac_tarjeta_cliente ctc on ctc.nro_tarjeta = ttc.nro_tarjeta and ctc.nro_transaccion = ttc.nro_transaccion
--WHERE TO_CHAR(ttc.fecha_transaccion, 'YYYY') = &v_año
--OR ttc.monto_total_transaccion IS NULL
GROUP BY CL.numrun, CL.dvrun, CL.pnombre, CL.snombre, CL.appaterno, CL.apmaterno, CL.direccion, pr.nombre_provincia, R.nombre_region
ORDER BY r.nombre_region, CL.appaterno;

-- 6B
SELECT S.id_sucursal, UPPER(R.NOMBRE_REGION), pr.NOMBRE_PROVINCIA, co.NOMBRE_COMUNA, S.direccion,
       COUNT(CASE WHEN ttc.cod_tptran_tarjeta = 101 then ttc.nro_tarjeta END) "COMPRAS VIGENTES",
       TO_CHAR(NVL(SUM(CASE WHEN ttc.cod_tptran_tarjeta = 101 then ttc.monto_total_transaccion END),0), '$999G999G999') "MONTO TOTAL COMPRAS",
       COUNT(CASE WHEN ttc.cod_tptran_tarjeta = 102 then ttc.nro_tarjeta END) "AVANCES VIGENTES",
       TO_CHAR(NVL(SUM(CASE WHEN ttc.cod_tptran_tarjeta = 102 then ttc.monto_total_transaccion END),0), '$999G999G999') "MONTO TOTAL AVANCES",
       COUNT(CASE WHEN ttc.cod_tptran_tarjeta = 103 then ttc.nro_tarjeta END) "SUPER AVANCES VIGENTES",
       TO_CHAR(NVL(SUM(CASE WHEN ttc.cod_tptran_tarjeta = 103 then ttc.monto_total_transaccion END),0), '$999G999G999') "MONTO TOTAL SUPER AVANCES"
FROM sucursal_retail S LEFT JOIN comuna co 
ON (S.cod_comuna = co.cod_comuna AND S.cod_provincia = co.cod_provincia AND S.cod_region = co.cod_region)
LEFT JOIN provincia pr ON (pr.cod_provincia = co.cod_provincia AND pr.cod_region = co.cod_region)
LEFT JOIN region R ON R.cod_region = pr.cod_region
LEFT JOIN transaccion_tarjeta_cliente ttc ON ttc.id_sucursal = s.id_sucursal 
--WHERE TO_CHAR(ttc.fecha_transaccion, 'yyyy') = &V_AÑO
--OR ttc.monto_total_transaccion IS NULL
GROUP BY S.id_sucursal, R.NOMBRE_REGION, pr.NOMBRE_PROVINCIA, co.NOMBRE_COMUNA, S.direccion
ORDER BY 2, 1;


