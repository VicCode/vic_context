#pragma once

#include <inttypes.h>
#include <stdbool.h>
#include <sys/types.h>

#ifdef	__cplusplus
extern "C" {
#endif

struct vic_context_detail;

typedef struct vic_context_detail * vic_context_t;

typedef void (* vic_context_entry_t)(intptr_t);

#define invalid_vic_context (vic_context_t)0

intptr_t vic_swap_context(vic_context_t *from, vic_context_t to, intptr_t arg, bool preserve_fpu/* = false*/);

vic_context_t vic_make_context(void *sp, size_t size, vic_context_entry_t entry);

#ifdef	__cplusplus
}
#endif

