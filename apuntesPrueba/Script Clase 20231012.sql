-- Obtener la identificación del empleado, nombre completo, codigo del departamento en el que trabaja, 
-- nombre del departamento, codigo del cargo que desempeña y nombre del trabajo de los empleados que
-- NO poseen un salario menor a todos los salarios promedios de los departamentos.
-- ofrecer una solucion con operadores set y otra con joins
-- solucion con operadores set
-- la primera consulta obtiene todos los empleados, la segunda aquellos 
-- que tienen un sueldo inferior al promedio de todos los sueldos promedios
-- de los departamentos, al usar el operador minus se obtienen los empleados
-- que tienen un sueldo superior al promedio
SELECT e.employee_id ID, last_name || ' ' || first_name nombre_empleado,
       d.department_id id_depto, d.department_name departamento,
       j.job_id id_cargo, j.job_title cargo 
FROM employees e join departments d
on d.department_id = e.department_id
join jobs j on j.job_id = e.job_id
MINUS
SELECT e.employee_id ID, last_name || ' ' || first_name nombre_empleado,
       d.department_id id_depto, d.department_name departamento,
       j.job_id id_cargo, j.job_title cargo 
FROM employees e join departments d
on d.department_id = e.department_id
join jobs j on j.job_id = e.job_id
where salary < all (select avg(salary) from employees
                    group by department_id);

-- solucion con joins (mas eficiente)
SELECT e.employee_id ID, last_name || ' ' || first_name nombre_empleado,
       d.department_id id_depto, d.department_name departamento,
       j.job_id id_cargo, j.job_title cargo 
FROM employees e join departments d
on d.department_id = e.department_id
join jobs j on j.job_id = e.job_id
where salary > any (select avg(salary) from employees
                    group by department_id);


-- SE DESEA OBTENER DATOS DE LOS EMPLEADOS 
-- (ID, NOMBRE COMPLETO, DEPARTAMENTO Y CARGO)
-- DE LOS EMPLEADOS QUE NO POSEEN CARGAS FAMILIARES 
-- OFREZCA UNA SOLUCION CON OPERADORES SET 
-- OTRA CON JOINS Y OTRA CON SUBCONSULTA

-- solucion con operador SET MINUS
SELECT e.employee_id ID, last_name || ' ' || first_name nombre_empleado,
       d.department_id id_depto, d.department_name departamento,
       j.job_id id_cargo, j.job_title cargo 
FROM employees e join departments d
on d.department_id = e.department_id
join jobs j on j.job_id = e.job_id
MINUS
SELECT e.employee_id ID, last_name || ' ' || first_name nombre_empleado,
       d.department_id id_depto, d.department_name departamento,
       j.job_id id_cargo, j.job_title cargo 
FROM employees e join departments d
on d.department_id = e.department_id
join jobs j on j.job_id = e.job_id
WHERE e.employee_id IN (select employee_id
                        from cargas_familiares)
ORDER BY 4,2;

-- solucion con operador SET INTERSECT                        
SELECT e.employee_id ID, last_name || ' ' || first_name nombre_empleado,
       d.department_id id_depto, d.department_name departamento,
       j.job_id id_cargo, j.job_title cargo 
FROM employees e join departments d
on d.department_id = e.department_id
join jobs j on j.job_id = e.job_id
INTERSECT
SELECT distinct e.employee_id ID, last_name || ' ' || first_name nombre_empleado,
       d.department_id id_depto, d.department_name departamento,
       j.job_id id_cargo, j.job_title cargo 
FROM employees e join departments d
on d.department_id = e.department_id
join jobs j on j.job_id = e.job_id
left join cargas_familiares cf on cf.employee_id = e.employee_id
where cf.employee_id is null
ORDER BY 4,2;

-- SOLUCION CON JOINS
SELECT distinct e.employee_id ID, last_name || ' ' || first_name nombre_empleado,
       d.department_id id_depto, d.department_name departamento,
       j.job_id id_cargo, j.job_title cargo 
FROM employees e join departments d
on d.department_id = e.department_id
join jobs j on j.job_id = e.job_id
left join cargas_familiares cf on cf.employee_id = e.employee_id
where cf.employee_id is null
ORDER BY 4,2;

