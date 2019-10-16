\name
TIME_SAMPLE

\palette
Arduino

\smalldescription
Permet de spécifier la durée d'acquisition/pilotage et le pas d'échantillonnage

\description
Ce bloc doit \bold{obligatoirement} être placé sur le schéma lors de l'utilisation d'autres blocs de la toolbox. 
Il permet de définir la durée de communication avec la carte Arduino ainsi que le pas d'échantillonnage utilisé pour les blocs (chaque bloc est cadencé par ce pas).
La communication série impose un pas limite pour chaque bloc qui est d'environ 8 ms (il est possible de descendre à 4 ms) par bloc. 
Il conviendra de tester pour des acquisitions complexes que l'échantillonnage retenu est suffisant, pour cela, il faut mesurer que le temps de simulation correspond au temps réel (une simulation de 10 s doit durer 10 s) ; à défaut, il faudra augmenter la période d'échantillonnage.

\dialogbox
\image{TIME_SAMPLE_dialogbox.png}
La durée de simulation (positive) doit être spécifiée.
Le pas d'échantillonnage doit être renseigné en faisant attention au nombre de blocs Arduino utilisé.

\example1
L'exemple ci-dessus montre l'utilisation du bloc dans le cas du clignotement de la led 13 de la carte UNO définie sur le port de communication 5. Les blocs utilisent les paramètres par défaut, sauf pour le bloc PULSE de la palette standard dont on spécifie le déphasage à 0.
\image{ARDUINO_SETUP_example.png}

\seealso
ARDUINO_SETUP
