#!/usr/bin/perl
use strict;
use warnings;
use IO::Handle;

# Detect the operating system
sub detect_os {
    open(my $os_fh, '<', '/etc/os-release') or die "Cannot open /etc/os-release: $!";
    my %os_info;

    while (<$os_fh>) {
        chomp;
        if (/^(\w+)=(.*)$/) {
            my ($key, $value) = ($1, $2);
            $value =~ s/^"//;
            $value =~ s/"$//;
            $os_info{$key} = $value;
        }
    }
    close($os_fh);
    return $os_info{ID} // 'unknown';
}

# Define log files based on the OS
my $os = detect_os();
my @log_files;

if ($os eq 'ubuntu' || $os eq 'debian') {
    @log_files = ('/var/log/syslog', '/var/log/kern.log');
    print "Detected OS: Debian/Ubuntu. Using /var/log/syslog and /var/log/kern.log.\n";
} elsif ($os eq 'rhel' || $os eq 'centos' || $os eq 'fedora') {
    @log_files = ('/var/log/messages', '/var/log/dmesg');
    print "Detected OS: Red Hat/CentOS/Fedora. Using /var/log/messages and /var/log/dmesg.\n";
} else {
    die "Unsupported or unknown operating system.\n";
}

# Patterns to detect events in the logs (USB events, kernel errors, software crashes, etc.)
my %patterns = (
    usb_insert   => qr/usb\s+\d-\d:\s+new\s+/i,
    usb_remove   => qr/usb\s+\d-\d:\s+USB\s+disconnect/i,
    kernel_error => qr/kernel:.*(error|warn|fail)/i,
    software_crash => qr/(segmentation fault|crash|core dumped|oom-killer|out of memory|fatal)/i,
);

# Function to monitor a log file
sub monitor_log {
    my ($logfile) = @_;

    open(my $log_fh, '<', $logfile) or die "Cannot open $logfile: $!";
    seek($log_fh, 0, 2);  # Move file pointer to the end to read new entries

    print "Monitoring log file: $logfile\n";

    while (1) {
        while (my $line = <$log_fh>) {
            chomp($line);

            # USB device insertion
            if ($line =~ $patterns{usb_insert}) {
                print "USB Device Inserted: $line\n";
            }

            # USB device removal
            if ($line =~ $patterns{usb_remove}) {
                print "USB Device Removed: $line\n";
            }

            # Kernel errors/warnings
            if ($line =~ $patterns{kernel_error}) {
                print "Kernel Error/Warning: $line\n";
            }

            # Software crashes (segmentation fault, core dump, OOM, etc.)
            if ($line =~ $patterns{software_crash}) {
                print "Software Crash Detected: $line\n";
                # Example action: trigger an email alert or restart a service
                # system("mail -s 'Software Crash Detected' admin@example.com < /dev/null");
            }
        }

        sleep(2);  # Poll interval to avoid high CPU usage

        # Reopen log file in case of log rotation
        if (!open($log_fh, '<', $logfile)) {
            print "Failed to reopen log file: $!\n";
            last;
        }
        seek($log_fh, 0, 2);  # Reposition at the end of the log file
    }

    close($log_fh);
}

# Main function to monitor multiple log files
sub main {
    my @log_pids;

    foreach my $logfile (@log_files) {
        my $pid = fork();

        if ($pid == 0) {
            # Child process will monitor the log file
            monitor_log($logfile);
            exit(0);  # Ensure child process exits after monitoring
        }
        push @log_pids, $pid;
    }

    # Parent process waits for all child processes to finish
    foreach my $pid (@log_pids) {
        waitpid($pid, 0);
    }
}

# Start monitoring
main();
