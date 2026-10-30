# Gráficos mensuales de consumo de boletas

## Objetivo

Simplificar la pantalla **Scan de Boletas** reemplazando el historial textual por una visualización mensual del consumo de electricidad y agua.

## Alcance

- Eliminar el aviso: `Tu documento se procesa solo en este dispositivo`.
- Sustituir el listado de auditoría por dos gráficos de barras independientes:
  - Electricidad, expresada en kWh.
  - Agua, expresada en m³.
- Agrupar los registros por el mes de inicio de su período de consumo.
- Mostrar como máximo los últimos seis meses que tengan registros, en orden cronológico.
- Sumar los consumos cuando existan varias boletas del mismo servicio y mes.
- Mostrar el valor de consumo sobre cada barra y la etiqueta abreviada del mes bajo ella.
- Para un servicio sin datos, mostrar un estado vacío dentro de su tarjeta sin ocultar el gráfico del otro servicio.
- Eliminar del historial los indicadores de origen y adjunto: `OCR Confirmado`, `Manual` y `Sin doc. adjunto`.

## Diseño técnico

`BillHistorySection` conservará su entrada `List<BillRecord>` y preparará dos series derivadas, una por servicio. La agrupación será una función pura que recibe registros, filtra por servicio, agrupa por `periodoDesde` en formato año-mes y suma `consumo`.

Se implementará un gráfico de barras liviano con widgets de Flutter existentes. No se agregará una dependencia de gráficos. Las tarjetas usarán el color ámbar para electricidad y azul para agua, conservando compatibilidad con tema claro y oscuro.

La eliminación del aviso se realizará en el widget de acciones de escaneo. No se modifica el flujo OCR, el almacenamiento de boletas, ni los endpoints del backend.

## Estados y validación

- Sin boletas: ambas tarjetas muestran su estado vacío.
- Solo electricidad o solo agua: se muestra su gráfico y el estado vacío del servicio restante.
- Múltiples boletas en el mismo mes: se representa una única barra con el consumo agregado.
- Se crearán o actualizarán pruebas de widget y de agrupación para validar filtrado, suma mensual y ausencia de las etiquetas eliminadas.
