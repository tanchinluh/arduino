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
// Modified 20191015 by TCL-ByteCode for Scilab 6 and multiple cards and supports

function block=ARDUINO_ANALOG_WRITE_sim(block,flag)
    global port_com arduino_sample_time h1 h2 h3 h4 h5;
    function DEBUG(message)
        disp("[DEBUG time = "+string(scicos_time())+"] {"+block.label+"} ARDUINO_ANALOG_WRITE Simulation: "+message);
    endfunction
    select flag
    case -5 // Error

    case 0 // Derivative State Update


    case 1 // Output Update
        u1 = block.inptr(1);      
        if abs(u1)>255 then
            //code_sent="4"+ascii(97+block.rpar(1))+ascii(255);
            code_sent="W"+ascii(48+block.rpar(1))+ascii(255);
        else
            //code_sent="4"+ascii(97+block.rpar(1))+ascii(abs(ceil(u1)));    
            code_sent="W"+ascii(48+block.rpar(1))+ascii(abs(ceil(u1)));
        end
        //        writeserial(port_com,code_sent);
        handle_num=block.rpar(2);
        handle_str = 'h'+string(handle_num);
        
        write_serial(evstr(handle_str),code_sent,3);

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
        //"You do not need to call pinMode() to set the pin as an output before calling analogWrite(). " 
    case 5 // Ending
        // FIXME: quoi faire a la fin de la simulation
        //code_sent="4"+ascii(97+block.rpar(1))+ascii(0);
        handle_num=block.rpar(2);
        handle_str = 'h'+string(handle_num);    
        code_sent="W"+ascii(48+block.rpar(1))+ascii(0);  
        
        //        writeserial(port_com,code_sent);
        write_serial(evstr(handle_str),code_sent,3);

    case 6 // Re-Initialisation

    case 9 // ZeroCrossing

    else // Unknown flag

    end
endfunction
