# Program to check if a 3x3 matrix is a Magic Square.
# To be run in the RIPES simulator.

.data
# Example matrix 1 (is a magic square)
# mat: .word 2, 7, 6
#      .word 9, 5, 1
#      .word 4, 3, 8

# Example matrix 2 (not a magic square)
mat: .word 1, 2, 3
     .word 4, 5, 6
     .word 7, 8, 9

N: .word 3     # Size of the square matrix

is_magic_msg: .string "The matrix IS a magic square.\n"
not_magic_msg: .string "The matrix IS NOT a magic square.\n"

.text
.global _start

_start:
    la a0, mat       # a0 holds the base address of the matrix
    lw a1, N         # a1 holds the matrix size (N)

    # -------------------------------------------------------------
    # Step 1: Calculate the magic constant (sum of first row)
    # -------------------------------------------------------------
    lw t0, 0(a0)     # Load mat[0][0]
    lw t1, 4(a0)     # Load mat[0][1]
    lw t2, 8(a0)     # Load mat[0][2]
    add s0, t0, t1   # s0 = mat[0][0] + mat[0][1]
    add s0, s0, t2   # s0 = mat[0][0] + mat[0][1] + mat[0][2] (magic_sum)

    # -------------------------------------------------------------
    # Step 2: Check all row sums
    # -------------------------------------------------------------
    mv t3, a1        # t3 = N (row counter)
    mv t4, a0        # t4 = current row address
    addi t5, a0, 4   # t5 = address for mat[1][0]
    addi t6, a0, 8   # t6 = address for mat[2][0]

row_loop:
    beq t3, zero, check_cols   # Exit loop if t3 == 0

    # Calculate sum of current row
    lw t0, 0(t4)
    lw t1, 4(t4)
    lw t2, 8(t4)
    add t6, t0, t1
    add t6, t6, t2

    bne t6, s0, not_magic      # If row sum != magic_sum, it's not a magic square

    addi t4, t4, 12            # Next row address (3 words * 4 bytes/word)
    addi t3, t3, -1            # Decrement row counter
    j row_loop

check_cols:
    # -------------------------------------------------------------
    # Step 3: Check all column sums
    # -------------------------------------------------------------
    mv t3, a1        # t3 = N (column counter)
    mv t4, a0        # t4 = base address of matrix

col_loop:
    beq t3, zero, check_diag1  # Exit loop if t3 == 0

    # Calculate sum of current column
    lw t0, 0(t4)       # Load mat[0][i]
    lw t1, 12(t4)      # Load mat[1][i] (next row, same column)
    lw t2, 24(t4)      # Load mat[2][i] (next row, same column)
    add t6, t0, t1
    add t6, t6, t2

    bne t6, s0, not_magic      # If column sum != magic_sum, not magic

    addi t4, t4, 4             # Next column address
    addi t3, t3, -1            # Decrement column counter
    j col_loop

check_diag1:
    # -------------------------------------------------------------
    # Step 4: Check main diagonal sum
    # -------------------------------------------------------------
    lw t0, 0(a0)       # mat[0][0]
    lw t1, 16(a0)      # mat[1][1] (12 bytes for first row + 4 bytes for next column)
    lw t2, 32(a0)      # mat[2][2]
    add t6, t0, t1
    add t6, t6, t2

    bne t6, s0, not_magic      # If diagonal sum != magic_sum, not magic

check_diag2:
    # -------------------------------------------------------------
    # Step 5: Check secondary diagonal sum
    # -------------------------------------------------------------
    addi t4, a0, 8     # Address of mat[0][2]
    lw t0, 0(t4)       # Load mat[0][2]
    lw t1, 8(t4)       # Load mat[1][1] (8 bytes for row swap - 4 for col skip)
    lw t2, 16(t4)      # Load mat[2][0]
    add t6, t0, t1
    add t6, t6, t2

    bne t6, s0, not_magic      # If diagonal sum != magic_sum, not magic

    # -------------------------------------------------------------
    # Step 6: It is a magic square
    # -------------------------------------------------------------
    la a0, is_magic_msg
    li a7, 4           # ecall for print string
    ecall
    j exit

not_magic:
    la a0, not_magic_msg
    li a7, 4           # ecall for print string
    ecall

exit:
    li a7, 10          # ecall for exit
    ecall