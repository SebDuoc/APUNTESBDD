-- CASO 1
SELECT initcap(h.appat_huesped||' '||SUBSTR(h.apmat_huesped,1,1)||'. '||h.nom_huesped) HUESPED,
       p.nom_procedencia PROCEDENCIA, re.nom_region REGION, 
       NVL(ag.nom_agencia, 'Viaja por su cuenta') agencia,
       COUNT(DISTINCT r.id_reserva) "NUMERO DE RESERVAS",
       COUNT(co.id_consumo) "NUMERO DE CONSUMOS",
       to_char(NVL(SUM(co.monto) * 930, 0), '$9g999g999') "MONTO CONSUMOS"
FROM huesped h JOIN reserva r
ON r.id_huesped = h.id_huesped
JOIN procedencia p ON p.id_procedencia = h.id_procedencia
join region re ON re.id_region = p.id_region
LEFT JOIN AGENCIA AG ON ag.id_agencia = h.id_agencia 
LEFT JOIN consumo co ON co.id_reserva = r.id_reserva
                AND co.id_huesped = h.id_huesped
where re.nom_region = 'Union Europea'
  AND TO_CHAR(r.ingreso, 'yyyy') = TO_CHAR(sysdate, 'yyyy') -1
group by h.appat_huesped, h.apmat_huesped,h.nom_huesped, p.nom_procedencia,
         re.nom_region, ag.nom_agencia
having COUNT(DISTINCT r.id_reserva) > (SELECT avg(COUNT(id_reserva))
                                       from reserva 
                                       group by id_huesped)
ORDER BY 5 DESC;

-- CASO 3
-- SOLUCION CON JOINS
INSERT INTO historico_clientes
SELECT TO_CHAR(r.ingreso, 'YYYY'),
       h.id_huesped,
       h.appat_huesped||' '||h.apmat_huesped||' '||h.nom_huesped,
       COUNT(r.id_reserva) 
