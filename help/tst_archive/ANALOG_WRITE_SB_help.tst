\name
ANALOG_WRITE_SB

\palette
Arduino

\smalldescription
Permet d'envoyer une valeur continûment variable sur un port donné

\description
Les sorties analogiques de l'Arduino Uno sont disponibles sur les pins de sorties logiques (digital)  3,5,6,9,10 et 11. Sur la carte Mega, les sorties sont sur les pins 1 à 13 et 44 à 46. Parler de sorties analogiques est donc un abus de langage. En effet, pour générer cette sortie en minimisant les pertes d’énergie, l'Arduino utilise des PWM (Pulse With Modulation, MLI en français) disponibles sur ces ports. En faisant varier le rapport cyclique de ces PWM, on modifie la tension moyenne aux bornes du composant connecté à ce port, celui-ci a donc l'impression d'avoir une tension d'entrée variable.
Le rapport cyclique qui théoriquement varie de 0 à 1 est codé sur 8 bits, ainsi une valeur de 0 correspond à un rapport cyclique de 0 et une valeur de 255 à un rapport cyclique de 1.
On rappelle que l'échantillonnage est de 8 ms au minimum pour ce bloc.

\dialogbox
\image{ANALOG_WRITE_SB_dialogbox.png}
Le numéro du port doit être 3, 5, 6, 9, 10, 11 pour une carte UNO (ports ayant le symbole PWM) et doit être de 1 à 13 ou 44 à 46 pour la carte MEGA. L'utilisation d'un port digital provoquera soit la mise à 0 soit la mise à 1 de celui-ci en fonction de la valeur envoyée.
Le numéro de la carte ne peut pas être modifié pour l'instant.

\example1
L'exemple ci-dessous montre l'utilisation du bloc dans le cas d'un variateur de l'intensité lumineuse d'une LED à partir d'une consigne issue d'un potentiomètre. La LED (en série avec une résistance bien choisie) est connectée à la masse (GND) et au port digital 10 tandis que le potentiomètre est connecté sur le port analogique 2. La valeur lue pour le potentiomètre étant codée sur 10 bits et le signal du PWM étant codé sur 8 bits, il est nécessaire d'ajouter une gain d'adaptation.
\image{ANALOG_WRITE_exemple.png}

\seealso
ANALOG_READ_SB
DIGITAL_READ_SB
DIGITAL_WRITE_SB
