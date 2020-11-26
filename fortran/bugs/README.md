# Debug Fortran code

This example is from [Jonathan Laver  and Mark Williamson](https://undo.io/resources/debugging-fortran-code-gdb/).

This folder contains a very simple Fortran code that calculate the ratios between successive integers.

## compile code

```
gfortran -o bugs.exe bugs.f90
```
## Run the code

```
./bugs.exe
```

This would return:

```
         Infinity
   2.00000000
   1.50000000
   1.33333337
   1.25000000
   1.20000005
   1.16666663
   1.14285719
   1.12500000
   1.11111116
```

 Obviously the code contains a bug!
 
## Building for debug

We can add the `-g` flag to generate debug information.

The Infinity value suggests an error in our floating point operation. For instance a division by zero.

Check your compiler as usually you can add compilation flags to trap exception for various floating point errors.

With gfortran we can use the `-ffpe-trap` compilation flag:

```
gfortran -g -ffpe-trap=zero,invalid,overflow,underflow -o bugs.exe bugs.f90
```

And now let's execute it:

```
./bugs.exe
```

We get:

```
Program received signal SIGFPE: Floating-point exception - erroneous arithmetic operation.

Backtrace for this error:
#0  0x7f39df1c8d1d in ???
#1  0x7f39df1c7f7d in ???
#2  0x7f39dec877ff in ???
#3  0x564e9b02296a in divide_
        at /opt/work/demo-debugging/fortran/bugs/bugs.f90:23
#4  0x564e9b022a19 in bugs
        at /opt/work/demo-debugging/fortran/bugs/bugs.f90:15
#5  0x564e9b022a84 in main
        at /opt/work/demo-debugging/fortran/bugs/bugs.f90:18
Floating point exception
```

- if you read carefully the output you can see there is an error in `divide` line 23:

```
print *,e/d
```

**YES**! There is an error when dividing `e` per `d`. But why?

- First thing we can do is to check the value of `d` by adding another print statement before.

## Debugging tools

- [gdb](https://www.gnu.org/software/gdb/) is one of the most popular (and free!) debugger
- [gdbgui](https://www.gdbgui.com/) uses `gdb` as a back end and offer a nice Graphical User Interface. It is also free.
- [Totalview](https://totalview.io/) is very popular among HPC users (but very expensive!);

### Using gdb

Let's start `bugs.exe` with the debugger. To stop execution on the first line of our program we use `b MAIN__`. 
The reason we need to use MAIN__ instead of main (as we would usually use with C) is that main actually runs some startup code to set up the enviroment.

```
  gdb ./bugs.exe
  [ ... GDB start-up messages ... ]
  (gdb) break MAIN__
  Breakpoint 1 at 0x4008c4: file bugs.f90, line 8.
  (gdb) run
  Starting program: /home/blog_posts/a.out 
  
  Breakpoint 1, bugs () at bugs.f90:8
  8        do p=1,10
Now we can step through each line of Fortran source code by pressing n:

  (gdb) n
  9            c(p)=p
  (gdb) n
  8        do p=1,10
  (gdb) n
  9            c(p)=p
```

`gdb` uses the debug information from gfortran to step through lines of source code, so we can see how the state is changing.

We could just do that until the error occurs – but it would be nice to jump to the exact moment of the floating point error we’re expecting. 

Now we’ve recompiled to trap on floating point exceptions we will receive a SIGFPE if a floating point error happens. 

By default, GDB will stop when it sees signals that indicate errors – in C code we often we see this when a SIGSEGV occurs due to a pointer-related bug.

If we simply continue with execution, GDB will stop the program when a floating-point error occurs:

```
  (gdb) cont
  Continuing.
  
  Program received signal SIGFPE, Arithmetic exception.
  0x0000000000400887 in divide (d=0, e=1) at bugs.f90:24
  24      print *,e/d
The debugger has now stopped on a floating point arithmetic exception – this is likely to be the source of our maths error. We can use the debugger to find out where we are:

  (gdb) bt
  #0  0x0000000000400887 in divide (d=0, e=1) at bugs.f90:24
  #1  0x0000000000400932 in bugs () at bugs.f90:15
  #2  0x0000000000400996 in main (argc=1, argv=0x7fffffffe811) at bugs.f90:19
  #3  0x00000034ff821d65 in __libc_start_main ([...]) at libc-start.c:285
  #4  0x0000000000400759 in _start ()
(arguments to __libc_start_main are omitted for brevity)
```

We’re in our divide function, called from our bugs routine. In an interactive session, we might use the list command to check on the surrounding code. For the purposes of this example, lets just inspect the values of the variables for mathematical errors:

```
  (gdb) p d
  $1 = 0
  (gdb) p e
  $2 = 1
  (gdb) p e/d
  $3 = inf
```

Given the values of d and e, it looks like we are dividing by zero by mistake – `gdb` confirms that e/d gives the result inf, or infinity. The order of the variables in the division (see line 23) is wrong – we should be dividing d by e and not the other way around. If we fix this bug and re-run then we’ll see the following output:

```
  ./bugs.exe
  
   0.00000000
  0.500000000
  0.666666687
  0.750000000
  0.800000012
  0.833333313
  0.857142866
  0.875000000
  0.888888896
  0.899999976
```

We’ve fixed our unwanted Infinity message! We’re now seeing the ratios of successive integers trending progressively closer to 1.0, as we would expect.


### using gdbgui

To install gdbgui, follow the documentation [here](https://www.gdbgui.com/installation/).

```
gdbgui ./bugs.exe
```

