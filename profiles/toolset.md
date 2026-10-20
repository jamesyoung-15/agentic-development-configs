# Toolset

What is installed on my machines. Use these instead of the older equivalents.

| Instead of | Use | Notes |
|---|---|---|
| `pip`, `venv`, `poetry` | `uv` | `uv run`, `uv add`, `uv sync` |
| `black`, `flake8`, `isort` | `ruff` | `ruff check --fix`, `ruff format` |
| `grep -r` | `rg` | respects gitignore |
| `find` | `fd` | |
| GitHub web UI | `gh` | |
| GitLab web UI | `glab` | |

## Conventions

- Shell is bash on Linux.
- Do not install anything globally without asking.
- If a tool in this table is missing on the machine, say so rather than silently falling back.
