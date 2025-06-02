/****************************************************************
BasicList
https://www.mql5.com/en/code/29780

The List class template provides a basic container for storing an ordered list
of basic data type objects.
For convenience, List also provides synonyms for stack operations,
which make code that uses List for stacks more explicit without defining another class.
Mql does not allow to manipulate pointers and basic types in one template,
so one generic list with pointer control is impossible for all built-in types and user types.
   This is why I made an independent template List for basic types.
Available operators:
   [index] Get,         eg. T var=list[3];
   += Append,           eg. list+=var;
   ^= Prepend,          eg. list^=var;
   -= Remove,           eg. list-=var;
   ~ RemoveAll,         eg. ~list;
   = Copy list,         eg. T listA=listB; //A-new,B-existing
/****************************************************************/
template <typename T>
class BasicList
{
public:
    // construction, destruction, initialization, and assignment
    BasicList() {}
    BasicList(BasicList &src) { Copy(items, src.items); }
    ~BasicList() {}
    // accessing
    T operator[](int i) { return Get(i); }
    T Get(int at)
    {
        int c = Count();
        if (c > 0 && at >= 0 && at < c)
        {
            return items[at];
        }
        return NULL;
    }
    T First()
    {
        int c = Count();
        if (c > 0)
        {
            return items[0];
        }
        return NULL;
    }
    T Last()
    {
        int c = Count();
        if (c > 0)
        {
            return items[c - 1];
        }
        return NULL;
    }
    //
    int Count() { return ArraySize(items); }
    int Find(T item)
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
    bool Contains(T item)
    {
        int c = Count();
        for (int i = 0; i < c; i++)
        {
            if (item == items[i])
            {
                return true;
            }
        }
        return false;
    }
    void Print()
    {
        int c = ArraySize(items);
        for (int i = 0; i < c; i++)
        {
            PrintFormat("%d:%s", i, (string)items[i]);
        }
    }
    // adding
    void operator+=(T item) { Append(item); }
    void operator^=(T item) { Prepend(item); }
    void Append(T item)
    {
        int c = ArraySize(items);
        IncreaseAt(c);
        items[c] = item;
    }
    void Prepend(T item)
    {
        IncreaseAt(0);
        items[0] = item;
    }
    // removing
    void operator-=(T item) { Remove(item); }
    void operator~() { RemoveAll(); }
    void Remove(T item)
    {
        int f = Find(item);
        if (f > -1)
        {
            ReduceAt(f);
        }
    }
    void RemoveLast() { ReduceAt(ArraySize(items) - 1); }
    void RemoveFirst() { ReduceAt(0); }
    void RemoveAll() { ArrayFree(items); }
    // stack interface
    T Top() { return Last(); }
    void Push(T item) { Append(item); }
    T Pop()
    {
        T top = Top();
        RemoveLast();
        return top;
    }

protected:
    T items[];
    // service
    void ReduceAt(int);
    void IncreaseAt(int);
    void Copy(T &dst[], T &src[])
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
void BasicList::ReduceAt(int p)
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
void BasicList::IncreaseAt(int p)
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
/**/