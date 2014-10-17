#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "support.h"

#define LINESIZE 80

#define fail_if(x) do { if (x) exit(1); } while (0)

static char buffer[LINESIZE];
static size_t buflen = 0;

static char input[LINESIZE];
static size_t inputlen = 0;

static size_t position = 0;

static void advance(size_t n)
{
	fail_if(n > buflen);
	memmove(buffer, buffer + n, buflen - n);
	buflen -= n;
	position += n;
}

static char peek(size_t i)
{
	while (!(i < buflen)) {
		int c = fgetc(stdin);
		fail_if(c == EOF);
		buffer[buflen++] = c;
	}
	return buffer[i];
}

static void skip_spaces(void)
{
	for (;;) {
		char c = peek(0);
		if (c == ' ' || c == '\n')
			advance(1);
		else
			break;
	}
}

bool TST(const char *s)
{
	skip_spaces();
	for (size_t i = 0; ; ++i) {
		char c = s[i];
		if (c == 0) {
			advance(i);
			return true;
		}
		if (c != peek(i))
			return false;
	}
}

bool ID(void)
{
	skip_spaces();
	inputlen = 0;
	size_t i = 0;
	char c = peek(i++);
	if (c >= 'A' && c <= 'Z') {
		input[inputlen++] = c;
		for (;;) {
			c = peek(i++);
			if ((c >= '0' && c <= '9') || (c >= 'A' && c <= 'Z')) {
				fail_if(inputlen >= sizeof input);
				input[inputlen++] = c;
			} else {
				advance(inputlen);
				return true;
			}
		}
	} else
		return false;
}

bool SR(void)
{
	skip_spaces();
	inputlen = 0;
	size_t i = 0;
	char c = peek(i++);
	if (c != '\'')
		return false;
	input[inputlen++] = c;
	for (;;) {
		c = peek(i++);
		fail_if(inputlen >= sizeof input);
		input[inputlen++] = c;
		if (c == '\'') {
			advance(i);
			return true;
		}
	}
}

static void xwrite(const void *buf, size_t n)
{
	fail_if(fwrite(buf, 1, n, stdout) != n);
}

static int start_col = 8;
static int current_col = 1;

static void indent(void)
{
	int n = start_col - current_col;
	if (n > 0) {
		char s[n];
		memset(s, ' ', n);
		xwrite(s, n);
		current_col += n;
	}
}

void CL(const char *s)
{
	indent();
	fputs(s, stdout);
}

void CI(void)
{
	indent();
	xwrite(input, inputlen);
}

void ERROR()
{
	exit(1);
}

void LB(void)
{
	start_col = 1;
}

void OUT(void)
{
	putchar('\n');
	current_col = 1;
	start_col = 8;
}

static char labelbuf[16384];
static size_t labelpos = 0;

static void todec(unsigned int i)
{
	if (i >= 10)
		todec(i / 10);
	fail_if(labelpos >= sizeof labelbuf);
	labelbuf[labelpos++] = '0' + (i % 10);
}

void GN(char **p)
{
	static unsigned int label_index = 0;
	char *s = *p;
	if (s == NULL) {
		s = &labelbuf[labelpos];
		fail_if(labelpos >= sizeof labelbuf);
		labelbuf[labelpos++] = 'L';
		todec(label_index++);
		fail_if(labelpos >= sizeof labelbuf);
		labelbuf[labelpos++] = 0;
		*p = s;
	}
	indent();
	fputs(s, stdout);
}

bool PROGRAM();

int main(int argc, char *argv[])
{
	if (argc > 1)
		fail_if(freopen(argv[1], "r", stdin) == NULL);
	PROGRAM();
	return 0;
}
