#ifndef HASH_H
# define HASH_H

# include "line.h"

# define XXH_INLINE_ALL
# include "xxhash.h"

# if __SIZEOF_POINTER__ == 8
#  define HASH(ln, sz)   (XXH3_64bits(ln, sz))
# else
#  error "not x64 arch (__SIZEOF_POINTER__ != 8)"
# endif

#endif /* HASH_H */
