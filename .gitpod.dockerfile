FROM gitpod/workspace-base

USER root

# Set environment variables
ENV PYENV_ROOT="/home/gitpod/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PATH:$PYENV_ROOT/shims"
ENV NODE_VERSION=20.18.0
ENV NVM_DIR="/home/gitpod/.nvm"
ENV PATH="$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH"
ENV PGDATA="/workspace/.pgsql/data"

# Update and install common dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y curl wget gnupg software-properties-common && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install essential development tools and libraries
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    libssl-dev \
    libffi-dev \
    zlib1g-dev \
    graphviz && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER gitpod

# Python setup
RUN curl -fsSL https://pyenv.run | bash && \
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc && \
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(pyenv init --path)"' >> ~/.bashrc && \
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc && \
    pyenv install 3.12.7 && \
    pyenv install 3.13.0 && \
    pyenv global 3.13.0 && \
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

USER root

# MongoDB setup
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor && \
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list && \
    apt-get update && apt-get install -y mongodb-mongosh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# PostgreSQL setup
RUN echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list && \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && apt-get install -y postgresql-16 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER gitpod

# PostgreSQL configuration
RUN mkdir -p ~/.pg_ctl/bin ~/.pg_ctl/sockets && \
    echo '#!/bin/bash\n[ ! -d $PGDATA ] && mkdir -p $PGDATA && initdb --auth=trust -D $PGDATA\npg_ctl -D $PGDATA -l ~/.pg_ctl/log -o "-k ~/.pg_ctl/sockets" start' > ~/.pg_ctl/bin/pg_start && \
    echo '#!/bin/bash\npg_ctl -D $PGDATA -l ~/.pg_ctl/log -o "-k ~/.pg_ctl/sockets" stop' > ~/.pg_ctl/bin/pg_stop && \
    chmod +x ~/.pg_ctl/bin/*

# Install Heroku CLI
RUN curl https://cli-assets.heroku.com/install.sh | sh

USER root

# Final cleanup
RUN apt-get autoremove -y && apt-get clean -y
