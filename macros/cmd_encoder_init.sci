function cmd_encoder_init(h,enc_mode,pin_no_1,pin_no_2)
    
    
    //Eajkl: activate encoder on channelA on INT number j (j=ascii(2 or 3 or 18 or 19 or 20 or 21) et channelB on pin k or INT number k (k=ascii(0)..ascii(53)) and l=1 or 2 or 4 for 1x mode (count every rising of chA) or 2x mode (count every change statement of chA) or  4x mode (every change statement of chA et chB)
    
       code_sent="Ea"+ascii(0+corresp(block.rpar(3))); //on envoie plus le PIN mais le numéro d'interruption
          if  block.rpar(2)==4 then //mode4
              code_sent=code_sent+ascii(0+corresp(block.rpar(4)))+string(block.rpar(2));// on envoie le num d'interruption
          else//mode 1 ou 2
              code_sent=code_sent+ascii(0+block.rpar(4))+string(block.rpar(2));//on envoie le num de PIN en mode 1x/2x
          end

//          writeserial(port_com,code_sent); 
          write_serial(1,code_sent,5)
          code_sent="Ez"+ascii(corresp(block.rpar(3)));
//          writeserial(port_com,code_sent); 
          write_serial(1,code_sent,3)
endfunction
