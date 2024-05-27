Monitoring plugins
==================

[![License](https://img.shields.io/:license-gpl-green.svg)](https://www.gnu.org/licenses/gpl-3.0.txt)


Plugins para monitoreo utilizados en NIS.


[[_TOC_]]


# check_docker.sh

Es un programa (script) para verificar el estado de los contenedores Docker


## Invocación del programa

Desde una terminal el programa puede invocarse de la siguiente manera:

<pre>
/usr/lib64/nagios/plugins/check_docker.sh --name gentoo-container
</pre>

Una vez ejecutado el script devolverá los siguientes datos:

<pre>
Ok: Docker container gentoo-container is Up. | online=1;0;0;0;1
</pre>


## Ayuda en línea

El programa cuenta con una ayuda en línea para permitirle al usuario conocer sus capacidades. La ayuda en línea puede invocarse de la siguiente manera:

<pre>
~ # /usr/lib64/nagios/plugins/check_docker.sh --help
check_docker.sh:
Check the status of Docker container.

  Uso: 
       /usr/lib64/nagios/plugins/check_docker.sh [-h|--help]
       /usr/lib64/nagios/plugins/check_docker.sh [-n|--name] DOCKER

       --help, -h
           Show this help.

       --name, -n
           Parameter to pass the name of the docker container.

       DOCKER
           Name of the docker container to examine.

</pre>



# check_docker_cpu.sh

Es un programa (script) para verificar el uso de procesador por un contenedor Docker.


## Invocación del programa

Desde una terminal el programa puede invocarse de la siguiente manera:

<pre>
/usr/lib64/nagios/plugins/check_docker_cpu.sh --name gentoo-container
</pre>

Una vez ejecutado el script devolverá los siguientes datos:

<pre>
CPU OK: 0.01% used. | TOTAL=100;;;0;100 gentoo-container=0.01;;;0;100
</pre>


## Ayuda en línea

El programa cuenta con una ayuda en línea para permitirle al usuario conocer sus capacidades. La ayuda en línea puede invocarse de la siguiente manera:

<pre>
~ # /usr/lib64/nagios/plugins/check_docker_cpu.sh --help
check_docker_cpu.sh:
Check the CPU used by a Docker container.

  Uso: 
       /usr/lib64/nagios/plugins/check_docker_cpu.sh [-h|--help]
       /usr/lib64/nagios/plugins/check_docker_cpu.sh [-c|--critical] CRITICAL [-n|--name] DOCKER [-w|--warning] WARNING

       --help, -h
           Show this help.

       --critical, -c
           Parameter to pass critical CPU percentage value.

       CRITICAL
           Critical CPU percentage.


       --name, -n
           Parameter to pass the name of the docker container.

       DOCKER
           Name of the docker container to examine.


       --warning, -w
           Parameter to pass warning CPU percentage value.

       WARNING
           Warning CPU percentage.

</pre>



# check_docker_disk.sh

Es un programa (script) para verificar el espacio en disco utilizado por un contenedor Docker.


## Invocación del programa

Desde una terminal el programa puede invocarse de la siguiente manera:

<pre>
/usr/lib64/nagios/plugins/check_docker_disk.sh --name gentoo-container
</pre>

Una vez ejecutado el script devolverá los siguientes datos:

<pre>
DISK OK: 1.92MB (virtual 3.16GB) used. | TOTAL=8349229056;;;0;8349229056 gentoo-container=3166417419;6679383244;7514306150;0;8349229056
</pre>


## Ayuda en línea

El programa cuenta con una ayuda en línea para permitirle al usuario conocer sus capacidades. La ayuda en línea puede invocarse de la siguiente manera:

<pre>
~ # /usr/lib64/nagios/plugins/check_docker_disk.sh --help
check_docker_disk.sh:
Check the disk size used by a Docker container.

  Uso: 
       /usr/lib64/nagios/plugins/check_docker_disk.sh [-h|--help]
       /usr/lib64/nagios/plugins/check_docker_disk.sh [-c|--critical] CRITICAL [-n|--name] DOCKER [-w|--warning] WARNING

       --help, -h
           Show this help.

       --critical, -c
           Parameter to pass critical disk size percentage value.

       CRITICAL
           Critical disk size percentage.


       --name, -n
           Parameter to pass the name of the docker container.

       DOCKER
           Name of the docker container to examine.


       --warning, -w
           Parameter to pass warning disk size percentage value.

       WARNING
           Warning disk size percentage.

</pre>



# check_docker_mem.sh

Es un programa (script) para verificar la memoria utilizada por un contenedor Docker.


## Invocación del programa

Desde una terminal el programa puede invocarse de la siguiente manera:

<pre>
/usr/lib64/nagios/plugins/check_docker_mem.sh --name gentoo-container
</pre>

Una vez ejecutado el script devolverá los siguientes datos:

<pre>
MEMORY OK: 35.89MiB / 988.4MiB - 3.63% used. | TOTAL=1036447744;;;0;1036447744 gentoo-odoo-1=37634048;829158195;932802969;0;1036447744
</pre>


## Ayuda en línea

El programa cuenta con una ayuda en línea para permitirle al usuario conocer sus capacidades. La ayuda en línea puede invocarse de la siguiente manera:

<pre>
~ # /usr/lib64/nagios/plugins/check_docker_mem.sh --help
check_docker_mem.sh:
Check the memory used by a Docker container.

  Uso: 
       /usr/lib64/nagios/plugins/check_docker_mem.sh [-h|--help]
       /usr/lib64/nagios/plugins/check_docker_mem.sh [-c|--critical] CRITICAL [-n|--name] DOCKER [-w|--warning] WARNING

       --help, -h
           Show this help.

       --critical, -c
           Parameter to pass critical memory percentage value.

       CRITICAL
           Critical memory percentage.


       --name, -n
           Parameter to pass the name of the docker container.

       DOCKER
           Name of the docker container to examine.


       --warning, -w
           Parameter to pass warning memory percentage value.

       WARNING
           Warning memory percentage.

</pre>



# check_nvme_temp.sh

Es un programa (script) para verificar para verificar la temperatura utilizada por una unidad de almacenamiento NVME.


## Invocación del programa

Desde una terminal el programa puede invocarse de la siguiente manera:

<pre>
/usr/lib64/nagios/plugins/check_nvme_temp.sh --device /dev/nvme0
</pre>

Una vez ejecutado el script devolverá los siguientes datos:

<pre>
Temp OK: the /dev/nvme0 drive is at 29.85°C. | TEMP=29.85;80;100;0;0
</pre>


## Ayuda en línea

El programa cuenta con una ayuda en línea para permitirle al usuario conocer sus capacidades. La ayuda en línea puede invocarse de la siguiente manera:

<pre>
~ # /usr/lib64/nagios/plugins/check_nvme_temp.sh --help
check_nvme_temp.sh:
Checks the temperature used by an NVME storage drive.

  Uso: 
       /usr/lib64/nagios/plugins/check_nvme_temp.sh [-h|--help]
       /usr/lib64/nagios/plugins/check_nvme_temp.sh [-c|--critical] CRITICAL [-d|--device] NVME [-w|--warning] WARNING

       --help, -h
           Show this help.

       --critical, -c
           Parameter to pass critical temperature in degrees Celsius value.

       CRITICAL
           Critical temperature in degrees Celsius.


       --device, -d
           Parameter to indicate the NVME storage unit to monitor.

       NVME
           NVME storage drive, for example /dev/nvme0.


       --warning, -w
           Parameter to pass warning temperature in degrees Celsius value.

       WARNING
           Warning temperature in degrees Celsius.

</pre>

