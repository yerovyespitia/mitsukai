#include "../Orzen-Bridging-Header.h"
#include <dlfcn.h>

void *orzen_mpv_get_proc_address(void *ctx, const char *name) {
    (void)ctx;
    return dlsym(RTLD_DEFAULT, name);
}
