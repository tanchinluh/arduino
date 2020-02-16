# Arduino TOOLBOX

Arduino Communication through Serial

## Getting Started


### Prerequisites

1. Scilab 6.0.x or Scilab 6.1.x

### Installing

The module could be easily install from the Scilab atoms portal by using command:

--> atomsInstall('arduino'); // Coming soon

or the offline version by replacing the input argument to the zip file name.

If you prefer to build then module, download the source and unzip it, just type in scilab:

```
--> exec("arduino_Path/builder.sce")
```

If the module is place in the "contrib" folder, it could be loaded from the "Toolboxes" menu. Otherwise, just type in scilab:

``` 
--> exec("arduino_path/loader.sce"); 
```

arduino_Path is where this file is.

### EXAMPLES and DEMOS
 To see some examples type in scilab:

--> help 

## Features
* Analog input
* Analog output (PWM)
* Digital input
* Digital output
* Encoder input
* Interrupt
* DC motor
* Servo motor

## Revisions

### REVISION NOTES 1.8
BUGS FIXED
* Fixed issue of extra figure popup when demo figure is on

NEW FEATURES
* Add command lines control support for common interface.
* Translate help pages in english
* Translate demos

### REVISION NOTES 1.7.1
BUGS FIXED
* Fixed 2206 Problem with Servo_Write Block
* Restore MPU6050 block

### REVISION NOTES 1.7
BUGS FIXED
* Fixed Scilab 6 compatibility issues
* Change the serial to Scilab from char to double to solved ascii issues.
* Fixed port >9 not supported issue
  
NEW FEATURES
* Multiple boards support (Set to 2 currently as more board yields slow response)
* Linux/MacOS(?) Support (Thanks to Nikolay Strelkov link in http://forge.scilab.org/index.php/p/arduino/issues/1556/) 
* Modified the dll for serial communication to Scilab 6.1.x gateway format, allowing other contributors to enhance it easier.

## To-Do
   * Change the firmware to get multiple channels and sent all back to host for performance improvement
   * Translate help pages in english
   * Translate blocks interfaces and error messages
   * Translate demos
 

## Version

This is the Revision 1.8 of arduino toolbox for Scilab 6.0.x

## Authors

This is the Revision 1.8 of arduino toolbox for Scilab 6.0.x
Modified By Tan Chin Luh 

Original Works By Bruno JOFRET

## License

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

## Acknowledgments

1. Bruno Jofret 
2. Yann Debray 
3. Samuel Gougeon

## Extra Demo Videos
1. Using Scilab arduino module for soft real-time closed-loop control
https://www.linkedin.com/posts/tanchinluh_scilab-activity-6590880449571192832-FwU9
2. Scilab arduino under linux
https://www.linkedin.com/posts/tanchinluh_scilab-activity-6590139219363094528-OAvt
3. Working with 2 Ardiono Uno boards
https://www.linkedin.com/posts/tanchinluh_scilab-arduino-activity-6589898816311390208-Oo7Z
https://www.linkedin.com/posts/tanchinluh_scilab-arduino-activity-6589484169330561024-A3io

