#ifndef UTILS_H
#define UTILS_H

static inline void *memcpy(void *dest, const void *src, size_t n) {
	char *d = dest;
	const char *s = src;
	for (size_t i = 0; i < n; ++i) {
		d[i] = s[i];
	}
	return dest;
}

static inline int strlen(const char *a) {
	size_t i = 0;
	while (*a) {
		++i;
		++a;
	}
	return i;
}

#endif /* UTILS_H */
