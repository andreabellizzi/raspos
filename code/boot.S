.section ".text.boot"  // Make sure the linker puts this at the start of the kernel image

.global _start  // Execution starts here

_start:
    // Check processor ID is zero (executing on main core), else hang
    //MRS Xt, <system register> // copy a system register into genpurp reg
    mrs     x1, mpidr_el1 
    // and bit a bit
    and     x1, x1, #3
    //<label>f means the label is forward and is used with numeric label
    //to hint the compiler
    //<label>b is the same but backward, with textual label is not used
    
    cbz     x1, 2f 
    // We're not on the main core, so hang in an infinite wait loop
1:  wfe
    b       1b
2:  // We're on the main core!

    // Set stack to start below our code
    ldr     x1, =_start
    mov     sp, x1

    // Clean the BSS section
    //ldr, load register with value
    ldr     x1, =__bss_start     // Start address
    ldr     w2, =__bss_size      // Size of the section
3:  cbz     w2, 4f               // Quit loop if zero
    //xzr is zero register used to write value 0 to memory or register
    //str store register xzr to memory [x1] and increment x1 by 8
    str     xzr, [x1], #8
    sub     w2, w2, #1
    cbnz    w2, 3b               // Loop if non-zero

    // Jump to our main() routine in C (make sure it doesn't return)
4:  bl      main
    // In case it does return, halt the master core too
    b       1b