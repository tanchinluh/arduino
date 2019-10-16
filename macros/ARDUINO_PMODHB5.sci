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

function [x, y, typ]=ARDUINO_PMODHB5_WRITE(job, arg1, arg2)
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
            [ok,num_pindir,num_pinen,num_arduino,exprs]=scicos_getvalue('Arduino PMODHB5 write parameters',..
            [gettext('Direction number Pin'),gettext('Enable number Pin'),gettext('Arduino card number')],list('vec',1,'vec',1,'vec',1), exprs)
            mess=[];

            if ~ok then
                // Cancel
                break;
            end
            if num_arduino > maxboard then
                mess=[mess ;gettext("Only "+string(maxboard)+" can be used with this toolbox version ")];
                ok=%f;
            end
            if num_pindir~=11 & num_pindir~=10 num_pindir <>9  & num_pindir<>6 & num_pindir<>5 & num_pindir<>3
                mess=[mess ;_("Direction number Pin must be 3, 5, 6, 9, 10, 11")]
                ok = %f
            end
            if num_pinen~=11 & num_pinen~=10 num_pinen <>9  & num_pinen<>6 & num_pinen<>5 & num_pinen<>3
                mess=[mess ;_("Enable number Pin must be 3, 5, 6, 9, 10, 11")]
                ok = %f
            end
            if num_pinen==num_pindir then
                mess=[mess ;_("Direction number Pin must be different from Enable number pin")]
                ok = %f
            end

            if ok then
                // Everything's ok
                model.rpar=[num_pindir,num_pinen,num_arduino];
                graphics.exprs = exprs;
                x.model=model;
                x.graphics = graphics;
                break
            else
                message(mess);
            end
        end
    case 'define' then
        model=scicos_model();
        model.sim=list("ARDUINO_PMODHB5_WRITE_sim", 5)
        model.blocktype='d';
        model.dep_ut=[%f %f];
        model.in=[1];
        model.evtin=[1]
        model.evtout=[1]
        model.firing=[0;-1]
        Pindir=11; Pinen=10; num_arduino=1;
        model.rpar=[Pindir,Pinen,num_arduino]; //Default Pin number and Arduino card number
        x=standard_define([2 2],model,[],[]);
        x.graphics.in_implicit=['E'];
        x.graphics.style=["blockWithLabel;verticalLabelPosition=bottom;verticalAlign=top;displayedLabel=Dir Pin %s Enable %s<br>on Arduino card %s"]
        x.graphics.exprs=[string(Pindir),string(Pinen),string(num_arduino)];
    end
endfunction
