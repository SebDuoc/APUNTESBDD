-- caso 1
SELECT TO_CHAR(numrun_cli, '099G999G999') || '-' || dvrun_cli "RUN EMPLEADO",
       INITCAP(appaterno_cli||' '||SUBSTR(apmaterno_cli,1,1)||'. '||pnombre_cli)||' '||snombre_cli "NOMBRE CLIENTE",
       direccion,
       NVL(TO_CHAR(fono_fijo_cli), 'NO POSEE TELEFONO FIJO') "TELEFONO FIJO",
       NVL(TO_CHAR(celular_cli), 'NO POSEE CELULAR') "TELEFONO FIJO",
       id_comuna comuna
FROM cliente
ORDER BY &id_comuna, &appaterno_cli desc;

-- caso 2
SELECT 'El empleado ' || pnombre_emp||' '||appaterno_emp||' '||apmaterno_emp || ' estuvo de cumpleaños el '
        || EXTRACT(DAY FROM fecha_nac) || ' de ' || TO_CHAR(fecha_nac, 'fmMonth') || '. Cumplió '
        || ROUND(MONTHS_BETWEEN(sysdate,fecha_nac) / 12) || ' años.' "LISTADO DE CUMPLEAÑOS"
FROM empleado
WHERE TO_CHAR(fecha_nac, 'MM') = TO_CHAR(sysdate, 'MM') - 1 
ORDER BY EXTRACT(DAY FROM fecha_nac), appaterno_emp;

SELECT 'El empleado ' || pnombre_emp||' '||appaterno_emp||' '||apmaterno_emp || ' estuvo de cumpleaños el '
        || EXTRACT(DAY FROM fecha_nac) || ' de ' || TO_CHAR(fecha_nac, 'fmMonth') || '. Cumplió '
        || ROUND(MONTHS_BETWEEN(sysdate,fecha_nac) / 12) || ' años.' "LISTADO DE CUMPLEAÑOS"
FROM empleado
WHERE TO_CHAR(fecha_nac, 'MM') = TO_CHAR(ADD_MONTHS(TO_DATE('&FECHA'),-1), 'MM') 
ORDER BY EXTRACT(DAY FROM fecha_nac), appaterno_emp;



-- CASO 3
SELECT CASE id_tipo_camion
               WHEN 'A' THEN  'Tradicional 6 Toneladas'
               WHEN 'B'	THEN  'Frigorífico'
               WHEN 'C'	THEN  'Camión 3/4'
               WHEN 'D'	THEN  'Trailer'
               WHEN 'E'	THEN  'Tolva'
       END "TIPO CAMION" ,
       nro_patente "NRO, PATENTE",
       anio AÑO, valor_arriendo_dia "VALOR ARRIENDO DIA",
       valor_garantia_dia "VALOR GARANTIA DIA",
       valor_arriendo_dia + NVL(valor_garantia_dia,0) "VALOR TOTAL DIA"
FROM camion
ORDER BY 1, 4 DESC, 5, 2;


-- CASO 4 OPCION 1 (POCO EFICIENTE POR USO DE DOBLE AMPERSAND Y UNDEFINE)
SELECT TO_CHAR(sysdate, 'MM/YYYY') "FECHA PROCESO",
       TO_CHAR(numrun_emp, '09G999G999') || '-' || dvrun_emp "RUN EMPLEADO",
       pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp "NOMBRE EMPLEADO",
       TO_CHAR(sueldo_base, '$9G999G999') "SUELDO BASE",
       CASE
          WHEN sueldo_base BETWEEN 320000 AND 450000 THEN &&utilidades * 0.005
          WHEN sueldo_base BETWEEN 450001 AND 600000 THEN &utilidades * 0.035
          WHEN sueldo_base BETWEEN 600001 AND 900000 THEN &utilidades * 0.025
          WHEN sueldo_base BETWEEN 900001 AND 1800000 THEN &utilidades * 0.0015
          WHEN sueldo_base >= 1800000 THEN &utilidades * 0.001
       END "BONIFICACION POR UTILIDADES"
