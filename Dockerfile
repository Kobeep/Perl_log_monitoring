FROM ubuntu:22.04

RUN apt install -y perl git libperl-dev

COPY log_monitor.pl /tmp/log_monitor.pl

RUN chmod +x /usr/local/bin/log_monitor.pl

CMD ["perl", "/usr/local/bin/log_monitor.pl"]
