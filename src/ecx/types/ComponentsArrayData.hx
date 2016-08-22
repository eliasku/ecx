package ecx.types;

import ecx.ds.CArray;

#if flash
typedef ComponentsArrayData = Dynamic;
#else
typedef ComponentsArrayData = CArray<Component>;
#end