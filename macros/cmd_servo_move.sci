function cmd_servo_move(h,servo_no,u1)
// Command to run servo motor which has been setup
//
// Calling Sequence
//     cmd_servo_move(h,servo_no,u1)
//
// Parameters
//     h : Board pointer, to indicate which board to use to differentiate one board from another
//     servo_no : 1=pin 9, 2=pin 10
//     u1 : 0 - 180 degree
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
//    cmd_servo_setup
//    cmd_servo_detach
//    
// Authors
//     Bruno JOFRET, Tan C.L. 
//    
      if (u1<0) then
          pin="Sw"+ascii(48+servo_no)+ascii(0);
      elseif u1>180 then
          pin="Sw"+ascii(48+servo_no)+ascii(180);
      else
          pin="Sw"+ascii(48+servo_no)+ascii(uint8(u1));
      end
      write_serial(1,pin,4);
              
endfunction
