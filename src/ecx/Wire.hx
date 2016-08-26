package ecx;

// TODO: compile-time error if not system type or not @:base system type

#if idea
typedef Wire<T> = T;
#else
typedef Wire<T:Service> = T;
#end