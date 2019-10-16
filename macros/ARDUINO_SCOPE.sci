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

function [x,y,typ]=ARDUINO_SCOPE(job,arg1,arg2)

    function diagram=create_xcosdiagram(nb_output,buffer_size)
        diagram=scicos_diagram();
        nb_objs=5;

        for i=1:nb_output
            scope=TOWS_c('define')
            scope.graphics.exprs = [string(buffer_size);"o"+string(i);"0"]
            scope.model.ipar=[buffer_size;2;24;i];
            scope.graphics.pin = nb_objs*(i-1)+4;
            scope.graphics.pein = nb_objs*(i-1)+5;

            clockc=SampleCLK('define')
            clockc.graphics.peout=nb_objs*(i-1)+5
            clockc.graphics.exprs=["0.1" ; "0"]
            clockc.model.rpar = [0.1 ; 0]

            input_port=IN_f('define')
            input_port.graphics.exprs=[string(i)]
            input_port.model.ipar=[i]
            input_port.graphics.pout=nb_objs*(i-1)+4

            diagram.objs(nb_objs*(i-1)+1)=input_port;
            diagram.objs(nb_objs*(i-1)+2)=scope;
            diagram.objs(nb_objs*(i-1)+3)=clockc;
            diagram.objs(nb_objs*(i-1)+4)=scicos_link(xx=[0 ; 0],yy=[0 ; 0], ct=[1, 1], from=[nb_objs*(i-1)+1, 1,0], to=[nb_objs*(i-1)+2, 1,1])
            diagram.objs(nb_objs*(i-1)+5)=scicos_link(xx=[0 ; 0],yy=[0 ; 0], ct=[5, -1], from=[nb_objs*(i-1)+3, 1,0], to=[nb_objs*(i-1)+2, 1,1])
        end
    endfunction

    x=[];y=[];typ=[];
    select job
    case 'set' then
        x=arg1;
        graphics=arg1.graphics;
        exprs=graphics.exprs
        model=arg1.model;

        while %t do
            [ok,nb_output,buffer_size,exprs]=scicos_getvalue(_('Scope parameters'),..
            [_('Number of superimposed curves (legends in next dialog)'),_("Buffer size")], ..
            list('vec',1,'vec',1), ..
            exprs(1:2))

            mess=[];
            if ~ok then
                // Cancel
                break;
            end

            if nb_output <= 0 | nb_output>=8
                mess=[mess ;_("Number of superimposed curves must be between 1 and 8")]
                ok = %f
            end


            if ok then
                in = ones(nb_output,1);
                a = nb_output;
                in2 = ones(a,1);
                //[model,graphics,ok]=set_io(model,graphics,list(),list(),[],[],list([in in2],ones(a,1)),list());


                string_in=string(in);
                graphics.in_implicit=strsubst(string_in,"1","E");
                model.in=-1*in;
                model.in2=-2*in;
                model.intyp=-1*in;

                diagram=create_xcosdiagram(nb_output,buffer_size);

                model.rpar=diagram;
                graphics.exprs(1:2) = exprs(1:2);
                x.model=model;
                x.graphics = graphics;
                break
            else
                message(mess);
            end

        end

        if ok  then

            str_gettext='[';
            labels='';
            list_='list(';
            names_='[';

            for i=1:nb_output
                labels=labels+'label'+string(i)+',';
                str_gettext=str_gettext+'gettext(''Curve name '+string(i)+''')'
                list_=list_+'''str'',-1';
                if size(graphics.exprs,1)==nb_output+2 then
                    names_=names_+''''+graphics.exprs(2+i)+'''';
                else
                    names_=names_+"''Curve "+string(i)+"''"
                end
                if i~=nb_output then
                    str_gettext=str_gettext+';';
                    list_=list_+",";
                    names_=names_+";";
                else
                    str_gettext=str_gettext+']';
                    list_=list_+')';
                    names_=names_+"]";
                end
            end

            exec_string='[ok,'+labels+'exprs]=scicos_getvalue(''Optional parameters'','+str_gettext+','+list_+','+names_+')';

            while %t do

                execstr(exec_string);

                if ~ok then
                    break;
                end

                if ok then
                    graphics.exprs= [graphics.exprs(1:2);exprs];
                    x.model=model;
                    x.graphics = graphics;
                    break
                else
                    message(mess);
                end
            end
        end

    case 'define' then
        nb_output = 1;
        nb_pts=200;
        labels="Curve";

        diagram=create_xcosdiagram(nb_output,nb_pts);

        model = scicos_model();
        model.sim='csuper'
        model.in=-1
        model.in2=-2
        model.intyp=-1
        model.blocktype='h'
        model.dep_ut=[%f %f]
        model.rpar=diagram
        x = standard_define([2 2], model, "", [])
        x.graphics.in_implicit=["E"];
        x.graphics.exprs=[string(nb_output);string(nb_pts);labels]
    end
endfunction

