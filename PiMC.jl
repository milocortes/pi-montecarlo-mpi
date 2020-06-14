## PiMC.jl

#### Ejecutar. El último argumento indica la cantidad de números aleatorios generados
# time mpirun -np 10 julia PiMC.jl 100000

using MPI
using LinearAlgebra
using Statistics
using Random
using SharedArrays


MPI.Init()
comm = MPI.COMM_WORLD
rank = MPI.Comm_rank(comm)
size = MPI.Comm_size(comm)
n=parse(Int,ARGS[1])
elements=Int(floor(n/size))

puntos_totales=size*elements

root = 0

### Función para calcular los puntos en el circulo
function compute_points(arregloUno,arregloDos,N)
    count=0
    for i=1:N
        r2 = arregloUno[i]^2 + arregloDos[i]^2
        if r2<1.0
            count+=1
        end
    end
    return count

end

if rank == root
   
    #Definimos una semilla
    rng_x = MersenneTwister(1234);
    rng_y = MersenneTwister(5678);
    #Definimos el arreglo de números aleatorios	
    data_x=(rand(rng_x,n))
    data_y=(rand(rng_y,n))
    
else
    data_x = zeros(Float64, 1, elements)
    data_y = zeros(Float64, 1, elements)

end

data_x = MPI.Scatter(data_x,elements,root, comm)
data_y = MPI.Scatter(data_y,elements,root, comm)

### Calculamos los puntos dentro del círculo unitario
n_in_circle=compute_points(data_x,data_y,elements)


### Realizamos el reduce
sr = MPI.Reduce(n_in_circle, +, root, comm)	

println("Procesador $rank . Puntos recibidos: $elements . Puntos dentro del círculo: $n_in_circle")	



if rank == root
   ## Calculamos pi
   pi_est=(sr/puntos_totales)*4.0	
   println(" ")
   println("Suma total de puntos dentro del círculo: $sr")
   println("Puntos totales: $puntos_totales")	
   println("La aproximación de pi es : $pi_est")		
	
end	

MPI.Finalize()





