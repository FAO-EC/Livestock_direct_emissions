# Livestock_direct_emissions
Script to estimate direct emissions in livestcok productions for Ecuador. Based on GLEAM model developed by FAO  


GANADERÍA CLIMÁTICAMENTE INTELIGENTE
INTEGRANDO LA REVERSIÓN DE LA DEGRADACIÓN DE TIERRAS Y REDUCIENDO LOS RIESGOS DE DESERTIFICACIÓN EN PROVINCIAS VULNERABLES	 


DOCUMENTO TÉCNICO

HERRAMIENTA DE CUANTIFICACIÓN DE EMISIONES DIRECTAS DE GASES DE EFECTO INVERNADERO EN SISTEMAS GANADEROS DEL ECUADOR
NIVEL NACIONAL

Descripción del modelo y guía de usuario
(versión R)


Quito, Ecuador
Noviembre, 2019

Proyecto: GCP/ECU/085/GFF – GCPECU/092/SCF
Ganadería Climáticamente Inteligente
Integrando la Reversión de Degradación de Tierras y Reducción del Riesgo de Desertificación en Provincias Vulnerables	 


Ejecutado por el Ministerio del Ambiente (MAE), Ministerio de Agricultura, Ganadería, Acuacultura y Pesca (MAGAP), con el apoyo técnico de la Organización de las Naciones Unidad para la Agricultura y la Alimentación (FAO) y el financiamiento del Fondo Mundial para el Medio Ambiente (GEF). 


Documento Técnico: herramienta de cuantificación de emisiones directas de gases de efecto invernadero en sistemas ganaderos.
Elaborado por:

Armando Rivera Moncada (Técnico SIG- Proyecto GCI)
Email: armando.d.rivera@outlook.com

Revisado por:

Juan Merino (Coordinador Nacional del Proyecto GCI)

Jonathan Torres Celi (Asistente Técnico del Proyecto GCI)

Pamela Sangoluisa (Especialista en Mitigación del Proyecto GCI)

CONTENIDO

1.1.	INTRODUCCIÓN	4

1.2.	ESTRUCTURA DEL MODELO	5

1.3.	DATOS DE ENTRADA	5

1.3.1.	DATOS PRODUCTIVOS NACIONALES: input_national_data.csv	6

1.3.2.	PASTO PRINCIPAL: input_ pasture_main_list.csv	8

1.3.3.	ALIMENTACIÓN COMPLEMENTARIA: input_feed_supplements_list.csv	9

1.4.	PROCESAMIENTO DE DATOS	10

1.4.1.	CONSIDERACIONES DEL CÁLCULO DE PARÁMETROS DEL HATO.	11

1.4.2.	CORRER EL MODELO.	13

1.5.	RESULTADOS	15

1.6.	REFERENCIAS	18


ACRÓNIMOS

GEI	Gases de efecto invernadero

GCI	Ganadería Climáticamente Inteligente

FAO	Organización de las Naciones Unidas para la Alimentación y Agricultura

PGCI	Proyecto de Ganadería Climáticamente Inteligente

SIG	Sistemas de Información Geográfica

1.1.	INTRODUCCIÓN

El proyecto Ganadería Climáticamente Inteligente (GCI) es una iniciativa implementada en conjunto por la Organización de las Naciones Unidas para la Alimentación FAO, el Ministerio del Ambiente y el Ministerio de Agricultura con el financiamiento del Fondo Mundial para el Medio Ambiente GEF. El objetivo del proyecto es reducir la degradación de la tierra e incrementar la capacidad de adaptación al cambio climático y de reducción de emisiones de GEI, a través de la implementación de políticas intersectoriales y técnicas de ganadería sostenible, con particular atención en las provincias vulnerables. Entre sus componentes se destacan el implementar estrategias de transferencia, difusión e implementación de tecnologías para el manejo ganadero climáticamente inteligente (MGCI) y el monitoreo de las emisiones de GEI y de la capacidad adaptativa en el sector ganadero.

