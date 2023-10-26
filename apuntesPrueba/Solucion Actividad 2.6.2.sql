INSERT INTO bonif_arriendos_mensual
SELECT to_char(sysdate, 'YYYYMM') anno_mes, E.numrun_emp,
       initcap(pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp) nombre_empleado,
       E.sueldo_base,
       COUNT(ac.id_arriendo) total_arriendos,
       round(sueldo_base * (COUNT(ac.id_arriendo)/100)) bonif_por_arriendos
FROM empleado E JOIN camion ca ON ca.numrun_emp = E.numrun_emp
JOIN arriendo_camion ac ON ac.nro_patente = ca.nro_patente
WHERE to_char(ac.fecha_ini_arriendo, 'mm/yyyy') = to_char(sysdate, 'mm/yyyy')
-- WHERE to_char(ac.fecha_ini_arriendo, 'mm/yyyy') = '&mm/yyyy' -- SI DESEAS INGRESAR MES Y AÑO COMO PARAMETRO
GROUP BY E.numrun_emp, pnombre_emp, snombre_emp, appaterno_emp, apmaterno_emp, sueldo_base
ORDER BY E.appaterno_emp;
COMMIT;

-- CASO 2 PROCESO 1
INSERT INTO clientes_arriendos_menos_prom (ANNO_PROCESO, NOMBRE_CLIENTE, TOTAL_ARRIENDOS)
SELECT TO_CHAR(SYSDATE, 'YYYY') anno_proceso, INITCAP(cl.pnombre_cli||' '||cl.snombre_cli||' '||cl.appaterno_cli||' '||cl.apmaterno_cli),
       count(ac.id_arriendo) total_arriendos       
FROM cliente cl LEFT JOIN arriendo_camion ac
ON ac.numrun_cli = cl.numrun_cli
WHERE TO_CHAR(ac.fecha_ini_arriendo, 'yyyy') = TO_CHAR(SYSDATE, 'YYYY')
OR ac.id_arriendo is null
GROUP BY cl.pnombre_cli,cl.snombre_cli,cl.appaterno_cli,cl.apmaterno_cli
HAVING COUNT(ac.id_arriendo) < (SELECT AVG(COUNT(*))
                                FROM arriendo_camion
                                GROUP BY numrun_cli)
ORDER BY cl.appaterno_cli;
COMMIT;

-- datos de los clientes antes de actualizar
select numrun_cli, pnombre_cli, snombre_cli, appaterno_cli, apmaterno_cli, id_categoria_cli
from cliente cl
WHERE INITCAP(CL.pnombre_cli||' '||CL.snombre_cli
      ||' '||CL.appaterno_cli||' '||CL.apmaterno_cli) IN (SELECT trim(nombre_cliente)
                                                          FROM clientes_arriendos_menos_prom);

-- CASO 2 PROCESO 2
UPDATE cliente CL
   SET id_categoria_cli = (SELECT id_categoria_cli
                           FROM categoria_cliente 
                           WHERE nombre_categoria_cli = 'BRONCE')                           
WHERE INITCAP(CL.pnombre_cli||' '||CL.snombre_cli
      ||' '||CL.appaterno_cli||' '||CL.apmaterno_cli) IN (SELECT trim(nombre_cliente)
                                                          FROM clientes_arriendos_menos_prom);

commit;

-- datos de los clientes despues de actualizar
select numrun_cli, pnombre_cli, snombre_cli, appaterno_cli, apmaterno_cli, id_categoria_cli
from cliente cl
WHERE INITCAP(CL.pnombre_cli||' '||CL.snombre_cli
      ||' '||CL.appaterno_cli||' '||CL.apmaterno_cli) IN (SELECT trim(nombre_cliente)
                                                          FROM clientes_arriendos_menos_prom);


-- pregunta 3
CREATE TABLE clientes_sin_arriendos AS
SELECT *
FROM cliente CL
WHERE CL.numrun_cli NOT IN (SELECT DISTINCT numrun_cli 
                            FROM arriendo_camion 
                            WHERE EXTRACT(YEAR FROM fecha_ini_arriendo) 
                            BETWEEN EXTRACT(YEAR FROM sysdate) - 1
                            AND EXTRACT(YEAR FROM sysdate));

SELECT * FROM clientes_sin_arriendos;

DELETE FROM cliente
WHERE numrun_cli IN (SELECT numrun_cli
                     FROM clientes_sin_arriendos); 
COMMIT;
SELECT * FROM cliente;

-- pregunta 4
INSERT INTO hist_arriendo_anual_camion
SELECT TO_CHAR(ROUND(SYSDATE, 'YEAR'), 'YYYY') ANNO_PROCESO, CA.NRO_PATENTE, VALOR_ARRIENDO_DIA, VALOR_GARANTIA_DIA,
       COUNT(AC.ID_ARRIENDO) TOTAL_ARRIENDOS       
FROM CAMION CA LEFT JOIN ARRIENDO_CAMION AC
ON AC.NRO_PATENTE = CA.NRO_PATENTE
WHERE TO_CHAR(AC.FECHA_INI_ARRIENDO, 'yyyy') = TO_CHAR(ROUND(SYSDATE, 'YEAR') -1, 'YYYY') 
OR AC.ID_ARRIENDO IS NULL
GROUP BY CA.NRO_PATENTE, VALOR_ARRIENDO_DIA, VALOR_GARANTIA_DIA
ORDER BY CA.NRO_PATENTE;

-- estado de la tabla camion antes de actualizar
select * from camion;

UPDATE camion
   SET valor_arriendo_dia = round(valor_arriendo_dia * 0.775),
       valor_garantia_dia = round(valor_arriendo_dia * 0.775) 
WHERE nro_patente IN (SELECT nro_patente
                      FROM hist_arriendo_anual_camion
                      WHERE total_veces_arrendado < 4);
COMMIT;

-- estado de la tabla camion despu s de actualizar
select * from camion;



-- caso 6
INSERT INTO informacion_sii
SELECT RUN, DV, anno, nom, meses, ant, sueldo_base, sanual, bono, mov, COL,
       sanual + bono + COL + mov sbruto_anual,
       sanual + bono impo
FROM (   
    SELECT numrun_emp RUN, dvrun_emp DV, to_char(round(sysdate, 'YEAR') -1, 'YYYY') anno,
           pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp nom,
           CASE 
              WHEN EXTRACT(YEAR FROM fecha_contrato) < EXTRACT(YEAR FROM sysdate) THEN 12
              ELSE  round(months_between(sysdate, fecha_contrato),1)
           END meses,
           round(months_between(sysdate, fecha_contrato) / 12) ant,
           sueldo_base,
           sueldo_base * 12 sanual,
           round(sueldo_base * (round(months_between(sysdate, fecha_contrato) / 12) /100)) bono,
           round(sueldo_base * 0.12 * 12) mov,
           round(sueldo_base * 0.20 * 12) COL
    FROM empleado
 )
order by run;

COMMIT;
