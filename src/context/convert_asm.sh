#!/bin/bash
# Created Time:    2015-08-30 16:13:46
# Modified Time:   2016-03-26 14:21:11

PROG_DIR=`dirname ${BASH_SOURCE[0]}`

ASM_DIR="$PROG_DIR/asm"

echo $PROG_DIR
echo $ASM_DIR

sed -i "s/jump_fcontext/vic_swap_context/g" `grep "jump_fcontext" -rl $ASM_DIR`
sed -i "s/make_fcontext/vic_make_context/g" `grep "make_fcontext" -rl $ASM_DIR`
