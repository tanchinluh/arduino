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
//

function block=ARDUINO_MPU6050_sim(block,flag)
    global port_com arduino_sample_time h1 h2 h3 h4 h5;
    function DEBUG(message)
        disp("[DEBUG time = "+string(scicos_time())+"] {"+block.label+"} ARDUINO_ANALOG_READ Simulation: "+message);
    endfunction
    select flag
    case -5 // Error

    case 0 // Derivative State Update

    case 1 // Output Update
        // Envoi de la trame sur le port série pour demander une lecture des valeurs du MPU6050
        // write_serial(1,"Gr",2);
        handle_num=block.rpar(2);
        handle_str = 'h'+string(handle_num);
        write_serial(evstr(handle_str),"Gr",2);
       

        //binary transfer
        [a,b,c]=status_serial(evstr(handle_str));
        tini=tic()
        t=toc()
        while (b < 18 & t<1) 
            [a,b,c]=status_serial(evstr(handle_str));
            t=toc()
        end

        if (t>=1) then
            disp("Probleme de transfert trop long !")
            val=0
        else
            values=read_serial(evstr(handle_str),18);
            //temp=ascii(values);
            temp = values; 
            for i =[1:9]
                data(i)=double(int16(uint16(256*temp((i-1)*2+2)+temp((i-1)*2+1))));
            end
            data(1)=data(1)/100
            data(2)=data(2)/100
            data(3)=data(3)/100

            for i=1:size(block.rpar,1)
                block.outptr(i)=data(block.rpar(i));
            end


        end



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

        disp("init MPU6050")
        write_serial(evstr(handle_str),"Ga",2);

    case 5 // Ending
        // FIXME: quoi faire a la fin de la simulation
        disp("End MPU6050")
        write_serial(evstr(handle_str),"Gs",2);

    case 6 // Re-Initialisation

    case 9 // ZeroCrossing

    else // Unknown flag

    end
endfunction
