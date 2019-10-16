//
// Scilab ( http://www.scilab.org/ ) - This file is part of Scilab
// Copyright (C) 2012-2012 - Scilab Enterprises - Bruno JOFRET
//
// This file must be used under the terms of the CeCILL.
// This source file is licensed as described in the file COPYING, which
// you should have received as part of this distribution.  The terms
// are also available at
// http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
//
//

function subdemolist = demo_gateway()
  demopath = get_absolute_file_path("arduino.dem.gateway.sce");

  subdemolist = ["Potentiomètre", "analog_read.dem.sce" ;
                 "Bouton poussoir Led", "digital_read_write.dem.sce" ;
                 "Variateur LED", "analog_write.dem.sce" ;
                 "MoteurCC pilotage direct", "motor.dem.sce";
                 "Encodeur", "encodeur.dem.sce";
                 "Interruptions", "interrupt_compteur.dem.sce";
                 "Asservissement position", "asserv.dem.sce";
                 "ServoMoteur", "servomotor.dem.sce";
                 "Exemples Livret", "exemples_livret.dem.gateway.sce";
                ];

  subdemolist(:,2) = demopath + subdemolist(:,2);

endfunction
subdemolist = demo_gateway();
clear demo_gateway; // remove demo_gateway on stack
