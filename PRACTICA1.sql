-- CASO 1
SELECT 
   TO_CHAR(SUBSTR(RUTCLIENTE, 1, LENGTH(RUTCLIENTE) - 2), '09g999g999') || '-' || SUBSTR(RUTCLIENTE, -1) "RUT CLIENTE",
   SUBSTR(NOMBRE, INSTR(NOMBRE, ' '))|| ' ' || SUBSTR(NOMBRE, 1, INSTR(NOMBRE, ' ')) "NOMBRE CLIENTE",
    CASE
        WHEN SALDO <= 0 THEN 'SUSPENDIDO'
        WHEN SALDO > 0 THEN 'VIGENTE'
    END SALDO,
    CODCOMUNA "COMUNA",
    ESTADO "ESTADO",
    TO_CHAR(CREDITO, '$99G999G999') "CREDITO",
    TO_CHAR(SALDO, '$99G999G999') SALDO   
FROM CLIENTE
WHERE (ESTADO = 'A' AND 50 > (SALDO * 100)/ CREDITO) OR (SALDO <= 0);

-- CASO 2
SELECT 
    CODPRODUCTO "COD.PRODUCTO",
    DESCRIPCION "DESCRIPCION",
    CASE 
        WHEN CODUNIDAD = 'UN' THEN 'UNITARIO'
        WHEN CODUNIDAD = 'LT' THEN 'LITRO'
        WHEN CODUNIDAD = 'MT' THEN 'METRO'
    END "UNIDAD",
    NVL(TO_CHAR(TOTALSTOCK), 'SIN STOCK') "STOCK ACTUAL",
    CODPAIS,
    CASE
        WHEN CODPAIS = 1 THEN 'CHILE'
        WHEN CODPAIS = 2 THEN 'EEUU'
        WHEN CODPAIS = 3 THEN 'INGLATERRA'
        WHEN CODPAIS = 4 THEN 'ALEMANIA'
        WHEN CODPAIS = 5 THEN 'FRANCIA'
        WHEN CODPAIS = 6 THEN 'CANADA'
        WHEN CODPAIS = 7 THEN 'ARGENTINA'
        WHEN CODPAIS = 8 THEN 'BRASIL'
    END "PAIS"
FROM PRODUCTO
WHERE (TOTALSTOCK < 50 AND CODPAIS != 2) OR (TOTALSTOCK IS NULL)
ORDER BY "PAIS" ASC, TOTALSTOCK DESC;

-- CASO 3 
SELECT 
    NUMBOLETA "BOLETA",
    TO_CHAR(SUBSTR(RUTCLIENTE, 1, LENGTH(RUTCLIENTE) - 2), '09g999g999') || '-' || SUBSTR(RUTCLIENTE, -1) "RUT CLIENTE",
    TO_CHAR(SUBSTR(RUTVENDEDOR, 1, LENGTH(RUTVENDEDOR) - 2), '09g999g999') || '-' || SUBSTR(RUTVENDEDOR, -1) "RUT VENDEDOR",
    FECHA,
    TO_CHAR(TOTAL, '$99g999g999') TOTAL,
    TO_CHAR(TRUNC(TOTAL - TOTAL * 0.25), '$99G999G999') REBAJA,
    NVL(TO_CHAR(NUM_DOCTO_PAGO), 'NO POSEE') "DOCUMENTO"
FROM BOLETA
WHERE TO_CHAR(FECHA, 'MMYYYY') = TO_CHAR(add_months(TO_DATE('&FECHA'), -1), 'MMYYYY')
ORDER BY FECHA DESC;


