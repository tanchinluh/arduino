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

function block=ARDUINO_ANALOG_READ_sim(block,flag)
    global port_com  arduino_sample_time h1 h2 h3 h4 h5;
    function DEBUG(message)
        disp("[DEBUG time = "+string(scicos_time())+"] {"+block.label+"} ARDUINO_ANALOG_READ Simulation: "+message);
    endfunction
    select flag
    case -5 // Error

    case 0 // Derivative State Update


    case 1 // Output Update
        // Envoi de la trame sur le port série : 3 pour un analog_READ et le num de pin (0 à ...)

        //pin="3"+ascii(97+block.rpar(1));
        //write_serial(1,pin,2);
        pin="A"+ascii(48+block.rpar(1));
        
        // 20191014: TCL: to handle multiple COM ports
        handle_num=block.rpar(2);
        handle_str = 'h'+string(handle_num);
        
        write_serial(evstr(handle_str),pin,2);

        //binary transfer
        [a,b,c]=status_serial(evstr(handle_str));
        while (b < 2) 
            [a,b,c]=status_serial(evstr(handle_str));
        end
        values=read_serial(evstr(handle_str),2);

        //temp=ascii(values);
        temp=values;
        val=double(int16(256*temp(2)+temp(1)));
        //val = evstr(values);
        
        block.outptr(1)=val;

    case 2 // State Update

    case 3 // OutputEventTiming
        //arduino_sample_time=0.01;
        evout = block.evout(1);
        if evout < 0
            evout = arduino_sample_time;
        else
            evout = evout + arduino_sample_time;
        end
        block.evout(1) = evout;
    case 4 // Initialization
        disp("init analog read")
        //      if block.rpar(1)~=0 & block.rpar(1)~=1 then
        //           pin="Da"+ascii(48+block.rpar(1))+"0";
        ////           writeserial(port_com,pin);                       
        //           write_serial(1,pin,4);
        //        end


    case 5 // Ending
        // FIXME: quoi faire a la fin de la simulation

    case 6 // Re-Initialisation

    case 9 // ZeroCrossing

    else // Unknown flag

    end
endfunction
