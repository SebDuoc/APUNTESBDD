-- DEMO DE FUNCIONES DE GRUPO Y USO DE CLAUSULAS GROUP BY Y HAVING
-- AVANZAMOS EN EL USO DE JOINS
-- FUNCIONES DE GRUPO -- ACTUAN SOBRE GRUPOS DE FILAS
-- EL GRUPO PUEDE SER TODA LA TABLA O LOS GRUPOS QUE SE HAYAN FORMADO
-- POR EL USO DE LA CLAUSULA GROUP BY
-- COUNT -- MAX -- MIN -- SUM -- AVG
-- SINTAXIS FUNCIONES DE GRUPO
-- NOMBRE_FUNCION ( [DISTINCT | ALL ] columna|expresion)
-- NO CONSIDERAN LOS NULOS EXCEPTO CUANDO SE USA COUNT(*)
-- SUM -- AVG SOLO SE USAN CON CAMPOS O EXPRESIONES NUMERICAS
-- MAX -- MIN -- COUNT SE UTILIZAN CON CUALQUIER CAMPO
-- HAVING NO EXISTE O NO SE JUSTIFICA SI NO HAY GROUP BY
-- PERO SI PUEDE EXISTIR UN GROUP BY SIN HAVING.


-- SINTAXIS DE SELECT CUANDO CONTIENE UN JOIN

SELECT t1.campo1, t1.campo2, t2.campo3 ... 
FROM tabla1 t1 [INNER] [NATURAL] JOIN tabla2 t2
ON|USING t1.campoclave = t2.campoclave
JOIN tabla3 t3 ON|USING t3.campoclave = t1.campoclave
WHERE condicion
GROUP BY campos
HAVING condicion
ORDER BY campos;
*/

ON CONTIENE LA CONDICION DE IGUALDAD

SELECT 
        RUTEMP RUN,
        PATERNO || ' ' || MATERNO || ' ' || NOMBRE NOMBRE_EMPLEADO,
        SUELDO,
        CASE IDZONA
            WHEN 1 THEN 'ORIENTE'
            WHEN 2 THEN 'PONIENTE'
            WHEN 3 THEN 'CENTRO'
            WHEN 4 THEN 'NORTE'
            WHEN 5 THEN 'SUR'
        END
FROM EMPLEADO;

-- LO MISMO CON UN JOIN
SELECT 
        e.rutemp run,
        e.paterno || ' ' || e.materno || ' ' || e.nombre nombre_empleado,
        e.sueldo,
        z.nomzona zona
FROM ZONA z JOIN EMPLEADO e 
ON z.idzona = e.idzona;


-- OBTENER RUT, NOMBRE COMPLETO, PUNTAJE, SUELDO, NOMBRE DEL CARGO y NOMBRE DE LA ZONA DE CADA UNO DE LOS EMPLEADOS.

SELECT
        e.RUTEMP RUN,
        e.PATERNO || ' ' || e.MATERNO || ' ' || e.NOMBRE NOMBRE_EMPLEADO,
        e.PUNTAJE,
        e.SUELDO, 
        e.IDCATEGORIA CODIGO_CARGO,
        c.NOMCATEGORIA NOMBRE_CATEGORIA,
        z.nomzona zona
FROM CATEGORIA c JOIN EMPLEADO e

ON c.IDCATEGORIA = e.IDCATEGORIA
JOIN zona z ON z.idzona = e.idzona;


-- OBTENER RUT, NOMBRE COMPLETO, PUNTAJE, SUELDO, NOMBRE DEL CARGO, NOMBRE DE LA ZONA Y DIRECCION DE LA OFICINA EN LA QUE TRABAJA CADA UNO DE LOS EMPLEADOS.

SELECT
        e.rutemp run,
        e.paterno || ' ' || e.materno || ' ' || e.nombre nombre_empleado,
        e.puntaje,
        e.sueldo, 
        e.idcategoria codigo_cargo,
        c.nomcategoria nombre_categoria,
        z.nomzona zona,
        o.diroficina direccion_oficina
FROM CATEGORIA c JOIN EMPLEADO e
ON c.IDCATEGORIA = e.IDCATEGORIA
JOIN zona z ON z.idzona = e.idzona
JOIN oficina o ON o.numoficina = e.numoficina;


-- OBTENER RUT, NOMBRE COMPLETO, PUNTAJE, SUELDO, NOMBRE DEL CARGO, NOMBRE DE LA ZONA Y DIRECCION DE LA OFICINA EN LA QUE TRABAJA CADA UNO DE LOS EMPLEADOS.
-- USO DE LA CLAUSULA USING

SELECT
        e.rutemp run,
        e.paterno || ' ' || e.materno || ' ' || e.nombre nombre_empleado,
        e.puntaje,
        e.sueldo, 
        idcategoria codigo_cargo,
        c.nomcategoria nombre_categoria,
        z.nomzona zona,
        o.diroficina direccion_oficina
FROM categoria c JOIN empleado e
USING (idcategoria)
JOIN zona z ON z.idzona = e.idzona
JOIN oficina o USING (numoficina);

-- USO DE LA CLAUSULA NATURAL
SELECT 
        e.rutemp run,
        e.paterno || ' ' || e.materno || ' ' || e.nombre nombre_empleado,
        e.sueldo,
        z.nomzona zona
