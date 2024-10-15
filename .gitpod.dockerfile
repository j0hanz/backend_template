FROM gitpod/workspace-base

USER root

# Set environment variables
ENV PYENV_ROOT="/home/gitpod/.pyenv" \
    NODE_VERSION="20.11.1" \
    NVM_DIR="/home/gitpod/.nvm" \
    PGDATA="/workspace/.pgsql/data" \
    PYTHONUSERBASE="/workspace/.pip-modules" \
    PIP_USER="yes"

# Update PATH
ENV PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PYTHONUSERBASE/bin:$PATH"

# Update and install common dependencies and essential development tools
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        gnupg \
        graphviz \
        libffi-dev \
        libpq-dev \
        libssl-dev \
        software-properties-common \
        wget \
        zlib1g-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER gitpod

# Python setup
RUN curl -fsSL https://pyenv.run | bash && \
    export PYENV_ROOT="$HOME/.pyenv" && \
    export PATH="$PYENV_ROOT/bin:$PATH" && \
    export PATH="$PYENV_ROOT/shims:$PATH" && \
    eval "$(pyenv init --path)" && \
    eval "$(pyenv virtualenv-init -)" && \
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
        requests \
        ruff && \
    rm -rf /tmp/*

# NodeJS setup
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
    nvm install "$NODE_VERSION" && \
    nvm use "$NODE_VERSION" && \
    npm install -g \
        eslint \
        node-gyp \
        node-ovsx-sign \
        prettier \
        typescript \
        yarn && \
    echo ". $NVM_DIR/nvm.sh" >> /home/gitpod/.bashrc.d/50-node

USER root

# MongoDB setup
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
    gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg && \
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] \
    https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/7.0 multiverse" | \
    tee /etc/apt/sources.list.d/mongodb-org-7.0.list && \
    apt-get update && apt-get install -y --no-install-recommends mongodb-mongosh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# PostgreSQL setup
RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
    gpg --dearmor -o /usr/share/keyrings/postgresql.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] \
    http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | \
    tee /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && apt-get install -y --no-install-recommends postgresql-16 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER gitpod

# PostgreSQL configuration
RUN mkdir -p ~/.pg_ctl/bin ~/.pg_ctl/sockets && \
    echo '#!/bin/bash\n[ ! -d "$PGDATA" ] && mkdir -p "$PGDATA" && initdb --auth=trust -D "$PGDATA"\npg_ctl -D "$PGDATA" -l ~/.pg_ctl/log -o "-k ~/.pg_ctl/sockets" start' \
    > ~/.pg_ctl/bin/pg_start && \
    echo '#!/bin/bash\npg_ctl -D "$PGDATA" -l ~/.pg_ctl/log -o "-k ~/.pg_ctl/sockets" stop' \
    > ~/.pg_ctl/bin/pg_stop && \
    chmod +x ~/.pg_ctl/bin/*

# Install Heroku CLI
RUN curl https://cli-assets.heroku.com/install.sh | sh

USER root

# Final cleanup
RUN apt-get autoremove -y && apt-get clean -y
