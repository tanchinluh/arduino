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

function [x, y, typ]=ARDUINO_MPU6050_READ(job, arg1, arg2)
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
          [ok,list_data,num_arduino,exprs]=scicos_getvalue(['Arduino MPU6050 parameters' ],..
                                         [gettext('Data to read (y;p;r;ax;ay;az;wx;wy;wz)'),gettext('Arduino card number')],list('str',-1,'str',-1), exprs)
          mess=[];

          if ~ok then
              break;
          end
          
//          if num_arduino<>"1" then
//              mess=[mess ;gettext("Only card 1 can be used with this toolbox version ")];
//              ok=%f;
//          end
            if num_arduino > maxboard then
                 mess=[mess ;gettext("Only "+string(maxboard)+" can be used with this toolbox version ")];
                ok=%f;
            end
          

          list_data2=stripblanks(strsplit(list_data,";"))
          nb_val=size(list_data2,1)
          possible_values=["y";"p";"r";"ax";"ay";"az";"wx";"wy";"wz"] //ordre emis par le MPU6050
          rep_data=[]
          for i=1:nb_val
              rep=find(list_data2(i)==possible_values)
              if isempty(rep) then
                  mess=[mess ;gettext("Value '""+list_data2(i)+"'" is not accepted")];
                  ok=%f
              else
                  rep_data=[rep_data;rep]
              end
          end

          if ok then
// Everything's ok
              model.rpar=rep_data;
              model.ipar=evstr(num_arduino)
              model.out=ones(nb_val,1)
              strE=strsubst(string(ones(nb_val,1)),"1","E")
              graphics.out_implicit=strE
              graphics.exprs = exprs;
              graphics.out_label=list_data2
              x.model=model;
              x.graphics = graphics;
              break
          else
              message(mess);
          end

      end  
     case 'define' then
      model=scicos_model();
      model.sim=list("ARDUINO_MPU6050_sim", 5)
      model.blocktype='d';
      model.dep_ut=[%f %f];
      model.out=[1;1;1];
      model.evtin=[1];
      model.evtout=[1];
      model.firing=[0;-1]
      model.rpar=[1;2;3]
      model.ipar=1
      x=standard_define([2 2],model,[],[]);
      x.graphics.exprs=["y;p;r";"1"]
      x.graphics.out_implicit=['E';'E';'E'];
      x.graphics.in_label=["y";"p";"r"]
      x.graphics.style=["blockWithLabel;verticalLabelPosition=bottom;verticalAlign=top;displayedLabel=MPU6050read"]
    end
endfunction
