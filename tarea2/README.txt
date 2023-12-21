README.txt

Tarea 2 - BAG

Esta carpeta contiene los scripts y demás datos necesarios para
llevar a cabo un análisis de los datos de un experimento de ChIP-Seq.

FLUJO DE TRABAJO:

En primer lugar se cargan las muestras mediante el reconocimiento de
sus ubicaciones tal y como se debe especificar en el fichero params.txt.
De igual manera se obtienen el número de inputs (inputs o mocks) y de muestras.
Además se especifica si el análisis se debe ejecutar para factores de
transcripción o marcas epigenéticas.

A continuación se crea el espacio de trabajo separado en distintas carpetas. Las carpetas genome
y annotation contienen el genoma y su índice respectivamente para la comparación con las muestras.
La carpeta samples contiene las muestras en la subcarpeta chip y los inputs en la subcarpeta input.
Dentro de estas subcarpetas hay tantas carpetas como muestras o inputs, cada una con su fichero
muestra o input.Finalmente, todos los archivos resultantes del análisis se guardan en la carpeta results.

Posteriormente se lleva a cabo la creación del índice del genoma y se llama a sbatch para
ejecutar al siguiente script. Por un lado se llama a sample_proc.sh para procesar las
muestras y paralelamente a input_proc.sh para los inputs. La ejecución de los scripts
ocurre paralelamente por el gestor de colas SLURM.

En ambos casos se procede al análisis de calidad de las muestras e inputs y posteriormente
al mapeo de las lecturas. Cuando todas las muestras e inputs han sido procesadas se llama
a sbatch para la ejecución del último script, peak_calling.sh.

En este script, en primer lugar se unifican los inputs en un merge, en el caso de que haya
más de un input. Seguidamente se determinan los picos de cada muestra mediante su comparación
con el merge. En el caso de que haya más de una muestra se hace una intersección de los
archivos .narrowPeak resultantes, o .broadPeak en el caso de modificaciones epigenéticas.
Con este único archivo .narrowPeak o .broadPeak se procede a la
ejecución del script de R para llevar a cabo el análisis matemático-computacional de los datos,
que incluye análisis de distribución global del cistroma y determinación del reguloma,
así como su análisis de enriquecimiento funcional. Por último y solo en el caso de que se
trabaje con un factor de transcripción, tal y como se debe especificar en params.txt, se utiliza
la herramienta HOMER para realizar un análisis de enriquecimiento de motivos de ADN en los sitios
de unión de dicho factor de transcripción.


INSTRUCCIONES DE USO:

El primer paso para el uso de estos scripts es la modificación del fichero de texto params.txt
incluido en la carpeta test. Este fichero contiene:

"path_input_x: "ruta global al fichero input número x.
"path_sample_y: "ruta global al fichero sample número y.
"path_genome: "ruta global al fichero del genoma.
"path_annotation: "ruta global al fichero de la anotación del genoma.
"experiment_name: "nombre de la carpeta del experimento resultante
"working_directory: "ruta global al directorio de trabajo donde se crea el espacio de trabajo.
"installation_directory: "ruta global al directorio de instalación donde se encuentran los scripts.
"number_of_inputs: "número de inputs.
"number_of_samples: "número de muestras.
"transcription_factor(Y/N): "especificación de si se trabaja con factores de transcripción (Y)
o con marcas epigenéticas (N).

Las comillas determinan la parte no modificable del fichero, a excepción de x e y que son cifras
en path_input_x y path_sample_y, que irán cambiando en función del número pertinente de input y
muestra respectivamente. Se advierte que se debe dejar un espacio siempre después de los dos puntos
(:) antes de añadir el contenido, tal como estipulan las comillas.
"number_of_inputs: " y "number_of_samples: " reciben cifras, no texto.
"transcription_factor(Y/N): " solo recibe y griega mayúscula (Y) o n mayúscula (N). Cualquier
otro dato va a interrumpir la ejecución de scripts.

Finalmente para llevar a cabo los scripts se debe ejecutar solo el primero que es "chip_var.sh", el
único ejecutable. Este script necesita del fichero params.txt modificado tal como se ha indicado y
ubicado en la carpeta test. En MobaXterm esta ejecución se llevaría a cabo mediante la siguiente instrucción:
./chip_var.sh test/params.txt