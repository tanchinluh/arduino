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

function []=post_xcos_simulate(%cpr, scs_m, needcompile)
    global port_com port_TCL;

    callXcos_Param_Var=%f //Définit s'il faut appeler la fonction de variation paramètrique
    callXcos_Param_Freq = %f;
    callRep_freq = %f;   // Lance la fonction de tracés des réponses fréquentielles.
    presence_param_var=%f // indique la présence d'un bloc param_var
    presence_rep_freq=%f  //idem pour rep freq
    presence_imprimante=%f  //indique la presence d'un bloc imprimante
    presence_bloc_end=%f    //indique la presence d'un bloc END (pour faire une reponse temporelle)
    presence_scope=%f   //indique la presence d'un bloc scope personnalisé
    presence_rep_temp=%f   //indique la presence d'un bloc pour faire une reponse temporelle
    presence_irep_temp=%f   //indique la presence d'un bloc pour faire une reponse temporelle IREP TEMP
    presence_arduino=%f   //indique la presence d'un bloc pour faire une reponse temporelle ARDUINO

    for i = 1:size(scs_m.objs)
        curObj= scs_m.objs(i);
        if (typeof(curObj) == "Block" & curObj.gui == "PARAM_VAR")
            presence_param_var=%t
        elseif (typeof(curObj) == "Block" & curObj.gui == "REP_FREQ")
            presence_rep_freq=%t
        elseif (typeof(curObj) == "Block" & curObj.gui == "IMPRIMANTE")
            disp("ok post")
            presence_imprimante=%t
            values= "P" + ascii(0) + ascii(0)
            writeserial(port_TCL,values);
            sleep(100)
            values= "P" + ascii(0) + ascii(0)
            writeserial(port_TCL,values);
            sleep(100)
            closeserial(port_TCL);
        elseif (typeof(curObj) == "Block" & curObj.gui == "ENDBLK")
            presence_bloc_end=%t
        elseif (typeof(curObj) == "Block" & curObj.gui == "REP_TEMP")
            presence_rep_temp=%t
        elseif (typeof(curObj) == "Block" & curObj.gui == "SCOPE")
            presence_scope=%t
        elseif (typeof(curObj) == "Block" & curObj.gui == "IREP_TEMP") then
            presence_irep_temp=%t
        elseif (typeof(curObj) == "Block" & curObj.gui == "ARDUINO_SETUP") then
            presence_arduino=%t
        end
    end

    if presence_arduino then
        ARDUINO_post_simulate(scs_m)
        return
    end

    if presence_irep_temp then
        SIMM_post_simulate(scs_m)
        return
    end

    if  presence_rep_temp then
        REP_TEMP_post_simulate(scs_m);
    end

    if  presence_param_var & ~presence_rep_freq
        callXcos_Param_Var = %t;
    end

    if  presence_param_var & presence_rep_freq
        callXcos_Param_Freq = %t;
    end

    if ~presence_param_var & presence_rep_freq
        callRep_freq = %t;
    end

    if ~presence_scope & ~presence_rep_freq then
        // On ajuste les scopes
        nicescope()
    end

    if presence_rep_freq & ~presence_param_var
        REP_FREQ_pre_simulate(scs_m, needcompile);
    end

    if  presence_imprimante==%t then
        //global inc;
        //PIC_end_of_simul() //deconnexion prealable du port serie au cas où.
    end

endfunction
