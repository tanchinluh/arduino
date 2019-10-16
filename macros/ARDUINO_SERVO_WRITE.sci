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

function [x, y, typ]=ARDUINO_SERVO_WRITE(job, arg1, arg2)
    x=[];
    y=[];
    typ=[];
    maxboard = 2;
    
    style = "ARDUINO_SERVO_WRITE;blockWithLabel;"+..
            "horizontalLabelPosition=right;horizontalAlign=left;"+..
            "displayedLabel=Servo %s<br>on board %s"
//            "verticalLabelPosition=bottom;verticalAlign=top;spacing=-2;"+..
    select job
    case 'plot' then
        // deprecated
    case 'getinputs' then
        // deprecated
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
            [ok,num_pin,num_arduino,exprs]=scicos_getvalue('Arduino Servo Write parameters',..
            [gettext('Servo number (1 or 2)'),gettext('Arduino board number')],list('vec',1,'vec',1), exprs)
            mess=[];

            if ~ok then// Cancel
                break;
            end
            if num_arduino > maxboard then
                mess=[mess ;gettext("Only "+string(maxboard)+" can be used with this toolbox version ")];
                ok=%f;
            end
            if num_pin < 1 | num_pin>2
                mess=[mess ;_("Servo numbers must be 1 or 2 (on pin 10 and 9)")]
                ok = %f
            end

            if ok then// Everything's ok
                model.rpar=[num_pin,num_arduino];
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
        model.sim=list("ARDUINO_SERVO_WRITE_sim", 5)
        model.blocktype='d';
        model.dep_ut=[%f %f];
        model.in=[1];
        model.evtin=[1]
        model.evtout=[1]
        model.firing=[0;-1]
        Pin=1;
        num_arduino=1;
        model.rpar=[Pin,num_arduino]; //Default Pin number and Arduino board number
        x=standard_define([2 2],model,[],[]);
        x.graphics.in_implicit = 'E';
        tmp = [string(Pin),string(num_arduino)]
        x.graphics.style = msprintf(style, tmp);
        x.graphics.exprs = tmp;
    end
endfunction