Los gases de efecto invernadero de la actividad ganadera se estiman en 7.1 millones de Gg de CO2-eq al año, lo cual representa cerca del 14% de las emisiones antropogénicas a nivel mundial (FAO, 2017a). Esta actividad es considerada una de las mayores fuentes de emisión en los sistemas agropecuarios. Ante esto, la FAO ha desarrollado un modelo de simulación de la actividad ganadera, Modelo Global de Evaluación Ambiental de la Ganadería (GLEAM, por sus siglas en inglés), para estimar las emisiones de gases de efecto invernadero en las diferentes etapas de producción de esta actividad. El modelo utiliza datos de distribución ganadera, alimentación, datos climáticos, localización y manejo productivo para identificar la interacción entre la actividad ganadera y su impacto en el medio ambiente (FAO, 2017b).

El proyecto Ganadería Climáticamente Inteligente ha implementado 165 fincas piloto en las zonas de intervención, en las cuales ha implementado buenas prácticas ganaderas con el fin de evaluar junto a los productores los beneficios productivos. Además, las fincas sirven como fuente de información continua, en la cual se levantan datos productivos y de manejo para los reportes de mitigación y adaptación que genera el proyecto. En este ámbito, se ha desarrollado una herramienta en R que automatiza los procesos del Modelo GLEAM, adaptándola a las condiciones de Ecuador. El software permite estimar las emisiones directas (provenientes del ganado) de gases de efecto invernadero (metano y óxido nitroso) de los procesos de fermentación entérica en los animales y del proceso de manejo de las excretas. Esta herramienta fue adaptada a nivel de finca a fin de incorporar los datos de las 165 fincas piloto y generar modelos de impacto durante el tiempo de intervención del proyecto.

1.2.	ESTRUCTURA DEL MODELO
 
1.3.	DATOS DE ENTRADA

El segmento del modelo GLEAM utilizado en este ejercicio usa varios parámetros del sistema productivo ganadero bovino para estimar productividad y emisiones directas (CH4 de la fermentación entérica, CH4 del manejo de excretas, N2O del manejo de excretas y N2O de las excretas dejadas en la pastura). Se analizaron los 4 primeros capítulos del documento GLEAM 2.0 y se determinaron las características de los datos requeridos en cada fórmula. El análisis se lo realizó tomando en cuenta la región en la que está ubicada la finca (costa, sierra y amazonía), el sistema productivo (marginal, mercantil, combinado y empresarial) y en los dos tipos de producción: Carne y Leche. 

El modelo usa varias matrices de entrada que agrupan los datos del manejo del hato y alimentación requeridos en la construcción de las variables que se usarán en el módulo GLEAM. 

1.3.1.	DATOS PRODUCTIVOS NACIONALES: input_national_data.csv

La matriz input_national_data incluye datos de manejo del hato bovino en cada una de las regiones del Ecuador. La matriz incluye 20 grupos que se forman de la combinación de las diferentes regiones, estratos y tipos de producto que se han identificado en el país. Se debe llenar los datos productivos de manejo del hato en cada uno de los grupos. En caso de que se requiera realizar el análisis de un solo grupo, se deberá colocar ceros en los datos de las opciones que no se vayan a analizar.
*Los datos ingresados deben ser el promedio de un año calendario. 

1.3.1.1.	Datos generales: 

Variable	Descripción

REGION	Se enumeran las 3 regiones del Ecuador, opciones: COSTA, SIERRA, AMAZONIA***

ESTRATO	Tipo de sistema productivo, opciones: MARGINAL, MERCANTIL, COMBINADO, EMPRESARIAL**

PRODUCTO	Tipo de producción, opciones: Carne, Leche*

*Escribir una sola opción. Debe ser escrita conservando el formato, es decir la primera letra en mayúsculas y el resto en minúsculas.

**Escribir una sola opción. Debe ser escrita conservando el formato, es decir en mayúsculas. Los sistemas se basan en la Metodología de valoración de tierras rurales (MAGAP & PRAT, 2008): Marginal (prácticas de manejo tradicionales, principal fuente de ingresos no proviene de la finca, genera pocos excedentes para la venta de productos), Mercantil (los productos generados en la finca son comercializados constantemente, la principal fuerza de trabajo en la finca es familiar, bajo en nivel de tecnificación), Combinado (semi-tecnificado, la principal fuerza de trabajo en la finca es asalariada, los productos generados en la finca son comercializados constantemente), Empresarial (altamente tecnificado, la principal fuerza de trabajo en la finca es permanente y asalariada, producción destinada a la agroindustria y mercado de exportación) 


