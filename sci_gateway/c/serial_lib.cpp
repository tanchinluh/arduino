#include <wchar.h>
#include "serial_lib.hxx"
extern "C"
{
#include "serial_lib.h"
#include "addfunction.h"
}

#define MODULE_NAME L"serial_lib"

int serial_lib(wchar_t* _pwstFuncName)
{
    if(wcscmp(_pwstFuncName, L"open_serial") == 0){ addCFunction(L"open_serial", &open_serial, MODULE_NAME); }
    if(wcscmp(_pwstFuncName, L"close_serial") == 0){ addCFunction(L"close_serial", &close_serial, MODULE_NAME); }
    if(wcscmp(_pwstFuncName, L"read_serial") == 0){ addCFunction(L"read_serial", &read_serial, MODULE_NAME); }
    if(wcscmp(_pwstFuncName, L"write_serial") == 0){ addCFunction(L"write_serial", &write_serial, MODULE_NAME); }
    if(wcscmp(_pwstFuncName, L"status_serial") == 0){ addCFunction(L"status_serial", &status_serial, MODULE_NAME); }

    return 1;
}
