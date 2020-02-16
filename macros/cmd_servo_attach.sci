function cmd_servo_attach(h,servo_no)
// Command to attach servo motor to Arduino
//
// Calling Sequence
//     cmd_servo_attach(h,servo_no)
//
// Parameters
//     h : Board pointer, to indicate which board to use to differentiate one board from another
//     servo_no : 1=pin 9, 2=pin 10
//
// Description
//     A servomotor is an rotary actuator consist of an electric motor, gears, a potentiometer and an analogue or digital electronics for control. The servomotor usualy used for a position control application (or speed for continuous rotation servos).
//
//     The user must give the command of the position setpoint or desired speed. This command is sent to the actuator in pulses spaced by 10 to 20 ms. The coding of these pulses is made such that a pulse of 1.5 ms corresponding to the centered position (rest), a pulse of 1 ms corresponds to an angle of 90° in the anticlockwise direction, and a pulse 2 ms corresponds to an angle of 90° clockwise. All other pulse widths give intermediate values​​.
//
//     A servomotor for continuous rotation, the pulse width control the rotational speed and the direction. It is recommended to use a voltage regulator to power the servomotor instead of using the Arduino board power. For simplicity, the function takes an input commnad in degrees from 0 to 180. Two actuators can be controlled with this toolbox. (modified version of 3 motors available)
//  
// Examples
//    h = open_serial(1,9,115200) 
//    cmd_servo_attach(h,1) 
//    sleep(1000)
//    cmd_servo_move(h,1,90) 
//    sleep(1000)
//    cmd_servo_move(h,1,45) 
//    sleep(1000)
//    cmd_servo_detach(h,1)
//    sleep(1000)
//    close_serial(h)
//
// See also
//    cmd_servo_move
//    cmd_servo_detach
//    
// Authors
//     Bruno JOFRET, Tan C.L. 
//    
    disp("init servo write")
       if servo_no==1 then //servo 1 on pin 9
           pin="Sa1"
           write_serial(h,pin,3);
       elseif servo_no==2 then //servo 2 on pin 10
           pin="Sa2"
           write_serial(h,pin,3);
       else
           error('Error')
       end
       
endfunction
