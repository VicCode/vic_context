#include <stdio.h>
#include <stdlib.h>

#include <vic/context.h>

static const size_t k_stacksize = 1024 * 64;

vic_context_t g_main_fiber = invalid_vic_context;
vic_context_t g_child_fiber = invalid_vic_context;

void child_entry(intptr_t argv) {
    long val = (long)argv;
    printf("child: before jump to main, val: %ld\n", val);
    val *= 10;
    val = (long)vic_swap_context(&g_child_fiber, g_main_fiber, (intptr_t)val, false);
    printf("child: after jump to main, val: %ld\n", val);
}

int32_t main(int32_t argc, char *argv[]) {
    void *p = malloc(k_stacksize);
    void *sp = (char *)p + k_stacksize;
    g_child_fiber = vic_make_context(sp, k_stacksize, child_entry);

    long val = 1;
    printf("main: before jump to child, val: %ld\n", val);
    val = (long)vic_swap_context(&g_main_fiber, g_child_fiber, (intptr_t)val, false);
    printf("main: after jump to child, val: %ld\n", val);
    free(p);
    printf("Exit..\n");
    return 0;
}
