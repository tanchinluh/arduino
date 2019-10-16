//
// Scilab ( http://www.scilab.org/ ) - This file is part of Scilab
// Copyright (C) 2012-2012 - Scilab ENterprises - Bruno JOFRET
//
// This file must be used under the terms of the CeCILL.
// This source file is licensed as described in the file COPYING, which
// you should have received as part of this distribution.  The terms
// are also available at
// http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
//
// Modified 20191015 by TCL-ByteCode for Scilab 6 and multiple cards and supports

function block=ARDUINO_WRITE_sim(block,flag)
    global port_com h1 h2 h3 h4 h5;
    function DEBUG(message)
        disp("[DEBUG time = "+string(scicos_time())+"] {"+block.label+"} ARDUINO_WRITE Simulation: "+message);
    endfunction
    select flag
    case -5 // Error

    case 0 // Derivative State Update

    case 1 // Output Update
        u1 = block.inptr(1);
        handle_num=block.rpar(2);
        handle_str = 'h'+string(handle_num);
        pin="2"+ascii(97+block.rpar);
        if (u1<0.1) then
            pin="2"+ascii(97+block.rpar)+"0";
            //          writeserial(port_com,pin);
            write_serial(evstr(handle_str),pin,3);
        else
            pin="2"+ascii(97+block.rpar)+"1";
            //          writeserial(port_com,pin);
            write_serial(evstr(handle_str),pin,3);
        end


    case 2 // State Update

    case 3 // OutputEventTiming

    case 4 // Initialization

    case 5 // Ending
        // FIXME: quoi faire a la fin de la simulation

        //     closeserial(port_com);

    case 6 // Re-Initialisation

    case 9 // ZeroCrossing

    else // Unknown flag

    end
endfunction
