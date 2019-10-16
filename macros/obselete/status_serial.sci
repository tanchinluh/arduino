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
function [a,b,c]=status_serial(nHandle)
    [a,b,c]=call("status_serial",nHandle,1,"i","out",[1,1],2,"i",[1,1],3,"i",[1,1],4,"i")
endfunction
