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

function [x, y, typ]=ARDUINO_ENCODER(job, arg1, arg2)
    global corresp;
    corresp(2)=0;corresp(3)=1;corresp(21)=2;corresp(20)=3;corresp(19)=4;corresp(18)=5;
    x=[];
    y=[];
    typ=[];
    maxboard = 2;

    select job
    case 'plot' then
        // deprecated
    case 'getinputs' then
        // deprecater
    case 'getoutputs' then
        // deprecated
    case 'getorigin' then
        // deprecated
    case 'set' then
        x=arg1;
        graphics=arg1.graphics;
        exprs=graphics.exprs
        model=arg1.model;

        while %t do
            [ok,num_arduino,counting_mode,exprs1]=scicos_getvalue('Arduino Encoder parameters',..
            [gettext('Arduino card number');gettext('Counting mode : 1 (up chanA) 2 (up/down chanA) 4 (up/down chanA and B)')],list('vec',1,'vec',1), exprs(1:2))
            mess=[];

            if ~ok then break; end //cancel
            //security tests
            if num_arduino > maxboard then
                mess=[mess ;gettext("Only "+string(maxboard)+" can be used with this toolbox version ")];
                ok=%f;
            end
            //          if num_encoder < 1 | num_encoder>4
            //              mess=[mess ;_("Encoder number must be 1 or 2 ")]
            //              ok = %f
            //          end
            if counting_mode ~=1 & counting_mode~=2 & counting_mode~=4
                mess=[mess ;_("Counting mode must be 1, 2 or 4")]
                ok = %f
            end

            if ok then
                ok2=%f
                if counting_mode==1 | counting_mode==2 then
                    [ok2,pin_A,pin_B,exprs2]=scicos_getvalue(['Definition of Pins Encoder';'UNO interruption PIN are : 2 or 3';'MEGA interruption PIN are : 2, 3 and 18 to 21'],..
                    [gettext('Pin Channel A (interruption PIN see above)');gettext('Pin Direction (whatever)')],list('vec',1,'vec',1), exprs(3:4))
                elseif counting_mode==4
                    [ok2,pin_A,pin_B,exprs2]=scicos_getvalue(['Definition of Pins Encoder';'UNO interruption PIN are : 2 or 3';'MEGA interruption PIN are : 2, 3 and 18 to 21'],..
                    [gettext('Pin Channel A (interruption PIN see above)');gettext('Pin Channel B (interruption PIN see above)')],list('vec',1,'vec',1), exprs(3:4))
                end
                if ~ok2 then break; end //cancel
                if pin_A~=2 & pin_A~=3 & pin_A~=18 & pin_A~=19 & pin_A~=20 & pin_A~=21 then
                    mess=[mess ;_("Pin for Channel A must be 2, 3 or 18 to 21 (pin with interrupts) ")]
                    ok2 = %f
                end
                if ok2 then
                    model.rpar=[num_arduino;counting_mode;pin_A;pin_B];
                    exprs=string(model.rpar);
                    graphics.exprs = exprs;
                    x.model=model;
                    x.graphics = graphics;
                    break
                else
                    message(mess);
                end
            else
                message(mess);
            end

        end
    case 'define' then
        model=scicos_model();
        model.sim=list("ARDUINO_ENCODER_sim", 5)
        model.blocktype='d';
        model.dep_ut=[%f %f];
        model.out=[1];
        model.evtin=[1];
        model.evtout=[1];
        model.firing=[0;-1]
        //num_encoder=1;
        num_arduino=1, counting_mode=2; pin_A=2; pin_B=4;
        model.rpar=[num_arduino;counting_mode;pin_A;pin_B]; //Default Pin number and Arduino card number
        x=standard_define([2 2],model,[],[]);
        x.graphics.out_implicit=['E'];
        x.graphics.style=["blockWithLabel;verticalLabelPosition=bottom;verticalAlign=top;spacing=-2;displayedLabel=Encoder<br>on card %s"]
        x.graphics.exprs=string([num_arduino;counting_mode;pin_A;pin_B])
    end
endfunction
