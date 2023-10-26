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


-- SE DESEA OBTENER DATOS DE LOS EMPLEADOS (ID, NOMBRE COMPLETO, DEPARTAMENTO Y CARGO)
-- DE LOS EMPLEADOS QUE NO POSEEN CARGAS FAMILIARES 
-- OFREZCA UNA SOLUCION CON OPERADORES SET Y OTRA CON JOINS Y OTRA CON SUBCONSULTA
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

                         
-- SE DESEA OBTENER DATOS DE LOS EMPLEADOS (ID, NOMBRE COMPLETO, ID Y NOMBRE DEL DEPARTAMENTO)
-- JUNTO CON EL NUMERO DE VENTAS Y EL MONTO TOTAL DE LAS VENTAS 
-- EN LOS DOS AÑOS INMEDIATAMENTE ANTERIORES AL AÑO ACTUAL
-- EL RESULTADO DEL PROCESO DEBE QUEDAR ALMACENADO EN LA TABLA DETALLE_VENTAS
-- OFREZCA UNA SOLUCION CON JOINS Y OTRA CON OPERADORES SET
-- SOLUCION CON JOINS


-- SOLUCION CON OPERADORES SET
-- ¿CUAL DE LAS SOLUCIONES ES MAS EFICIENTE?