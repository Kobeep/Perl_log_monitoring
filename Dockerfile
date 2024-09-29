FROM fedora:latest

RUN dnf install -y perl git

COPY log_monitor.pl /tmp/log_monitor.pl

RUN chmod +x /usr/local/bin/log_monitor.pl

CMD ["perl", "/usr/local/bin/log_monitor.pl"]
