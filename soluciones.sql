-- ══════════════════════════════════════════
-- RetailChain — UNION y UNION ALL
-- Autor: Matías Agustín D'aloia
-- Fecha: 17/10/2026
-- Motor: SQL Server (SSMS)
-- Correr primero schema.sql.
-- ══════════════════════════════════════════

USE RetailChain;
GO

-- ── CONSULTA 1: UNION ────────────────────
-- Reporte de Catálogo Unificado
-- Pregunta de negocio: ¿Qué productos únicos comercializa
-- la empresa en toda su red de sucursales?
-- Operador: UNION (elimina filas completamente duplicadas)

-- No traigo la columna stock a proposito. Comercial pide el catalogo, no el
-- inventario, y ademas el stock rompe el UNION: el Monitor 103 tiene 5 en Norte
-- y 3 en Sur, asi que con stock las dos filas serian distintas y no se
-- eliminaria ninguna. Sin stock, las filas repetidas quedan identicas y UNION
-- las junta en una sola.
SELECT
id_producto,
nombre_producto,
categoria
FROM inventario_sucursal_norte
UNION
SELECT
id_producto,
nombre_producto,
categoria
FROM inventario_sucursal_sur
ORDER BY id_producto;
-- esperado: 11 filas. El ORDER BY va una sola vez al final, no adentro de cada SELECT.


-- ── CONSULTA 2: UNION ALL ────────────────
-- Auditoría de Stock Total
-- Pregunta de negocio: ¿Cuántos registros físicos de stock
-- existen en total entre ambas sucursales?
-- Operador: UNION ALL (mantiene todos los registros incluyendo duplicados)

-- Aca si va el stock y ademas agrego de que sucursal viene cada fila, sino
-- operaciones no sabe donde esta parado cada producto.
SELECT
id_producto,
nombre_producto,
categoria,
stock,
'Norte' AS sucursal
FROM inventario_sucursal_norte
UNION ALL
SELECT
id_producto,
nombre_producto,
categoria,
stock,
'Sur' AS sucursal
FROM inventario_sucursal_sur
ORDER BY id_producto, sucursal;
-- esperado: 14 filas, las 7 de Norte mas las 7 de Sur. No se descarta ninguna.
-- La suma de stock da 200 unidades fisicas en toda la cadena.


-- ── CONSULTA 3: COMPARACIÓN DE RESULTADOS ─
-- Ejecutá estas dos consultas para comparar cuántas filas
-- devuelve cada operador y explicá la diferencia en tu README
SELECT COUNT(*) AS filas_union FROM (
    SELECT id_producto, nombre_producto, categoria FROM inventario_sucursal_norte
    UNION
    SELECT id_producto, nombre_producto, categoria FROM inventario_sucursal_sur
) AS resultado_union;
-- esperado: 11

SELECT COUNT(*) AS filas_union_all FROM (
    SELECT id_producto, nombre_producto, categoria, stock FROM inventario_sucursal_norte
    UNION ALL
    SELECT id_producto, nombre_producto, categoria, stock FROM inventario_sucursal_sur
) AS resultado_union_all;
-- esperado: 14

-- Para acordarme: UNION compara todas las filas entre si para sacar las
-- repetidas, UNION ALL las pega una atras de la otra y listo. Si no necesito
-- sacar duplicados, UNION ALL siempre.
