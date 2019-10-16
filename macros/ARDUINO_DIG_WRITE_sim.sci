//
// Scilab ( http://www.scilab.org/ ) - This file is part of Scilab
// Copyright (C) 2011-2011 - DIGITEO - Bruno JOFRET
//
// This file must be used under the terms of the CeCILL.
// This source file is licensed as described in the file COPYING, which
// you should have received as part of this distribution.  The terms
// are also available at
// http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
//
// Modified 20191014 by TCL-ByteCode for Scilab 6 and multiple cards and supports

function block=ARDUINO_DIG_WRITE_sim(block,flag)
    global port_com arduino_sample_time h1 h2 h3 h4 h5;

    function DEBUG(message)
        disp("[DEBUG time = "+string(scicos_time())+"] {"+block.label+"} ARDUINO_DIG_WRITE Simulation: "+message);
    endfunction
    select flag
    case -5 // Error

    case 0 // Derivative State Update


    case 1 // Output Update
        u1 = block.inptr(1);      
        if (u1<0.01) then
            //pin="2"+ascii(97+block.rpar(1))+"0";
            pin="Dw"+ascii(48+block.rpar(1))+"0";
            //          writeserial(port_com,pin);
        else
            //pin="2"+ascii(97+block.rpar(1))+"1";
            pin="Dw"+ascii(48+block.rpar(1))+"1";
            //          writeserial(port_com,pin);
        end
        //write_serial(1,pin,3);

        handle_num=block.rpar(2);
        handle_str = 'h'+string(handle_num);
        write_serial(evstr(handle_str),pin,4);

    case 2 // State Update

    case 3 // OutputEventTiming
        evout = block.evout(1);
        if evout < 0
            evout = arduino_sample_time;
        else
            evout = evout + arduino_sample_time;
        end
        block.evout(1) = evout;

    case 4 // Initialization
        disp("init digital write")
        handle_num=block.rpar(2);
        handle_str = 'h'+string(handle_num);
        //        pin="0"+ascii(97+ block.rpar(1))+"1";  // élaboration du string à envoyer pour initialiser le pin
        //        write_serial(1,pin,3);
        pin="Da"+ascii(48+ block.rpar(1))+"1";  // élaboration du string à envoyer pour initialiser le pin
        write_serial(evstr(handle_str),pin,4);


    case 5 // Ending
        // FIXME: quoi faire a la fin de la simulation


    case 6 // Re-Initialisation

    case 9 // ZeroCrossing

    else // Unknown flag

    end
endfunction