FROM ZONA z NATURAL JOIN EMPLEADO e;


-- se obtienen todos los registros cuya llave foranea tambien existe como llave primaria.


-- obtener un informe que detalle el numero de propiedades
-- a cargo de un empleado y el total de las rentas que 
-- le corresponde administrar. El informe debe mostrar 
-- rut del empleado, nombre completo,numero de propiedad y total de las 
-- rentas

SELECT 
        e.rutemp rut,
        e.paterno || ' ' || e.materno || ' ' || e.nombre nombre_empleado,
        COUNT(p.numpropiedad) NRO_PROPIEDADES,
        TO_CHAR(SUM(p.renta), '$99G999G999') TOTAL_RENTAS
FROM propiedad p JOIN empleado e
ON e.rutemp = p.rutemp
GROUP BY e.rutemp, e.paterno, e.materno, e.nombre;


-- USO DE CLAUSULA HAVING
-- SIRVE PARA FILTRAR LOS GRUPOS FORMADOS
-- CREAR UN INFORME QUE MUESTRE LAS ZONAS EXISTENTES JUNTO
-- CON EL NUMERO DE EMPLEADOS Y EL TOTAL DE SUELDOS POR ZONA,
-- EL INFORME DEBE MOSTRAR SOLO LAS ZONAS QUE TENGAN
-- MAS DE 4 EMPLEADOS

SELECT 
    UPPER(z.nomzona) nombre_zona,
    COUNT(rutemp) NRO_EMPLEADOS,
    TO_CHAR(SUM(e.sueldo), '$99G999G999') TOTAL_SUELDO
FROM zona z JOIN empleado e
ON z.idzona = e.idzona
GROUP BY z.nomzona
HAVING COUNT(e.rutemp) > 4;



-- mostrar en el informe solo los empleados que administran
-- propiedades por un monto total de rentas inferior a los $700.000.


-- mostrar en el informe solo los empleados que administran
-- propiedades de dos dormitorios
-- por un monto total de rentas inferior a los $700.000.


-- obtener un listado de las categorias o tipos
-- de empleados existentes junto con el numero
-- de empleados en cada categoria y el promedio
-- de los sueldos por categoria 


-- obtener un listado de las categorias existentes en la
-- empresa junto con el numero
-- de empleados de genero femenino en cada categoria y el promedio
-- de los sueldos por categoria 

-- obtener un listado de los empleados de sexo femenino
-- existentes en la empresa junto con el numero
-- de empleados en cada categoria y el promedio
-- de los sueldos por categoria. El informe debe mostrar
-- solo las categorias que tengan mas de 2 empleados
-- de sexo femenino

-- LA GERENCIA DESEA INCREMENTAR LOS SUELDOS DE LOS EMPLEADOS
-- CON UN PORCENTAJE DE LAS RENTAS DE LAS PROPIEDADES QUE 
-- ELLOS ADMINISTRAN. POR ESTE MOTIVO HA SOLICITADO QUE ELABORE
-- UN INFORME QUE CONTENGA RUT, NOMBRE COMPLETO, OFICINA,
-- NUMERO DE PROPIEDADES QUE ADMINISTRA Y PROMEDIO DE LAS RENTAS
-- DE LAS MISMAS

SELECT
        e.rutemp rut,
        e.paterno || ' ' || e.materno || ' ' || e.nombre nombre_empleado,
        o.diroficina oficina,
        COUNT(p.numpropiedad) nro_propiedades,
        ROUND(AVG(p.renta)) promedio_rentas
FROM empleado e JOIN oficina o
ON e.numoficina = o.numoficina
JOIN propiedad p ON p.rutemp = e.rutemp
GROUP BY e.rutemp, e.paterno, e.materno, e.nombre, o.diroficina;


-- LA GERENCIA DESEA INCREMENTAR LOS SUELDOS DE LOS EMPLEADOS VARONES
-- CON UN PORCENTAJE DE LAS RENTAS DE LAS PROPIEDADES QUE 
-- ELLOS ADMINISTRAN. POR ESTE MOTIVO HA SOLICITADO QUE ELABORE
-- UN INFORME QUE CONTENGA RUT, NOMBRE COMPLETO, OFICINA,
-- NUMERO DE PROPIEDADES QUE ADMINISTRA Y PROMEDIO DE LAS RENTAS
-- DE LAS MISMAS

-- LA GERENCIA DESEA INCREMENTAR LOS SUELDOS DE LOS EMPLEADOS VARONES
-- CON UN PORCENTAJE DE LAS RENTAS DE LAS PROPIEDADES QUE 
-- ELLOS ADMINISTRAN. POR ESTE MOTIVO HA SOLICITADO QUE ELABORE
-- UN INFORME QUE CONTENGA RUT, NOMBRE COMPLETO, OFICINA,
-- NUMERO DE PROPIEDADES QUE ADMINISTRA Y PROMEDIO DE LAS RENTAS
-- DE LAS MISMAS. EL INFORME DEBE MOSTRAR SOLO LOS EMPLEADOS
-- QUE OSTENTEN UN PROMEDIO DE RENTAS MENOR A 500000


       


