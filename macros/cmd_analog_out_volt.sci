function cmd_analog_out_volt(h,pin_no,val)
// Command to sent out analog signal to a connected Arduino board
//
// Calling Sequence
//     cmd_analog_out_volt(h,pin_no)
//
// Parameters
//     h : Board pointer, to indicate which board to use to differentiate one board from another
//     pin_no : Digital pin with ~ to sent the signal
//     val : The value in volt (0-5) to be sent to the digital pins with ~ sign. 
//
// Description
//     The analog outputs of the Arduino Uno is available at the pins 3,5,6,9,10 and 11, while on the Mega board, the outputs are on pins 1-13 and 44-46. 
// It is a bit misleading to use the term "analog output", because in order to generate this output while minimizing energy losses, 
// the Arduino uses PWM (Pulse Width Modulation) available on these ports. By varying the duty cycle of the PWM is altered the average 
// voltage across the component connected to this port, which has the effect of having a analog output voltage.
//
// Examples
//    h = open_serial(1,9,115200) 
//    cmd_analog_out_volt(h,9,1.2)
//    close_serial(h)
// 
// See also
//    cmd_analog_out
//    cmd_arduino_a_control
//
// Authors
//     Bruno JOFRET, Tan C.L. 
//    

    if val > 5 then
        val = 5;
    elseif val < 0
        val = 0;
    end
    val = val .* 255 ./ 5;
    
    code_sent="W"+ascii(48+pin_no)+ascii(abs(ceil(val)));
    write_serial(h,code_sent,3);

endfunction