1.3.1.2.	Datos del hato: Número de animales por categoría

Variable	Descripción

AF	Número de hembras adultas - vacas (mayores a 2 años)

AM	Número de machos adultos - toros (mayores a 2 años)

YF	Número de hembras entre 1 y 2 años - vaconas

YM	Número de machos entre 1 y 2 años - toretes

CF	Número de hembras menores a 1 año - terneras

CM	Número de machos menores a 1 año - terneros


1.3.1.3.	Datos del hato: Parámetros de mortalidad y salida de animales

Variable	Descripción

DRIF	Tasa de mortalidad en terneras*

DR1M	Tasa de mortalidad en terneros*

DR2	Tasa de mortalidad de animales adultos

* En caso de poseer una sola tasa para terneros y terneras, se puede utilizar el mismo valor en ambas variables.


1.3.1.4.	Datos del hato: Parámetros de fertilidad y pesos

Variable	Descripción

AFC_MONTHS	Edad promedio en meses que las vacas tienen su primer parto**

AFKG	Peso promedio en kg de las vacas*

AMKG	Peso promedio en kg de los toros*

CKG	Peso promedio en kg de las terneras y terneros al nacimiento*

MFSKG	Peso promedio en kg de las vaconas al sacrificio o venta*

MMSKG	Peso promedio en kg de los toretes al sacrificio o venta*

*Todos los pesos se ingresan en kilogramos.

**Edades y período se ingresan en meses.


1.3.1.5.	Datos del hato: Parámetros productivos

Variable	Descripción

RRF	Tasa de reemplazo de hembras adultas.

FR	Tasa de fertilidad

ERF	Tasa de descarte de hembras adultas

ERM	Tasa de descarte de machos adultos

MILK_YIELD	Producción de leche promedio en litros por animal por día

LACT_PER_MONTHS	Período de lactancia promedio***

MILK_FAT	Porcentaje de grasa en la leche*

MILK_PROTEIN	Porcentaje de proteína en la leche**

*Valores por defecto: región costa = 3.98, región sierra = 3.72, región amazónica = 3.17

**Valores por defecto: región costa = 3.42, región sierra = 3.01, región amazónica = 2.91

***Edades y período se ingresan en meses.


1.3.1.6.	Datos de la finca: Manejo de excretas

Variables	Descripción

MMSPASTURE	Porcentaje de las excretas que son dejadas en los potreros sin manejo

MMSDAILY	Porcentaje de las excretas que son dispersadas diariamente en los potreros

MMSLIQUID	Porcentaje de las excretas que es almacenado con un mínimo agregado de agua fuera del lugar en el que están los animales, 
usualmente por períodos menores a un año

MMSCOMPOSTING	Porcentaje de las excretas que se utiliza para la fabricación de abonos orgánicos con volteo frecuente para mezclado y aireación

MMSANAEROBIC	Porcentaje de las excretas que se recogen en un tanque contenedor o laguna cubierta de manera anaeróbica (sin presencia de aire). Por lo general, los digestores se diseñan para descomponer los desechos, produciendo biogas que es capturado y usado como combustible

MMSDRYLOT	Porcentaje de las excretas que se acumulan en un área abierta sin cobertura vegetal

MMSSOLID	Porcentaje de las excretas que se almacena en camas, típicamente por un período de varios meses. El estiércol se puede apilar debido a la presencia de una cantidad suficiente de material de cama o la pérdida de humedad por evaporación.

MMSUNCOVEREDLAGOON	Porcentaje de las excretas que se almacenan de forma líquida en lagunas diseñadas para estabilizar los residuos y el almacenar. El almacenamiento es por largos períodos de un año o más. El líquido de la laguna es utilizado como fertilizante.

MMSBURNED	Porcentaje de las excretas que se secan y se queman como combustible.

* La suma de los porcentajes del manejo de las excretas debe sumar 100.


1.3.2.	PASTO PRINCIPAL: input_ pasture_main_list.csv

