FROM jenkins/jenkins:lts-jdk21

USER root

# Install Docker CLI, Python and required utilities
RUN apt-get update && \
    apt-get install -y docker.io curl python3 python3-pip python3-venv && \
    rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/v1.34.0/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Install kind
RUN curl -Lo /usr/local/bin/kind \
    "https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-amd64" && \
    chmod +x /usr/local/bin/kind

# Copy Jenkins plugin list
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

# Plugin installation disabled here because plugins are installed at runtime
# RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Run Jenkins as non-root user
USER jenkins