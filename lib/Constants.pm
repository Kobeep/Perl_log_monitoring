package Constants;
use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw($POLL_INTERVAL %PATTERNS);

our $POLL_INTERVAL = 2;

our %PATTERNS = (
    usb_insert     => qr/usb\s+\d-\d:\s+new\s+/i,
    usb_remove     => qr/usb\s+\d-\d:\s+USB\s+disconnect/i,
    kernel_error   => qr/kernel:.*(error|warn|fail)/i,
    software_crash => qr/(segmentation fault|crash|core dumped|oom-killer|out of memory|fatal)/i,
);

1;
