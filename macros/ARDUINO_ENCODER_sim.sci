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

function block=ARDUINO_ENCODER_sim(block,flag)
    global port_com arduino_sample_time corresp h1 h2 h3 h4 h5;
    function DEBUG(message)
        disp("[DEBUG time = "+string(scicos_time())+"] {"+block.label+"} ARDUINO_ANALOG_READ Simulation: "+message);
    endfunction
    select flag
    case -5 // Error

    case 0 // Derivative State Update

    case 1 // Output Update
        // Envoi de la trame sur le port série pour dire de renvoyer la valeur comptée
        code_sent="Ep"+ascii(corresp(block.rpar(3)));
        //      writeserial(port_com,code_sent);
        handle_num=block.rpar(1);
        handle_str = 'h'+string(handle_num);

        write_serial(evstr(handle_str),code_sent,3)

        //      //binary transfer
        //      [q,flags]=serialstatus(port_com);
        //      while (q(1) < 4)
        //        [q,flags]=serialstatus(port_com);
        //      end
        //      values=readserial(port_com,4);

        //binary transfert
        [a,b,c]=status_serial(evstr(handle_str));
        while (b < 4)
            [a,b,c]=status_serial(evstr(handle_str));
        end
        values=read_serial(evstr(handle_str),4);
        //temp=ascii(values);
        temp = values;  
        val=double(int32(uint32(256^3*temp(4)+256^2*temp(3)+256*temp(2)+temp(1))));
        //      disp(val)
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
        //          code_sent="Fa"+string(block.rpar(1))+string(block.rpar(4))+string(block.rpar(5))+string(block.rpar(3))
        code_sent="Ea"+ascii(0+corresp(block.rpar(3))); //on envoie plus le PIN mais le numéro d'interruption
        if  block.rpar(2)==4 then //mode4
            code_sent=code_sent+ascii(0+corresp(block.rpar(4)))+string(block.rpar(2));// on envoie le num d'interruption
        else//mode 1 ou 2
            code_sent=code_sent+ascii(0+block.rpar(4))+string(block.rpar(2));//on envoie le num de PIN en mode 1x/2x
        end
        
        handle_num=block.rpar(1);
        handle_str = 'h'+string(handle_num);
        //          writeserial(port_com,code_sent);
        write_serial(evstr(handle_str),code_sent,5)
        code_sent="Ez"+ascii(corresp(block.rpar(3)));
        //          writeserial(port_com,code_sent);
        write_serial(evstr(handle_str),code_sent,3)
    case 5 // Ending
        if  block.rpar(2)==4 then //mode4
            code_sent="Er"+ascii(corresp(block.rpar(3)))+ascii(corresp(block.rpar(4)));
        else
            code_sent="Er"+ascii(corresp(block.rpar(3)))+ascii(corresp(block.rpar(3)));
        end
        //          writeserial(port_com,code_sent);

        handle_num=block.rpar(1);
        handle_str = 'h'+string(handle_num);
        write_serial(evstr(handle_str),code_sent,4)
        //          disp(code_sent)
    case 6 // Re-Initialisation

    case 9 // ZeroCrossing

    else // Unknown flag

    end
endfunction
