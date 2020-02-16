function cmd_digital_out(h,pin_no,val)
// Command to sent out digital signal to a connected Arduino board
//
// Calling Sequence
//      cmd_digital_out(h,pin_no,val)
//
// Parameters
//     h : Board pointer, to indicate which board to use to differentiate one board from another
//     pin_no : Digital pin to sent the signal
//     val : The value of 0 or 1 to be sent to the digital pins with. It is correspond to 0 and 5V
//
// Description
//     The Arduino board has a set of logical ports (digital) that are used for writing or reading data from a component.
//
//     To map a UNO, ports 2-13 are available (0 and 1 are used for serial transmission). For MEGA board, ports 2-53 are available. The port takes the low logic level (0) or logic high (1) which corresponds to the reference voltage.
//  
// Examples
//    h = open_serial(1,9,115200) 
//    cmd_digital_out(h,13,0) 
//    sleep(1000)
//    cmd_digital_out(h,13,1) 
//    sleep(1000)
//    close_serial(h)
// 
// See also
//    cmd_digital_in
//
// Authors
//     Bruno JOFRET, Tan C.L. 
//    

    if isvector(pin_no)

        for cnt = 1: size(pin_no,2)
            if size(pin_no) == size(val)
                pin="Da"+ascii(48+pin_no(cnt))+"1";
                write_serial(h,pin,4);
                if val(cnt) > 0.5 then
                    val(cnt) = 1;
                else
                    val(cnt) = 0;
                end
                pin="Dw"+ascii(48+pin_no(cnt))+string(val(cnt));
                write_serial(h,pin,4);

            else

                pin="Da"+ascii(48+pin_no(cnt))+"1";
                write_serial(h,pin,4);
                if val > 0.5 then
                    val = 1;
                else
                    val = 0;
                end
                pin="Dw"+ascii(48+pin_no(cnt))+string(val);
                write_serial(h,pin,4);
            end

        end
    else

        pin="Da"+ascii(48+pin_no)+"1";
        write_serial(h,pin,4);
        if val > 0.5 then
            val = 1;
        else
            val = 0;
        end
        pin="Dw"+ascii(48+pin_no)+string(val);
        write_serial(h,pin,4);
    end
endfunction
