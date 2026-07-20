# Repository Guidelines

## Project Structure & Module Organization

This repository is a personal Doom Emacs configuration. Root files define the global setup: `init.el` enables Doom modules, `config.el` contains global settings, and `packages.el` declares global packages. Feature-specific configuration belongs under `modules/custom/<module>/`; AI integrations live under `modules/custom-ai/<module>/`. A module commonly contains `.doommodule`, `config.el`, optional `packages.el`, helper `.el` files, and `README.org`. There is no separate test or asset directory.

## Build, Test, and Development Commands

- `doom sync`: synchronize Doom after changing `init.el`, any `packages.el`, or module declarations.
- `doom doctor`: diagnose missing dependencies and invalid Doom configuration.
- `M-x doom/reload`: reload configuration from a running Emacs session; restart Emacs when package or module changes require it.

This configuration has no standalone build system. Run commands from this repository unless the Doom CLI requires otherwise.

## Coding Style & Naming Conventions

Write Emacs Lisp and preserve the lexical-binding header used by existing files. Follow the surrounding two-space indentation and standard Lisp formatting. Prefer Doom helpers such as `after!`, `use-package!`, `load!`, `package!`, and `map!` over duplicating load-order logic. Keep related behavior inside its owning module rather than expanding root `config.el`. Use lowercase kebab-case for modules and files, for example `javascript-ext/formatter-detect.el`; extension modules generally use the `-ext` suffix. Add packages only in the relevant `packages.el`.

## Testing Guidelines

No automated test framework or coverage threshold is configured. Validate every change with `doom sync` and `doom doctor`, then reload or restart Emacs and manually exercise the affected mode, hook, key binding, formatter, or LSP integration. Module dependency checks belong in `doctor.el` when applicable.

## Commit & Pull Request Guidelines

Git history primarily uses Conventional Commit prefixes: `feat:`, `fix:`, `chore:`, `docs:`, and `refactor:`. Optional scopes are used when useful, as in `feat(go): add gci formatter integration`. Keep the subject concise and limited to one logical change. Pull requests should state the purpose, list affected modules, and report the validation commands run. Link relevant issues and include screenshots only for visible UI changes such as dashboard, modeline, or completion behavior.

## Security & Local Configuration

Do not commit credentials, API keys, machine-specific paths, or generated `custom.el`; the latter is intentionally ignored.
