// This file is released under the 3-clause BSD license. See COPYING-BSD.

function builder_gw_c()


    gw_c_path = get_absolute_file_path("builder_gateway_c.sce")

    if getos() == "Windows"
        gw_c_files = findfiles(gw_c_path, '*_win.c');
    else
        gw_c_files = findfiles(gw_c_path, '*_linux.c');
    end

    func = ['open_serial','open_serial','csci6';...
    'close_serial','close_serial','csci6';...
    'read_serial','read_serial','csci6';...
    'write_serial','write_serial','csci6';...
    'status_serial','status_serial','csci6';]
 
    tbx_build_gateway("serial_lib", ..
    func, ..
    gw_c_files, ..
    gw_c_path, ..
    "", ..
    "");


endfunction

builder_gw_c();
clear builder_gw_c; // remove builder_gw_c on stack