La matriz input_pature_main_list debe contener la lista de los pastos principales que tienen mayor presencia en cada grupo productivo (combinado_carne, combinado_leche, empresarial_carne, empresarial_leche, marginal_carne, marginal_leche, mercantil_carne y mercantil_leche). La tabla 1 muestra los datos de los principales pastos que se encuentran en el Ecuador. Los datos que se muestran en el listado fueron recopilados de diferentes fuentes literarias, con la colaboración de personal de la Subsecretaría de Ganadería del Ministerio de Agricultura y Ganadería y el Instituto Nacional de Investigaciones Agropecuarias.

•	digestibility_percentage: Es el porcentaje de digestibilidad asociado al pasto.

•	nitrogen_content: Es el contenido máximo de nitrógeno (gramos de nitrógeno / kg materia seca) del pasto.

•	percentage_costa: Porcentaje de presencia del pasto en la región costa.

•	percentage_sierra: Porcentaje de presencia del pasto en la región sierra.

•	percentage_amazonia: Porcentaje de presencia del pasto en la región amazonia.

Las tablas permiten colocar los porcentajes de presencia de cada pasto en cada región por cada uno de los grupos productivos. De esta manera se puede colocar al mismo pasto y su presencia en varias regiones del país. Si han identificado 8 grupos productivos y se han diseñado una tabla por cada grupo. En caso de manejar los mimos pastos en varios grupos, se deberán repetir los datos de pastos en esos grupos. De ser necesario se pueden aumentar pastos al listado.


1.3.3.	ALIMENTACIÓN COMPLEMENTARIA: input_feed_supplements_list.csv

La matriz input_feed_supplements_list debe incluir los alimentos, adicionales al pasto, que conforman la canasta alimenticia de los animales, así como los kilogramos de materia fresca de cada alimento que se les da a las diferentes categorías de animales al día. La tabla 2 describe datos de los principales alimentos que se manejan en la canasta alimenticia en el Ecuador. Los datos que se muestran en el listado fueron recopilados de diferentes fuentes literarias, con la colaboración de personal de la Subsecretaría de Ganadería del Ministerio de Agricultura y Ganadería y el Instituto Nacional de Investigaciones Agropecuarias.

•	digestibility_percentage: Es el porcentaje de digestibilidad asociado al alimento.

•	nitrogen_content: Es el contenido de nitrógeno (gramos de nitrógeno / kg materia seca) del alimento.

•	dry_matter_percentage: Es el porcentaje de materia seca del alimento.

•	adult_female_feed_costa_kg: Los kilogramos del alimento que se les da en promedio a cada vaca al día (kilogramos por animal por día) en la región costa.

•	other_categories_feed_costa_kg: Kilogramos del alimento que se le da en promedio a cada animal de las otras categorías de animales (vaconas, toros, toretes) al día (kilogramos por animal por día) en la región costa.

•	adult_female_feed_sierra_kg: Los kilogramos del alimento que se les da en promedio a cada vaca al día (kilogramos por animal por día) en la región sierra.

•	other_categories_feed_sierra_kg: Kilogramos del alimento que se le da en promedio a cada animal de las otras categorías de animales (vaconas, toros, toretes) al día (kilogramos por animal por día) en la región sierra.

•	adult_female_feed_amazonia_kg: Los kilogramos del alimento que se les da en promedio a cada vaca al día (kilogramos por animal por día) en la región amazonia.

•	other_categories_feed_amazonia_kg: Kilogramos del alimento que se le da en promedio a cada animal de las otras categorías de animales (vaconas, toros, toretes) al día (kilogramos por animal por día) en la región amazonia.


1.4.	PROCESAMIENTO DE DATOS

El modelamiento de datos en la herramienta incorpora varios insumos espaciales en formato raster. Uno de estos insumos es el mapa GLW (Gridded Livestock of the World) (Gilbert et al., 2018) adaptado a país, el cual incorpora la distribución potencial del número de animales por píxel de acuerdo con las características del terreno.

Adicionalmente, se utiliza datos de temperatura promedio anual a nivel nacional (Fick and Hijmans, 2017). 

El tercer componente GIS se construyó a partir del mapa del mapa de Cobertura y Uso de la Tierra (SIGTIERRAS, 2016).   De este insumo se extrajo los diferentes sistemas productivos Marginal, Mercantil, Combinado y Empresarial para cada una de las regiones Costa, Sierra y Amazonía. La combinación de este mapa con el modelo GLW, permitió obtener mapas del potencial de número de animales por sistema productivo en cada una de las regiones.

