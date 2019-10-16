\name
SERVO_WRITE_SB

\palette
Arduino

\smalldescription
Permet de piloter un servomoteur en renseignant l'angle de 0 à 180° souhaité

\description
Un servomoteur est un ensemble constitué d'un moteur électrique, d'un réducteur, d'un potentiomètre et d'une partie électronique analogique ou numérique pour la commande. C'est donc un asservissement de position (ou de vitesse pour les servomoteurs à rotation continue).
L'utilisateur ne doit donc qu'envoyer la consigne de position ou de vitesse souhaitée. Cette consigne est transmise au servomoteur sous forme d'impulsions espacées de 10 à 20 ms. Le codage de ces impulsions est fait de telle façon qu'une impulsion de 1,5 ms correspond à la position centrée (de repos), une impulsion de 1 ms correspond à un angle de 90° dans le sens trigonométrique et enfin une impulsion de 2 ms correspond à un angle de 90° dans le sens horaire. Toutes les autres largeurs d'impulsion donneront des valeurs intermédiaires.
Pour un servomoteur à rotation continue, la largeur des impulsions donne la vitesse de rotation ainsi que le sens.
Il faut penser à utiliser un régulateur de tension plutôt que l'alimentation de la carte Arduino pour alimenter le servomoteur.
Pour simplifier, le bloc ne demande en entrée que l'angle souhaité en degré de 0 à 180.
Deux servomoteurs peuvent être pilotés avec la toolbox.

On rappelle que l'échantillonnage est de 10 ms au minimum pour ce bloc.

\dialogbox
\image{SERVO_SB_dialogbox.png}
Le bloc propose de choisir le numéro du servomoteur piloté.
Le numéro de la carte ne peut pas être modifié pour l'instant.

\example1
L'exemple ci-dessous montre l'utilisation du bloc servomoteur dont la position est donnée par un potentiomètre relié sur le port analogique 0.
Un gain d'adaptation a été utilisé pour convertir les données numériques codées sur 10 bits en sortie du potentiomètre en une grandeur variant de 0 à 180 pour spécifier la position souhaitée du servomoteur.
\image{SERVO_SB_exemple.png}

\seealso
DCMOTOR_SB
