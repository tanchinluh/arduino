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

function [x, y, typ]=MPU6050_READ_SB(job, arg1, arg2)
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
                                         [gettext('Data to read (y;p;r;ax;ay;az;wx;wy;wz)'),gettext('Arduino card number')],list('str',-1,'vec',1), exprs)
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
              
              
              val=possible_values(rep_data)
              diagram=scicos_diagram();
              nb_val=size(val,1)
              arduino_comp=ARDUINO_MPU6050_READ('define')
              arduino_comp.model.rpar=rep_data
              arduino_comp.model.ipar=evstr(num_arduino)
              arduino_comp.graphics.pein = 2+nb_val;
              arduino_comp.graphics.peout = 2+nb_val;
              arduino_comp.graphics.pout = [3+nb_val:2+2*nb_val]';
              arduino_comp.graphics.exprs=[val;"1"]
              arduino_comp.model.out=ones(nb_val,1)
              arduino_comp.graphics.out_implicit=strsubst(string(ones(nb_val,1)),"1","E")
              diagram.objs(1)=arduino_comp;
              
              for i=1:nb_val
                  diagram.objs(i+1)=OUT_f('define')
                  diagram.objs(i+1).graphics.exprs=[string(i)]
                  diagram.objs(i+1).model.ipar=[i]
                  diagram.objs(i+1).graphics.pin=2+nb_val+i;
              end
              diagram.objs(nb_val+2)=scicos_link(xx=[0 ; 0],yy=[0 ; 0], ct=[5, -1], from=[1, 1,0], to=[1, 1,1])
              for i=1:nb_val
                  diagram.objs(2+nb_val+i)=scicos_link(xx=[0 ; 0],yy=[0 ; 0], ct=[1,1], from=[1, i,0], to=[i+1, 1,1])
              end
              
              model.rpar=diagram
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
      diagram=scicos_diagram();
      val="y;p;r"
      nb_val=3
      arduino_comp=ARDUINO_MPU6050_READ('define')
      arduino_comp.model.rpar=[1;2;3]
      arduino_comp.model.ipar=1
      arduino_comp.graphics.pein = 2+nb_val;
      arduino_comp.graphics.peout = 2+nb_val;
      arduino_comp.graphics.pout = [3+nb_val:2+2*nb_val]';
      arduino_comp.graphics.exprs=[val;"1"]
      arduino_comp.model.out=ones(nb_val,1)
      arduino_comp.graphics.out_implicit=strsubst(string(ones(nb_val,1)),"1","E")
      diagram.objs(1)=arduino_comp;
      
      for i=1:nb_val
          diagram.objs(i+1)=OUT_f('define')
          diagram.objs(i+1).graphics.exprs=[string(i)]
          diagram.objs(i+1).model.ipar=[i]
          diagram.objs(i+1).graphics.pin=2+nb_val+i;
      end
      diagram.objs(nb_val+2)=scicos_link(xx=[0 ; 0],yy=[0 ; 0], ct=[5, -1], from=[1, 1,0], to=[1, 1,1])
      for i=1:nb_val
          diagram.objs(2+nb_val+i)=scicos_link(xx=[0 ; 0],yy=[0 ; 0], ct=[1,1], from=[1, i,0], to=[i+1, 1,1])
      end

      model=scicos_model();
      model.sim='csuper'
      model.blocktype='h';
      model.dep_ut=[%f %f];
      model.rpar=diagram
      model.out=ones(nb_val,1)
      x=standard_define([2 2],model,[],[]);
      x.graphics.exprs=["y;p;r";"1"]
      x.graphics.out_implicit=strsubst(string(ones(nb_val,1)),"1","E")
      list_data=stripblanks(strsplit(val,";"))
      x.graphics.out_label=list_data
      x.graphics.style=["blockWithLabel;verticalLabelPosition=bottom;verticalAlign=top;displayedLabel=MPU6050read"]
    end
endfunction
