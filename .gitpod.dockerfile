FROM gitpod/workspace-base:2024-10-31-10-31-39

# Set environment variables
ENV PYENV_ROOT="/home/gitpod/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PATH:$PYENV_ROOT/shims"
ENV NODE_VERSION=20.18.0
ENV NVM_DIR="/home/gitpod/.nvm"
ENV PATH="$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH"
ENV PGDATA="/workspace/.pgsql/data"

# Update and install common dependencies
RUN sudo apt-get update && sudo apt-get upgrade -y && \
    sudo apt-get install -y curl wget gnupg software-properties-common && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# Install essential development tools and libraries
RUN sudo apt-get update && sudo apt-get install -y \
    build-essential \
    libpq-dev \
    libssl-dev \
    libffi-dev \
    zlib1g-dev \
    graphviz && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# Python setup
RUN curl -fsSL https://pyenv.run | bash && \
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc && \
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(pyenv init --path)"' >> ~/.bashrc && \
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc && \
    pyenv install 3.12.7 && \
    pyenv global 3.12.7 && \
    pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir \
    bandit \
    coverage \
    djlint \
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

ENV PYTHONUSERBASE=/workspace/.pip-modules \
    PIP_USER=yes
ENV PATH=$PYTHONUSERBASE/bin:$PATH

# NodeJS setup
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install $NODE_VERSION && \
    nvm use $NODE_VERSION && \
    npm install -g typescript yarn node-gyp eslint prettier node-ovsx-sign && \
    echo ". $NVM_DIR/nvm.sh" >> /home/gitpod/.bashrc.d/50-node

# MongoDB setup
RUN sudo curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor && \
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list && \
    sudo apt-get update && sudo apt-get install -y mongodb-mongosh && \
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# PostgreSQL configuration
RUN mkdir -p ~/.pg_ctl/bin ~/.pg_ctl/sockets && \
    echo '#!/bin/bash\n[ ! -d $PGDATA ] && mkdir -p $PGDATA && sudo initdb --auth=trust -D $PGDATA\nsudo pg_ctl -D $PGDATA -l ~/.pg_ctl/log -o "-k ~/.pg_ctl/sockets" start' > ~/.pg_ctl/bin/pg_start && \
    echo '#!/bin/bash\nsudo pg_ctl -D $PGDATA -l ~/.pg_ctl/log -o "-k ~/.pg_ctl/sockets" stop' > ~/.pg_ctl/bin/pg_stop && \
    chmod +x ~/.pg_ctl/bin/*

# Install Heroku CLI
RUN sudo curl https://cli-assets.heroku.com/install.sh | sh

# Allow React and DRF to run together on Gitpod
ENV DANGEROUSLY_DISABLE_HOST_CHECK=true
