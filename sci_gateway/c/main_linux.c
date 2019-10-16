/**************************************************
file: main.c
purpose: serial librairie for Scilab

Alain Caignot
**************************************************/
#include <unistd.h>
#include <termios.h>
#include "api_scilab.h"
#include "Scierror.h"
#include "sciprint.h"
#include <errno.h>
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h> /* memset */
#include <stdio.h>
#include "sci_malloc.h"


#define MAXPORTS 5 //used to opened several COM to have several Arduino card

int set_interface_attribs (int fd, int speed, int parity)
{
        struct termios tty;
        memset (&tty, 0, sizeof tty);
        if (tcgetattr (fd, &tty) != 0)
        {
                return -1;
        }
	int posix_baudrate=0;

switch(speed) {
case 115200: posix_baudrate = B115200; break;
default: return;
}
        cfsetospeed (&tty, posix_baudrate);
        cfsetispeed (&tty, posix_baudrate);

        tty.c_cflag = (tty.c_cflag & ~CSIZE) | CS8;     // 8-bit chars
        // disable IGNBRK for mismatched speed tests; otherwise receive break
        // as \000 chars
        tty.c_iflag &= ~IGNBRK;         // disable break processing
        tty.c_lflag = 0;                // no signaling chars, no echo,
                                        // no canonical processing
        tty.c_oflag = 0;                // no remapping, no delays
        tty.c_cc[VMIN]  = 0;            // read doesn't block
        tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

        tty.c_iflag &= ~(IXON | IXOFF | IXANY); // shut off xon/xoff ctrl

        tty.c_cflag |= (CLOCAL | CREAD);// ignore modem controls,
                                        // enable reading
        tty.c_cflag &= ~(PARENB | PARODD);      // shut off parity
        tty.c_cflag |= parity;
        tty.c_cflag &= ~CSTOPB;
        tty.c_cflag &= ~CRTSCTS;

        if (tcsetattr (fd, TCSANOW, &tty) != 0)
        {
                return -1;
        }
        return 0;
}

void set_blocking (int b, int should_block)
{
        struct termios tty;
        memset (&tty, 0, sizeof tty);
        if (tcgetattr (b, &tty) != 0)
        {
                return;
        }

        tty.c_cc[VMIN]  = should_block ? 1 : 0;
        tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout
}

// Function to open port COM
//__declspec(dllexport) void __stdcall open_serial(int *handle,int *port, int *baudrate, int *OK){
int open_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out)
{
	static int handleport[MAXPORTS];
	double handle = 0;
	double port = 0;
	double baudrate = 0;
    int *OK = malloc(sizeof(int));

	// Check the number of input arguments
	if (nin != 3)
	{
		Scierror(77, "Wrong number of input argument(s): %d expected.\n", 3);
		return -1;
	}

	// Check the number of output arguments
	if (nout != 1)
	{
		Scierror(77, "Wrong number of output arguments: %d expected.\n", 1);
		return -1;
	}

	// in[0] : Double
	if (scilab_isDouble(env, in[0]) == 0 || scilab_isScalar(env, in[0]) == 0)
	{
		Scierror(77, "Wrong type for input argument %d: A double expected.\n", 1);
		return -1;
	}
	scilab_getDouble(env, in[0], &handle);
	int int_handle = (int)handle;

	//in[1] : Double
	if (scilab_isDouble(env, in[1]) == 0 || scilab_isScalar(env, in[1]) == 0)
	{
		Scierror(77, "Wrong type for input argument %d: A double expected.\n", 2);
		return -1;
	}
	scilab_getDouble(env, in[1], &port);

	//in[2] : Double
	if (scilab_isDouble(env, in[2]) == 0 || scilab_isScalar(env, in[2]) == 0)
	{
		Scierror(77, "Wrong type for input argument %d: A double expected.\n", 3);
		return -1;
	}
	scilab_getDouble(env, in[2], &baudrate);

	char *portname;
		switch((int)port){
		case 0: portname = "//dev/ttyACM0";break;
		case 1: portname = "//dev/ttyACM1";break;
                case 2: portname = "//dev/ttyACM2";break;
                case 3: portname = "//dev/ttyACM3";break;
                case 4: portname = "//dev/ttyACM4";break;
                case 5: portname = "//dev/ttyACM5";break;
                case 6: portname = "//dev/ttyACM6";break;
                case 7: portname = "//dev/ttyACM7";break;
		default : return;
	}
	*OK = 0;
	handleport[int_handle] = open (portname, O_RDWR | O_NOCTTY | O_SYNC);
	//fd = open (portname, O_RDWR | O_NOCTTY); //srikant
	if (handleport[int_handle] < 0)
	{
        Scierror(999, "Fail to open serial port %s.\n", *portname);
		*OK = 2;
		return;
	}
	set_interface_attribs (handleport[int_handle], baudrate, 0);
	set_blocking (handleport[int_handle], 0);                // set no blocking

    void* val;
	val = &handleport[int_handle];
	out[0] = scilab_createPointer(env, val);

	sleep(1);
	return 0;
}

////__declspec (dllexport) void __stdcall close_serial(int *handle, int *OK) {
int close_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out) {

	int res;
	int *OK = 0;
	void const** hport;

	// Check number of input arguments
	if (nin != 1)
	{
		Scierror(77, "Wrong number of input argument(s): %d expected.\n", 1);
		return -1;
	}

	// in[0] : pointer
	if (scilab_isPointer(env, in[0]) == 0)
	{
		Scierror(999, "Wrong type for input argument %d: A pointer expected.\n", 1);
		return -1;
	}
	scilab_getPointer(env, in[0], &hport);

	res = close(*hport);
    //sciprint("%i\n",res);
	// Check whether the port is closed successfully.
	if (res == 0) {
		sciprint("Serial port closed SUCCESSFULLY.\n");
	}
	else {
		sciprint("Serial port closed FAIL.\n");
	}

	return 0;

}