FROM empleado
ORDER BY appaterno_emp;

UNDEFINE UTILIDADES;

-- CASO 4 OPCION2
SELECT TO_CHAR(sysdate, 'MM/YYYY') "FECHA PROCESO",
       TO_CHAR(numrun_emp, '09G999G999') || '-' || dvrun_emp "RUN EMPLEADO",
       pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp "NOMBRE EMPLEADO",
       TO_CHAR(sueldo_base, '$9G999G999') "SUELDO BASE",
       TO_CHAR(&utilidades * CASE
          WHEN sueldo_base BETWEEN 320000 AND 450000 THEN 0.005
          WHEN sueldo_base BETWEEN 450001 AND 600000 THEN 0.035
          WHEN sueldo_base BETWEEN 600001 AND 900000 THEN  0.025
          WHEN sueldo_base BETWEEN 900001 AND 1800000 THEN 0.0015
          WHEN sueldo_base >= 1800000 THEN 0.001
       END, '$9G999G999') "BONIFICACION POR UTILIDADES"
FROM empleado
ORDER BY appaterno_emp;


-- CASO 5 OPCION 1
SELECT NUMRUN_EMP||'-'||dvrun_emp "RUN EMPLEADO",
        pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp "NOMBRE EMPLEADO",
       ROUND(MONTHS_BETWEEN(SYSDATE, fecha_contrato) / 12) "AÑOS CONTRATADO",
       TO_CHAR(sueldo_base, '$9G999G999') "SUELDO BASE",
       TO_CHAR(ROUND(sueldo_base * ROUND(MONTHS_BETWEEN(SYSDATE, fecha_contrato) / 12) / 100), '$9G999G999') "VALOR MOVILIZACION",
       TO_CHAR(round(sueldo_base * CASE 
                              WHEN sueldo_base >= 450000 THEN SUBSTR(sueldo_base,1,1)
                              ELSE SUBSTR(sueldo_base,1,2)
                           END / 100), '$9G999G999G999') "BONIF. EXTRA MOVILIZACION",
       TO_CHAR(ROUND(sueldo_base * ROUND(MONTHS_BETWEEN(SYSDATE, fecha_contrato) / 12) / 100) +
       round(sueldo_base * CASE 
                               WHEN sueldo_base >= 450000 THEN SUBSTR(sueldo_base,1,1)
                               ELSE SUBSTR(sueldo_base,1,2)
                           END / 100), '$9G999G999G999') "VALOR MOVILIZACION TOTAL"
FROM empleado
WHERE id_comuna IN (117, 118, 120, 122, 126)
ORDER BY appaterno_emp;


-- CASO 5 OPCION 2
SELECT "RUN EMPLEADO", 
        pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp "NOMBRE EMPLEADO",
        "AÑOS CONTRATADO", TO_CHAR(sueldo_base, '$9G999G999') "SUELDO BASE",
       TO_CHAR(pct1, '$9G999G999') "VALOR MOVILIZACION", TO_CHAR(pct2, '$9G999G999G999') "BONIF. EXTRA MOVILIZACION",
       TO_CHAR(pct1+pct2, '$9G999G999G999') "VALOR MOVILIZACION TOTAL"
FROM (
      SELECT NUMRUN_EMP||'-'||dvrun_emp "RUN EMPLEADO",
             pnombre_emp,snombre_emp,appaterno_emp,apmaterno_emp,
             ROUND(MONTHS_BETWEEN(SYSDATE, fecha_contrato) / 12) "AÑOS CONTRATADO",
             sueldo_base,
             ROUND(sueldo_base * ROUND(MONTHS_BETWEEN(SYSDATE, fecha_contrato) / 12) / 100) PCT1,
             round(sueldo_base * CASE 
                              WHEN sueldo_base >= 450000 THEN SUBSTR(sueldo_base,1,1)
                              ELSE SUBSTR(sueldo_base,1,2)
                           END / 100) pct2
      FROM empleado
      WHERE id_comuna IN (117, 118, 120, 122, 126)
     )
