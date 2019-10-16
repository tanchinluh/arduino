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

function block=ARDUINO_SERVO_WRITE_sim(block,flag)
    global port_com arduino_sample_time h1 h2 h3 h4 h5;
    function DEBUG(message)
        disp("[DEBUG time = "+string(scicos_time())+"] {"+block.label+"} ARDUINO_ANALOG_WRITE Simulation: "+message);
    endfunction
    select flag
    case -5 // Error

    case 0 // Derivative State Update

    case 1 // Output Update
        u1 = block.inptr(1);      
        if (u1<0) then
            //pin="8"+ascii(96+block.rpar(1))+ascii(0);
            pin="Sw"+ascii(48+block.rpar(1))+ascii(0);
            //          writeserial(port_com,pin);
        elseif u1>180 then
            //pin="8"+ascii(96+block.rpar(1))+ascii(180);
            pin="Sw"+ascii(48+block.rpar(1))+ascii(180);
            //          writeserial(port_com,pin);
        else
            //pin="8"+ascii(96+block.rpar(1))+ascii(uint8(u1));
            pin="Sw"+ascii(48+block.rpar(1))+ascii(uint8(u1));
            //          writeserial(port_com,pin);
        end
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
        disp("init servo write")
        handle_num=block.rpar(2);
        handle_str = 'h'+string(handle_num);
                
        if block.rpar(1)==1 then //servo 1 on pin 9
            pin="Sa1"
            //pin="6a1" 
            //           writeserial(port_com,pin); 
            write_serial(evstr(handle_str),pin,3);
        elseif block.rpar(1)==2 then //servo 2 on pin 10
            //pin="6b1" 
            pin="Sa2"
            //           writeserial(port_com,pin); 
            write_serial(evstr(handle_str),pin,3);
        else
            messagebox("Issue about the servomotor id")
            error('problem')
        end
    case 5 // Ending
        handle_num=block.rpar(2);
        handle_str = 'h'+string(handle_num);        
        if block.rpar(1)==1 then //servo 1 on pin 10
            //pin="6a0" 
            pin="Sd1"
            //           writeserial(port_com,pin); 
            write_serial(evstr(handle_str),pin,3);
        elseif block.rpar(1)==2 then //servo 2 on pin 9
            //pin="6b0" 
            pin="Sd2"
            //           writeserial(port_com,pin); 
            write_serial(evstr(handle_str),pin,3);
        else
            messagebox("Issue about the servomotor id")
            error('problem')
        end
    case 6 // Re-Initialisation

    case 9 // ZeroCrossing

    else // Unknown flag

    end
endfunction
