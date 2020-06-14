#!/bin/bash

for i in   1 2 4 5 8 10

do

echo "************************************"
echo "Procesos "$i

for j in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
do
echo "Iteración "$j

### Tiempos de ejecución para el .py

output_time_py="$( TIMEFORMAT='%R ,%U ,%S ,%P';time ( mpiexec  -np $i python PiMC.py 100000000 ) 2>&1 1>/dev/null )"

### Guardaremos la salida NumProc, lenguaje, Real time, User time, System time, CPU percent

echo "$i,$j, Python,$output_time_py">>output_time.txt

done

done
