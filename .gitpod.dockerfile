FROM gitpod/workspace-base:latest

# Environment variables
ENV PYENV_ROOT="/home/gitpod/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PATH:$PYENV_ROOT/shims"
ENV NODE_VERSION=20.18.0
ENV NVM_DIR="/home/gitpod/.nvm"
ENV PATH="$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH"
ENV PGDATA="/workspace/.pgsql/data"

# Update and install common dependencies
RUN sudo apt-get update && sudo apt-get upgrade -y && \
    sudo apt-get install -y \
    curl wget gnupg software-properties-common \
    build-essential libpq-dev libssl-dev libffi-dev zlib1g-dev graphviz && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# Node.js setup
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install $NODE_VERSION && \
    nvm use $NODE_VERSION && \
    npm install -g typescript yarn node-gyp eslint prettier node-ovsx-sign && \
    echo ". $NVM_DIR/nvm.sh" >> /home/gitpod/.bashrc.d/50-node

# Python setup
ENV PYTHON_VERSION=3.12.7
RUN sudo install-packages python3-pip && \
    curl -fsSL https://pyenv.run | bash && \
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc && \
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(pyenv init --path)"' >> ~/.bashrc && \
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc && \
    pyenv install $PYTHON_VERSION && \
    pyenv global $PYTHON_VERSION && \
    python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel && \
    python3 -m pip install --no-cache-dir --upgrade \
        bandit \
        coverage \
        djlint \
        django-debug-toolbar \
        ipython \
        isort \
        mypy \
        pip-review \
        pylint \
        pyparsing \
        pydot \
        pytest \
        pytest-django \
        pytest-cov \
        requests \
        watchdog \
        ruff && \
    sudo rm -rf /tmp/*

# Python user base setup
ENV PYTHONUSERBASE=/workspace/.pip-modules
ENV PIP_USER=yes
ENV PATH=$PYTHONUSERBASE/bin:$PATH

# MongoDB setup
RUN sudo curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
    sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor && \
    echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
    sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list && \
    sudo apt-get update && sudo apt-get install -y mongodb-mongosh && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# PostgreSQL configuration
RUN mkdir -p ~/.pg_ctl/bin ~/.pg_ctl/sockets && \
    echo '#!/bin/bash\n[ ! -d $PGDATA ] && mkdir -p $PGDATA && sudo initdb --auth=trust -D $PGDATA\nsudo pg_ctl -D $PGDATA -l ~/.pg_ctl/log -o "-k ~/.pg_ctl/sockets" start' > ~/.pg_ctl/bin/pg_start && \
    echo '#!/bin/bash\nsudo pg_ctl -D $PGDATA -l ~/.pg_ctl/log -o "-k ~/.pg_ctl/sockets" stop' > ~/.pg_ctl/bin/pg_stop && \
    chmod +x ~/.pg_ctl/bin/*

# Install Heroku CLI
RUN sudo curl https://cli-assets.heroku.com/install.sh | sh

# Allow React and Django REST Framework to run together on Gitpod
ENV DANGEROUSLY_DISABLE_HOST_CHECK=true

# Copy VS Code extensions
COPY .vscode/extensions/ /home/gitpod/.vscode/extensions/

# Change ownership to the gitpod user and set permissions
RUN sudo chown -R gitpod:gitpod /home/gitpod/.vscode/extensions/ && \
    chmod 644 /home/gitpod/.vscode/extensions/*.vsix

# Ensure pyenv is initialized in all shell sessions
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile && \
    echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile && \
    echo 'eval "$(pyenv init -)"' >> ~/.bash_profile && \
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.profile && \
    echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.profile && \
    echo 'eval "$(pyenv init -)"' >> ~/.profile && \
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc && \
    echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc