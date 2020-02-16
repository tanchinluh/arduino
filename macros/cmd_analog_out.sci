function cmd_analog_out(h,pin_no,val)
// Command to sent out analog signal to a connected Arduino board
//
// Calling Sequence
//     cmd_analog_out(h,pin_no,val)
//
// Parameters
//     h : Board pointer, to indicate which board to use to differentiate one board from another
//     pin_no : Digital pin with ~ to sent the signal
//     val : The value of 0-255 to be sent to the digital pins with ~ sign. It will be then scaled to 0-5V
//
// Description
//     The analog outputs of the Arduino Uno is available at the pins 3,5,6,9,10 and 11, while on the Mega board, the outputs are on pins 1-13 and 44-46. 
// It is a bit misleading to use the term "analog output", because in order to generate this output while minimizing energy losses, 
// the Arduino uses PWM (Pulse Width Modulation) available on these ports. By varying the duty cycle of the PWM is altered the average 
// voltage across the component connected to this port, which has the effect of having a analog output voltage.
//
// The input port accepts the value from 0 to 255 which is correspoding to the duty cycle of 0 to 100%. In other words, sending 0 to the block will generate 0 V output at the port, 127 generates 2.5V and 255 generates 5V. (the port is 8 bits, so the resolutions of output would be 2^8 =256).
//  
// Examples
//    h = open_serial(1,9,115200) 
//    cmd_analog_out(h,9,100)
//    close_serial(h)
// 
// See also
//    cmd_analog_out_volt
//    cmd_arduino_a_control
//
// Authors
//     Bruno JOFRET, Tan C.L. 
//    
    
    if val > 255 then
        val = 255;
    elseif val < 0
        val = 0;
    end
    code_sent="W"+ascii(48+pin_no)+ascii(abs(ceil(val)));
    write_serial(h,code_sent,3);

endfunction
