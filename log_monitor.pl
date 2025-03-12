#!/usr/bin/perl
use strict;
use warnings;
use IO::Handle;
use File::Tail;
use POSIX qw(setsid);
use Carp;

use lib 'lib';
use Utils qw(log_message detect_os);
use Constants qw($POLL_INTERVAL %PATTERNS);

if ($> != 0) {
    exec("sudo", $0, @ARGV) or die "Failed to execute with sudo: $!";
}
STDOUT->autoflush(1);

$SIG{INT}  = sub { log_message("Received SIGINT, exiting..."); exit 0; };
$SIG{TERM} = sub { log_message("Received SIGTERM, exiting..."); exit 0; };

my $os = detect_os();
my @log_files;
if ($os =~ /^(ubuntu|debian)$/i) {
    @log_files = ('/var/log/syslog', '/var/log/kern.log');
    log_message("Detected OS: Debian/Ubuntu. Using /var/log/syslog and /var/log/kern.log.");
} elsif ($os =~ /fedora/i || $os =~ /rhel/i || $os =~ /centos/i) {
    @log_files = ('/var/log/messages');
    if (-e '/var/log/dmesg') {
         push @log_files, '/var/log/dmesg';
         log_message("Detected OS: Red Hat/CentOS/Fedora. Using /var/log/messages and /var/log/dmesg.");
    } else {
         log_message("Detected OS: Red Hat/CentOS/Fedora. /var/log/dmesg not found. Using only /var/log/messages.");
    }
} elsif ($os =~ /asahi/i) {
    @log_files = ('/var/log/syslog', '/var/log/kern.log');
    log_message("Detected OS: Asahi Linux. Using /var/log/syslog and /var/log/kern.log.");
} else {
    die "Unsupported or unknown operating system: $os.\n";
}

sub monitor_log {
    my ($logfile) = @_;
    log_message("Monitoring log file: $logfile");

    my $file = File::Tail->new(
        name        => $logfile,
        interval    => $POLL_INTERVAL,
        maxinterval => $POLL_INTERVAL * 2,
        adjustafter => 7,
    );

    while (defined(my $line = $file->read)) {
         chomp($line);
         if ($line =~ $PATTERNS{usb_insert}) {
             log_message("USB Device Inserted: $line");
         }
         if ($line =~ $PATTERNS{usb_remove}) {
             log_message("USB Device Removed: $line");
         }
         if ($line =~ $PATTERNS{kernel_error}) {
             log_message("Kernel Error/Warning: $line");
         }
         if ($line =~ $PATTERNS{software_crash}) {
             log_message("Software Crash Detected: $line");
         }
    }
}

sub main {
    my @children;
    foreach my $logfile (@log_files) {
        my $pid = fork();
        if (!defined $pid) {
            carp "Failed to fork for $logfile: $!";
            next;
        }
        if ($pid == 0) {
            monitor_log($logfile);
            exit(0);
        }
        push @children, $pid;
    }
    foreach my $child (@children) {
        waitpid($child, 0);
    }
}

# Start monitoring
main();
