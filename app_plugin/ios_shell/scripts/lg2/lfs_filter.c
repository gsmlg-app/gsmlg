/*
 * Git LFS filter (spec v1) for lg2: clean stores content in the local
 * object store and emits a pointer, smudge restores locally available
 * objects and otherwise leaves the pointer in place.
 */
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include <CommonCrypto/CommonDigest.h>
#include <git2.h>
#include <git2/sys/filter.h>

#define LFS_VERSION_LINE "version https://git-lfs.github.com/spec/v1\n"
#define LFS_OID_PREFIX "oid sha256:"
#define LFS_SIZE_PREFIX "size "
#define LFS_POINTER_LIMIT 1024
#define LFS_OID_LENGTH 64
#define LFS_PATH_LIMIT 4096

int lg2_lfs_filter_register(void);

static int lfs_fail(const char *message, const char *path)
{
	char text[LFS_PATH_LIMIT + 256];
	snprintf(text, sizeof(text), "git-lfs: %s %s: %s", message, path, strerror(errno));
	git_error_set_str(GIT_ERROR_FILTER, text);
	return -1;
}

static int lfs_parse_pointer(const char *data, size_t length, char *oid, unsigned long long *size)
{
	size_t version = strlen(LFS_VERSION_LINE);
	size_t oid_prefix = strlen(LFS_OID_PREFIX);
	size_t size_prefix = strlen(LFS_SIZE_PREFIX);
	size_t position;
	size_t digits = 0;
	unsigned long long value = 0;
	int i;

	if (length >= LFS_POINTER_LIMIT || length < version + oid_prefix + LFS_OID_LENGTH + 1 + size_prefix + 2)
		return 0;
	if (memcmp(data, LFS_VERSION_LINE, version) != 0)
		return 0;
	position = version;
	if (memcmp(data + position, LFS_OID_PREFIX, oid_prefix) != 0)
		return 0;
	position += oid_prefix;
	for (i = 0; i < LFS_OID_LENGTH; i++) {
		char c = data[position + i];
		if (!((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f')))
			return 0;
	}
	memcpy(oid, data + position, LFS_OID_LENGTH);
	oid[LFS_OID_LENGTH] = '\0';
	position += LFS_OID_LENGTH;
	if (data[position++] != '\n')
		return 0;
	if (length - position < size_prefix || memcmp(data + position, LFS_SIZE_PREFIX, size_prefix) != 0)
		return 0;
	position += size_prefix;
	while (position < length && data[position] >= '0' && data[position] <= '9') {
		if (value > (~0ULL - 9) / 10)
			return 0;
		value = value * 10 + (unsigned long long)(data[position] - '0');
		position++;
		digits++;
	}
	if (digits == 0 || position + 1 != length || data[position] != '\n')
		return 0;
	*size = value;
	return 1;
}

static int lfs_make_directory(const char *path)
{
	if (mkdir(path, 0777) == 0 || errno == EEXIST)
		return 0;
	return lfs_fail("unable to create directory", path);
}

static int lfs_object_path(char *out, const char *gitdir, const char *oid)
{
	int written = snprintf(out, LFS_PATH_LIMIT, "%slfs/objects/%.2s/%.2s/%s", gitdir, oid, oid + 2, oid);
	if (written < 0 || written >= LFS_PATH_LIMIT) {
		git_error_set_str(GIT_ERROR_FILTER, "git-lfs: repository path is too long");
		return -1;
	}
	return 0;
}

static int lfs_object_exists(const char *path, unsigned long long size)
{
	struct stat info;
	return stat(path, &info) == 0 && S_ISREG(info.st_mode) && (unsigned long long)info.st_size == size;
}

static int lfs_store_object(const char *gitdir, const char *oid, const git_buf *from)
{
	char object[LFS_PATH_LIMIT];
	char directory[LFS_PATH_LIMIT];
	char temporary[LFS_PATH_LIMIT];
	const char *suffixes[] = { "lfs", "lfs/tmp", "lfs/objects" };
	size_t offset = 0;
	FILE *file;
	int descriptor;
	int i;

	if (lfs_object_path(object, gitdir, oid) < 0)
		return -1;
	if (lfs_object_exists(object, (unsigned long long)from->size))
		return 0;
	for (i = 0; i < 3; i++) {
		snprintf(directory, sizeof(directory), "%s%s", gitdir, suffixes[i]);
		if (lfs_make_directory(directory) < 0)
			return -1;
	}
	snprintf(directory, sizeof(directory), "%slfs/objects/%.2s", gitdir, oid);
	if (lfs_make_directory(directory) < 0)
		return -1;
	snprintf(directory, sizeof(directory), "%slfs/objects/%.2s/%.2s", gitdir, oid, oid + 2);
	if (lfs_make_directory(directory) < 0)
		return -1;

	snprintf(temporary, sizeof(temporary), "%slfs/tmp/%s.XXXXXX", gitdir, oid);
	descriptor = mkstemp(temporary);
	if (descriptor < 0)
		return lfs_fail("unable to create temporary file", temporary);
	file = fdopen(descriptor, "wb");
	if (!file) {
		close(descriptor);
		unlink(temporary);
		return lfs_fail("unable to open temporary file", temporary);
	}
	while (offset < from->size) {
		size_t count = fwrite(from->ptr + offset, 1, from->size - offset, file);
		if (count == 0)
			break;
		offset += count;
	}
	if (offset != from->size || fclose(file) != 0) {
		if (offset != from->size)
			fclose(file);
		unlink(temporary);
		return lfs_fail("unable to write object", temporary);
	}
	if (rename(temporary, object) != 0) {
		unlink(temporary);
		return lfs_fail("unable to store object", object);
	}
	return 0;
}

static void lfs_sha256(char *out, const git_buf *from)
{
	static const char hex[] = "0123456789abcdef";
	unsigned char digest[CC_SHA256_DIGEST_LENGTH];
	CC_SHA256_CTX context;
	size_t offset = 0;
	int i;

	CC_SHA256_Init(&context);
	while (offset < from->size) {
		size_t chunk = from->size - offset;
		if (chunk > 0x40000000)
			chunk = 0x40000000;
		CC_SHA256_Update(&context, from->ptr + offset, (CC_LONG)chunk);
		offset += chunk;
	}
	CC_SHA256_Final(digest, &context);
	for (i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
		out[i * 2] = hex[digest[i] >> 4];
		out[i * 2 + 1] = hex[digest[i] & 0x0f];
	}
	out[LFS_OID_LENGTH] = '\0';
}

static int lfs_clean(git_buf *to, const git_buf *from, const char *gitdir)
{
	char oid[LFS_OID_LENGTH + 1];
	char pointer[LFS_POINTER_LIMIT];
	unsigned long long size;
	int length;

	if (from->size == 0 || lfs_parse_pointer(from->ptr, from->size, oid, &size))
		return GIT_PASSTHROUGH;
	lfs_sha256(oid, from);
	if (lfs_store_object(gitdir, oid, from) < 0)
		return -1;
	length = snprintf(pointer, sizeof(pointer), "%s%s%s\n%s%llu\n",
		LFS_VERSION_LINE, LFS_OID_PREFIX, oid, LFS_SIZE_PREFIX, (unsigned long long)from->size);
	return git_buf_set(to, pointer, (size_t)length);
}

static int lfs_smudge(git_buf *to, const git_buf *from, const char *gitdir)
{
	char oid[LFS_OID_LENGTH + 1];
	char object[LFS_PATH_LIMIT];
	unsigned long long size;
	char *contents;
	FILE *file;
	size_t length;
	int error;

	if (!lfs_parse_pointer(from->ptr, from->size, oid, &size))
		return GIT_PASSTHROUGH;
	if (lfs_object_path(object, gitdir, oid) < 0 || !lfs_object_exists(object, size))
		return GIT_PASSTHROUGH;
	file = fopen(object, "rb");
	if (!file)
		return lfs_fail("unable to open object", object);
	contents = malloc(size > 0 ? (size_t)size : 1);
	if (!contents) {
		fclose(file);
		git_error_set_oom();
		return -1;
	}
	length = fread(contents, 1, (size_t)size, file);
	if (length != (size_t)size || ferror(file)) {
		free(contents);
		fclose(file);
		return lfs_fail("unable to read object", object);
	}
	fclose(file);
	error = git_buf_set(to, contents, length);
	free(contents);
	return error;
}

static int lfs_apply(git_filter *self, void **payload, git_buf *to, const git_buf *from, const git_filter_source *src)
{
	git_repository *repository = git_filter_source_repo(src);
	const char *gitdir;

	(void)self;
	(void)payload;
	if (!repository)
		return GIT_PASSTHROUGH;
	gitdir = git_repository_path(repository);
	if (git_filter_source_mode(src) == GIT_FILTER_TO_ODB)
		return lfs_clean(to, from, gitdir);
	return lfs_smudge(to, from, gitdir);
}

static git_filter lfs_filter = GIT_FILTER_INIT;

int lg2_lfs_filter_register(void)
{
	int error;

	lfs_filter.attributes = "filter=lfs";
	lfs_filter.apply = lfs_apply;
	error = git_filter_register("lfs", &lfs_filter, GIT_FILTER_DRIVER_PRIORITY);
	return error == GIT_EEXISTS ? 0 : error;
}
