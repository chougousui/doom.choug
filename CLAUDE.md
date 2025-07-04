# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Doom Emacs configuration repository. Doom Emacs is a highly configurable Emacs framework that provides a modern, efficient editing environment with extensive customization options.

## Key Commands

### Doom Emacs Management
- `doom sync` - Synchronize packages after modifying `init.el` or `packages.el`
- `doom upgrade` - Update Doom Emacs and packages
- `doom doctor` - Diagnose configuration issues
- `doom purge` - Clean up orphaned packages
- `doom reload` - Reload Doom configuration (or use `M-x doom/reload`)

### Development Workflow
- No specific build/test commands - this is an Emacs configuration
- Configuration changes are applied via `doom sync` followed by Emacs restart
- Use `M-x doom/reload` for live configuration reloading when possible

## Architecture

### Core Configuration Files
- `init.el` - Main module configuration defining which Doom modules are enabled
- `config.el` - Personal configuration and customizations  
- `packages.el` - Package declarations and customizations

### Module System
The configuration uses Doom's modular architecture with two custom module categories:

#### `:custom` modules (in `modules/custom/`)
Core functionality extensions:
- `choug` - Personal defaults and key bindings, includes swiper integration
- `corfu-ext` - Completion UI extensions  
- `vertico-ext` - Search/selection UI extensions
- `lsp-ext` - LSP enhancements
- `modeline-ext` - Status line customizations
- Language-specific extensions: `go-ext`, `python-ext`, `php-ext`, `lua-ext`, `lisp-ext`
- UI extensions: `doom-dashboard-ext`, `syntax-ext`
- Utility modules: `fnm`, `fcitx`, `iedit`, `plantuml-ext`, `revert-whitespace`

#### `:custom-ai` modules (in `modules/custom-ai/`)
AI integration modules:
- `claude-code` - Claude Code integration with `C-c c` prefix bindings
- `codeium` - AI code completion
- `gptel` - ChatGPT integration (currently commented out)

### Language Support
Configured with LSP and tree-sitter for:
- Go (`+lsp +tree-sitter`)
- Python (`+lsp +pyright +tree-sitter`) 
- JavaScript (`+lsp +tree-sitter`)
- Rust (`+lsp +tree-sitter`)
- Java (`+lsp +tree-sitter`)
- PHP (`+lsp +tree-sitter`)
- Lua (`+lsp +tree-sitter`)
- JSON, YAML, Web (`+lsp +tree-sitter`)
- Zig (`+lsp +tree-sitter`)
- Dart/Flutter (`+flutter +lsp`)

## Module Structure

Each custom module follows Doom's convention:
- `config.el` - Module configuration code
- `packages.el` - Package declarations (if needed)
- `README.org` - Module documentation
- Additional files as needed (e.g., `funcs.el`, `segments.el`)

## Key Customizations

### Theme and UI
- Uses `spacemacs-dark` theme
- Disabled `ws-butler` package due to conflicts with formatters
- Corfu completion with orderless matching
- Vertico for minibuffer completion
- Custom dashboard and modeline extensions

### Claude Code Integration
- Bound to `C-c c` prefix for all Claude Code commands
- Key bindings:
  - `C-c c c` - Start claude code
  - `C-c c t` - Toggle claude buffer

### Development Features  
- LSP enabled for most languages
- Tree-sitter for enhanced syntax highlighting
- Format on save enabled
- Syntax checking enabled
- Git integration via vc-gutter

## Making Changes

1. Modify relevant configuration files (`init.el`, `config.el`, `packages.el`, or module files)
2. Run `doom sync` to synchronize changes
3. Restart Emacs or use `M-x doom/reload` for some changes
4. Use `doom doctor` to diagnose any issues

When adding new packages, declare them in `packages.el` or the relevant module's `packages.el` file, then run `doom sync`.
