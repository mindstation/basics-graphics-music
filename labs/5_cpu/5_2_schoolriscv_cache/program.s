# li pseudo-instruction

        li      t0, 0xB           ## iterations count
        li      t3, 0x12345678    ## there li is two real instructions: lui and addi
        li      t4, 0x12345000    ## two real instructions: lui and addi
        li      t5, -0x123

# RISC-V fibonacci program
#
# Stanislav Zhelnio, 2020
# Amended by Yuri Panchul, 2024

#init:

        #li       t1, 0x1         ## iteration decrement value

        #li       a1, 1
        #li       a7, 0xffff0020  ## memory-mapped I/O: start/stop cycle counter port address
                                 ### RARS MMIO addresses is 0xffff0000 - 0xffffffe0
                                 ### two real instructions
        #sw       a1, 0(a7)       ## cycle_cnt start

#fibonacci:

        #mv      a0, zero
        #li      t2, 1

#loop:   add     t3, a0, t2
        #mv      a0, t2
        #mv      t2, t3
        #sub     t0, t0, t1
        #bnez    t0, loop

        #sw       zero, 0(a7)     ## cycle_cnt stop
        #nop                      ## nop for program align; mem_ctrl prefetch take four commands time after time
#finish: beqz     zero, finish

# RISC-V factorial program
# Uncomment it when necessary

init:
          li       t1, 0x1         ## decrement value for loop counters

          li       a1, 1
          li       a7, 0xffff0020  ## memory-mapped I/O: start/stop cycle counter port address
                                   ## RARS MMIO addresses is 0xffff0000 - 0xffffffe0
                                   ## two real instructions
          sw       a1, 0(a7)       ## cycle_cnt start

factorial:

          li      a0, 1
          li      t2, 2

          nop                      ## nop for program align; mem_ctrl prefetch take four commands time after time
loop:     mv      t6, t2
          mv      a1, zero
          beqz    zero, mul_loop
          add     a6, a1, a0
          add     a6, a1, a0
          add     a6, a1, a0
mul_ret:  mv      a0, a1
          addi    t2, t2, 1
          sub     t0, t0, t1
          add     a6, a1, a0
          bnez    t0, loop

          sw      zero, 0(a7)      ## cycle_cnt stop
          nop
          nop
          beqz    zero, finish
mul_loop: add     a1, a1, a0
          sub     t6, t6, t1
          add     a6, a1, a0
          add     a6, a1, a0
          bnez    t6, mul_loop
          add     a6, a1, a0
          add     a6, a1, a0
          add     a6, a1, a0
          beqz    zero, mul_ret
          nop

finish:   beqz     zero, finish
