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

function []=ARDUINO_post_simulate(%cpr, scs_m, needcompile)

    global port_com h1 h2 h3 h4 h5

    presence_arduino=%f //indique la presence d'un bloc arduino setup
    // find SCOPE bloc for plotting at the end of simulation
    presence_scope=%f;
    list_scope=[];
    display_now=1;
    grid_on=1;


    for i = 1:size(scs_m.objs)
        curObj= scs_m.objs(i);
        if (typeof(curObj) == "Block" & curObj.gui == "ARDUINO_SETUP")
            presence_arduino=%t   
                
                // 20191014: TCL: to handle multiple COM ports
                handle_num=scs_m.objs(i).model.rpar(1)
                handle_str = 'h'+string(handle_num);
                
            try
                //closeserial(port_com)
                [a,b,c]=status_serial(evstr(handle_str));
                while (b+c > 0) 
                    [a,b,c]=status_serial(evstr(handle_str));
                end
                close_serial(evstr(handle_str))
                disp('Close serial port ok')
            catch
                messagebox("The serial port can''t be closed.")
                error('close serial port')

            end
        elseif (typeof(curObj) == "Block" & curObj.gui == "TIME_SAMPLE") then
            if exists(curObj.graphics.exprs(3)) then
                display_now=evstr(curObj.graphics.exprs(3));
            else
                display_now=1
            end

        elseif (typeof(curObj) == "Block" & curObj.gui == "ARDUINO_SCOPE")
            presence_scope=%t 
            list_scope($+1)=i;
        end

    end

    // adjust scope and add grid
    if presence_scope & ~display_now then
        plot_aftersim_ard2(list_scope,scs_m)
        //   elseif presence_scope & display_now then
        //       plot_aftersim_ard1(list_scope,scs_m)
    else
        nicescope()
        if grid_on then
            list_fig=winsid();
            for i=list_fig
                scf(i);
                xgrid;
            end
        end
    end  

    disp('Fin post_simulate')

endfunction

function plot_aftersim_ard1(list_scope,scs)
    nb_outputs_by_scope=[];
    nb_outputs=[]
    nb_total_outputs=0;
    nb_scope=size(list_scope,1);
    legendes=cell();
    //    grid_on=0;
    list_fig=winsid();

    for i=1:size(list_scope,1)
        scf(list_fig(i));
        j=list_scope(i);
        obj=scs_m.objs(j);       
        nb_outputs($+1)=evstr(obj.graphics.exprs(1));
        legendes(i).entries=obj.graphics.exprs(3:$);
        nb_total_outputs=nb_total_outputs+nb_outputs($);
        legend(legendes(i).entries);
    end
    nicescope() 
    xgrid
endfunction


function plot_aftersim_ard2(list_scope,scs)

    nb_outputs_by_scope=[];
    nb_total_outputs=0;
    nb_scope=size(list_scope,1);
    legendes=cell();
    //    grid_on=0;

    for i=1:size(list_scope,1)
        j=list_scope(i);
        obj=scs_m.objs(j);       
        nb_outputs($+1)=evstr(obj.graphics.exprs(1));
        legendes(i).entries=obj.graphics.exprs(3:$);
        nb_total_outputs=nb_total_outputs+nb_outputs($);
    end

    c_color=[[0.75,0.75,0];[0.25,0.25,0.25];[0,0,1];[0,0.5,0];[1,0,0];[0,0.75,0.75];[0.75,0,0.75]];
    handle_fig=figure();
    set(handle_fig,"background",8)
    drawlater();
    //extraction des champs stockés
    D=[];
    legend_c=[];
    nb_objs_in_scopeblock=5;

    for i=1:nb_scope
        subplot(nb_scope,1,i);
        //legend_c=strsplit(scs.objs(num_scope(i)).graphics.exprs(2)," ");
        legend_c=legendes(i).entries;
        if size(legend_c,1)~=nb_outputs(i) then
            legend_c=_gettext("curv")+string([1:nb_outputs(i)]);
        end

        list_obj=scs_m.objs(list_scope(i)).model.rpar.objs;
        no=1;
        for j=1:size(list_obj)
            if (typeof(list_obj(j)) == "Block" & list_obj(j).gui == "TOWS_c") then
                label=list_obj(j).graphics.exprs(2);
                D(i,no)=evstr(label);
                no=no+1;                                    
            end
        end

        for no=1:nb_outputs(i)
            plot(D(i,no).time,D(i,no).values,'color',[c_color(modulo(no,6)+1,1),c_color(modulo(no,6)+1,2),c_color(modulo(no,6)+1,3)],'thickness',2)
        end
        h=legend(legend_c);
        set(h,"background",8)
        xgrid

        //title("scope_"+string(i));
    end
    drawnow();
endfunction