Para el procesamiento de los resultados, se generó un script “script_emisiones_nacional.R” en R programming, que recopila los algoritmos desarrollados en el modelo GLEAM. Los comentarios dentro del script enlazan los algoritmos con las secciones del documento GLEAM 2.0 en las que se encuentra su descripción. Esto permite una lectura fácil y ágil de los algoritmos generados. El modelo GLEAM trabaja con datos de temperatura media y porcentaje de lixiviación de sólidos y líquidos. Para este proceso se utilizan 3 imágenes raster (temp.tif, leachliquid.tif y lichsolid.tif), las cuales se encuentran dentro de la carpeta DATA. Para procesar estos datos se utilizó la librería “raster” del paquete R, la cual permite procesar datos raster.


1.4.1.	CONSIDERACIONES DEL CÁLCULO DE PARÁMETROS DEL HATO.

Varios algoritmos del modelo requirieron de parámetros cuyo cálculo se realizó mediante un análisis en conjunto con el equipo técnico del Proyecto Ganadería Climáticamente Inteligente, a fin de definir la mejor forma de construirlos. Estos cálculos se describen a continuación:

1.	Las unidades de los datos de entrada fueron homologadas para su uso en Ecuador. De esta manera, se manejan kilogramos (en todos los datos de peso) y meses (en los datos de períodos). 

2.	Los resultados de emisiones están dados en kg CO2 eq / año. Por este motivo, los datos ingresados deben corresponder al período de un año calendario.

3.	El número total de animales (vacas, vaconas, terneras, toros, toretes y terneros) corresponden al promedio de animales que se tuvieron en el año en evaluación.

4.	El modelo GLEAM maneja el dato de Edad al Primer Parto (AFC por sus siglas en inglés) en años, por lo que se asigna la siguiente ecuación:

AFC = edad al primer parto en meses / 12

5.	Se incluyó un proceso de corrección de los pesos de animales adultos (vacas - AFKG y toros - AMKG) con los pesos al sacrificio de animales jóvenes (vaconas - MFSKG y toretes - MMSKG). Al fin de evitar que los pesos de los animales jóvenes sean mayores a los de los animales adultos por algún error de introducción de datos. 

La restricción: Si AFKG es menor que MFSKG, entonces se asigna:

AFKG = MFSKG

MFSKG = AFKG

La restricción: Si AMKG es menor que MMSKG, entonces se asigna:

AMKG = MMSKG

MMSKG = AMKG


6.	Para los datos de grasa y proteína en la leche se generaron valores por defecto regionales para los casos en que no exista un análisis. Los valores son:

Región	  Grasa en la leche	  Proteína en la leche

Amazonía	3.17	              2.91

Costa	    3.98	              3.42

Sierra	  3.72	              3.01

7.	El período de lactancia (LACT_PER por sus siglas en inglés) en el modelo GLEAM está contemplado en días, por lo que se asigna la siguiente ecuación para el cálculo:

LACT_PER = período de lactancia en meses * 30.4 
  
8.	Los porcentajes de manejo de excretas tienen que sumar 100. Para conocer porcentaje en un sistema específico, se puede hacer una aproximación en relación con el tiempo que los animales pasan en ciertas instalaciones de la finca. Por ejemplo, si los animales pasan 4 horas en una sala de ordeño y el resto del tiempo en los potreros, se puede asumir que 4 horas (16% del tiempo) se manejan las excretas en lote de secado y 20 horas (84% del tiempo) las excretas no tienen manejo:

Excretas lote de secado = 16

Excretas sin manejo = 84
  

9.	Para obtener la tasa de mortalidad de terneras (DR1F) y terneros (DR1M), se sugiere la siguiente fórmula:

DR1F = (terneras muertas / (terneras + terneras muertas)) * 100

DR1M = (terneros muertos / (terneros + terneros muertos)) * 100  


10.	La tasa de mortalidad en adultos se obtiene con la siguiente fórmula:

DR2 = ((vacas muertas + toros muertos) / (vacas + toros + vacas muertas + toros muertos + vacas faenadas + toros faenados + vacas vendidas + toros vendidos))*100
  
11.	El peso de terneros y terneras (CKG) se corrige de acuerdo con los valores ingresados, de la siguiente manera:

Si solo existe datos de peso de terneros: CKG = peso de terneros

