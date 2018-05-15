package ecx;

/**
	Declare fields in Service classes with Wire<T> to inject other Services.
**/
#if idea
typedef Wire<T> = T;
#else
typedef Wire<T:Service> = T;
#end