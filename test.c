#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NUM_TESTS 4
#define CMD_BUFFER 256
#define OUT_BUFFER 256

typedef struct {
  const char *cmd;
  const char *arg;
  const char *expect;
} TestCase;

static TestCase tests[NUM_TESTS] = {
    {"d2b", "10", "1010"},
    {"b2d", "1010", "10"},
    {"d2h", "255", "FF"},
    {"h2d", "FF", "255"},
};

/* run a shell command and return its first line (malloc’d) with newline trimmed
 */
char *run_cmd(const char *cmd) {
  FILE *fp = popen(cmd, "r");
  if (!fp) {
    fprintf(stderr, "❌ popen failed\n");
    return NULL;
  }
  char buf[OUT_BUFFER] = {0};
  if (!fgets(buf, sizeof(buf), fp)) {
    buf[0] = '\0';
  }
  pclose(fp);
  /* trim trailing newline */
  size_t len = strlen(buf);
  if (len && buf[len - 1] == '\n')
    buf[len - 1] = '\0';
  return strdup(buf);
}

int main(void) {
  int fails = 0;

  puts("🛠️  Building the binary via `make`…");
  if (system("make") != 0) {
    fprintf(stderr, "❌ `make` failed, aborting tests\n");
    return EXIT_FAILURE;
  }

  puts("✅ Build succeeded. Running tests:\n");

  for (int i = 0; i < NUM_TESTS; i++) {
    char cmdline[CMD_BUFFER];
    snprintf(cmdline, sizeof(cmdline), "./main %s %s", tests[i].cmd,
             tests[i].arg);

    char *out = run_cmd(cmdline);
    if (out == NULL) {
      fprintf(stderr, "❌ could not run: %s\n", cmdline);
      fails++;
      continue;
    }

    if (strcmp(out, tests[i].expect) == 0) {
      printf("✔ %s %s → %s\n", tests[i].cmd, tests[i].arg, out);
    } else {
      printf("✖ %s %s → got “%s” but expected “%s”\n", tests[i].cmd,
             tests[i].arg, out, tests[i].expect);
      fails++;
    }
    free(out);
  }

  if (fails) {
    printf("\n❌ %d test(s) failed\n", fails);
    return EXIT_FAILURE;
  } else {
    puts("\n🎉 All tests passed!");
    return EXIT_SUCCESS;
  }
}
