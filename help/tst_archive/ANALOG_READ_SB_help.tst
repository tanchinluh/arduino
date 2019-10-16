\name
ANALOG_READ_SB

\palette
Arduino

\smalldescription
Permet de réaliser l'acquisition d'une grandeur analogique sur le port Analogique d'une carte Arduino.

\description
La carte Arduino UNO possède 6 ports d'entrées analogiques (de A0 à A5), la carte Arduino Mega possède 16 ports d'entrée analogique (de A0 à A15). Le bloc proposé permet de transmettre la valeur numérique codée sur 10 bits (de 0 à 1023) d'une grandeur analogique associée à un port d'entrée.
On rappelle que l'échantillonnage est de 8 ms au minimum pour ce bloc.

\dialogbox
\image{ANALOG_READ_SB_dialogbox.png}
Le numéro du port de 0 à 5 doit être spécifié pour la carte UNO, de 0 à 15 pour une carte MEGA.
Le numéro de la carte ne peut pas être modifié pour l'instant.
Il n'y a pas de vérification de la valeur donnée, veuillez vous reporter à la spécification de votre carte Arduino pour mettre une valeur correcte.

\example1
L'exemple ci-dessous montre l'utilisation du bloc dans le cas d'un potentiomètre angulaire dont la broche de mesure est connectée au port 2. Les deux autres broches du potentiomètre sont reliées à la masse (GND) et le 5 Volt de la carte directement.
\image{ANALOG_READ_example.png}

\seealso
ANALOG_WRITE_SB
DIGITAL_READ_SB
DIGITAL_WRITE_SB
