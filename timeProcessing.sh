#!/bin/bash
touch output_time.txt

for i in   1 2 3 4 5 6 7 8 9 10

do

echo "************************************"
echo "Procesos "$i

for j in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
do

echo "Iteración "$j

### Tiempos de ejecución para el .cpp
output_time_cpp="$( TIMEFORMAT='%R ,%U ,%S ,%P';time ( mpiexec -np $i PiMC 100000000 ) 2>&1 1>/dev/null )"

### Tiempos de ejecución para el .jl
output_time_jl="$( TIMEFORMAT='%R ,%U ,%S ,%P';time ( mpirun -np $i julia PiMC.jl 100000000 ) 2>&1 1>/dev/null )"

### Guardaremos la salida NumProc, lenguaje, Real time, User time, System time, CPU percent
echo "$i,$j, C++,$output_time_cpp">>output_time.txt
echo "$i,$j, Julia,$output_time_jl">>output_time.txt

done

done
