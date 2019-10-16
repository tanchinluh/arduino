/**************************************************
file: main.c
purpose: serial librairie for Scilab

Alain Caignot
**************************************************/

#include "api_scilab.h"
#include "Scierror.h"
#include "sciprint.h"
#include "BOOL.h"
#include "localization.h"
#include <locale.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "os_string.h"
#include "sci_malloc.h"
//#ifdef _WIN32
#include <windows.h>
//#else
//#include <unistd.h>
//#endif

#define MAXPORTS 5 //used to opened several COM to have several Arduino card
int open_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out);
int close_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out);
int write_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out);
int status_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out);
int read_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out);

// Function to open port COM
//__declspec(dllexport) void __stdcall open_serial(int *handle,int *port, int *baudrate, int *OK){
int open_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out)
{
	static HANDLE handleport[MAXPORTS];
	DCB dcbSerialParams;
	DWORD dwBytesWrite = 0;
	DWORD dwBytesRead = 10;
	COMMTIMEOUTS timeouts = { 0 };
	double handle = 0;
	double port = 0;
	double baudrate = 0;

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

	// Consider to replace itoa to a standard way, and to allow COM port more than 9
	//char tmp[5] = "COM5";
	char tmp[15] = "\\\\.\\COM5";
	itoa(port, &tmp[7], 10);

	// Create Serial port handle
	handleport[int_handle] = CreateFile(tmp,
		GENERIC_READ | GENERIC_WRITE,
		0,//FILE_SHARE_READ | FILE_SHARE_WRITE //to test : recuperation COM port if simulation crashes
		0,
		OPEN_EXISTING,
		FILE_ATTRIBUTE_NORMAL,
		0);

	// Errors checking
	if (handleport[int_handle] == INVALID_HANDLE_VALUE) {
		if (GetLastError() == ERROR_FILE_NOT_FOUND) {
			//serial port does not exist. Inform user.
			Scierror(999, "Serial port %s: does not exist.\n", tmp);
			return -1;
		}
		//some other error occurred. Inform user.
		Scierror(999, "Unknown Error.\n");
		return -1;
	}

	dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
	if (!GetCommState(handleport[int_handle], &dcbSerialParams)) {
		//error getting state
		Scierror(999, "Error getting state from %s.\n", tmp);
		return -1;
	}
	dcbSerialParams.BaudRate = baudrate;
	dcbSerialParams.ByteSize = 8;
	dcbSerialParams.StopBits = ONESTOPBIT;
	dcbSerialParams.Parity = NOPARITY;
	if (!SetCommState(handleport[int_handle], &dcbSerialParams)) {
		//error setting serial port state
		Scierror(999, "Error setting state from %s.\n", tmp);
		return -1;
	}

	//  
	timeouts.ReadIntervalTimeout = 50;
	timeouts.ReadTotalTimeoutConstant = 50;
	timeouts.ReadTotalTimeoutMultiplier = 1;
	timeouts.WriteTotalTimeoutConstant = 50;
	timeouts.WriteTotalTimeoutMultiplier = 1;
	if (!SetCommTimeouts(handleport[int_handle], &timeouts)) {
		//error occureed. Inform user
		Scierror(999, "Unknown Error.\n");
		return -1;
	}

	// Create output pointer if COM port open successfully
	void* val;
	val = &handleport[int_handle];
	out[0] = scilab_createPointer(env, val);

	Sleep(500);
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

	res = CloseHandle(*hport);

	// Check whether the port is closed successfully.
	if (res == 1) {
		sciprint("Serial port closed SUCCESSFULLY.\n");
	}
	else {
		sciprint("Serial port closed FAIL.\n");
	}
	
	return 0;

}

//__declspec (dllexport) void __stdcall write_serial(int *handle, char str[],int *size, int *OK){
int write_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out) {

	DWORD dwBytesWrite = 0;
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
	res = WriteFile(*hport, ch, size, &dwBytesWrite, NULL);
	out[0] = scilab_createDouble(env, (double)*OK);

	free(OK);
	return 0;

}

//__declspec (dllexport) void __stdcall status_serial(int *handle, int *OK,int *nbread, int *nbwrite){
int status_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out) {
	
	DWORD dwErrorFlags;
	COMSTAT ComStat;
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

	res = ClearCommError(*hport, &dwErrorFlags, &ComStat);

	if (res == 0) {//error
		*OK = -1;
		return *OK;
	}
	*nbread = ComStat.cbInQue;
	*nbwrite = ComStat.cbOutQue;

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

	DWORD dwBytesRead = 0;
	int res;
	void const** hport;
	double size = 0;
	unsigned char buf[10];

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
	res = ReadFile(*hport, buf, size, &dwBytesRead, NULL);
	
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
