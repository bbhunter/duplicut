#include "error.h"

int        die(const char *fmt, ...)
{
    va_list ap;

    va_start(ap, fmt);
    dprintf(STDERR_FILENO, "%s: ", PROGNAME);
    vdprintf(STDERR_FILENO, fmt, ap);
    write(STDERR_FILENO, "\n", 1);
    va_end(ap);
    exit(1);
    return (1);
}

int        error(const char *fmt, ...)
{
    va_list ap;

    va_start(ap, fmt);
    write(STDERR_FILENO, "error: ", 7);
    vdprintf(STDERR_FILENO, fmt, ap);
    write(STDERR_FILENO, "\n", 1);
    va_end(ap);
    return (-1);
}