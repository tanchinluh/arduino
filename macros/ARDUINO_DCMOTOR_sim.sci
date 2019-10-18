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

function block=ARDUINO_DCMOTOR_sim(block,flag)
    global port_com arduino_sample_time h1 h2 h3 h4 h5;
    function DEBUG(message)
        disp("[DEBUG time = "+string(scicos_time())+"] {"+block.label+"} ARDUINO_DCMOTOR Simulation: "+message);
    endfunction
    select flag
    case -5 // Error

    case 0 // Derivative State Update


    case 1 // Output Update
        //DEBUG("Output update ");

        u1 = block.inptr(1);     
        //envoi de la direction 
        direction=sign(u1);
        //      if block.rpar(1)==1 then //adafruit shield
        //         if direction>=0 then
        //          code_dir="f";
        //         else
        //          code_dir="b";
        //        end
        //        code_sent="B"+ascii(48+block.rpar(5))+code_dir; 
        ////        writeserial(port_com,code_sent);
        //        write_serial(1,code_sent,3)
        //
        //        if abs(u1)>255 then
        //          code_sent="A"+ascii(48+block.rpar(5))+ascii(255);
        ////          writeserial(port_com,code_sent);
        //          write_serial(1,code_sent,3)
        //        else
        //          code_sent="A"+ascii(48+block.rpar(5))+ascii(abs(ceil(u1)));
        ////          writeserial(port_com,code_sent);
        //          write_serial(1,code_sent,3)
        //        end
        //      else  //generic L298 L293
        if direction>=0 then
            code_dir=ascii(49);
        else
            code_dir=ascii(48);
        end
        if abs(u1)>255 then
            val = 255;
        elseif u1 == 0
            val = 1;    // 20191018 - workaround for ascii(0)
        else
            val=abs(ceil(u1));
        end

        //code_sent="A"+ascii(48+block.rpar(5))+code_dir+ascii(val);
        code_sent="M"+ascii(48+block.rpar(5))+code_dir+ascii(val);
        //          writeserial(port_com,code_sent);
        
        handle_num=block.rpar(2);
        handle_str = 'h'+string(handle_num);
        
        write_serial(evstr(handle_str),code_sent,4)
        //      end


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
        disp("init DCmotor")
        if(block.rpar(1)==1) then
            //code_sent="91";
            code_sent="C"+string(block.rpar(5))+ascii(48+block.rpar(4))+ascii(48+block.rpar(3))+"1";    //adafruit
        elseif (block.rpar(1)==2) then
            code_sent="C"+string(block.rpar(5))+ascii(48+block.rpar(4))+ascii(48+block.rpar(3))+"1";   //code pour initialiser L298
        elseif (block.rpar(1)==3) then
            code_sent="C"+string(block.rpar(5))+ascii(48+block.rpar(4))+ascii(48+block.rpar(3))+"0";   //code pour initialiser L293
        end

        //        writeserial(port_com,code_sent);  
        handle_num=block.rpar(2);
        handle_str = 'h'+string(handle_num);
        
        write_serial(evstr(handle_str),code_sent,5)
        //        disp(code_sent)

        //Attente que l'arduino reponde OK
        [a,b,c]=status_serial(evstr(handle_str));
        while (b < 2) 
            [a,b,c]=status_serial(evstr(handle_str));
        end
        values=read_serial(evstr(handle_str),2);
        if (ascii(values) == 'OK') then
            disp('Init motor successful')
        else
            disp('Init motor failed')
        end

    case 5 // Ending
        // FIXME: quoi faire a la fin de la simulation
        //code_sent="M"+ascii(48+block.rpar(5))+"r";
        //code_sent="M"+ascii(48+block.rpar(5))+ascii(0)+ascii(0);
        //        writeserial(port_com,code_sent);
        //write_serial(1,code_sent,3)
        code_sent="M"+ascii(48+block.rpar(5))+"1"+ascii(0);
        
        handle_num=block.rpar(2);
        handle_str = 'h'+string(handle_num);
        write_serial(evstr(handle_str),code_sent,4)
        //      write_serial(1,code_sent,4)
        //      if block.rpar(1)==1 then
        //        
        //    else
        //        code_sent="B"+ascii(48+block.rpar(5))+"r";
        ////        writeserial(port_com,code_sent);  
        //        write_serial(1,code_sent,3)
        ////        disp(code_sent)
        //      end

    case 6 // Re-Initialisation

    case 9 // ZeroCrossing

    else // Unknown flag

    end
endfunction
