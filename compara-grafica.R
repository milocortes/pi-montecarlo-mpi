#### Limpiamos el entorno de trabajo
rm(list = ls())

library(ggplot2)
library(sqldf)
library(reshape)

#### Leemos el txt

datos<-read.table("output_time.txt",sep=",", col.names=c("procesos","iteracion","lenguaje","real_time","user_time","system_time","cpu_percent") )

###  "procesos"    "lenguaje"    "real_time"   "user_time"   "system_time" "cpu_percent"
datos<- datos[,c( "procesos","lenguaje","real_time")]

datos$lenguaje<-gsub(" ","",datos$lenguaje)

consulta<-paste('SELECT procesos, lenguaje, 
  AVG(real_time) as real_time_mean, 
  MIN(real_time) as real_time_min,
  MAX(real_time) as real_time_max,
  STDEV(real_time) as real_time_std FROM datos 
  GROUP BY procesos, lenguaje')

sub_data_group<-sqldf(consulta)

sub_data_group_real_time_mean<-cast(sub_data_group[,c("procesos" ,"lenguaje","real_time_mean" )],procesos~lenguaje)

sub_data_group_real_time_mean<-subset(sub_data_group_real_time_mean,sub_data_group_real_time_mean$procesos!=3 & sub_data_group_real_time_mean$procesos!=6 & sub_data_group_real_time_mean$procesos!=7 & sub_data_group_real_time_mean$procesos!=9)


ggplot(sub_data_group_real_time_mean, aes(x = procesos))+
  geom_line(aes(y =`C++` , colour = "C++"))+
  geom_line(aes(y =Julia , colour = "Julia"))+
  geom_line(aes(y = Python/10, colour = "Python"))+ 
  scale_y_continuous(sec.axis = sec_axis(~.*10, name = "Segundos (Python)"))+
  scale_colour_manual(values=c('#0661A5','#E69F00','red'))+
  labs(
    y = "Segundos (C++ y Julia)",
    x = "Número de procesos",
    title=expression("Estimación de "~pi~" con el método Monte Carlo con MPI (Message Passing Interface)"),
    subtitle = "Puntos aleatorios generados (N)= 100,000,000",
    colour = "Lenguajes"
  )+theme_minimal()



