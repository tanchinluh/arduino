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

function [x, y, typ]=ARDUINO_INTERRUPT(job, arg1, arg2)
    global corresp;
    corresp(2) = 0;
    corresp(3) = 1;
    corresp(18) = 5;
    corresp(19) = 4;
    corresp(20) = 3;
    corresp(21) = 2;
    corresp = corresp + 1;
    maxboard = 2;
    x=[];
    y=[];
    typ=[];
    style = "ARDUINO_INTERRUPT;blockWithLabel;"+..
            "verticalLabelPosition=bottom;verticalAlign=top;spacing=-2;align=center;"+..
            "displayedLabel=Interrupt<br>on pin %s on board %s"
    select job
    case 'set' then
        x=arg1;
        graphics=arg1.graphics;
        exprs=graphics.exprs
        model=arg1.model;

        while %t do
            [ok,pin_interrupt,num_arduino,exprs1]=scicos_getvalue(['Arduino Interrupt parameters';'UNO interruption PIN are : 2 or 3';'MEGA interruption PIN are : 2, 3 and 18 to 21'],..
            [gettext('Interrupt pin number');
             gettext('Arduino board number')],list('vec',1,'vec',1), exprs(1:2))
            mess=[];

            if ~ok then break; end //cancel
            //security tests
            if num_arduino> maxboard then
                mess=[mess ;gettext("Only "+string(maxboard)+" can be used with this toolbox version ")];
                ok=%f;
            end

            if ok then            
                model.rpar=[pin_interrupt;num_arduino];
                exprs=string(model.rpar);
                graphics.exprs = exprs;
                x.model=model;
                x.graphics = graphics;
                x.graphics.style = msprintf(style, exprs')
                break
            else
                message(mess);
            end

        end
    case 'define' then
        model=scicos_model();
        model.sim=list("ARDUINO_INTERRUPT_sim", 5)
        model.blocktype='d';
        model.dep_ut=[%f %f];
        model.out=[1];
        model.evtin=[1];
        model.evtout=[1];
        model.firing=[0;-1]
        pin_interrupt=2; num_arduino=1;
        model.rpar=[pin_interrupt;num_arduino]; //Default Pin number and Arduino board number
        x=standard_define([2 2],model,[],[]);
        x.graphics.out_implicit=['E'];
        tmp = string([pin_interrupt;num_arduino])
        x.graphics.style = msprintf(style, tmp')
        x.graphics.exprs = tmp
    end
endfunction
