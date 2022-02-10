/**************************************************
file: main.c
purpose: serial librairie for Scilab

Alain Caignot
**************************************************/

#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <unistd.h>

#include "api_scilab.h"
#include "Scierror.h"
#include "sciprint.h"

static scilabStatus set_interface_attribs(int fd, int baudrate, int parity)
{
	speed_t speed;
	struct termios tty;

	if (tcgetattr(fd, &tty) < 0)
	{
		return STATUS_ERROR;
	}

	switch(baudrate)
	{
	case 115200:
		speed = B115200;
		break;
	default:
		return STATUS_ERROR;
	}

	if (cfsetospeed(&tty, speed) < 0 || cfsetispeed(&tty, speed) < 0)
	{
		return STATUS_ERROR;
	}

	tty.c_cflag = (tty.c_cflag & ~CSIZE) | CS8; // 8-bit chars
	// disable IGNBRK for mismatched speed tests; otherwise receive break
	// as \000 chars
	tty.c_iflag &= ~IGNBRK; // disable break processing
	tty.c_lflag = 0; // no signaling chars, no echo,
	// no canonical processing
	tty.c_oflag = 0; // no remapping, no delays
	tty.c_cc[VMIN] = 0; // read doesn't block
	tty.c_cc[VTIME] = 5; // 0.5 seconds read timeout

	tty.c_iflag &= ~(IXON | IXOFF | IXANY); // shut off xon/xoff ctrl

	tty.c_cflag |= (CLOCAL | CREAD); // ignore modem controls,
	// enable reading
	tty.c_cflag &= ~(PARENB | PARODD);// shut off parity
	tty.c_cflag |= parity;
	tty.c_cflag &= ~CSTOPB;
	tty.c_cflag &= ~CRTSCTS;

	if (tcsetattr(fd, TCSANOW, &tty) < 0)
	{
		return STATUS_ERROR;
	}

	return STATUS_OK;
}

static scilabStatus set_blocking(int fd, int should_block)
{
	struct termios tty;

	if (tcgetattr(fd, &tty) < 0)
	{
		return STATUS_ERROR;
	}

	tty.c_cc[VMIN] = should_block ? 1 : 0;
	tty.c_cc[VTIME] = 5; // 0.5 seconds read timeout

	if (tcsetattr(fd, TCSANOW, &tty) < 0)
	{
		return STATUS_ERROR;
	}

	return STATUS_OK;
}

int open_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out)
{
	wchar_t *in1;
	double in2;
	int fd;
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

	//in[0] : port handle number - ignored

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
		Scierror(77, "Wrong type for input argument %d: A double expected.\n", 3);
		return STATUS_ERROR;
	}
	scilab_getDouble(env, in[2], &in2);
	baudrate = (int)(in2 + 0.5);

	char portname[100];
	wcstombs(portname, in1, sizeof(portname));

	fd = open(portname, O_RDWR | O_NOCTTY | O_SYNC);
	//fd = open(portname, O_RDWR | O_NOCTTY); //srikant
	if (fd < 0)
	{
		Scierror(999, "Fail to open serial port %s: %s\n", portname, strerror(errno));
		return STATUS_ERROR;
	}

	//sciprint("Opened port %d: %s at %d\n", fd, portname, baudrate);

	if (set_interface_attribs(fd, baudrate, 0) != STATUS_OK ||
		set_blocking(fd, 0) != STATUS_OK)
	{
		Scierror(999, "Fail to configure port %s: %s\n", portname, strerror(errno));
		return STATUS_ERROR;
	}

	// Clear BREAK
	ioctl(fd, TIOCCBRK, NULL);

	// Reset DTR and RTS
	int flags = TIOCM_DTR | TIOCM_RTS;
	ioctl(fd, TIOCMBIC, &flags);

	out[0] = scilab_createPointer(env, (void*)(intptr_t)fd);

	sleep(1);
	return STATUS_OK;
}

int close_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out)
{
	void *in0;
	int fd;

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
	scilab_getPointer(env, in[0], &in0);
	fd = (intptr_t)in0;

	//sciprint("Closing port %d\n", fd);

	if (close(fd) != 0)
	{
		sciprint("Failed to close the port: %s\n", strerror(errno));
	}

	return STATUS_OK;
}

int write_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out)
{
	void *in0;
	wchar_t* in1;
	double in2;
	int fd;
	int size;

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
		Scierror(999, "%s: Wrong type for input argument %d: A pointer expected.\n", __func__, 1);
		return STATUS_ERROR;
	}
	scilab_getPointer(env, in[0], &in0);
	fd = (intptr_t)in0;

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
	size = (int)(in2 + 0.5);

	//sciprint("Writing %d bytes to port %d\n", size, fd);

	// Convert input string from wchar to char
	char ch[100];
	wcstombs(ch, in1, sizeof(ch));

	int ret = write(fd, ch, size);

	if (ret < 0)
	{
		Scierror(999, "Write to port failed: %s\n", strerror(errno));
		return STATUS_ERROR;
	}

	if (ret != size)
	{
		Scierror(999,"Unexpected number of bytes written: expected %d but written %d", size, ret);
		return STATUS_ERROR;
	}

	return STATUS_OK;
}

int status_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out)
{
	void *in0;
	int fd;

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
		Scierror(999, "%s: Wrong type for input argument %d: A pointer expected.\n", __func__, 1);
		return STATUS_ERROR;
	}
	scilab_getPointer(env, in[0], &in0);
	fd = (intptr_t)in0;

	int nbread = 0;
	int nbwrite = 0;

	ioctl(fd, TIOCINQ, &nbread);
	ioctl(fd, TIOCOUTQ, &nbwrite);

	//sciprint("Status port %d: in=%d out=%d\n", fd, nbread, nbwrite);

	// Create outputs
	out[0] = scilab_createDouble(env, (double)0);
	out[1] = scilab_createDouble(env, (double)nbread);
	out[2] = scilab_createDouble(env, (double)nbwrite);

	return STATUS_OK;
}

int read_serial(scilabEnv env, int nin, scilabVar* in, int nopt, scilabOpt* opt, int nout, scilabVar* out)
{
	void *in0;
	double in1;
	int fd;
	int size;
	unsigned char buf[200];

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
		Scierror(999, "%s: Wrong type for input argument #%d: A pointer expected.\n", __func__, 1);
		return STATUS_ERROR;
	}
	scilab_getPointer(env, in[0], &in0);
	fd = (intptr_t)in0;

	// in[1] : double
	if (scilab_isDouble(env, in[1]) == 0 || scilab_isScalar(env, in[1]) == 0)
	{
		Scierror(999,"Wrong type for input argument %d: A integer expected.\n", 2);
		return STATUS_ERROR;
	}
	scilab_getDouble(env, in[1], &in1);
	size = (int)(in1 + 0.5);

	//sciprint("Read %d bytes from port %d\n", size, fd);

	int ret = read(fd, buf, size);

	if (ret < 0)
	{
		Scierror(999, "Read from port failed: %s\n", strerror(errno));
		return STATUS_ERROR;
	}

	if (ret != size)
	{
		Scierror(999,"Unexpected number of bytes read: expected %d but read %d", size, ret);
		return STATUS_ERROR;
	}

	// Creating output as double
	double* out1 = NULL;

	out[0] = scilab_createDoubleMatrix2d(env, 1, size, 0);
	scilab_getDoubleArray(env, out[0], &out1);

	for (int i = 0; i < size; ++i)
	{
		out1[i] = (double)*(buf+i);
	}

	return STATUS_OK;
}
