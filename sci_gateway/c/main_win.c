/**************************************************
file: main.c
purpose: serial librairie for Scilab

Alain Caignot
**************************************************/

#include <windows.h>
#include <string.h>
#include <stdio.h>

#include "api_scilab.h"
#include "Scierror.h"
#include "sciprint.h"

static LPVOID GetLastErrorString(void)
{
	LPVOID *lpLpMsgBuf = NULL;

	FormatMessage(
		FORMAT_MESSAGE_ALLOCATE_BUFFER |
		FORMAT_MESSAGE_FROM_SYSTEM |
		FORMAT_MESSAGE_IGNORE_INSERTS,
		NULL,
		GetLastError(),
		MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
		(LPTSTR) &lpLpMsgBuf,
		0,
		NULL);

	return lpLpMsgBuf;
}

static scilabStatus GetFullPortName(char *name, size_t maxlen)
{
	char *number = name;
	char *endp;

	if (strncmp(name, "COM", 3) == 0)
		number = name + 3;

	long n = strtol(number, &endp, 10);
	if (n < 1 || n > 255 || name == endp || *endp != '\0')
		return STATUS_ERROR;

	int len = snprintf(name, maxlen, "\\\\.\\COM%d", n);
	if (len >= maxlen)
		return STATUS_ERROR;

	return STATUS_OK;
}

int open_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out)
{
	DCB dcbSerialParams;
	COMMTIMEOUTS timeouts = { 0 };
	wchar_t *in1;
	double in2;
	void *hPort;
	int baudrate;

	(void)nopt;
	(void)opt;

	// Check the number of input arguments
	if (nin != 3)
	{
		Scierror(77, "Wrong number of input argument(s): %d expected.\n", 3);
		return STATUS_ERROR;
	}

	// Check the number of output arguments
	if (nout != 1)
	{
		Scierror(77, "Wrong number of output arguments: %d expected.\n", 1);
		return STATUS_ERROR;
	}

	//in[1] : String
	if (scilab_isString(env, in[1]) == 0 || scilab_isScalar(env, in[1]) == 0)
	{
		Scierror(77, "Wrong type for input argument %d: A string expected.\n", 2);
		return STATUS_ERROR;
	}
	scilab_getString(env, in[1], &in1);

	//in[2] : Double
	if (scilab_isDouble(env, in[2]) == 0 || scilab_isScalar(env, in[2]) == 0)
	{
		Scierror(77, "Wrong type for input argument %f: A double expected.\n", 3);
		return STATUS_ERROR;
	}
	scilab_getDouble(env, in[2], &in2);
	baudrate = (int)(in2 + 0.5);

	char portname[100];
	wcstombs(portname, in1, sizeof(portname));

	if (GetFullPortName(portname, sizeof(portname)) != STATUS_OK)
	{
		Scierror(77, "Invalid port name '%s'. Expected a number in range [1,255] with optional COM prefix", portname);
		return STATUS_ERROR;
	}

	// Create Serial port handle
	hPort = CreateFile(portname,
		GENERIC_READ | GENERIC_WRITE,
		0,//FILE_SHARE_READ | FILE_SHARE_WRITE //to test : recuperation COM port if simulation crashes
		0,
		OPEN_EXISTING,
		FILE_ATTRIBUTE_NORMAL,
		0);

	//sciprint("Open %s at %d bps %p\n", portname, baudrate, hPort);

	// Errors checking
	if (hPort == INVALID_HANDLE_VALUE)
	{
		char *lpMsg = GetLastErrorString();
		Scierror(999, "Failed to open %s: %s\n", portname, lpMsg);
		LocalFree(lpMsg);
		return STATUS_ERROR;
	}

	dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
	if (!GetCommState(hPort, &dcbSerialParams))
	{
		char *lpMsg = GetLastErrorString();
		Scierror(999, "Error getting state: %s\n", lpMsg);
		LocalFree(lpMsg);
		return STATUS_ERROR;
	}
	dcbSerialParams.BaudRate = baudrate;
	dcbSerialParams.ByteSize = 8;
	dcbSerialParams.StopBits = ONESTOPBIT;
	dcbSerialParams.Parity = NOPARITY;
	dcbSerialParams.fOutxCtsFlow = FALSE;
	dcbSerialParams.fOutxDsrFlow = FALSE;
	dcbSerialParams.fDtrControl = DTR_CONTROL_DISABLE;
	dcbSerialParams.fRtsControl = RTS_CONTROL_DISABLE;
	dcbSerialParams.fOutX = FALSE;
	dcbSerialParams.fInX = FALSE;
	if (!SetCommState(hPort, &dcbSerialParams))
	{
		char *lpMsg = GetLastErrorString();
		Scierror(999, "Error setting state with error\n", lpMsg);
		LocalFree(lpMsg);
		return STATUS_ERROR;
	}

	//
	timeouts.ReadIntervalTimeout = 50;
	timeouts.ReadTotalTimeoutConstant = 50;
	timeouts.ReadTotalTimeoutMultiplier = 1;
	timeouts.WriteTotalTimeoutConstant = 50;
	timeouts.WriteTotalTimeoutMultiplier = 1;
	if (!SetCommTimeouts(hPort, &timeouts))
	{
		char *lpMsg = GetLastErrorString();
		Scierror(999, "Failed to configure timeouts: %s\n", lpMsg);
		LocalFree(lpMsg);
		return STATUS_ERROR;
	}

	if (!EscapeCommFunction(hPort, CLRBREAK) ||
		!EscapeCommFunction(hPort, CLRDTR) ||
		!EscapeCommFunction(hPort, CLRRTS))
	{
		// Failed to clear BREAK, DTR and RTS
		char *lpMsg = GetLastErrorString();
		Scierror(999, "Failed to reset signals with error\n", lpMsg);
		LocalFree(lpMsg);
		return STATUS_ERROR;
	}

	//sciprint("Serial port %s opened SUCCESSFULLY.\n", portname);
	out[0] = scilab_createPointer(env, hPort);

	Sleep(1000);
	return STATUS_OK;
}

