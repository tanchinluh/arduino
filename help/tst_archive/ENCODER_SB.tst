\name
ENCODER_SB

\palette
Arduino

\smalldescription
Permet de compter un ensemble d'événements sur une ou plusieurs voies.

\description
Beaucoup de capteurs (codeur incrémental, capteur à effet Hall...) renvoient un signal créneau pour lequel on souhaite compter les fronts. Le bloc permet de réaliser cette opération pour un ou deux codeurs. On utilise pour cela les interruptions disponibles sur la carte Arduino. Ce sont des entrées capables d’arrêter le programme principal lors d'un changement d’état (fronts d'un signal) afin d’exécuter un sous-programme. Ce sous-programme consiste dans ce cas à incrémenter ou décrémenter un compteur. 
Les pins 2 et 3 sont les seuls pins de l'Arduino Uno supportant les interruptions. Sur la carte Mega, les pins sont 2, 3 et 18 à 21. Il est nécessaire d'utiliser un signal supplémentaire pour connaître le sens du codeur.
Ainsi, le bloc offre la possibilité de fonctionner un codeur en quadrature, il faut alors que les deux voies soient câblées sur les pins d'interruption et les fronts montants et descendants sont pris en compte sur les deux voies (la précision est augmentée et on peut également déterminer le sens). 
Par contre si on utilise un mode autre que la quadrature, seule une voie doit être branchée en interruption, l'autre peut être reliée à une entrée logique classique. 

On rappelle que l'échantillonnage est de 8 ms au minimum pour ce bloc.

\dialogbox

Le bloc propose deux menus. 
Le premier permet de choisir le mode de lecture du signal délivré par le codeur (choix entre 1, 2 ou 4).
Le numéro de la carte ne peut pas être modifié pour l'instant.
\image{ENCODER_SB_dialogbox1.png}
Le mode 1 utilise une seule voie d'interruption et une voie digitale quelconque pour déterminer le sens. Seuls les fronts montants de la voie d'interruption sont pris en compte dans ce mode.
Le mode 2 utilise les mêmes voies mais les fronts montants et descendants de la voie d'interruption sont pris en compte.
Le mode 4 correspond au mode quadrature. Dans ce mode, les fronts montants et descendants des deux voies sont pris en compte.

Le second menu permet de spécifier les ports utilisés en fonction du mode retenu :
\image{ENCODER_SB_dialogbox2.png}
mode 1x : déclaration du pin d'interruption 2 ou 3 sur une carte UNO (2, 3 ou 18 à 21 pour la carte MEGA) et déclaration d'un pin digital quelconque de 2 à 13 pour une carte UNO (2 à 53 pour la carte MEGA)
mode 2x : même principe.
mode 4x : utilisation obligatoire de deux pins d'interruptions 2 et 3 sur une carte UNO ou 2 parmi 2, 3 ou 18 à 21 pour une carte MEGA.

\example1
L'exemple ci-dessous montre l'utilisation du bloc dans le cas d'un moteur dont on relève la position au cours du temps et la vitesse à partir du signal provenant du codeur. Le mode 4x a été choisi pour améliorer la précision. Le paramétrage du moteur est le même que celui de l'exemple sur le moteur.
\image{ENCODER_exemple.png}

\example2
L'exemple suivant montre un asservissement de position utilisant l'information du codeur pour comparaison avec une grandeur de consigne. Un correcteur PI est utilisé pour corrigé l'écart et délivrer la tension de commande du moteur à courant continu.
\image{ASSERV_POS_exemple.png}

\seealso
DCMOTOR_SB
