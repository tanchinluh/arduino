\name
DIGITAL_WRITE_SB

\palette
Arduino

\smalldescription
Permet d'envoyer une valeur logique 0 ou 1 sur un port donné.

\description
La carte UNO possède un ensemble de ports logiques (digital) qui sont utilisés pour l'écriture ou la lecture de données issues d'un composant.
Pour une carte UNO, les ports de 2 à 13 sont disponibles (0 et 1 sont utilisés pour la transmission série). Pour une carte MEGA, les ports 2 à 53 sont disponibles. Le port prend le niveau logique bas (0) ou le niveau logique haut (1) qui correspond à la tension de référence.
On rappelle que l'échantillonnage est de 8 ms au minimum pour ce bloc.

\dialogbox
\image{DIGITAL_WRITE_SB_dialogbox.png}
Le numéro du port digital est compris entre 2 et 53, à choisir en fonction de sa carte Arduino.
Le numéro de la carte ne peut pas être modifié pour l'instant.

\example1
L'exemple ci-dessous montre l'utilisation du bloc dans le cas d'un montage constitué d'un interrupteur dont une broche est reliée au port digital 7 et une LED reliée au port digital 10. Un appui sur le bouton entraîne l'allumage de la LED.
\image{DIGITAL_exemple.png}

\seealso
ANALOG_READ_SB
ANALOG_WRITE_SB
DIGITAL_READ_SB
