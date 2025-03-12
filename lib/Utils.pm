package Utils;
use strict;
use warnings;
use IO::Handle;
use POSIX qw(localtime);
use Carp;
use Exporter 'import';

our @EXPORT_OK = qw(log_message detect_os);

sub log_message {
    my ($msg) = @_;
    my $time = localtime(time);
    print "[$time] $msg\n";
}

# Detect OS
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

1;
