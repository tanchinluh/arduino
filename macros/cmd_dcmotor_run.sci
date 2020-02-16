function cmd_dcmotor_run(h,motor_no,u1)
// Command to run DC motor after setting up
//
// Calling Sequence
//     cmd_dcmotor_run(h,motor_no,u1)
//
// Parameters
//     h : Board pointer, to indicate which board to use to differentiate one board from another
//     motor_no : ID in which the motor has been connected
//     u1 : Value to sent, range from -255 to 255, for clockwise and anti-clockwise direction
//
// Description
//     Arduino board does not deliver enough power, so it is necessary to use a H-bridge circuit/IC to control the motor. There are several types of H-bridge IC that do not all operate on the same principle. For example, the L298 requires the use of a PWM signal with current sense. The L293 uses two PWM to set the speed and direction. Ready-to-use Shields are also available.
//
//     Remember that the PWM is 8-bit (0 to 255). The input of the block could accept any value, but it would saturate at +- 255. 
//  
// Examples
//     h = open_serial(1,9,115200) 
//     cmd_dcmotor_setup(h,3,1,9,10)  // Setup DC motor of type 3 (L293), motor 1, pin 9 and 10  
//     cmd_dcmotor_run(h,1,255) 
//     sleep(1000)
//     cmd_dcmotor_run(h,1,-255)
//     sleep(1000)
//     cmd_dcmotor_release(h,1) 
//     close_serial(h)

// See also
//    cmd_dcmotor_setup
//    cmd_dcmotor_release
//    
// Authors
//     Bruno JOFRET, Tan C.L. 
//    
      direction=sign(u1);

          if direction>=0 then
              code_dir=ascii(49);
          else
              code_dir=ascii(48);
          end
          if abs(u1)>255 then
              val=255;
          else
              val=abs(ceil(u1));
          end
          
          code_sent="M"+ascii(48+motor_no)+code_dir+ascii(val);
          write_serial(h,code_sent,4)
//      end


endfunction
