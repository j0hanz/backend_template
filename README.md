This repository provides a simple Gitpod workspace template pre-configured for **Django development** with Python and Node.js, along with PostgreSQL and MongoDB support. It includes linters like Ruff and Djlint for maintaining code quality.

---

## Features

- **Django Ready**: Quickly start building Django applications.
- **Python Environment**: Python 3.12.2 managed via Pyenv.
- **Node.js Environment**: Node.js 20.11.1 managed via NVM.
- **Databases**:
  - PostgreSQL 16
  - MongoDB Shell (`mongosh`)
- **Linters and Formatters**:
  - **Ruff**: Fast Python linter. [Documentation](https://docs.astral.sh/ruff/configuration/)
  - **Djlint**: Linter and formatter for Django templates. [Documentation](https://www.djlint.com/docs/configuration/)
- **VS Code Extensions**: Pre-installed extensions for enhanced development.

---

## Getting Started

### Open in Gitpod

Click the button below to open this repository in Gitpod:

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/j0hanz/backend_template)

### Workspace Initialization

The workspace will automatically set up your development environment, including installing dependencies and starting services.

---

## Using Ruff and Djlint in the Terminal

### Ruff

Ruff is a fast Python linter that helps you maintain code quality. For detailed configuration options, refer to the [Ruff Documentation](https://docs.astral.sh/ruff/configuration/).

#### Linting Code with Ruff

To lint your Python code:

```bash
ruff check path/to/your/code
```

Replace `path/to/your/code` with the directory or file you want to lint.

#### Auto-fixing Issues

Ruff can automatically fix certain issues:

```bash
ruff check path/to/your/code --fix
```

### Djlint

Djlint is a tool for linting and formatting Django templates. For detailed configuration, see the [Djlint Documentation](https://www.djlint.com/docs/configuration/).

#### Linting Templates

To lint your Django templates:

```bash
djlint path/to/your/templates
```

#### Formatting Templates

To format your templates:

```bash
djlint path/to/your/templates --reformat
```

---

## Starting and Stopping PostgreSQL

Start PostgreSQL:

```bash
/home/gitpod/.pg_ctl/bin/pg_start
```

Stop PostgreSQL:

```bash
/home/gitpod/.pg_ctl/bin/pg_stop
```

---

## Customization

- **Update Python or Node.js Versions**: Modify `PYTHON_VERSION` or `NODE_VERSION` in `.gitpod.dockerfile`.
- **Adjust Linting Rules**: Edit `pyproject.toml` to change settings for Ruff and Djlint.
  - **Ruff Configuration**: See the [Ruff Documentation](https://docs.astral.sh/ruff/configuration/) for available options.
  - **Djlint Configuration**: Refer to the [Djlint Documentation](https://www.djlint.com/docs/configuration/) for configuration details.
- **Add VS Code Extensions**: Update the `extensions` list in `.gitpod.yml`.

---

Happy coding!
