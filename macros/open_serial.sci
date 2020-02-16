// function open_serial
// Command to initialize the serial port which is connected to Arduino
//
// Calling Sequence
//     res=open_serial(nHandle, nPort,baudrate)
//
// Parameters
//     n : Board number, reserved for future use. For this version, any number would do
//     nPort : Com port in which the Arduino is connected to
//     baudrate : baudrate for the serial comminication
//     h : Board pointer, to indicate which board to use to differentiate one board from another
//  
// Description
//     To connect to the Arduino board. To check the port number, do to the device manager or check it from the Arduino software
//  
// Examples
//    h = open_serial(1,9,115200) 
//    close_serial(h)
//
// See also
//    close_serial
//    
// Authors
//     Bruno JOFRET, Tan C.L. 

