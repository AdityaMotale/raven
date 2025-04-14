#include <stdio.h>
#include <sys/ioctl.h>
#include <unistd.h>

const char *purple = "\033[35m";       // purple
const char *orange = "\033[38;5;208m"; // orange
const char *reset = "\033[0m";         // escape code

const int logo_width = 50;

const int ascii_art_len = 12;
const char *ascii_art[] = {
    "",
    "",
    "",
    "  /$$$$$$  /$$$$$$  /$$    /$$/$$$$$$  /$$$$$$$     ",
    " /$$__  $$|____  $$|  $$  /$$/$$__  $$| $$__  $$    ",
    "| $$  \\__/ /$$$$$$$ \\  $$/$$/ $$$$$$$$| $$  \\ $$ ",
    "| $$      /$$__  $$  \\  $$$/| $$_____/| $$  | $$   ",
    "| $$     |  $$$$$$$   \\  $/ |  $$$$$$$| $$  | $$   ",
    "|__/      \\_______/    \\_/   \\_______/|__/  |__/ ",
    "",
    "",
    "",
};

const int cmds_len = 4;
const char *cmd_desc[] = {
    "Base10 to Base2  ",
    "Base2 to Base10  ",
    "Base10 to Base16 ",
    "Base16 to Base10 ",
};
const char *cmd_bind[] = {
    "d2b",
    "b2d",
    "d2h",
    "h2d",
};

void print_commands(void) {
  // fetch no. of available col's in terminal view
  struct winsize w;
  ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
  const int terminal_width = w.ws_col;

  int left_padding = (terminal_width - logo_width) / 2;

  // print ascii art
  for (int i = 0; i < ascii_art_len; i++) {
    printf("%*s%s\n", left_padding, "", ascii_art[i]);
  }

  // Print each command line with colors.
  for (int i = 0; i < cmds_len; i++) {
    // Using the spacing constant between description and key binding.
    printf("%*s%s%s%s", left_padding, "", purple, cmd_desc[i], reset);

    // Add fixed spacing between the description and key binding.
    for (int s = 0; s < 26; s++) {
      putchar(' ');
    }

    printf("%s%s%s\n", orange, cmd_bind[i], reset);
  }

  // Print a separator.
  printf("\n\n\n");
}
