//
// Scilab ( http://www.scilab.org/ ) - This file is part of Scilab
// Copyright (C) 2012-2012 - Scilab Enterprises - Vincent COUVERT
//
// This file must be used under the terms of the CeCILL.
// This source file is licensed as described in the file COPYING, which
// you should have received as part of this distribution.  The terms
// are also available at
// http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
//
//

function subdemolist = demo_gateway()
  demopath = get_absolute_file_path("exemples_livret.dem.gateway.sce");

  subdemolist = ["Exemple 1", "arduino2.dem.sce" ;
                 "Exemple 2", "arduino3.dem.sce" ;
                 "Exemple 3", "arduino4.dem.sce" ;
                 "Exemple 4", "arduino5.dem.sce" ;
                 "Exemple 5", "arduino7.dem.sce" ;
                 "Exemple 6", "arduino8.dem.sce" ;
                 "Exemple 7", "arduino9.dem.sce" ;
                ];

  subdemolist(:,2) = demopath + subdemolist(:,2);

endfunction
subdemolist = demo_gateway();
clear demo_gateway; // remove demo_gateway on stack
