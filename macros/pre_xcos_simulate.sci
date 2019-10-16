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

global port_com port_TCL taskAI0 bufferSizeNI;

function continueSimulation=pre_xcos_simulate(scs_m, needcompile)
    global port_com port_TCL taskAI0;

    continueSimulation = %t;
    callXcos_Param_Var=%f //Définit s'il faut appeler la fonction de variation paramètrique
    callXcos_Param_Freq = %f;
    callRep_freq = %f;
    presence_param_var=%f // indique la présence d'un bloc param_var
    presence_rep_freq=%f  //idem pour rep freq
    presence_imprimante=%f  //indique la presence d'un bloc imprimante
    presence_bloc_end=%f    //indique la presence d'un bloc END (pour faire une reponse temporelle)
    presence_rep_temp=%f   //indique la presence d'un bloc pour faire une reponse temporelle
    presence_irep_temp=%f  //indique la presence d'un bloc pour faire une reponse temporelle avec SIMM
    presence_scope=%f   //indique la presence d'un bloc scope personnalisé
    presence_arduino=%f //indique la presence d'un bloc arduino setup
    presence_NI600X=%f //indique la presence d'un bloc NI600X

    for i = 1:size(scs_m.objs)
        curObj= scs_m.objs(i);
        if (typeof(curObj) == "Block" & curObj.gui == "PARAM_VAR")
            presence_param_var=%t
        elseif (typeof(curObj) == "Block" & curObj.gui == "REP_FREQ")
            presence_rep_freq=%t
            //freq_temp_analysis=curObj.model.rpar(5);
        elseif (typeof(curObj) == "Block" & curObj.gui == "IMPRIMANTE")
            presence_imprimante=%t
            block_imprimante=curObj;
            scs_m.props.tol(5)=1;
        elseif (typeof(curObj) == "Block" & curObj.gui == "ENDBLK")
            presence_bloc_end=%t
        elseif (typeof(curObj) == "Block" & curObj.gui == "REP_TEMP")
            presence_rep_temp=%t
        elseif (typeof(curObj) == "Block" & curObj.gui == "ARDUINO_SETUP")
            presence_arduino=%t
        elseif (typeof(curObj) == "Block" & curObj.gui == "IREP_TEMP")
            presence_irep_temp=%t
        elseif (typeof(curObj) == "Block" & curObj.gui == "SCOPE")
            presence_scope=%t
        elseif (typeof(curObj) == "Block" & curObj.gui == "NI600X_C_READ")
            presence_NI600X=%t
            block_NI600X=curObj;
            scs_m.props.tol(5)=1;
        end
    end

    if presence_NI600X then
        init_NI(block_NI600X);
    end

    if  presence_imprimante==%t then
        continueSimulation=init_imprimante(block_imprimante)
    end

    if  presence_arduino==%t then
        scs_m=ARDUINO_pre_simulate(scs_m);
        continueSimulation = %t;
        //        scs_m=resume(scs_m)
        //        return;
    end

    if ~presence_rep_freq then
        if (~presence_rep_temp &  presence_scope )
            message("Insert a REP_TEMP block whether you wish to perform a time analysis with one or several SCOPE blocks")
            continueSimulation = %f;
            return
        end
    end

    if presence_rep_temp then
        scs_m=REP_TEMP_pre_simulate(scs_m);
        continueSimulation = %t;
    end

    if presence_irep_temp then
        scs_m=SIMM_pre_simulate(scs_m);
        continueSimulation = %t;
        //        scs_m=resume(scs_m)
        //        return;
    end


    if  presence_param_var & ~presence_rep_freq then
        continueSimulation=Param_Temp_pre_simulate(scs_m,needcompile);
    end

    if  presence_param_var & presence_rep_freq then
        if presence_rep_temp then
            continueSimulation=Param_Temp_pre_simulate(scs_m,needcompile);
        end
        Param_Freq_pre_simulate(scs_m, needcompile);
        continueSimulation = %f; //pour ne pas avoir un 2ème affichage : les scopes sont gérés par le Param_Var_pre_simulate
    end

    if presence_rep_freq & presence_scope & ~presence_rep_temp & ~presence_param_var  then
        disp('Simulation duration set to 0')
        scs_m.props.tf=0;
        //Param_Freq_pre_simulate(scs_m, needcompile);
        continueSimulation = %t;
    end
    scs_m=resume(scs_m)

endfunction