FROM huesped h JOIN reserva r
ON H.ID_HUESPED = R.ID_HUESPED
WHERE TO_CHAR(r.ingreso, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY') -2
  OR TO_CHAR(r.ingreso, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY') -1
GROUP BY TO_CHAR(r.ingreso, 'YYYY'), h.id_huesped, h.appat_huesped, h.apmat_huesped,
         h.nom_huesped
ORDER BY h.id_huesped;
COMMIT;

SELECT TO_CHAR(r.ingreso, 'YYYY'),
       h.id_huesped,
       h.appat_huesped||' '||h.apmat_huesped||' '||h.nom_huesped,
       COUNT(r.id_reserva) 
FROM huesped h JOIN reserva r
ON H.ID_HUESPED = R.ID_HUESPED
WHERE TO_CHAR(r.ingreso, 'YYYY') between TO_CHAR(SYSDATE, 'YYYY') -2
  and TO_CHAR(SYSDATE, 'YYYY') -1
GROUP BY TO_CHAR(r.ingreso, 'YYYY'), h.id_huesped, h.appat_huesped, h.apmat_huesped,
         h.nom_huesped
ORDER BY h.id_huesped;

-- solucion con operadores set
-- operador union
SELECT TO_CHAR(r.ingreso, 'YYYY'),
       h.id_huesped,
       h.appat_huesped||' '||h.apmat_huesped||' '||h.nom_huesped,
       COUNT(r.id_reserva) 
FROM huesped h JOIN reserva r
ON H.ID_HUESPED = R.ID_HUESPED
WHERE TO_CHAR(r.ingreso, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY') -2
GROUP BY TO_CHAR(r.ingreso, 'YYYY'), h.id_huesped, h.appat_huesped, h.apmat_huesped,
         h.nom_huesped
UNION
SELECT TO_CHAR(r.ingreso, 'YYYY'),
       h.id_huesped,
       h.appat_huesped||' '||h.apmat_huesped||' '||h.nom_huesped,
       COUNT(r.id_reserva) 
FROM huesped h JOIN reserva r
ON H.ID_HUESPED = R.ID_HUESPED
WHERE TO_CHAR(r.ingreso, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY') -1
GROUP BY TO_CHAR(r.ingreso, 'YYYY'), h.id_huesped, h.appat_huesped, h.apmat_huesped,
         h.nom_huesped
ORDER BY 2;

-- OPERADOR INTERSECT
SELECT TO_CHAR(r.ingreso, 'YYYY'),
       h.id_huesped,
       h.appat_huesped||' '||h.apmat_huesped||' '||h.nom_huesped,
       COUNT(r.id_reserva) 
FROM huesped h JOIN reserva r
ON H.ID_HUESPED = R.ID_HUESPED
WHERE TO_CHAR(r.ingreso, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY') -2
  OR TO_CHAR(r.ingreso, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY') -1
GROUP BY TO_CHAR(r.ingreso, 'YYYY'), h.id_huesped, h.appat_huesped, h.apmat_huesped,
         h.nom_huesped
INTERSECT
SELECT TO_CHAR(r.ingreso, 'YYYY'),
       h.id_huesped,
       h.appat_huesped||' '||h.apmat_huesped||' '||h.nom_huesped,
       COUNT(r.id_reserva) 
FROM huesped h JOIN reserva r
ON H.ID_HUESPED = R.ID_HUESPED
GROUP BY TO_CHAR(r.ingreso, 'YYYY'), h.id_huesped, h.appat_huesped, h.apmat_huesped,
         h.nom_huesped
ORDER BY 2;

-- OPERADOR MINUS
SELECT TO_CHAR(r.ingreso, 'YYYY'),
       h.id_huesped,
       h.appat_huesped||' '||h.apmat_huesped||' '||h.nom_huesped,
       COUNT(r.id_reserva) 
FROM huesped h JOIN reserva r
ON H.ID_HUESPED = R.ID_HUESPED
WHERE TO_CHAR(r.ingreso, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY') -2
  OR TO_CHAR(r.ingreso, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY') -1
GROUP BY TO_CHAR(r.ingreso, 'YYYY'), h.id_huesped, h.appat_huesped, h.apmat_huesped,
         h.nom_huesped
minus
SELECT TO_CHAR(r.ingreso, 'YYYY'),
       h.id_huesped,
       h.appat_huesped||' '||h.apmat_huesped||' '||h.nom_huesped,
       COUNT(r.id_reserva) 
FROM huesped h JOIN reserva r
ON H.ID_HUESPED = R.ID_HUESPED
WHERE TO_CHAR(r.ingreso, 'YYYY') NOT between TO_CHAR(SYSDATE, 'YYYY') -2
  and TO_CHAR(SYSDATE, 'YYYY') -1
GROUP BY TO_CHAR(r.ingreso, 'YYYY'), h.id_huesped, h.appat_huesped, h.apmat_huesped,
         h.nom_huesped;

-- CASO 3B
UPDATE egresos_dia ed
   SET consumos = consumos - (SELECT reservas * &monto
                              FROM historico_clientes hc
                              where ed.id_huesped = hc.id_huesped
                              AND agno_proceso =
                              EXTRACT(YEAR FROM SYSDATE) -1)
WHERE ed.consumos > 0;


-- mostrar run, sueldo_base y comision
-- de todos los empleados que poseen reservas
SELECT run_empleado, sueldo_base, comision
from empleado
where run_empleado not IN (select run_empleado
                       from reserva); 

SELECT run_empleado, sueldo_base, comision
from empleado e
where not exists (select *
              from reserva r
              where r.run_empleado = e.run_empleado); 

SELECT * FROM RESERVA;

UPDATE RESERVA
  SET run_empleado = '10125945-7'
where run_empleado = '13746912-9';
commit;

UPDATE RESERVA
  SET run_empleado = '11124678-3'
where run_empleado = '9789456-3';
commit;

-- SE REQUIERE MODIFICAR EL SUELDO BASE Y LA COMISION
-- DEL EMPLEADO. EN EL CASO DEL SUELDO SE DEBEN AGREGAR
-- $10.000 POR CADA RESERVA QUE EL EMPLEADO TENGA
-- EN EL AÑO ACTUAL Y EN EL CASO
-- DE LA COMISION SE DEBE AGREGAR UN PUNTO PORCENTUAL
-- POR CADA RESERVA

UPDATE EMPLEADO E
   SET sueldo_base = sueldo_base + (SELECT COUNT(*) * 10000
                                    FROM RESERVA R
                                    WHERE R.RUN_EMPLEADO = E.RUN_EMPLEADO
                                    AND TO_CHAR(INGRESO, 'YYYY') =
                                    TO_CHAR(SYSDATE, 'YYYY')),
       comision = comision + (SELECT COUNT(*) * 0.1
                                    FROM RESERVA R
                                    WHERE R.RUN_EMPLEADO = E.RUN_EMPLEADO
                                    AND TO_CHAR(INGRESO, 'YYYY') =
                                    TO_CHAR(SYSDATE, 'YYYY'))
where run_empleado  IN (select run_empleado
                       from reserva);                             


rollback;                                    

