Si solo existe datos de peso de terneras: CKG = peso de terneras

Si existen datos de terneras y terneros: CKG = (peso de terneras + peso de terneros) / 2

12.	A la tasa de fertilidad de hembras de reemplazo (FRRF) se le asigna 95, tal como indica el documento GLEAM – página 12.

13.	La tasa de reemplazo de vacas (RRF) se calcula de la siguiente manera:

RRF = ((vaconas - vacas muertas - vacas de descarte) / (vacas + vacas muertas + vacas faenadas + vacas vendidas)) * 100

14.	La tasa de salida de vacas (ERF) se calcula con la siguiente ecuación:

ERF = ((vacas de descarte + vacas vendidas) / (vacas + vacas muertas + vacas faenadas + vacas vendidas)) * 100

15.	La tasa de salida de toros (ERM) se calcula con la siguiente ecuación:

ERM = ((toros de descarte + toros vendidos) / (toros + toros muertos + toros faenados + toros vendidos)) * 100

16.	La tasa de fertilidad (FR) se calcula de diferente manera dependiendo del tipo de producción de la finca:

Si es producción de leche: FR = (número de partos / vacas en producción) * 100

Si es producción de carne: FR = (número de partos / vacas) * 100

17.	Para el cálculo de alimentación, en la sección de valores nutricionales (página 52 del documento GLEAM), se asignaron algunos valores por tipo de sistema productivo, los cuales se describen a continuación:

Porcentaje de energía digerible (DE):

Sistema marginal = 45

Sistema mercantil = 50

Sistema combinado = 55

Sistema empresarial = 60


Energía dietética neta estimada (grow_nema):

Sistema marginal = 3.5

Sistema mercantil = 4.5

Sistema combinado = 5.5

Sistema empresarial = 6.5


18.	En la sección de proyección del hato realizado en el cálculo, se obtienen los siguientes valores: hembras de reemplazo (RF), machos de reemplazo (RM), hembras de carne (MF) y machos de carne (MM). Para el cálculo de los animales de reemplazo se toman en cuenta las salidas de animales en la proyección del hato y se calcula el número de animales que se requieren para reemplazar esas salidas. El resto de los animales que ingresan al hato y que no son considerados de reemplazo, se los considera de carne.

La distribución de los animales calculados (RF, RM, MF y MM) es asignada al número total de animales jóvenes de nuestro hato (vaconas y toretes):

RF hato = RF calculado * (vaconas + toretes) / (RF + RM + MF + MM)

RM hato = RM calculado * (vaconas + toretes) / (RF + RM + MF + MM)

MF hato = MF calculado * (vaconas + toretes) / (RF + RM + MF + MM)

MM hato = MM calculado * (vaconas + toretes) / (RF + RM + MF + MM)


1.4.2.	CORRER EL MODELO.

El script de programación está realizado en R programing y requiere del software R para su uso. Adicionalmente se recomienda utilizar RStudio para un fácil procesamiento del script. Las pruebas fueron realizadas utilizando la versión 3.6.1 de R y la versión 1.2.1335 de RStudio.

El script tiene comentarios que ayudan a vincular cada sección y logaritmos con su respectiva sección del documento GLEAM. La carpeta que contiene el script debe contener los archivos CSV de los datos de entrada, tal como se muestra en la imagen 1.

 
Imagen 1: componentes del script de emisiones

Ver sección 1.3 para conocer la manera de gestionar los datos de entrada. Una vez llenados los archivos de entrada seguimos el siguiente procedimiento:

•	Abrir el archivo script_emisiones.R en RStudio

•	Seleccionar todas las líneas de código

•	Presionar el botón RUN

•	Se generan varias carpetas por cada tipo de sistema productivo y producto, las cuales contienen todos los subproductos en formato raster del cálculo de emisiones.

•	Se genera una carpeta RESULTADOS con los siguientes archivos:

o	combinado.tiff: Mapa raster que muestra la distribución de las emisiones de carne y leche en el sistema productivo Combinado.

o	empresarial.tiff: Mapa raster que muestra la distribución de las emisiones de carne y leche en el sistema productivo Empresarial.

o	marginal.tiff: Mapa raster que muestra la distribución de las emisiones de carne y leche en el sistema productivo Marginal.