//__declspec (dllexport) void __stdcall write_serial(int *handle, char str[],int *size, int *OK){
int write_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out) {

	// DWORD dwBytesWrite = 0;
	int res;
	void const** hport;
	double size = 0;
	wchar_t* str = 0;
	wchar_t* in1 = 0;

	int *OK = malloc(sizeof(int));
	*OK = 0;

	// Check number of input arguments
	if (nin != 3)
	{
		Scierror(77, "Wrong number of input argument(s): %d expected.\n", 3);
		*OK = -1;
		return *OK;
	}

	// in[0] : pointer
	if (scilab_isPointer(env, in[0]) == 0)
	{
		Scierror(999, "Wrong type for input argument %d: A pointer expected.\n", 1);
		*OK = -1;
		return *OK;
	}
	scilab_getPointer(env, in[0], &hport);

	// in[1] : string
	if (scilab_isString(env, in[1]) == 0 || scilab_isScalar(env, in[1]) == 0)
	{
		Scierror(999, "Wrong type for input argument %d: A String expected.\n", 2);
		*OK = -1;
		return *OK;
	}
	scilab_getString(env, in[1], &str);

	// in[2] : Double
	if (scilab_isDouble(env, in[2]) == 0 || scilab_isScalar(env, in[2]) == 0)
	{
		Scierror(999, "Wrong type for input argument %d: A double expected.\n", 3);
		*OK = -1;
		return *OK;
	}
	scilab_getDouble(env, in[2], &size);

	// Convert input string from wchar to char
	char ch[100];
	wcstombs(ch, str, size);
	//res = WriteFile(*hport, ch, size, &dwBytesWrite, NULL);
    res = write(*hport, ch, (int)size);
	//usleep(*size*100);

    //sciprint("%i\n",**hport.rdbuf()->in_avail());

	out[0] = scilab_createDouble(env, (double)*OK);

	free(OK);
	return 0;

}

//__declspec (dllexport) void __stdcall status_serial(int *handle, int *OK,int *nbread, int *nbwrite){
int status_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out) {

	//DWORD dwErrorFlags;
	//COMSTAT ComStat;
	int res;
	void const** hport;
	int *nbread = malloc(sizeof(int));
	int *nbwrite = malloc(sizeof(int));
	int *OK = malloc(sizeof(int));
	*OK = 0;

	// Check number of input arguments
	if (nin != 1)
	{
		Scierror(77, "Wrong number of input argument(s): %d expected.\n", 1);
		*OK = -1;
		return *OK;
	}

	// in[0] : pointer
	if (scilab_isPointer(env, in[0]) == 0)
	{
		Scierror(999, "Wrong type for input argument %d: A pointer expected.\n", 1);
		*OK = -1;
		return *OK;
	}
	scilab_getPointer(env, in[0], &hport);

	//res = ClearCommError(*hport, &dwErrorFlags, &ComStat);

	//if (res == 0) {//error
	//	*OK = -1;
	//	return *OK;
	//}
	//*nbread = ComStat.cbInQue;
	//*nbwrite = ComStat.cbOutQue;

	// These are kind of dummy?? consider to change to other method that returned actual buffer values.
    //*nbread = 2;
	*nbwrite = 0;
	*nbread = 0;
	*OK = 0;

    ioctl(*hport, 0x541B, nbread);

	// Create outputs
	out[0] = scilab_createDouble(env, (double)*OK);
	out[1] = scilab_createDouble(env, (double)*nbread);
	out[2] = scilab_createDouble(env, (double)*nbwrite);

	free(OK);
	free(nbread);
	free(nbwrite);
	return 0;
}

//__declspec (dllexport) void __stdcall read_serial(int *handle,char buf[],int *size){
int read_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out) {

	//DWORD dwBytesRead = 0;
	int res;
	void const** hport;
	double size = 0;
	unsigned char buf[200];

	// Check number of input arguments
	if (nin != 2)
	{
		Scierror(77,"Wrong number of input argument(s): %d expected.\n", 2);
		return STATUS_ERROR;
	}

	// in[0] : pointer
	if (scilab_isPointer(env, in[0]) == 0)
	{
		Scierror(999, "Wrong type for input argument #%d: A pointer expected.\n", 1);
		return STATUS_ERROR;
	}
	scilab_getPointer(env, in[0], &hport);

	// in[1] : double
	if (scilab_isDouble(env, in[1]) == 0 || scilab_isScalar(env, in[1]) == 0)
	{
		Scierror(999,"Wrong type for input argument %d: A double expected.\n", 2);
		return STATUS_ERROR;
	}
	scilab_getDouble(env, in[1], &size);

	// Read from serial
	// setlocale(LC_ALL, "en_US.utf8");
	//res = ReadFile(*hport, buf, size, &dwBytesRead, NULL);
    res = read(*hport, buf, (int)size);

	// Creating output as double
	int inr1 = 1;
	int inc1 = size;
	double* out1 = NULL;

	out[0] = scilab_createDoubleMatrix2d(env, inr1, inc1, 0);
	scilab_getDoubleArray(env, out[0], &out1);

	for (int i = 0; i < size; ++i)
	{
		out1[i] = (double)*(buf+i);
	}


	return 0;

}


