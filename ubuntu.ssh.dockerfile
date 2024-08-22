FROM ubuntu:22.04

# set shell to bash and error on any failure, unset variables, and pipefail
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

# hadolint ignore=DL3013,DL3008
RUN apt-get update && apt-get install --no-install-recommends openssh-server sudo python3 pip -y && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --no-cache-dir supervisor
COPY ./packages/infrastructure/docker/ubuntu.ssh.supervisor.conf /etc/supervisor.conf
# Set the root password
# hadolint ignore=DL3001
RUN echo "root:root" | chpasswd && \
    # Enable password authentication over SSH for root
    sed 's/\(#\{0,1\}PermitRootLogin .*\)/PermitRootLogin yes/' /etc/ssh/sshd_config > /tmp/sshd_config && mv /tmp/sshd_config /etc/ssh/sshd_config && \
    sed 's/\(#\{0,1\}PasswordAuthentication .*\)/PasswordAuthentication yes/' /etc/ssh/sshd_config > /tmp/sshd_config && mv /tmp/sshd_config /etc/ ssh/sshd_config && \
    # Start the SSH service to create the necessary run symlinks
    service ssh start
# Expose docker port 22
EXPOSE 22

CMD ["supervisord", "-c", "/etc/supervisor.conf"]
