\name
DCMOTOR_SB

\palette
Arduino

\smalldescription
Permet de piloter un hacheur (relié à un moteur)

\description
Le bloc DCMOTOR permet de piloter 1 ou plusieurs moteurs à courant continu. La carte Arduino ne délivre pas suffisamment de puissance, c'est pourquoi il est nécessaire d'utiliser un préactionneur de type hacheur en amont du moteur. Il existe plusieurs types de hacheurs qui ne fonctionnent pas tous selon le même principe. Le L298 nécessite par exemple l'utilisation d'un PWM et d'un signal logique spécifiant le sens. Le L293 utilise deux PWM pour spécifier la vitesse et le sens. Des cartes prêtes à l'emploi sont également disponibles.
C'est pourquoi le bloc permet de choisir le type de carte ou de hacheur utilisé et en fonction du choix, un menu propose de spécifier les caractéristiques de chaque composant (numéro des ports utilisés ou bien numéro du moteur...)
On rappelle que le PWM est codé sur 8 bits (de 0 à 255). 
Cependant en entrée du bloc, il est possible d'entrer un nombre positif ou négatif quelconque, une saturation logicielle à +- 255 est integrée dans la définition du bloc.
On rappelle que l'échantillonnage est de 8 ms au minimum pour ce bloc.

\dialogbox

Le bloc propose deux menus. 
Le premier permet de choisir le type de carte utilisé : 
1 pour la carte officielle Motorshield Reverse 3 disponible sur le site arduino.cc, 
2 pour un hacheur L298 utilisant un PWM et un sens, 
3 pour un hacheur L293 utilisant deux PWM
Le numéro de la carte ne peut pas être modifié pour l'instant.
\image{DCMOTOR_SB_dialogbox1.png}

Le second menu est spécifique au type de carte retenue
Pour la carte Motorshield on renseigne le numéro 1 ou 2 pour le moteur A ou B
\image{DCMOTOR_SB_dialogbox2.png}
Pour le L298, on renseigne le numéro du port de spécification du sens (n'importe quel port digital), le numéro du port PWM pour la vitesse (3,5,6,9,10,11) et le numéro du moteur piloté (limité de 1 à 4)
\image{DCMOTOR_SB_dialogbox3.png}
Pour le L293, on renseigne les numéros des 2 PWM et le numéro du moteur (de 1 à 3)
\image{DCMOTOR_SB_dialogbox1.png}

\example1
L'exemple ci-dessous montre l'utilisation du bloc moteur associé à un potentiomètre. Lorsque le potentiomètre est en position médiane, le moteur ne tourne pas tandis que lorsque le potentiomètre est tourné dans un sens ou dans l'autre, le moteur tourne plus ou moins vite dans un sens ou dans l'autre. 
Un gain d'adaptation a été utilisé pour convertir les données numériques codées sur 10 bits et l'entrée moteur codée sur 8 bits.
\image{DCMOTOR_exemple.png}

\seealso
ENCODER_SB
SERVO_WRITE_SB
