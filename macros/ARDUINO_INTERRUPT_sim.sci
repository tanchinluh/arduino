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

function block=ARDUINO_INTERRUPT_sim(block,flag)
    global port_com arduino_sample_time corresp h1 h2 h3 h4 h5;

    function DEBUG(message)
        disp("[DEBUG time = "+string(scicos_time())+"] {"+block.label+"} ARDUINO_INTERRUPT Simulation: "+message);
    endfunction
    select flag
    case -5 // Error

    case 0 // Derivative State Update

    case 1 // Output Update
        // Envoi de la trame sur le port série pour dire de renvoyer la valeur comptée
        code_sent="Ip"+ascii(corresp(block.rpar(1)));
        handle_num=block.rpar(2);
        handle_str = 'h'+string(handle_num);

        write_serial(evstr(handle_str),code_sent,3)

        //binary transfert
        [a,b,c]=status_serial(evstr(handle_str));
        while (b < 4)
            [a,b,c]=status_serial(evstr(handle_str));
        end
        values=read_serial(evstr(handle_str),4);
        // temp=ascii(values);
        temp=values;
        val=double(int32(uint32(256^3*temp(4)+256^2*temp(3)+256*temp(2)+temp(1))));
        block.outptr(1)=val;


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
        code_sent="Ia"+ascii(0+corresp(block.rpar(1))); //on envoie plus le PIN mais le numéro d'interruption
        handle_num=block.rpar(2);
        handle_str = 'h'+string(handle_num);
        
        write_serial(evstr(handle_str),code_sent,3)
        code_sent="Iz"+ascii(corresp(block.rpar(1)));
        write_serial(evstr(handle_str),code_sent,3)
    case 5 // Ending
        code_sent="Ir"+ascii(corresp(block.rpar(1)));
        handle_num=block.rpar(2);
        handle_str = 'h'+string(handle_num);        
        write_serial(evstr(handle_str),code_sent,3)
    case 6 // Re-Initialisation

    case 9 // ZeroCrossing

    else // Unknown flag

    end
endfunction
