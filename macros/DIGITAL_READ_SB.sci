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

function [x, y, typ]=DIGITAL_READ_SB(job, arg1, arg2)
    x=[];
    y=[];
    typ=[];
    maxboard = 2;
    
    style = "DIGITAL_READ_SB;blockWithLabel;" + ..
            "verticalLabelPosition=bottom;verticalAlign=top;spacing=-2;align=center;"+..
            "displayedLabel=Digital READ<br>Pin %s on board %s"
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
            [ok,num_pin,num_arduino,exprs]=scicos_getvalue(['Arduino Digital Read parameters' ; 'UNO digital PIN are : 0 to 13.'; 'MEGA digital PIN are : 0 to 53.'],..
            [gettext('Digital Pin'),gettext('Arduino board number')],list('vec',1,'vec',1), exprs)
            mess=[];

            if ~ok then// Cancel
                break;
            end
            if num_arduino > maxboard then
                mess=[mess ;gettext("Only "+string(maxboard)+" can be used with this toolbox version ")];
                ok=%f;
            end
            if num_pin < 3 | num_pin>53
                mess=[mess ;_("Digital Pin must be between 3 and 53.")]
                ok = %f
            end

            if ok then// Everything's ok
                rpar=[num_pin,num_arduino];
                model.rpar.objs(1).model.rpar=rpar;
                model.rpar.objs(1).graphics.exprs= string(rpar);
                graphics.exprs = string(rpar);

                x.model=model;
                x.graphics = graphics;
                x.graphics.style = msprintf(style, exprs')
                break
            else
                message(mess);
            end

        end
    case 'define' then
        diagram=scicos_diagram();
        arduino_comp=ARDUINO_DIGITAL_READ('define')
        arduino_comp.graphics.pein = 3;
        arduino_comp.graphics.peout = 3;
        arduino_comp.graphics.pout = 4;
        output_port=OUT_f('define')
        output_port.graphics.exprs=["1"]
        output_port.model.ipar=[1]
        output_port.graphics.pin=4;

        diagram.objs(1)=arduino_comp;
        diagram.objs(2)=output_port;
        diagram.objs(3)=scicos_link(xx=[0 ; 0],yy=[0 ; 0], ct=[5, -1], from=[1, 1,0], to=[1, 1,1])
        diagram.objs(4)=scicos_link(xx=[0 ; 0],yy=[0 ; 0], ct=[1,1], from=[1, 1,0], to=[2, 1,1])

        model=scicos_model();
        model.sim='csuper'
        model.blocktype='h';
        model.dep_ut=[%f %f];
        model.rpar=diagram
        model.out=-1
        model.out2=-2
        model.outtyp=-1
        Pin=3; num_arduino=1;
        x=standard_define([2 2],model,[],[]);
        x.graphics.out_implicit=['E'];
        tmp = [string(Pin),string(num_arduino)]
        x.graphics.style = msprintf(style, tmp);
        x.graphics.exprs = tmp;
    end
endfunction
