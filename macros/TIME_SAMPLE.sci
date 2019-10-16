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

function [x, y, typ]=TIME_SAMPLE(job, arg1, arg2)
    x=[];
    y=[];
    typ=[];
    style = "TIME_SAMPLE;blockWithLabel;" + ..
            "verticalLabelPosition=center;align=center;"+..
            "displayedLabel=Duration : %s<br>Sampling period : %s"
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
            [ok,tf,period,display_now,exprs]=scicos_getvalue('Time sample parameters',..
            [gettext('Duration of acquisition (s)'),gettext('Sampling period (s)'),gettext('Display curves continuously (1 yes / 0 no)')],                                                        list('vec',1,'vec',1,'vec',1), ..
            exprs)
            mess=[];

            if ~ok then// Cancel
                break;
            end

            if period <0.005 then
                mess=[gettext("sampling period must be greater than 0.005")];
                ok=%f;
            end

            if display_now ~=1 & display_now~=0
                mess=[mess ;_("Choose 1 or 0 to display curves during simulation or at the end")]
                ok = %f
            end

            if ok then// Everything's ok
                model.rpar=[tf,period,display_now];
                graphics.exprs = exprs;
                x.model=model;
                x.graphics = graphics;
                x.graphics.style = msprintf(style, exprs(1:2)');
                break
            else
                message(mess);
            end
        end
    case 'define' then
        model=scicos_model();
        model.sim=list("TIME_SAMPLE", 99)
        model.blocktype='c';
        model.dep_ut=[%f %f];
        model.in=[];
        tf=10;
        period=0.1;
        model.rpar=[tf,period,1]; //Digital Output number
        x=standard_define([6 2],model,[],[]);
        x.graphics.in_implicit=[];
        x.graphics.exprs=[string(tf),string(period),string(1)];
        x.graphics.style = msprintf(style, string(tf),string(period))
    end
endfunction
