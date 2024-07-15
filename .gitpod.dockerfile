FROM gitpod/workspace-base

# Update and upgrade at the beginning
USER root
RUN apt-get update -y && apt-get upgrade -y \
    && apt-get install -y curl lsb-release

# NodeJS Setup
USER gitpod
ENV NODE_VERSION=16.13.0
ENV TRIGGER_REBUILD=1
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | PROFILE=/dev/null bash \
    && bash -c ". .nvm/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm use $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && npm install -g typescript yarn node-gyp" \
    && echo ". ~/.nvm/nvm.sh" >> /home/gitpod/.bashrc.d/50-node
ENV PATH=$PATH:/home/gitpod/.nvm/versions/node/v${NODE_VERSION}/bin

# Python Setup
USER root
RUN apt-get install -y python3-pip

USER gitpod
ENV PYTHON_VERSION=3.12.2
ENV PYENV_ROOT=$HOME/.pyenv
ENV PATH=$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH

# Install pyenv and Python version
RUN curl -fsSL https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash \
    && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc \
    && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc \
    && echo 'eval "$(pyenv init --path)"' >> ~/.bashrc \
    && echo 'eval "$(pyenv init -)"' >> ~/.bashrc \
    && echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc.d/60-python \
    && pyenv update \
    && pyenv install $PYTHON_VERSION \
    && pyenv global $PYTHON_VERSION

# Upgrade pip and install Python packages
RUN python3 -m pip install --no-cache-dir --upgrade pip \
    && python3 -m pip install --no-cache-dir --upgrade \
    setuptools wheel virtualenv pipenv pylint rope flake8 \
    mypy autopep8 pep8 pylama pydocstyle bandit notebook djlint \
    twine \
    && sudo rm -rf /tmp/*

# Set Python user base and update PATH
ENV PYTHONUSERBASE=/workspace/.pip-modules
ENV PIP_USER=yes
ENV PATH=$PYTHONUSERBASE/bin:$PATH

# Setup Heroku CLI
USER root
RUN curl https://cli-assets.heroku.com/install.sh | sh

# Setup PostgreSQL
RUN echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 \
    && apt-get update -y \
    && apt-get install -y postgresql-12

USER gitpod
ENV PGDATA="/workspace/.pgsql/data"
RUN mkdir -p ~/.pg_ctl/bin ~/.pg_ctl/sockets \
    && echo '#!/bin/bash\n[ ! -d $PGDATA ] && mkdir -p $PGDATA && initdb --auth=trust -D $PGDATA\npg_ctl -D $PGDATA -l ~/.pg_ctl/log -o "-k ~/.pg_ctl/sockets" start\n' > ~/.pg_ctl/bin/pg_start \
    && echo '#!/bin/bash\npg_ctl -D $PGDATA -l ~/.pg_ctl/log -o "-k ~/.pg_ctl/sockets" stop\n' > ~/.pg_ctl/bin/pg_stop \
    && chmod +x ~/.pg_ctl/bin/*

# Ensure .cache directory is writable
USER root
RUN mkdir -p /home/gitpod/.cache/Microsoft && chown -R gitpod:gitpod /home/gitpod/.cache

# PostgreSQL Environment Variables
ENV PGDATABASE="postgres"
ENV PATH="/usr/lib/postgresql/12/bin:$PATH"

# Add Aliases
RUN echo 'alias run="python3 $GITPOD_REPO_ROOT/manage.py runserver 0.0.0.0:8000"' >> ~/.bashrc \
    && echo 'alias heroku_config=". $GITPOD_REPO_ROOT/.vscode/heroku_config.sh"' >> ~/.bashrc \
    && echo 'alias python=python3' >> ~/.bashrc \
    && echo 'alias pip=pip3' >> ~/.bashrc \
    && echo 'alias arctictern="python3 $GITPOD_REPO_ROOT/.vscode/arctictern.py"' >> ~/.bashrc \
    && echo 'alias font_fix="python3 $GITPOD_REPO_ROOT/.vscode/font_fix.py"' >> ~/.bashrc \
    && echo 'alias set_pg="export PGHOSTADDR=127.0.0.1"' >> ~/.bashrc \
    && echo 'alias mongo=mongosh' >> ~/.bashrc \
    && echo 'alias make_url="python3 $GITPOD_REPO_ROOT/.vscode/make_url.py"' >> ~/.bashrc

# Local environment variables
ENV PORT="8080"
ENV IP="0.0.0.0"

# Allow React and DRF to run together on Gitpod
ENV DANGEROUSLY_DISABLE_HOST_CHECK=true

# Final update, upgrade, and cleanup
USER root
RUN apt-get update -y && apt-get upgrade -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/*