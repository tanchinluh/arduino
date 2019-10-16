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

function block=ARDUINO_SERVO_READ_sim(block,flag)
    global port_com arduino_sample_time h1 h2 h3 h4 h5;
    function DEBUG(message)
        disp("[DEBUG time = "+string(scicos_time())+"] {"+block.label+"} ARDUINO_ANALOG_READ Simulation: "+message);
    endfunction
    select flag
    case -5 // Error

    case 0 // Derivative State Update

    case 1 // Output Update
        // Envoi de la trame sur le port série : 3 pour un analog_READ et le num de pin (0 à ...)
        pin="7"+ascii(96+block.rpar(1));
        //      writeserial(port_com,pin);
        handle_num=block.rpar(2);
        handle_str = 'h'+string(handle_num);

        write_serial(evstr(handle_str),pin,2);

        values=[];
        value=[];
        while(value~=ascii(13)) then
            //          value=readserial(port_com,1);
            value=read_serial(evstr(handle_str),1);
            values=[values value];
        end

        v=strsubst(values,string(ascii(10)),'')
        v=strsubst(v,string(ascii(13)),'')
        block.outptr(1)=evstr(v);

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
        disp("init servo read")
        handle_num=block.rpar(2);
        handle_str = 'h'+string(handle_num);
        if block.rpar(1)==1 then //servo 1 on pin 10
            pin="6a1" 
            //           writeserial(port_com,pin); 
            write_serial(evstr(handle_str),pin,3);
        elseif block.rpar(1)==2 then //servo 2 on pin 9
            pin="6b1" 
            //           writeserial(port_com,pin); 
            write_serial(evstr(handle_str),pin,3);
        else
            messagebox("Issue about the servomotor id")
            error('problem')
        end
    case 5 // Ending

    case 6 // Re-Initialisation

    case 9 // ZeroCrossing

    else // Unknown flag

    end
endfunction
