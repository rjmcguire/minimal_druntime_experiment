module c_types;

version(D_LP64)
{
    public alias ssize_t        = long; 
    public alias c_int          = long;
    public alias c_unsigned_int = ulong;
    public alias c_long         = long;
}
else
{
    public alias ssize_t        = int;
    public alias c_int          = int;
    public alias c_unsigned_int = uint;
    public alias c_long         = long;
}