function cmd_dcmotor_release(h,motor_no)
// Command to release pins which have setup for DC motor 
//
// Calling Sequence
//     cmd_dcmotor_release(h,motor_no)
//
// Parameters
//     h : Board pointer, to indicate which board to use to differentiate one board from another
//     motor_no : ID in which the motor has been connected
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
      code_sent="M"+ascii(48+motor_no)+"1"+ascii(0);
      write_serial(h,code_sent,4);
      
         code_sent="M"+ascii(48+motor_no)+"r";
        write_serial(h,code_sent,3)
endfunction
