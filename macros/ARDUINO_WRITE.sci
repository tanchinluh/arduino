//
// Scilab ( http://www.scilab.org/ ) - This file is part of Scilab
// Copyright (C) 2012-2012 - Scilab Enterprises - Bruno JOFRET
//
// This file must be used under the terms of the CeCILL.
// This source file is licensed as described in the file COPYING, which
// you should have received as part of this distribution.  The terms
// are also available at
// http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
//
// Modified 20191015 by TCL-ByteCode for Scilab 6 and multiple cards and supports

function [x, y, typ]=ARDUINO_WRITE(job, arg1, arg2)
    x=[];
    y=[];
    typ=[];
    maxboard = 2;
    style = "ARDUINO_WRITE;blockWithLabel;"+..
    "verticalLabelPosition=bottom;verticalAlign=top;align=center;"+..
    "displayedLabel=DigOut %s"
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
            [ok,num_pin,exprs]=scicos_getvalue('Arduino Digital Write parameters',..
            [gettext('Digital Pin')], ..
            list('vec',1), ..
            exprs)
            mess=[];

            if ~ok then// Cancel
                break;
            end

            if num_pin < 0 | num_pin>13
                mess=[mess ;_("Digital Pin must be between 0 and 13.")]
                ok = %f
            end


            if ok then// Everything's ok
                model.rpar=num_pin;
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
        model.sim=list("ARDUINO_WRITE_sim", 5)
        model.blocktype='d';
        model.dep_ut=[%f %f];
        model.in=[1];
        DigOut=0;
        model.rpar=[DigOut]; //Digital Output number
        x=standard_define([2 2],model,[],[]);
        x.graphics.in_implicit = 'E';
        x.graphics.style = msprintf(style, string(DigOut))
        x.graphics.exprs=string(DigOut);
    end
endfunction