o	mercantil.tiff: Mapa raster que muestra la distribución de las emisiones de carne y leche en el sistema productivo Mercantil.

o	Total.tiff: Mapa raster que muestra la distribución de las emisiones a nivel nacional.

o	herd_total.csv: Matriz que muestra los resultados en número de animales de la proyección del hato que realiza el modelo.

o	emissions_total.csv: Matriz que muestra los resultados de emisiones nacionales. 
 

1.5.	RESULTADOS 

El script genera dos matrices de resultados con los datos del modelamiento del hato bovino y con los datos de emisiones directas por tipo de fuente. Adicionalmente, se muestra el estimado de producción de carne y leche durante el año de evaluación. La intensidad de emisiones se calcula dividiendo el total de emisiones para el estimado de producción de carne y leche. Este factor indica el nivel de eficiencia del sistema productivo, y se puede comparar con los datos nacionales, los cuales se describen a continuación:

La intensidad de emisiones del 10% más bajo de la muestra nacional evaluada por el proyecto Ganadería Climáticamente Inteligente son:

Para Sistemas de Carne: 27.30 kg CO2 eq / kg carne a la canal

Para Sistemas de Leche: 1.9 kg CO2 eq / litro de leche

A continuación, se hace una descripción de la matriz de emisiones de los resultados de la herramienta (emissions_total.csv)

Variables	Descripción -	Unidades

REGION	Se enumeran las 3 regiones del Ecuador	

ESTRATO	Tipo de sistema productivo	

PRODUCTO	Tipo de producción	

AFEXIT	Número de hembras adultas que salen	- número

AMEXIT	Número de machos adultos que salen	- número

MFEXIT	Número de hembras de carne que salen	- número

MMEXIT	Número de machos de carne que salen	- número

RFEXIT	Número de hembras de reemplazo que salen	- número

Milk_production	Producción de leche	- litros de leche

Meat_production_FF	Producción de carne de salida de animales adultos hembras	- kg carne a la canal

Meat_production_FM	Producción de carne de salida de animales adultos machos - kg carne a la canal

Meat_production_M	Producción de carne de animales jóvenes sacrificados - kg carne a la canal

Meat_total	Total de producción de carne -	kg carne a la canal

CH41CO2TOTAFM	Metano de la fermentación entérica de las vacas en producción	- kg CO2 eq

CH41CO2TOTAFN	Metano de la fermentación entérica de las vacas secas	- kg CO2 eq

CH41CO2TOTAM	Metano de la fermentación entérica de los toros	- kg CO2 eq

CH41CO2TOTRF	Metano de la fermentación entérica de las hembras de reemplazo	- kg CO2 eq

CH41CO2TOTRM	Metano de la fermentación entérica de los machos de reemplazo	- kg CO2 eq

CH41CO2TOTMM	Metano de la fermentación entérica de los machos de carne	- kg CO2 eq

CH41CO2TOTMF	Metano de la fermentación entérica de las hembras de carne	- kg CO2 eq

CH42CO2TOTAFM	Metano del manejo de excretas de las vacas en producción	- kg CO2 eq

CH42CO2TOTAFN	Metano del manejo de excretas de las vacas secas	- kg CO2 eq

CH42CO2TOTAM	Metano del manejo de excretas de los toros	- kg CO2 eq

CH42CO2TOTRF	Metano del manejo de excretas de las hembras de reemplazo	- kg CO2 eq

CH42CO2TOTRM	Metano del manejo de excretas de los machos de reemplazo	- kg CO2 eq

CH42CO2TOTMM	Metano del manejo de excretas de los machos de carne	- kg CO2 eq

CH42CO2TOTMF	Metano del manejo de excretas de las hembras de carne	- kg CO2 eq

NOTOTCO2AFM	Óxido nitroso del manejo de excretas de las vacas en producción	- kg CO2 eq

NOTOTCO2AFN	Óxido nitroso del manejo de excretas de las vacas secas	- kg CO2 eq

NOTOTCO2AM	Óxido nitroso del manejo de excretas de los toros	- kg CO2 eq

NOTOTCO2RF	Óxido nitroso del manejo de excretas de las hembras de reemplazo	- kg CO2 eq

NOTOTCO2RM	Óxido nitroso del manejo de excretas de los machos de reemplazo	- kg CO2 eq

