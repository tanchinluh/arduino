//
// This file is part of Arduino toolbox
// Copyright (C) 2012-2012 - DEMOSCIENCES - Alain CAIGNOT
//
// This file must be used under the terms of the CeCILL.
// This source file is licensed as described in the file COPYING, which
// you should have received as part of this distribution.  The terms
// are also available at
// http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt
//
//
function res=read_serial(nHandle,sz)
//    res=call("read_serial",nHandle,1,"i",sz,3,"i","out",[sz,1],2,"c");
    res_temp=call("read_serial",nHandle,1,"i",sz,3,"i","out",[sz,1],2,"c")
    res = ascii(ascii(res_temp)(1:sz));
      
endfunction
