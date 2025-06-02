/****************************************************************
Object List
https://www.mql5.com/en/code/29765

The List class template provides a basic container for storing an ordered list of objects.
For convenience, List also provides synonyms for stack operations,
which make code that uses List for stacks more explicit without defining another class.
Structural notes
   By default, when the list is destroyed, it deletes all dynamic objects.
      Automatic objects will be destroyed anyway.
      This means that you do not have to use operator delete on any objects that you create.
      Once the object has been added to the list, it will not forget it,
       and be able to access it for erasing on destruction.
      Anything that is removed from the list, is transferred to the recycle bin,
       and kept there for safety, keeping the 'hanging' pointers,
       and thus minimizing the chance for the 'bad pointer access' critical error.
      This is justified in most cases, because computer memory is huge these days.
      There is not much burden on efficiency either, only memory, slight though.
      However, for flexibility, the Remove methods have the option to permanently delete the removed object.
      If you need to keep the objects after the list destruction (rare),
       use the MemDelete method to set the memdelete flag false.
      The 'del' parameter in Remove methods is a flag for deleting the object from memory.
      Access to the object will no longer be available, and will raise a critical error.
   The list keeps references to valid objects only, null pointers are removed on access/count attempt.
      However if you use access methods with pointer return, and try to access wrong index,
       you will get a null pointer, this means error index.
      There is a classic workaround for this: the TryGet method which writes the pointer and tells you
       if the returned pointer is valid, so if the method returns false, you shall not use the pointer.
   Hash methods return Mql internal object 'hash codes', as seen when you try to print an object/pointer.
      I'm not sure how these codes are generated, but they seem to be pretty reliable in identifying objects with ==.
Available operators:
   [index] Get,            eg. Class T* pointer=list[3];
   += Append,              eg. list+=pointer;   //list+=&object;
   ^= Prepend,             eg. list^=pointer;   //list+=&object;
   -= Remove,              eg. list-=pointer;   //list+=&object;
   /= Remove & delete,     eg. list/=pointer;   //list+=&object;
   ~ RemoveAll,            eg. ~list;
   = Copy list,            eg. Class listA=listB; //A-new,B-existing
/****************************************************************/
template <typename T>
class ObjectList
{
public:
    // construction, destruction, initialization, and assignment
    ObjectList(bool memdelete = true)
        : mdelete(memdelete)
    {
    }
    ObjectList(ObjectList &src)
    {
        mdelete = src.mdelete;
        Copy(items, src.items);
        Copy(mem, src.mem);
    }
    ~ObjectList()
    {
        RemoveAll();
        if (mdelete)
            EmptyMem();
    }
    ObjectList operator=(ObjectList &);
    void MemDelete(bool memdelete)
    {
        mdelete = memdelete;
    }
    // accessing
    T *operator[](int i)
    {
        return Get(i);
    }
    T *Get(int at)
    {
        int c = Count();
        if (c > 0 && at >= 0 && at < c)
        {
            return items[at];
        }
        return NULL;
    }
    T *First()
    {
        int c = Count();
        if (c > 0)
        {
            return items[0];
        }
        return NULL;
    }
    T *Last()
    {
        int c = Count();
        if (c > 0)
        {
            return items[c - 1];
        }
        return NULL;
    }
    bool TryGet(T *dst, int at)
    {
        if ((dst = Get(at)) != NULL)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    //
    int Count()
    {
        KillBad();
        return ArraySize(items);
    }
    int Find(T *item)
    {
        int c = Count();
        for (int i = 0; i < c; i++)
        {
            if (item == items[i])
            {
                return i;
            }
        }
        return -1;
    }
    void PrintHash()
    {
        for (int i = 0; i < ArraySize(items); i++)
        {
            PrintFormat("%d:%d(%s)", i, Hash(items[i]), typename(items[i]));
        }
    }
    int Hash(T *item)
    {
        string s;
        StringConcatenate(s, s, item);
        return (int)StringToInteger(s);
    }
    int Hash(int at)
    {
        T *p = Get(at);
        return (p != NULL) ? Hash(p) : 0;
    }
    // adding
    void operator+=(T *item)
    {
        Append(item);
    }
    void operator^=(T *item)
    {
        Prepend(item);
    }
    void Append(T *item)
    {
        Append(item, items);
    }
    void Prepend(T *item)
    {
        IncreaseAt(0);
        items[0] = item;
    }
    // removing
    void operator-=(T *item)
    {
        Remove(item, 0);
    }
    void operator/=(T *item)
    {
        Remove(item, 1);
    }
    void operator~()
    {
        RemoveAll();
    }
    void Remove(T *item, bool del = 0)
    {
        int f = Find(item);
        if (f > -1)
        {
            {
                if (del)
                {
                    Delete(item);
                }
                else
                {
                    Append(item, mem);
                }
            }
            ReduceAt(f);
        }
    }
    void RemoveLast(bool del = 0)
    {
        KillBad();
        if (del)
        {
            Delete(Last());
        }
        else
        {
            Append(Last(), mem);
        }
        ReduceAt(ArraySize(items) - 1);
    }
    void RemoveFirst(bool del = 0)
    {
        KillBad();
        if (del)
        {
            Delete(First());
        }
        else
        {
            Append(First(), mem);
        }
        ReduceAt(0);
    }
    void RemoveAll(bool del = 0);
    // stack interface
    T *Top()
    {
        return Last();
    }
    void Push(T *item)
    {
        Append(item);
    }
    T *Pop()
    {
        T *top = Top();
        RemoveLast();
        return top;
    }

protected:
    T *items[];
    T *mem[];
    bool mdelete;
    // service
    void Append(T *item, T *&dst[])
    {
        int r = ArrayResize(dst, ArraySize(dst) + 1);
        dst[r - 1] = item;
    }
    void EmptyMem()
    {
        for (int i = 0; i < ArraySize(mem); i++)
        {
            Delete(mem[i]);
        }
        ArrayFree(mem);
    }
    void Delete(T *item)
    {
        if (CheckPointer(item) == 1)
            delete item;
    }
    void KillBad()
    {
        for (int i = 0; i < ArraySize(items); i++)
        {
            if (items[i] == NULL)
            {
                ReduceAt(i);
                i--;
            }
        }
    }
    void ReduceAt(int);
    void IncreaseAt(int);
    void Copy(T *&dst[], T *&src[])
    {
        int c = ArraySize(src);
        ArrayResize(dst, c);
        for (int i = 0; i < c; i++)
        {
            dst[i] = src[i];
        }
    }
};
/****************************************************************/
template <typename T>
void ObjectList::ReduceAt(int p)
{
    int c = ArraySize(items);
    for (int i = p; i < c; i++)
    {
        int next = i + 1;
        if (next < c)
        {
            items[i] = items[next];
        }
    }
    ArrayResize(items, c - 1);
}
/****************************************************************/
template <typename T>
void ObjectList::IncreaseAt(int p)
{
    int c = ArraySize(items);
    ArrayResize(items, c + 1);
    for (int i = c; i >= p; i--)
    {
        int prev = i - 1;
        if (prev >= 0)
        {
            items[i] = items[prev];
        }
    }
}
/****************************************************************/
template <typename T>
void ObjectList::RemoveAll(bool del = 0)
{
    int c = Count();
    for (int i = 0; i < c; i++)
    {
        if (items[i])
        {
            if (del)
            {
                Delete(items[i]);
            }
            else
            {
                Append(items[i], mem);
            }
        }
    }
    ArrayFree(items);
}

/****************************************************************
Example of ObjectList usage
/****************************************************************/
/**
void OnStart()
  {
   ObjectList<A>list;
   A* o1=new B();             //dynamic
   A  o2;                     //automatic
   A* o3=&o2;                 //automatic

   list+=&o2;                 //append object ref
   list^=o1;                  //prepend
   list+=o3;                  //append pointer
   list.PrintHash();          //see output

     {string s; for(int i=0; i<13; i++) {s+="-";} Print(s);}

   list-=&o2;                 //remove
   ObjectList<A>list2=list;   //copy list
   list2.PrintHash();         //see output

     {string s; for(int i=0; i<13; i++) {s+="-";} Print(s);}

   ~list;                     //clean list, this is empty now
   list2.RemoveLast();        //remove
   list2.PrintHash();         //see output

     {string s; for(int i=0; i<13; i++) {s+="-";} Print(s);}

   A* o=list2[0];                                        //direct access
   Print(list2.Hash(o));   //2097152     //   same...    //risky to use o without check, but if you sure
   Print(list2.Hash(0));   //2097152     //...object
   Print(list2.TryGet(o,666)); //false, don't use o      //safe access
   /**
   ...On destruction the list will delete the dynamic object o1 from memory.

  }
/****************************************************************
Output:
/**
   0:2097152(A*)
   1:3145728(A*)
   2:3145728(A*)
   -------------
   0:2097152(A*)
   1:3145728(A*)
   -------------
   0:2097152(A*)
   -------------
   2097152
   2097152
   false
*/