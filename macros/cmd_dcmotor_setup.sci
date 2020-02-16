function cmd_dcmotor_setup(h,driver_type,motor_no,pin_no_1,pin_no_2)
// Command to setup pins to control DC motor
//
// Calling Sequence
//     cmd_dcmotor_setup(h,driver_type,motor_no,pin_no_1,pin_no_2)
//
// Parameters
//     h : Board pointer, to indicate which board to use to differentiate one board from another
//     driver_type : 1=Motorshield Rev3, 2=L298, 3=L293
//     motor_no : ID used to identify motor to be connected
//     pin_no_1 : Depends on the driver type, choose the correct pins for the purpose. For example, using L293 require PWM pin to be selected.
//     pin_no_2 : Depends on the driver type, choose the correct pins for the purpose. For example, using L293 require PWM pin to be selected.
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
//    cmd_dcmotor_run
//    cmd_dcmotor_release
//    
// Authors
//     Bruno JOFRET, Tan C.L. 
//    
                    
    disp("init DCmotor")
    if(driver_type==1) then
        //code_sent="91";
        code_sent="C"+string(motor_no)+ascii(48+pin_no_1)+ascii(48+pin_no_2)+"1";    //adafruit
    elseif (driver_type==2) then
        code_sent="C"+string(motor_no)+ascii(48+pin_no_1)+ascii(48+pin_no_2)+"1";   //code pour initialiser L298
    elseif (driver_type==3) then
        code_sent="C"+string(motor_no)+ascii(48+pin_no_1)+ascii(48+pin_no_2)+"0";   //code pour initialiser L293
    end

    write_serial(h,code_sent,5)


    //Attente que l'arduino reponde OK
    [a,b,c]=status_serial(1);
    while (b < 2) 
        [a,b,c]=status_serial(1);
    end
    values=read_serial(1,2);
    if (values == 'OK') then
        disp('Init motor successful')
    else
        disp('Init motor unsuccessful')
    end

endfunction
