#include <stdio.h>
#include <stdlib.h>

#include <vic/context.h>

static const size_t k_stacksize = 1024 * 64;

vic_context_t g_main_fiber = invalid_vic_context;
vic_context_t g_child_fiber = invalid_vic_context;

void child_entry(intptr_t argv) {
    while (true) {
        vic_swap_context(&g_child_fiber, g_main_fiber, (intptr_t)0, false);
    }
}

int32_t main(int32_t argc, char *argv[]) {
    unsigned long count = 10000;
    if (argc > 1) {
        count = strtoul(argv[1], NULL, 10);
    }
    void *p = malloc(k_stacksize);
    void *sp = (char *)p + k_stacksize;
    g_child_fiber = vic_make_context(sp, k_stacksize, child_entry);

    unsigned long i;
    for (i = 0; i < count; ++i) {
        vic_swap_context(&g_main_fiber, g_child_fiber, (intptr_t)0, false);
    }
    free(p);
    return 0;
}
