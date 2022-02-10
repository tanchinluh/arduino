//
// Scilab ( http://www.scilab.org/ ) - This file is part of Scilab
// Copyright (C) 2010-2010 - DIGITEO -
//
// This file must be used under the terms of the CeCILL.
// This source file is licensed as described in the file COPYING, which
// you should have received as part of this distribution.  The terms
// are also available at
// http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
//
// Is this being used???

function []=init_arduino(scs_m, needcompile)
    disp("Initializing Arduino...");
    scs=[]
    // On recopie le scs_m
    scs=scs_m;
    // Retrieve all objects
    objs = scs_m.objs;

    nombre_blocs=0;    //Nombre de blocs dans le diagramme
    nombre_liens=0;    //Nombre de lien dans le diagramme
    nb_arduino=0; //nombre de cartes arduino
    port_com_arduino=list();    //numero des ports com associes a chaque carte arduino

    //liste des types de blocs arduino
    list_arduino_gui=["ARDUINO_DIGITAL_WRITE","ARDUINO_DIGITAL_READ","ARDUINO_ANALOG_WRITE","ARDUINO_ANALOG_READ","ARDUINO_DCMOTOR","ARDUINO_SERVO_WRITE","ARDUINO_SERVO_READ","ARDUINO_STEPPER","ARDUINO_ENCODER"];
    //initialisation des tableaux utilisés pour stocker les pin et type des blocs du schéma
    nb_block_by_type=[]
    arduino_pin_by_typeblock=cell(size(list_arduino_gui,2),1)
    for i=1:size(list_arduino_gui,2)
        nb_block_by_type($+1)=0;
        arduino_pin_by_typeblock(i).entries=[];
    end

    //Récupère le nombre de blocs dans le modèle
    for i=1:size(objs)
        if typeof(objs(i))=='Block' then
            nombre_blocs=nombre_blocs+1;
        end
    end

    // Passe en revue tous les blocs pour relever dans des tableaux chacun des types de blocs
    for i=1:nombre_blocs
        if objs(i).gui=="ARDUINO_SETUP" then nb_arduino=nb_arduino+1;
            port_com_arduino(objs(i).model.rpar(1))=objs(i).model.opar(1); //on stocke le numero du com de la carte numerotée dans le bloc
        end
        //pour chaque bloc on releve le pin indiqué et on le stocke dans la catégorie correspondante
        rep=find(objs(i).gui==list_arduino_gui);
        if ~isempty(rep) then
            nb_block_by_type(rep)=nb_block_by_type(rep)+1;
            arduino_pin_by_typeblock(rep).entries($+1)=objs(i).model.rpar(1);
        end
    end

    //initialisation des ports_com
    //TODO : ouvrir plusieurs ports_com en fonction du numero de carte
    global port_com
    try
        i=1;
        //port_com=openserial(port_com_arduino(i),"115200,n,8,1"); //ouverture du port com de la carte i
        open_serial(i,port_com_arduino(i),115200); //ouverture du port COM de l'arduino i
        disp("Communication with board "+string(i)+" on com "+string(port_com_arduino(i))+" is ok")

        sleep(2000)
    catch
        messagebox("Wrong communication port")
        error("Wrong communication port")
        disp(lasterror())
        return
    end
    //configuration des Pin Pout
    try
        //mise a zero programme arduino
        //writeserial(port_com,ascii(201)+ascii(201));
        write_serial(1,ascii(201)+ascii(201),2); // utilité ?

        for j=1:size(list_arduino_gui,2)
            disp(list_arduino_gui(j))
            for i=arduino_pin_by_typeblock(j).entries

                if list_arduino_gui(j)=="ARDUINO_DIGITAL_WRITE" then
                    pin="0"+ascii(97+i)+"1";  // élaboration du string à envoyer pour initialiser le pin
                    //writeserial(port_com,pin);  // envoyer le string
                    write_serial(1,pin,3);
                end
                if list_arduino_gui(j)=="ARDUINO_DIGITAL_READ" then
                    pin="0"+ascii(97+i)+"0";
                    //writeserial(port_com,pin);
                    write_serial(1,pin,3);
                end
                if list_arduino_gui(j)=="ARDUINO_ANALOG_WRITE" then
                    pin="0"+ascii(97+i)+"1";
                    //writeserial(port_com,pin);
                    write_serial(1,pin,3);
                end
                if list_arduino_gui(j)=="ARDUINO_ANALOG_READ" then
                    if i~=0 & i~=1 then
                        pin="0"+ascii(97+i)+"0";
                        //writeserial(port_com,pin);
                        write_serial(1,pin,3);
                    end
                end
                if list_arduino_gui(j)=="ARDUINO_DCMOTOR" then
                    disp("motor")
                    code_sent="92";
                    //writeserial(port_com,code_sent);
                    write_serial(1,pin,2);
                end
                if list_arduino_gui(j)=="ARDUINO_STEPPER" then

                end
                if list_arduino_gui(j)=="ARDUINO_SERVO_WRITE" then
                    if i==1 then //servo 1 on pin 10
                        pin="6a1"
                        //writeserial(port_com,pin);
                        write_serial(1,pin,3);
                    elseif i==2 then //servo 2 on pin 9
                        pin="6b1"
                        //writeserial(port_com,pin);
                        write_serial(1,pin,3);
                    else
                        messagebox("Issue about the servomotor id")
                        error('problem')
                    end
                    disp(pin)
                end
                if list_arduino_gui(j)=="ARDUINO_SERVO_READ" then
                    if i==1 then //servo 1 on pin 10
                        pin="6a1"
                        //writeserial(port_com,pin);
                        write_serial(1,pin,3);
                    elseif i==2 then //servo 2 on pin 9
                        pin="6b1"
                        //writeserial(port_com,pin);
                        write_serial(1,pin,3);
                    else
                        messagebox("Issue about the servomotor id")
                        error('problem')
                    end
                    disp(pin)
                end
                if list_arduino_gui(j)=="ARDUINO_ENCODER" then
                    code_sent="E"+string(i)+"a"
                    disp(code_sent)
                    //writeserial(port_com,code_sent);
                    write_serial(1,code_sent,3);
                end
            end
        end
    catch
        error("Wrong communication port")
    end

    disp("Initialization done")
endfunction




















