// function close_serial(h)
// Command to close the serial port which is connected to Arduino
//
// Calling Sequence
//     res=close_serial(h)
//
// Parameters
//     h : Board pointer, to indicate which board to use to differentiate one board from another
//     res : 0 if the connection is successful, else the connection fail
//  
// Description
//     It is important to close the serial port after use, else the port would be busy and restart of Scilab might required to connect to it again.
//  
// Examples
//    h = open_serial(1,9,115200) 
//    close_serial()
//
// See also
//    open_serial
//    
// Authors
//     Bruno JOFRET   , Tan C.L.  
//
