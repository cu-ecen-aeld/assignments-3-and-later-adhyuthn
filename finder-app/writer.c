#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <sys/syslog.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <syslog.h>

int main(int argc, char *argv[])
{
	openlog("Writer - CU", LOG_PID | LOG_CONS , LOG_USER);

	if (argc < 3) { 
		syslog(LOG_ERR, "Enough Arguments not provided");
		return 1;
	}
	const char* writefile = argv[1];
	const char* writestr = argv[2];
	int fd = open(writefile, O_WRONLY | O_CREAT | O_TRUNC, S_IWUSR | S_IRUSR | S_IWGRP | S_IRGRP | S_IROTH);
	ssize_t writer = write(fd, writestr, strlen(writestr));
	syslog(LOG_DEBUG, "Writing %s to %s", writefile, writestr);
	if (writer == -1) {
		syslog(LOG_ERR, "Writing failed");
	}
	close(fd);
	closelog();
	return 0;
}