-- SOLUCION CON SUBCONSULTAS
SELECT distinct e.employee_id ID, last_name || ' ' || first_name nombre_empleado,
       d.department_id id_depto, d.department_name departamento,
       j.job_id id_cargo, j.job_title cargo 
FROM employees e join departments d
on d.department_id = e.department_id
join jobs j on j.job_id = e.job_id
WHERE e.employee_id NOT IN (SELECT employee_id
                            FROM cargas_familiares)
ORDER BY 4,2;

                         
-- SE DESEA OBTENER DATOS DE LOS EMPLEADOS 
-- (ID, NOMBRE COMPLETO, ID Y NOMBRE DEL DEPARTAMENTO)
-- JUNTO CON EL NUMERO DE VENTAS Y EL MONTO TOTAL DE LAS VENTAS 
-- EN LOS DOS AÑOS INMEDIATAMENTE ANTERIORES AL AÑO ACTUAL
-- EL RESULTADO DEL PROCESO DEBE QUEDAR ALMACENADO EN LA TABLA DETALLE_VENTAS
-- OFREZCA UNA SOLUCION CON JOINS Y OTRA CON OPERADORES SET
-- SOLUCION CON JOINS
INSERT INTO detalle_ventas
SELECT TO_CHAR(v.fecha, 'yyyy'),
       e.employee_id, e.last_name||' '||e.first_name,
       d.department_id, d.department_name,
       COUNT(v.id_venta),
       SUM(v.monto_venta) 
FROM employees e join departments d
ON d.department_id = e.department_id
JOIN ventas v ON v.employee_id = e.employee_id 
WHERE TO_CHAR(v.fecha, 'yyyy') = TO_CHAR(sysdate, 'yyyy') - 1
 OR TO_CHAR(v.fecha, 'yyyy') = TO_CHAR(sysdate, 'yyyy') - 2
group by TO_CHAR(v.fecha, 'yyyy'), e.employee_id, 
         e.last_name,e.first_name, d.department_id, d.department_name
ORDER BY 1; 

SELECT TO_CHAR(v.fecha, 'yyyy'),
       e.employee_id, e.last_name||' '||e.first_name,
       d.department_id, d.department_name,
       COUNT(v.id_venta),
       SUM(v.monto_venta) 
FROM employees e join departments d
ON d.department_id = e.department_id
JOIN ventas v ON v.employee_id = e.employee_id 
WHERE TO_CHAR(v.fecha, 'yyyy') BETWEEN TO_CHAR(sysdate, 'yyyy') - 2
         AND TO_CHAR(sysdate, 'yyyy') - 1
group by TO_CHAR(v.fecha, 'yyyy'), e.employee_id, 
         e.last_name,e.first_name, d.department_id, d.department_name
ORDER BY 1; 

SELECT TO_CHAR(v.fecha, 'yyyy'),
       e.employee_id, e.last_name||' '||e.first_name,
       d.department_id, d.department_name,
       COUNT(v.id_venta),
       SUM(v.monto_venta) 
FROM employees e join departments d
ON d.department_id = e.department_id
JOIN ventas v ON v.employee_id = e.employee_id 
WHERE TO_CHAR(v.fecha, 'yyyy') = TO_CHAR(sysdate, 'yyyy') - 1
group by TO_CHAR(v.fecha, 'yyyy'), e.employee_id, 
         e.last_name,e.first_name, d.department_id, d.department_name
union
SELECT TO_CHAR(v.fecha, 'yyyy'),
       e.employee_id, e.last_name||' '||e.first_name,
       d.department_id, d.department_name,
       COUNT(v.id_venta),
       SUM(v.monto_venta) 
FROM employees e join departments d
ON d.department_id = e.department_id
JOIN ventas v ON v.employee_id = e.employee_id 
WHERE TO_CHAR(v.fecha, 'yyyy') = TO_CHAR(sysdate, 'yyyy') - 2
group by TO_CHAR(v.fecha, 'yyyy'), e.employee_id, 
         e.last_name,e.first_name, d.department_id, d.department_name
order by 1;





COMMIT;

SELECT * FROM DETALLE_VENTAS;

ALTER TABLE EMPLOYEES ADD COMISION NUMBER(8);
ALTER TABLE EMPLOYEES ADD ASIGNACION NUMBER(8) DEFAULT 200000;

ALTER TABLE EMPLOYEES DROP COLUMN ASIGNACION;

