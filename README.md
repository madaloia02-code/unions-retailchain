# unions-retailchain

Práctica de UNION y UNION ALL sobre el inventario de las dos sucursales de RetailChain.
Curso de Data Analytics, Coderhouse — Matías Agustín D'aloia.

`schema.sql` crea la base `RetailChain` con las dos tablas y sus datos. `soluciones.sql`
tiene las tres consultas. Motor: SQL Server (T-SQL), ejecutado desde SSMS.

## ¿Cuántas filas devuelve cada consulta y por qué son distintas?

La Consulta 1 con UNION devuelve **11 filas** y la Consulta 2 con UNION ALL devuelve
**14**. Entre las dos sucursales hay 7 + 7 = 14 registros, así que UNION descartó 3.

Los tres que eliminó son los productos que están cargados igual en las dos sucursales:

| id_producto | nombre_producto | categoria |
|---|---|---|
| 103 | Monitor 4K 27" | Computación |
| 104 | Teclado Mecánico | Accesorios |
| 106 | SSD Externo 1TB | Almacenamiento |

Hay un detalle que conviene mirar. En la Consulta 1 no traigo la columna `stock`, y no
es casualidad: el Monitor 103 tiene 5 unidades en Norte y 3 en Sur. Si incluyera el
stock, esas dos filas serían distintas entre sí y UNION no eliminaría ninguna, con lo
cual devolvería las mismas 14 filas que UNION ALL. UNION compara la fila completa, no
el producto.

El caso inverso también está en los datos: la Webcam HD 1080p aparece en las dos
sucursales con el mismo nombre y la misma categoría, pero con id 107 en Norte y 111 en
Sur. Como el id difiere, la fila no es idéntica y las dos sobreviven al UNION. Para el
catálogo eso probablemente sea un error de carga: es el mismo producto con dos códigos.

## ¿Por qué UNION ALL es más eficiente?

Porque hace menos trabajo. UNION ALL concatena los dos resultados y los devuelve.

UNION, en cambio, tiene que garantizar que no haya filas repetidas, y para eso compara
todas las filas de un conjunto contra todas las del otro. Internamente el motor resuelve
eso ordenando el resultado completo o armando una tabla hash, que es una operación
extra de CPU y memoria. En el plan de ejecución de SQL Server se ve como un paso de
ordenamiento con eliminación de duplicados que en UNION ALL directamente no aparece.

Con 14 filas no se nota. Sobre millones de registros, esa diferencia es minutos.

## ¿En qué casos de negocio usarías cada uno?

**UNION ALL, para contar volumen.** En mi trabajo atiendo equipos Lenovo en garantía.
Si quiero saber cuántos casos se atendieron en el trimestre y tengo un listado por mes,
los junto con UNION ALL: si un mismo equipo volvió a entrar en septiembre y en octubre,
son dos atenciones distintas y las dos tienen que contar. Con UNION perdería una y el
volumen quedaría subestimado.

**UNION, para armar un listado sin repetidos.** Si de esos mismos listados mensuales
quiero sacar qué modelos de equipo pasaron por el servicio durante el año, ahí sí quiero
cada modelo una sola vez. Que un modelo haya entrado veinte veces no me agrega nada a
una lista de modelos.

La regla que me queda: si la pregunta empieza con "cuántos", casi siempre es UNION ALL.
Si empieza con "cuáles", suele ser UNION.

## ¿Qué pasa si las columnas no coinciden en número o tipo?

SQL Server rechaza la consulta y no devuelve nada.

Si no coincide la **cantidad** de columnas, el error es el 205: *"All queries combined
using a UNION, INTERSECT or EXCEPT operator must have an equal number of expressions in
their target lists"*. Es bastante claro y se arregla rápido.

Si la cantidad coincide pero los **tipos** no son compatibles, el error aparece recién
al convertir. Por ejemplo, si en una parte va `nombre_producto` y en la misma posición
de la otra va `stock`, SQL Server intenta convertir el texto a número y tira el error
245: *"Conversion failed when converting the varchar value ... to data type int"*.

Ese segundo caso es más traicionero, porque la consulta parece bien escrita y el error
habla de conversión, no de UNION. Por eso conviene alinear las columnas en el mismo
orden en las dos partes y no confiar en que el motor las acomode: no lo hace, las toma
por posición.
