# PiMC.py
### Ejecutar. El último argumento indica la cantidad de números aleatorios generados
### time mpiexec  --oversubscribe -np 10 python PiMC.py 100000

# Cargamos la librerías
import numpy as np
import matplotlib.pyplot as plt
import functools 
import sys
import random

# MPI
from mpi4py import MPI


comm = MPI.COMM_WORLD
rank=comm.rank
size=comm.size
n=int(sys.argv[1])

### EL proceso 1 será el especializado en generar números aleatorios 
if rank == 0:
    data_x = np.array([random.random() for x in range(n)]) 
    data_y = np.array([random.random() for x in range(n)])

else:
    data_x = None
    data_y = None
### Aquí usamos el scatter para distribuir los datos
chunk_x= np.zeros(int((n/size)))
chunk_y= np.zeros(int((n/size)))

comm.Scatter(data_x,chunk_x,root=0)
comm.Scatter(data_y,chunk_y,root=0)

### Definimos un contador para almacenar los puntos que caen dentro del círculo unitario
count = 0

for x, y in zip(chunk_x,chunk_y) :
  if x * x + y * y < 1:
    count += 1

print('Procesador '+str(rank)+'. Puntos recibidos ', int((n/size)),'. Puntos dento del círculo: '+ str(count))

### La suma global la recibirá el maestro y la mostrará en pantalla 
global_sum = comm.reduce (count , op = MPI .SUM , root =0) 


if rank == 0:
   pi_est=(global_sum/int(sys.argv[1]))*4
   print('Suma total de puntos dentro del círculo: '+ str(global_sum))
   print('Puntos totales: '+str(sys.argv[1]))
   print('La aproximación de pi es: '+str(pi_est))


