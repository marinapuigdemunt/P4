PAV - P4: reconocimiento y verificación del locutor
===================================================

Obtenga su copia del repositorio de la práctica accediendo a [Práctica 4](https://github.com/albino-pav/P4)
y pulsando sobre el botón `Fork` situado en la esquina superior derecha. A continuación, siga las
instrucciones de la [Práctica 2](https://github.com/albino-pav/P2) para crear una rama con el apellido de
los integrantes del grupo de prácticas, dar de alta al resto de integrantes como colaboradores del proyecto
y crear la copias locales del repositorio.

También debe descomprimir, en el directorio `PAV/P4`, el fichero [db_8mu.tgz](https://atenea.upc.edu/mod/resource/view.php?id=3654387?forcedownload=1)
con la base de datos oral que se utilizará en la parte experimental de la práctica.

Como entrega deberá realizar un *pull request* con el contenido de su copia del repositorio. Recuerde
que los ficheros entregados deberán estar en condiciones de ser ejecutados con sólo ejecutar:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.sh
  make release
  run_spkid mfcc train test classerr verify verifyerr
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Recuerde que, además de los trabajos indicados en esta parte básica, también deberá realizar un proyecto
de ampliación, del cual deberá subir una memoria explicativa a Atenea y los ficheros correspondientes al
repositorio de la práctica.

A modo de memoria de la parte básica, complete, en este mismo documento y usando el formato *markdown*, los
ejercicios indicados.

## Ejercicios.

### SPTK, Sox y los scripts de extracción de características.

- Analice el script `wav2lp.sh` y explique la misión de los distintos comandos involucrados en el *pipeline*
  principal (`sox`, `$X2X`, `$FRAME`, `$WINDOW` y `$LPC`). Explique el significado de cada una de las 
  opciones empleadas y de sus valores.

- Explique el procedimiento seguido para obtener un fichero de formato *fmatrix* a partir de los ficheros de
  salida de SPTK (líneas 45 a 51 del script `wav2lp.sh`).

  * ¿Por qué es más conveniente el formato *fmatrix* que el SPTK?

- Escriba el *pipeline* principal usado para calcular los coeficientes cepstrales de predicción lineal
  (LPCC) en su fichero <code>scripts/wav2lpcc.sh</code>:
```bash
sox $inputfile -t raw - dither -p 12 | $X2X +sf | $FRAME -l 200 -p 40 | $WINDOW -l 200 -L 200 |
	$LPC -l 240 -m $lpc_order | $LPC2C -m $lpc_order -M $cepstrum_order  > $base.lpcc
```
  
- Escriba el *pipeline* principal usado para calcular los coeficientes cepstrales en escala Mel (MFCC) en su
  fichero <code>scripts/wav2mfcc.sh</code>:
```bash
   sox $inputfile -t raw -e signed -b 16 - | $X2X +sf | $FRAME -l 200 -p 40 |
    $MFCC -l 200 -m $mfcc_order -n $mfcc_order_channel_melfilterbank -s 8 -w 0 > $base.mfcc
 ```

### Extracción de características.

- Inserte una imagen mostrando la dependencia entre los coeficientes 2 y 3 de las tres parametrizaciones
  para todas las señales de un locutor.
  
  + Indique **todas** las órdenes necesarias para obtener las gráficas a partir de las señales 
    parametrizadas.
    
Primero hemos convertido a texto los coeficientes 2 y 3 del fichero de parámetros del locutor SES017:

LP:
```bash
fmatrix_show work/lp/BLOCK01/SES017/*.lp | egrep '^\[' | cut -f4,5 > lp_2_3.txt
```
LPCC:
```bash
fmatrix_show work/lpcc/BLOCK01/SES017/*.lpcc | egrep '^\[' | cut -f4,5 > lpcc_2_3.txt
```
MFCC:
```bash
fmatrix_show work/mfcc/BLOCK01/SES017/*.mfcc | egrep '^\[' | cut -f4,5 > mfcc_2_3.txt
```

A continuación hemos creado las 3 gráficas mediante el siguiente script de MATLAB:
```bash
%%Gráficas

%LP
fileID_lp = fopen('lp_2_3.txt','r');
formatSpec_lp = '%f %f';
size_lp = [2 Inf];
lp_transp = fscanf(fileID_lp,formatSpec_lp, size_lp);
lp = lp_transp';

lp_coef_2 = lp(:, 1);
lp_coef_3 = lp(:, 2);

subplot(3,1,1);
plot(lp_coef_2,lp_coef_3,"*")
title('Dependencia entre los coeficientes 2 y 3 de la parametrización LP del locutor 17')
xlabel("Coeficiente 2")
ylabel("Coeficiente 3")

%LPCC
fileID_lpcc = fopen('lpcc_2_3.txt','r');
formatSpec_lpcc = '%f %f';
size_lpcc = [2 Inf];
lpcc_transp = fscanf(fileID_lpcc,formatSpec_lpcc, size_lpcc);
lpcc = lpcc_transp';

lpcc_coef_2 = lpcc(:, 1);
lpcc_coef_3 = lpcc(:, 2);

subplot(3,1,2);
plot(lpcc_coef_2,lpcc_coef_3,"*")
title('Dependencia entre los coeficientes 2 y 3 de la parametrización LPCC del locutor 17')
xlabel("Coeficiente 2")
ylabel("Coeficiente 3")

%MFCC
fileID_mfcc = fopen('mfcc_2_3.txt','r');
formatSpec_mfcc = '%f %f';
size_mfcc = [2 Inf];
mfcc_transp = fscanf(fileID_mfcc,formatSpec_mfcc, size_mfcc);
mfcc = mfcc_transp';

mfcc_coef_2 = mfcc(:, 1);
mfcc_coef_3 = mfcc(:, 2);

subplot(3,1,3);
plot(mfcc_coef_2,mfcc_coef_3,"*")
title('Dependencia entre los coeficientes 2 y 3 de la parametrización MFCC del locutor 17')
xlabel("Coeficiente 2")
ylabel("Coeficiente 3")
```

![foto](https://github.com/marinapuigdemunt/P4/assets/125259801/1da93223-46c4-45c8-ac09-b4ec2e1a13a3)


  + ¿Cuál de ellas le parece que contiene más información?

Para saber cual contiene más información nos fijamos en los puntos de las gráficas. Cuanto más separados estén más incorrelados estarán y por tanto, aportarán más información. 

Si observamos la gráfica de la LP vemos que los puntos forman una especie de recta, por lo tanto, conociendo uno de los dos coeficientes podemos determinar el valor del otro. Así que con solo uno de los dos, obtendríamos la misma información que con ambos.

En cambio, las gráficas de la LPCC y MFCC tienen sus puntos mucho mejor distribuidos en los ejes, pero claramente se ve que la MFCC está mucho más incorrelada y por lo tanto, es la que contiene más información.

- Usando el programa <code>pearson</code>, obtenga los coeficientes de correlación normalizada entre los
  parámetros 2 y 3 para un locutor, y rellene la tabla siguiente con los valores obtenidos.

LP: ``pearson work/lp/BLOCK01/SES017/*.lp``

![image](https://github.com/marinapuigdemunt/P4/assets/125259801/c9403217-e709-487c-9dbc-53047d7bc361)

LPCC: ``pearson work/lpcc/BLOCK01/SES017/*.lpcc``

![image](https://github.com/marinapuigdemunt/P4/assets/125259801/0fce67c7-d64d-40dd-8762-1b97120825aa)

MFCC: ``pearson work/mfcc/BLOCK01/SES017/*.mfcc``

![image](https://github.com/marinapuigdemunt/P4/assets/125259801/973b7141-f0bc-4c65-9554-19ed63982b25)



  |                        | LP   | LPCC | MFCC | 
  |------------------------|:----:|:----:|:----:|
  | &rho;<sub>x</sub>[2,3] |   -0.872284   |   -0.0457713   |   -0.203934   |
  
  + Compare los resultados de <code>pearson</code> con los obtenidos gráficamente.
  
En la LP hemos obtenido una rho en valor absoluto bastante cercana a 1, esto implica una alta correlación entre componentes tal y como habíamos visto antes con la gráfica. En cambio, en la LPCC y la MFCC hemos obtenido unos valores muy cercanos a 0 y por lo tanto obtenemos unos coeficientes poco correlados tal y como habíamos observado en las gráficas. Hemos de destacar que sorprendentemente hemos obtenido un valor más cerano a 0 con la LPCC.

- Según la teoría, ¿qué parámetros considera adecuados para el cálculo de los coeficientes LPCC y MFCC?

Según la teoría, para la LPCC el orden típico de coeficientes está entre 8 y 16. En cambio, para la MFCC se eligen entre 12 y 25 coeficientes y el númereo de filtros MEL suele ser entre 20 y 40.

### Entrenamiento y visualización de los GMM.

Complete el código necesario para entrenar modelos GMM.

Para entrenar los modelos de un locutor (por ejemplo el SES017) utilizamos la siguiente orden:

``gmm_train -d work/lp -e lp -g SES017.gmm lists/class/SES017.train``

En cambio, para entrenar los GMM de todos los locutores a la vez utilizamos:

LP: ``FEAT=lp run_spkid train``

LPCC: ``FEAT=lpcc run_spkid train``

MFCC: ``FEAT=mfcc run_spkid train``

- Inserte una gráfica que muestre la función de densidad de probabilidad modelada por el GMM de un locutor
  para sus dos primeros coeficientes de MFCC.

- Inserte una gráfica que permita comparar los modelos y poblaciones de dos locutores distintos (la gŕafica
  de la página 20 del enunciado puede servirle de referencia del resultado deseado). Analice la capacidad
  del modelado GMM para diferenciar las señales de uno y otro.

### Reconocimiento del locutor.

Complete el código necesario para realizar reconociminto del locutor y optimice sus parámetros.

- Inserte una tabla con la tasa de error obtenida en el reconocimiento de los locutores de la base de datos
  SPEECON usando su mejor sistema de reconocimiento para los parámetros LP, LPCC y MFCC.

### Verificación del locutor.

Complete el código necesario para realizar verificación del locutor y optimice sus parámetros.

- Inserte una tabla con el *score* obtenido con su mejor sistema de verificación del locutor en la tarea
  de verificación de SPEECON. La tabla debe incluir el umbral óptimo, el número de falsas alarmas y de
  pérdidas, y el score obtenido usando la parametrización que mejor resultado le hubiera dado en la tarea
  de reconocimiento.
 
### Test final

- Adjunte, en el repositorio de la práctica, los ficheros `class_test.log` y `verif_test.log` 
  correspondientes a la evaluación *ciega* final.

### Trabajo de ampliación.

- Recuerde enviar a Atenea un fichero en formato zip o tgz con la memoria (en formato PDF) con el trabajo 
  realizado como ampliación, así como los ficheros `class_ampl.log` y/o `verif_ampl.log`, obtenidos como 
  resultado del mismo.
