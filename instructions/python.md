<!-- load: eager | when: Writing or editing Python -->

# Python Standards

## Tooling

- `uv` for packages, virtualenvs, and project config. No `pip install` into a global env, no `requirements.txt` unless the project already has one.
- `ruff` for lint and format. Run `uv run ruff check --fix` and `uv run ruff format` before declaring work done.
- `uv run pytest` for tests.
- Type hints on public functions. `mypy` or `ty` only if the project already configures it.

## Code

- Prefer the standard library. Add a dependency when it saves real work, not to avoid 10 lines.
- Short docstrings on public functions, classes, and modules. One line is usually enough.
- Comments explain why, not what. Stale or inaccurate comments are worse than no comment, so delete a comment rather than let it drift from the code.
- Raise specific exceptions. Do not catch bare `Exception` unless you re-raise or log with context.
- No `print` for diagnostics in library code, use `logging`.

## Layout

- `src/<package>/` layout for anything installable.
- `tests/` mirrors the package structure.
- Config in `pyproject.toml`. Do not add `setup.py`, `setup.cfg`, or `.flake8`.
