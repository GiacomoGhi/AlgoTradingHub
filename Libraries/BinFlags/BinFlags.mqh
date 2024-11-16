#include "../List/BasicList.mqh";

/****************************************************************
Binary Flags
https://www.mql5.com/en/code/29480

Minimize bool parameters in a function signature.
You can use binary flags to minimize bool parameters in a function signature.
For example, MQL int size is 32 bits, so you can pack 32 1/0 parameters in a single int flag variable.
BinFlags can be initialized with any integer data type:char, bool, short, int, color, long, datetime.
Your maximum flag length will vary: 1 byte = 8 bits, 2 bytes = 16 bits, etc.
A flag represents a number which has only one '1' bit in any position.
Such numbers are 1, 2, 4, 8, 16, 32, etc. You get it.
Large numbers of this kind look better in hex: 0x1, 0x2, 0x4, 0x8, 0x10, 0x20, etc.
This class works with flags, which follow the rule.
BinFlags must be initialized first. You can overwrite later the internal flags with Write.
You can check, set, reset any number of flags.
Multiple flags should be separated by '|'.
/****************************************************************/

class BinFlags
{
public:
    BinFlags()
        : mflags(0)
    {
    }
    BinFlags(int flags)
        : mflags(flags)
    {
    }
    void Write(int flags)
    {
        mflags = flags;
    }
    int Read()
    {
        return mflags;
    }
    bool HasFlag(int flags)
    {
        return (mflags & (flags)) == flags;
    }
    bool HasAnyFlag(BasicList<int> *flagsList)
    {
        for (int i = 0; i < flagsList.Count(); i++)
        {
            if (HasFlag(flagsList.Get(i)))
            {
                return true;
            }
        }
        return false;
    }
    void SetFlag(int flags)
    {
        mflags |= (flags);
    }
    void ResetFlag(int flags)
    {
        mflags &= ~(flags);
    }
    void Clear()
    {
        mflags = 0;
    }
    string Format();

protected:
    int Bits()
    {
        int i = 0;
        for (i; i < sizeof(int) * 8; i += 4)
        {
            if (mflags < (int)pow(2, i))
            {
                break;
            }
        }
        return (i) ? i : 1;
    }
    int mflags;
};
/****************************************************************/
string BinFlags::Format()
{
    string format = "BinFlags:";
    int bits = Bits();
    for (int i = bits; i > 0; i--)
    {
        string prefix = (i % 4 == 0 && i != bits) ? " " : "";
        format += ((mflags & (1 << (i - 1))) != 0) ? prefix + "1" : prefix + "0";
    }
    return format;
}

/**
Example of BinFalgs usage.
#include "BinFlags.mqh"
enum ENUM_EXAMPLE_FLAGS {A=0x1,B=0x2,C=0x4,D=0x8};
void OnStart()
  {
   BinFlags<int>bf(A|B);             //init & write

   Print(bf.Format());               //0011 (2 flags on)
   Print("A:",bf.HasFlag(A));        //A:true
   Print("AD:",bf.HasFlag(A|D));     //AD:false
   bf.Set(C|D);                      //set C & D
   Print(bf.Format());               //1111 (all flags on)
   bf.Rst(A);                        //reset A
   Print("BCD:",bf.HasFlag(B|C|D));  //BCD:true
   Print(bf.Format());               //1110 (one flag down)
  }
Output:
   BinFlags:0011
   A:true
   AD:false
   BinFlags:1111
   BCD:true
   BinFlags:1110
*/