-- UNA VEZ EFECTUADOS LOS CALCULOS DEL PROCESO ANTERIOR SE REQUIERE
-- MODIFICAR LA ASIGNACION DEL EMPLEADO AGREGANDOLE EL MONTO DE LAS
-- VENTAS QUE POSEAN EN LOS DOS AÑOS CONSIDERADOS EN EL PROCESO.
-- LA MODIFICACION AFECTARÁ SOLO A LOS EMPLEADOS QUE POSEAN MAS
-- DE 50 VENTAS EN CUALQUIERA DE LOS AÑOS CONSIDERADOS

SELECT EMPLOYEE_ID, ASIGNACION
FROM EMPLOYEES
WHERE EMPLOYEE_ID in (SELECT ID_EMPLEADO
                     FROM DETALLE_VENTAS
                     WHERE CANTIDAD_DE_VENTAS > 50);

UPDATE employees e
   SET asignacion = asignacion + (SELECT SUM(TOTAL_VENTAS)
                                  FROM DETALLE_VENTAS dv
                                  WHERE dv.id_empleado =
                                    e.employee_id)
WHERE EMPLOYEE_ID in (SELECT ID_EMPLEADO
                     FROM DETALLE_VENTAS
                     WHERE CANTIDAD_DE_VENTAS > 50);

ROLLBACK;
                                  
-- UNA VEZ EFECTUADOS LOS CALCULOS DEL PROCESO ANTERIOR SE REQUIERE
-- MODIFICAR LA COMISION DEL EMPLEADO AGREGANDOLE EL MONTO DE LAS
-- VENTAS QUE POSEAN EN LOS DOS AÑOS CONSIDERADOS EN EL PROCESO.
-- LA MODIFICACION AFECTARÁ SOLO A LOS EMPLEADOS QUE POSEAN MAS
-- DE 25000 EN EL TOTAL DE LAS VENTAS EN CUALQUIERA DE LOS AÑOS CONSIDERADOS

SELECT EMPLOYEE_ID, COMISION
FROM EMPLOYEES
WHERE employee_id IN (SELECT id_empleado
                      from detalle_ventas 
                      where total_ventas > 25000); 

SELECT id_empleado
from detalle_ventas 
where total_ventas > 25000;                      

UPDATE employees e
   SET comision = (SELECT SUM(total_ventas)
                   from detalle_ventas dv
                   where dv.id_empleado = e.employee_id)
WHERE employee_id IN (SELECT id_empleado
                      from detalle_ventas 
                      where total_ventas > 25000); 

UPDATE EMPLOYEES
  SET COMISION = 0,
      ASIGNACION = 0; 
COMMIT;

-- UNA VEZ EFECTUADOS LOS CALCULOS DEL PROCESO ANTERIOR SE REQUIERE
-- MODIFICAR LA COMISION DEL EMPLEADO AGREGANDOLE EL MONTO DE LAS
-- VENTAS QUE POSEAN EN LOS DOS AÑOS CONSIDERADOS EN EL PROCESO.
-- Y EL MONTO DE LA ASIGNACION AGREGANDOLE EL 50% DE LAS VENTAS DE 
-- LOS AÑOS CONSIDERADOS
-- LA MODIFICACION AFECTARÁ SOLO A LOS EMPLEADOS QUE POSEAN
-- MAS DE 40 VENTAS EN CUALQUIERA DE LOS AÑOS RESPECTIVOS
SELECT EMPLOYEE_ID, COMISION, ASIGNACION
FROM EMPLOYEES
WHERE EMPLOYEE_ID IN (SELECT ID_EMPLEADO
                      FROM DETALLE_VENTAS
                      WHERE cantidad_de_ventas > 40);

UPDATE EMPLOYEES e
   SET comision = (select sum(total_ventas)
                   from detalle_ventas dv
                   where dv.id_empleado = e.employee_id),
       asignacion = asignacion + (SELECT SUM(TOTAL_VENTAS) * 0.5
                                  FROM detalle_ventas dv
                                  where dv.id_empleado = e.employee_id)
WHERE EMPLOYEE_ID IN (SELECT ID_EMPLEADO
                      FROM DETALLE_VENTAS
                      WHERE cantidad_de_ventas > 40);
                                  
                   
  






-- SOLUCION CON OPERADORES SET
-- ¿CUAL DE LAS SOLUCIONES ES MAS EFICIENTE?