int close_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out)
{
	void *hPort;

	(void)nopt;
	(void)opt;
	(void)out;

	// Check number of input arguments
	if (nin != 1)
	{
		Scierror(77, "Wrong number of input argument(s): %d expected.\n", 1);
		return STATUS_ERROR;
	}

	// Check the number of output arguments
	if (nout != 0)
	{
		Scierror(77, "Wrong number of output arguments: %d expected.\n", 0);
		return STATUS_ERROR;
	}

	// in[0] : pointer
	if (scilab_isPointer(env, in[0]) == 0)
	{
		Scierror(999, "Wrong type for input argument %d: A pointer expected.\n", 1);
		return STATUS_ERROR;
	}
	scilab_getPointer(env, in[0], &hPort);

	//sciprint("Close port %p\n", hPort);

	// Check whether the port is closed successfully.
	if (!CloseHandle(hPort))
	{
		char *lpMsg = GetLastErrorString();
		Scierror(999, "Failed to close the port: %s\n", lpMsg);
		LocalFree(lpMsg);
		return STATUS_ERROR;
	}

	return STATUS_OK;
}

int write_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out)
{
	DWORD dwBytesWrite;
	void *hPort;
	wchar_t* in1;
	double in2;
	DWORD size;

	(void)nopt;
	(void)opt;
	(void)out;

	// Check number of input arguments
	if (nin != 3)
	{
		Scierror(77, "Wrong number of input argument(s): %d expected.\n", 3);
		return STATUS_ERROR;
	}

	// Check the number of output arguments
	if (nout != 0)
	{
		Scierror(77, "Wrong number of output arguments: %d expected.\n", 0);
		return STATUS_ERROR;
	}

	// in[0] : pointer
	if (scilab_isPointer(env, in[0]) == 0)
	{
		Scierror(999, "Wrong type for input argument %d: A pointer expected.\n", 1);
		return STATUS_ERROR;
	}
	scilab_getPointer(env, in[0], &hPort);

	// in[1] : string
	if (scilab_isString(env, in[1]) == 0 || scilab_isScalar(env, in[1]) == 0)
	{
		Scierror(999, "Wrong type for input argument %d: A String expected.\n", 2);
		return STATUS_ERROR;
	}
	scilab_getString(env, in[1], &in1);

	// in[2] : Double
	if (scilab_isDouble(env, in[2]) == 0 || scilab_isScalar(env, in[2]) == 0)
	{
		Scierror(999, "Wrong type for input argument %d: A double expected.\n", 3);
		return STATUS_ERROR;
	}
	scilab_getDouble(env, in[2], &in2);
	size = (DWORD)(in2 + 0.5);

	//sciprint("Write %d bytes into port %p\n", size, hPort);

	// Convert input string from wchar to char
	char ch[100];
	wcstombs(ch, in1, sizeof(ch));

	if (!WriteFile(hPort, ch, size, &dwBytesWrite, NULL))
	{
		char *lpMsg = GetLastErrorString();
		Scierror(999,"Failed to write into port: %s", lpMsg);
		LocalFree(lpMsg);
		return STATUS_ERROR;
	}

	if (size != dwBytesWrite)
	{
		Scierror(999,"Unexpected number of bytes written: expected %d but written %d", size, dwBytesWrite);
		return STATUS_ERROR;
	}

	return STATUS_OK;
}

