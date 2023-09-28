-- CASO 1
SELECT 
    TO_CHAR(c.numrun, '09g999g999') || '-' || c.dvrun "RUN CLIENTE",
    INITCAP(c.pnombre) || ' ' || INITCAP(c.snombre) || ' ' || INITCAP(c.appaterno) || ' ' || INITCAP(c.apmaterno) "NOMBRE CLIENTE",   
    TO_CHAR(c.fecha_nacimiento, 'dd "de" Month') "DIA DE CUMPLEAÑOS",
    s.direccion || ' / ' || UPPER(r.nombre_region) "Direccion Sucursal / REGION SUCURSAL"
FROM cliente c JOIN sucursal_retail s
ON (c.cod_region = s.cod_region AND c.cod_provincia = s.cod_provincia AND c.cod_comuna = s.cod_comuna)
JOIN region r
ON s.cod_region = r.cod_region
WHERE TO_CHAR(c.fecha_nacimiento, 'MM') = TO_CHAR(ADD_MONTHS(SYSDATE, 0),'MM') AND 
    r.cod_region = &region
ORDER BY TO_CHAR(c.fecha_nacimiento, 'dd/MM'), c.appaterno;

-- CASO 2
SELECT 
    TO_CHAR(c.numrun, '09g999g999') || '-' || UPPER(c.dvrun) "RUN CLIENTE",
    UPPER(c.pnombre) || ' ' || UPPER(c.snombre) || ' ' || UPPER(c.appaterno) || ' ' || UPPER(c.apmaterno) "NOMBRE CLIENTE",
    LPAD(TO_CHAR(SUM(ttc.monto_transaccion), '$99g999g999'), 30, ' ') "MONTO COMPRAS/AVANCES/S.AVANCES",
    LPAD(TO_CHAR(ROUND((SUM(ttc.monto_transaccion) / 10000) * 250), '99g999g999'), 23,' ') "TOTAL PUNTOS ACUMULADOS"
FROM cliente c JOIN tarjeta_cliente t
ON c.numrun = t.numrun 
JOIN transaccion_tarjeta_cliente ttc
ON t.nro_tarjeta = ttc.nro_tarjeta
WHERE TO_CHAR(fecha_transaccion, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY') - 1
GROUP BY c.numrun, c.dvrun, c.pnombre, c.snombre, c.appaterno, c.apmaterno
ORDER BY  "TOTAL PUNTOS ACUMULADOS", c.appaterno;

-- CASO 3










