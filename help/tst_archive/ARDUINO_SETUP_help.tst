\name
ARDUINO_SETUP

\palette
Arduino

\smalldescription
Permet de configuration le port de communication série entre l'arduino et scilab.

\description
Ce bloc doit \bold{obligatoirement} être placé sur le schéma lors de l'utilisation d'autres blocs de la toolbox. 
Il permet de définir le port de communication entre la carte Arduino et Xcos.
Le port à utiliser peut être déterminé en lançant l'application Arduino et en vérifiant le com indiqué dans Outils/Port série. Celui-ci peut également être modifié dans le Gestionnaire de périphériques / Ports (options Avancées).
Il n'est pas possible actuellement d'utiliser plusieurs cartes Arduino.

La toolbox n'est utilisable que sous Windows pour l'instant.

\bold{Attention pour utiliser la toolbox Arduino, il est indispensable de charger dans la carte Arduino le programme toolbox_arduino.ino disponible sur le site :} http://www.demosciences.fr


\dialogbox
\image{ARDUINO_SETUP_dialogbox.png}
Le port de communication doit être spécifié (entre 2 et 9 sinon un message d'erreur apparaît).
Le numéro de carte Arduino doit être égal à 1 actuellement (sinon un message d'erreur apparaît)

\example1
L'exemple ci-dessus montre l'utilisation du bloc dans le cas du clignotement de la led 13 de la carte UNO définie sur le port de communication 5. Les blocs utilisent les paramètres par défaut, sauf pour le bloc PULSE de la palette standard dont on spécifie le déphasage à 0.
\image{ARDUINO_SETUP_example.png}

\seealso
TIME_SAMPLE
