function values = cmd_digital_in(h,pin_no)
    // Command to read in digital signal from a connected Arduino board
    //
    // Calling Sequence
    //      values = cmd_digital_in(h,pin_no)
    //
    // Parameters
    //     h : Board pointer, to indicate which board to use to differentiate one board from another
    //     pin_no : Digital pin to measure the signal
    //
    // Description
    //     The Arduino board has a set of logical ports (digital) that are used for writing or reading data from a component.
    //
    //     To map a UNO, ports 2-13 are available (0 and 1 are used for serial transmission). For MEGA board, ports 2-53 are available. The port takes the low logic level (0) or logic high (1) which corresponds to the reference voltage.
    //  
    // Examples
    //     h = open_serial(1,9,115200) 
    //     val = cmd_digital_in(h,2) 
    //     close_serial(h)
    // 
    // See also
    //    cmd_digital_out
    //    
    //
    // Authors
    //     Bruno JOFRET, Tan C.L. 
    //    

    if isvector(pin_no)
        for cnt = 1: size(pin_no,2)
            pin="Da"+ascii(48+pin_no(cnt))+"0";
            write_serial(h,pin,4);
            pin="Dr"+ascii(48+pin_no(cnt));
            write_serial(1,pin,3);
            //binary transfer
            [a,b,c]=status_serial(h);
            while (b < 1) 
                [a,b,c]=status_serial(h);
            end
            values(cnt)=strtod(read_serial(h,1))-48; // Add  -48 for new firmware
        end
    else
        pin="Da"+ascii(48+pin_no)+"0";
        write_serial(h,pin,4);
        pin="Dr"+ascii(48+pin_no);
        write_serial(1,pin,3);
        //binary transfer
        [a,b,c]=status_serial(h);
        while (b < 1) 
            [a,b,c]=status_serial(h);
        end
        values=strtod(read_serial(h,1))-48; // Add  -48 for new firmware
    end
endfunction
