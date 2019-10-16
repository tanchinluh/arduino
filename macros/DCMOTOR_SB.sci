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

function [x, y, typ]=DCMOTOR_SB(job, arg1, arg2)
    x=[];
    y=[];
    typ=[];
    maxboard = 2;
    style = "DCMOTOR_SB;blockWithLabel;"+..
            "verticalLabelPosition=bottom;verticalAlign=top;spacing=-2;align=center;"+..
            "displayedLabel=Typeshield %s<br>on board %s"
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
            [ok1,type_shield,num_arduino,exprs1]=scicos_getvalue(..
            ['Arduino DC MOTOR parameters'
             ' '
             '(a) 1: MotorShield Rev3, 2: PMODHB5 or L298 based, 3: L293 (2 PWM)'
             ],..
            [gettext('Type of Shield (a) 1|2|3');..
             gettext('Arduino board number')],list('vec',1,'vec',1), exprs(1:2))
            mess=[];

            if ~ok1 then break; end //cancel

            if num_arduino > maxboard then
                mess=[mess ;gettext("Only "+string(maxboard)+" can be used with this toolbox version ")];
                ok1=%f;
            end
            if type_shield~=1 & type_shield~=2 & type_shield~=3 
                mess=[mess ;_("Type shield must be 1, 2 or 3")]
                ok1 = %f
            end

            if ok1 then
                num_pin_1=0; num_pin_2=0;  
                if type_shield==1 then //get number of motor (between 1 et 2)
                    [ok,motor_number,exprs2]=scicos_getvalue('Motorshield Rev 3 parameters',..
                    [gettext('Channel for DC motor : A (type 1) or B (type 2)')],list('vec',1), exprs(5))
                    if ~ok then break;  end //cancel
                    if (motor_number <1 | motor_number > 2)
                        mess=[mess ;_("Motor number must be 1 or 2 for Motorshield Rev 3 board")]
                        ok = %f
                    end      
                    if motor_number==1 then
                        num_pin_1=12;
                        num_pin_2=3;
                    else
                        num_pin_1=13;
                        num_pin_2=11;
                    end
                elseif  type_shield==2 then
                    [ok,num_pin_1,num_pin_2,motor_number,exprs2]=scicos_getvalue('PMODHB5 or L298 driver parameters',..
                    [gettext('Direction pin ');gettext('Enable (speed) Pin');gettext('Motor number (between 1 and 4)')],list('vec',1,'vec',1,'vec',1), exprs(3:5))
                    if ~ok then break;  end //cancel  
                    if (motor_number < 1 | motor_number>4)
                        mess=[mess ;_("Motor number must be between 1 and 4")]
                        ok = %f
                    end                      
                elseif  type_shield==3 then
                    [ok,num_pin_1,num_pin_2,motor_number,exprs2]=scicos_getvalue('L293 driver parameters (control 2 PWM)',..
                    [gettext('PWM 1 Pin');gettext('PWM 2 Pin');gettext('Motor number (between 1 and 3)')],list('vec',1,'vec',1,'vec',1), exprs(3:5))
                    if ~ok then break;  end //cancel  
                    if (motor_number < 1 | motor_number>4)
                        mess=[mess ;_("Motor number must be between 1 and 4")]
                        ok = %f
                    end   
                end

                if ok  then
                    rpar=[type_shield;num_arduino;num_pin_1;num_pin_2;motor_number];
                    // Everything's ok
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

            else 
                message(mess);
            end
        end

    case 'define' then
      diagram=scicos_diagram();
      arduino_comp=ARDUINO_DCMOTOR('define')
      arduino_comp.graphics.pein = 3;
      arduino_comp.graphics.peout = 3;
      arduino_comp.graphics.pin = 4;
      input_port=IN_f('define')
      input_port.graphics.exprs=["1"]
      input_port.model.ipar=[1]
      input_port.graphics.pout=4;
      
      diagram.objs(1)=arduino_comp;
      diagram.objs(2)=input_port;
      diagram.objs(3)=scicos_link(xx=[0 ; 0],yy=[0 ; 0], ct=[5, -1], from=[1, 1,0], to=[1, 1,1])
      diagram.objs(4)=scicos_link(xx=[0 ; 0],yy=[0 ; 0], ct=[1,1], from=[2, 1,0], to=[1, 1,1])
      
      model=scicos_model();
      model.sim='csuper'
      model.blocktype='h';
      model.dep_ut=[%f %f];
      model.rpar=diagram
      model.in=-1
      model.in2=-2
      model.intyp=-1
        num_arduino=1; type_shield=1; num_pin_1=13; num_pin_2=11; motor_number=1;
        x=standard_define([2 2],model,[],[]);
        x.graphics.in_implicit=['E'];
        tmp = string([type_shield;num_arduino;num_pin_1;num_pin_2;motor_number])
        x.graphics.style = msprintf(style, tmp(1:2)')
        x.graphics.exprs = tmp;
    end
endfunction
