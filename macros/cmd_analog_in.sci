function val = cmd_analog_in(h,pin_no)
// Command to read in analog signal from a connected Arduino board
//
// Calling Sequence
//     val = cmd_analog_in(h,pin_no)
//
// Parameters
//     h : Board pointer, to indicate which board to use to differentiate one board from another
//     pin_no : Analog pin to measure the signal
//     val : Reading in the range of 0-1023 to to indicate the input voltage from 0-5V
//
// Description
//     Arduino UNO board has 6 analog input ports (A0 to A5), the Arduino Mega board has 16 analog input ports (A0 to A15). 
//     The 10 bits channels convert the analog input from 0 to 5 volts, to a digital value between 0 and 1023.
//  
// Examples
//    h = open_serial(1,9,115200) 
//    val = cmd_analog_in(h,9)
//    close_serial(h)
// 
// See also
//    cmd_analog_in_volt
//    
//
// Authors
//     Bruno JOFRET, Tan C.L. 
//    
                
   pin="A"+ascii(48+pin_no);
      write_serial(h,pin,2);
  
      //binary transfer
      [a,b,c]=status_serial(h);
      while (b < 2) 
        [a,b,c]=status_serial(h);
      end
      values=read_serial(h,2);

      temp=(values);
      val=double(int16(256*temp(2)+temp(1)));
      
    
      
endfunction