ORDER BY appaterno_emp;

-- CASO 6
SELECT año_proceso "AÑO TRIBUTARIO", TO_CHAR(numrun_emp, '09g999g999')||'-'||dvrun_emp "RUN EMPLEADO",
       empleado "NOMBRE EMPLEADO", meses "MESES TRABAJADOS EN EL AÑO", años "AÑOS TRABAJADOS",
       sueldo_base "SUELDO BASE MENSUAL", s_anual "SUELDO BASE ANUAL", b_anual "BONO POR AÑOS ANUAL",
       m_anual "MOVILIZACION ANUAL", col_anual "COLACION ANUAL", 
       s_anual + b_anual + m_anual + col_anual "SUELDO BRUTO ANUAL",
       s_anual + b_anual "RENTA IMPONIBLE ANUAL"
FROM (
         SELECT TO_CHAR(SYSDATE, 'YYYY') año_proceso, numrun_emp, dvrun_emp,
                pnombre_emp||' '||snombre_emp||' '||appaterno_emp||' '||apmaterno_emp empleado,
                CASE 
                    WHEN ROUND(MONTHS_BETWEEN(TRUNC(SYSDATE , 'YEAR') -1, FECHA_CONTRATO),1) > 12 THEN 12
                    ELSE ROUND(MONTHS_BETWEEN(TRUNC(SYSDATE , 'YEAR') -1, FECHA_CONTRATO),1)
                END meses,
                CASE 
                    WHEN ROUND(MONTHS_BETWEEN(TRUNC(SYSDATE , 'YEAR') -1, FECHA_CONTRATO),1) >= 12 
                        THEN ROUND(MONTHS_BETWEEN(TRUNC(SYSDATE , 'YEAR') -1, FECHA_CONTRATO)/12) 
                    ELSE 0
                END años ,
                sueldo_base,
                sueldo_base * CASE 
                                   WHEN ROUND(MONTHS_BETWEEN(TRUNC(SYSDATE , 'YEAR') -1, FECHA_CONTRATO),1) > 12 THEN 12
                                   ELSE ROUND(MONTHS_BETWEEN(TRUNC(SYSDATE , 'YEAR') -1, FECHA_CONTRATO),1)
                              END s_anual,
                TRUNC(sueldo_base *  CASE 
                                   WHEN ROUND(MONTHS_BETWEEN(TRUNC(SYSDATE , 'YEAR') -1, FECHA_CONTRATO),1) >= 12 
                                         THEN ROUND(MONTHS_BETWEEN(TRUNC(SYSDATE , 'YEAR') -1, FECHA_CONTRATO)/12) 
                                   ELSE 0
                               END / 100) * CASE 
                                               WHEN ROUND(MONTHS_BETWEEN(TRUNC(SYSDATE , 'YEAR') -1, FECHA_CONTRATO),1) > 12 THEN 12
                                               ELSE ROUND(MONTHS_BETWEEN(TRUNC(SYSDATE , 'YEAR') -1, FECHA_CONTRATO),1)
                                           END  b_anual,
                ROUND(sueldo_base * 0.12 * CASE 
                                                WHEN ROUND(MONTHS_BETWEEN(TRUNC(SYSDATE , 'YEAR') -1, FECHA_CONTRATO),1) > 12 THEN 12
                                                ELSE ROUND(MONTHS_BETWEEN(TRUNC(SYSDATE , 'YEAR') -1, FECHA_CONTRATO),1)
                                            END) m_anual,
                ROUND(sueldo_base * 0.2) *  CASE 
                                                WHEN ROUND(MONTHS_BETWEEN(TRUNC(SYSDATE , 'YEAR') -1, FECHA_CONTRATO),1) > 12 THEN 12
                                                ELSE ROUND(MONTHS_BETWEEN(TRUNC(SYSDATE , 'YEAR') -1, FECHA_CONTRATO),1)
                                            END col_anual
         FROM empleado
         ORDER BY numrun_emp
      );


