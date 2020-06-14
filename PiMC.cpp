//PiMC.cpp

// Compilar
// mpicxx PiMC.cpp -o PiMC

// Ejecutar. El último argumento indica el número de números aleatorios a generar
// time mpiexec -np 10 PiMC 10000


#include <iostream>
#include <mpi.h>
#include<vector> // Para vector
#include <algorithm>    // Para generate
#include <cstdlib>      // std::rand, std::srand

using namespace std;

int compara(float x, float y){
    float valor=x*x+y*y;
    if (valor<1.0) {
      return 1;
    }
    return 0;
}

int main(int argc, char const *argv[]) {


  MPI::Init();

  int rank = MPI::COMM_WORLD.Get_rank();
  int size = MPI::COMM_WORLD.Get_size();

  int N=atoi(argv[1]);;
  int chunk=N/size;
  int conteo=0;

  vector<float> data_x(N);
  vector<float> data_y(N);

  // El nodo 0 se encarga de llenar el arreglo de números aleatorios
  if (rank == 0) {
    std::generate(data_x.begin(), data_x.end(), [](){return ((float) rand()/RAND_MAX);});

    std::generate(data_y.begin(), data_y.end(), [](){return ((float) rand()/RAND_MAX);});

  }

  // Para cada proceso, creamos un buffer que almacenará subconjuntos del arreglo principal

  vector<float> sub_rand_nums_x(chunk);
  vector<float> sub_rand_nums_y(chunk);

  //  Realizamos la operación Scatter para enviar los números aleatorios generados por el maestro al resto de los procesos
  MPI_Scatter(data_x.data(), chunk, MPI_FLOAT, sub_rand_nums_x.data(),
              N, MPI_FLOAT, 0, MPI_COMM_WORLD);

  MPI_Scatter(data_y.data(), chunk, MPI_FLOAT, sub_rand_nums_y.data(),
              N, MPI_FLOAT, 0, MPI_COMM_WORLD);


   std::transform (sub_rand_nums_x.begin(), sub_rand_nums_x.end(), sub_rand_nums_y.begin(), sub_rand_nums_x.begin(),[&conteo](float x, float y) { return  conteo=compara(x,y) + conteo ; });

   std::cout<<"Proceso "<<rank;
   std::cout<<". Puntos recibidos "<< chunk <<". Puntos dentro del círculo "<< conteo<<std::endl;

   // Utilizamos la operación de Reduce para reunir las sumas locales en una suma global
   int global_sum;
   MPI_Reduce(&conteo, &global_sum, 1, MPI_INT, MPI_SUM, 0,MPI_COMM_WORLD);

   // Imprimimos los resultados
   if (rank == 0) {
	float pi_estimate= ((float)global_sum/N)*4;
	std::cout<<"La estimacíón de pi es : " <<pi_estimate<<std::endl;
   }

   MPI::Finalize();

  return 0;
}

// Compilar
// mpicxx PiMC.cpp -o PiMC

// Ejecutar
// time mpiexec -np 10 PiMC 10000