int status_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out)
{
	DWORD dwErrorFlags;
	COMSTAT ComStat;
	void *hPort;
	int nbread;
	int nbwrite;

	(void)nopt;
	(void)opt;

	// Check number of input arguments
	if (nin != 1)
	{
		Scierror(77, "Wrong number of input argument(s): %d expected.\n", 1);
		return STATUS_ERROR;
	}

	// Check the number of output arguments
	if (nout != 3)
	{
		Scierror(77, "Wrong number of output arguments: %d expected.\n", 3);
		return STATUS_ERROR;
	}

	// in[0] : pointer
	if (scilab_isPointer(env, in[0]) == 0)
	{
		Scierror(999, "Wrong type for input argument %d: A pointer expected.\n", 1);
		return STATUS_ERROR;
	}
	scilab_getPointer(env, in[0], &hPort);

	if (!ClearCommError(hPort, &dwErrorFlags, &ComStat))
	{
		char *lpMsg = GetLastErrorString();
		Scierror(999,"Failed to get port's status: %s\n", lpMsg);
		LocalFree(lpMsg);
		return STATUS_ERROR;
	}

	nbread  = ComStat.cbInQue;
	nbwrite = ComStat.cbOutQue;

	//sciprint("Status port %p: in=%d out=%d\n", hPort, nbread, nbwrite);

	// Create outputs
	out[0] = scilab_createDouble(env, (double)0);
	out[1] = scilab_createDouble(env, (double)nbread);
	out[2] = scilab_createDouble(env, (double)nbwrite);

	return STATUS_OK;
}

int read_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out)
{
	DWORD dwBytesRead;
	void *hPort;
	double in1;
	DWORD size;
	unsigned char buf[10];

	(void)nopt;
	(void)opt;

	// Check number of input arguments
	if (nin != 2)
	{
		Scierror(77,"Wrong number of input argument(s): %d expected.\n", 2);
		return STATUS_ERROR;
	}

	// Check the number of output arguments
	if (nout != 1)
	{
		Scierror(77, "Wrong number of output arguments: %d expected.\n", 1);
		return STATUS_ERROR;
	}

	// in[0] : pointer
	if (scilab_isPointer(env, in[0]) == 0)
	{
		Scierror(999, "Wrong type for input argument #%d: A pointer expected.\n", 1);
		return STATUS_ERROR;
	}
	scilab_getPointer(env, in[0], &hPort);

	// in[1] : double
	if (scilab_isDouble(env, in[1]) == 0 || scilab_isScalar(env, in[1]) == 0)
	{
		Scierror(999,"Wrong type for input argument %d: A double expected.\n", 2);
		return STATUS_ERROR;
	}
	scilab_getDouble(env, in[1], &in1);
	size = (DWORD)(in1 + 0.5);

	if (!ReadFile(hPort, buf, size, &dwBytesRead, NULL))
	{
		char *lpMsg = GetLastErrorString();
		Scierror(999,"Failed to read from port: %s\n", lpMsg);
		LocalFree(lpMsg);
		return STATUS_ERROR;
	}

	if (size != dwBytesRead)
	{
		Scierror(999,"Unexpected number of bytes read: expected %d but read %d", size, dwBytesRead);
		return STATUS_ERROR;
	}

	//sciprint("Read %d bytes from port %p\n", size, hPort);

	// Creating output as double
	double* out1;

	out[0] = scilab_createDoubleMatrix2d(env, 1, size, 0);
	scilab_getDoubleArray(env, out[0], &out1);

	for (unsigned i = 0; i < dwBytesRead; ++i)
	{
		out1[i] = (double)*(buf+i);
	}

	return STATUS_OK;
}
