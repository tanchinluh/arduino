\name
INTERRUPT_SB

\palette
Arduino

\smalldescription
Permet de compter un ensemble d'événements sur une ou plusieurs voies.

\description
Il s'agit de lire un compteur qui compte l'information issue de capteurs de position absolue (capteur à effet Hall...).
Le bloc permet de lire les fronts montants détectés sur les entrées à interruptions disponibles de la carte Arduino. Ce sont des entrées capables d’arrêter le programme principal lors d'un changement d’état (fronts d'un signal) afin d’exécuter un sous-programme. Ce sous-programme consiste dans ce cas à incrémenter un compteur. 
Les pins 2 et 3 sont les seuls pins de l'Arduino Uno supportant les interruptions. Sur la carte Mega, les pins sont 2, 3 et 18 à 21. 
On rappelle que l'échantillonnage est de 8 ms au minimum pour ce bloc.

\dialogbox

Le bloc propose un menu qui permet la déclaration du pin d'interruption 2 ou 3 sur une carte UNO (2, 3 ou 18 à 21 pour la carte MEGA) et déclaration d'un pin digital quelconque de 2 à 13 pour une carte UNO (2 à 53 pour la carte MEGA).
Le numéro de la carte ne peut pas être modifié pour l'instant.
\image{INTERRUPT_SB_dialogbox.png}


\example1
L'exemple ci-dessous montre l'utilisation du bloc pour compter le signal d'une fourche optique connecté sur le pin 3.
\image{INTERRUPT_exemple.png}

\seealso
ENCODER_SB