NOTOTCO2MM	Óxido nitroso del manejo de excretas de los machos de carne	- kg CO2 eq

NOTOTCO2MF	Óxido nitroso del manejo de excretas de las hembras de carne	- kg CO2 eq

NOTOTPASTUREAFM	Óxido nitroso de las excretas sin manejo de las vacas en producción	- kg CO2 eq

NOTOTPASTUREAFN	Óxido nitroso de las excretas sin manejo de las vacas secas	- kg CO2 eq

NOTOTPASTUREAM	Óxido nitroso de las excretas sin manejo de los toros	- kg CO2 eq

NOTOTPASTURERF	Óxido nitroso de las excretas sin manejo de las hembras de reemplazo	- kg CO2 eq

NOTOTPASTURERM	Óxido nitroso de las excretas sin manejo de los machos de reemplazo	- kg CO2 eq

NOTOTPASTUREMM	Óxido nitroso de las excretas sin manejo de los machos de carne	- kg CO2 eq

NOTOTPASTUREMF	Óxido nitroso de las excretas sin manejo de las hembras de carne	- kg CO2 eq

CH4_from_enteric_fermentation	Total de metano de la fermentación entérica	- kg CO2 eq

CH4_from_manure_management	Total de metano del manejo de excretas	- kg CO2 eq

N2O_from_manure_management	Total de óxido nitroso del manejo de excretas	- kg CO2 eq

N2O_from_pasture	Total de óxido nitroso de las excretas sin manejos	- kg CO2 eq

TOTAL_EMISSIONS	Total de emisiones	- kg CO2 eq

MILK_INTENSITY	Intensidad de emisiones en leche 	- kg CO2 eq / litro de leche

MEAT_INTENSITY	Intensidad de emisiones en carne -	kg CO2 eq / kg carne a la canal


A continuación, se hace una descripción de la matriz de resultados del modelamiento del hato de la herramienta (herd_total.csv)

Variables	Descripción -	Unidades

REGION	Se enumeran las 3 regiones del Ecuador	

ESTRATO	Tipo de sistema productivo	

PRODUCTO	Tipo de producción	

AFEXIT	Número de hembras adultas que salen	- número

AMEXIT	Número de machos adultos que salen	- número

MFEXIT	Número de hembras de carne que salen	- número

MMEXIT	Número de machos de carne que salen	- número

RFEXIT	Número de hembras de reemplazo que salen	- número

Milk_production	Producción de leche	litros de leche

Meat_production_FF	Producción de carne de salida de animales adultos hembras	- kg carne a la canal

Meat_production_FM	Producción de carne de salida de animales adultos machos	- kg carne a la canal

Meat_production_M	Producción de carne de animales jóvenes sacrificados	- kg carne a la canal

Meat_total	Total de producción de carne	- kg carne a la canal

AF	Número total de vacas en el año	- número

AM	Número total de toros en el año	- número

RF	Número total de hembras de reemplazo en el año	- número

RM	Número total de machos de reemplazo en el año	- número

MM	Número total de machos de carne en el año	- número

MF	Número total de hembras de carne en el año	- número

TOTAL_HERD	Total de animales en el año	- número

 

1.6.	REFERENCIAS

BIBLIOGRAFIA

FAO (2017a). Global Livestock Environmental Assessment Model (GLEAM).

FAO (2017b). Livestock solutions for climate change. Tomado de http://www.fao.org/3/a-i8098e.pdf

Fick, S.E. and R.J. Hijmans, 2017. Worldclim 2: New 1-km spatial resolution climate surfaces for global land areas. International Journal of Climatology.

Gilbert, Marius; Nicolas, Gaëlle; Cinardi, Giusepina; Van Boeckel, Thomas P.; Vanwambeke, Sophie; Wint, William G. R.; Robinson, Timothy P., 2018, "Global cattle distribution in 2010 (5 minutes of arc)", https://doi.org/10.7910/DVN/GIVQ75, Harvard Dataverse, V3

MAGAP & PRAT. (2008). Metodología de valoración de tierras rurales–Propuesta.

SIGTIERRAS. (2016). Manual para el usuario: Levantamiento de cartografía temática escala 1:25000, lotes 1 y 2, versión 2.0. Quito - Ecuador.
