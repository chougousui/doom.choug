# CLAUDE.md

为 Claude Code 提供的项目指南。

## 概述

Doom Emacs 个人配置仓库，使用 Emacs 默认键绑定风格（非 Evil 模式）。

## 常用命令

- `doom sync` - 修改 `init.el` 或 `packages.el` 后同步包
- `doom doctor` - 诊断配置问题
- `M-x doom/reload` - 实时重载配置

## 项目结构

```
.
├── init.el          # 模块启用配置
├── config.el        # 全局个人配置（主题等）
├── packages.el      # 全局包声明
└── modules/
    ├── custom/      # 功能扩展模块
    └── custom-ai/   # AI 集成模块
```

## 配置归属

### 全局配置 (`config.el`, `packages.el`)

| 配置项 | 文件 |
|--------|------|
| spacemacs-theme 主题 | `packages.el`, `config.el` |
| 禁用 ws-butler | `packages.el` |
| 行号显示、org-directory | `config.el` |

### `:custom` 模块

| 模块 | 管理的配置 |
|------|-----------|
| `choug` | 字体(JetBrains Mono + 楷体)、Leader 键(M-m)、projectile、auto-revert、trailing-whitespace |
| `corfu-ext` | Corfu 补全 UI |
| `vertico-ext` | Vertico 搜索 UI |
| `lsp-ext` | LSP 通用配置：headerline 面包屑、文件监控阈值 |
| `fnm` | Node.js 版本管理 |
| `go-ext` | Go：golines 格式化器(gofumpt, 120字符)、go-ts-mode 缩进 |
| `javascript-ext` | JS/TS：lsp-biome、lsp-oxlint、apheleia、缩进设置 |
| `python-ext` | Python：ruff 格式化、pyvenv 自动激活 .venv |
| `php-ext` | PHP 语言配置 |
| `lua-ext` | Lua 语言配置 |
| `zig-ext` | Zig 语言配置 |
| `dart-ext` | Dart/Flutter 配置 |
| `json-ext` | JSON 配置 |
| `lisp-ext` | Emacs Lisp 配置 |
| `doom-dashboard-ext` | 启动仪表板 |
| `modeline-ext` | 模式行定制 |
| `syntax-ext` | 语法高亮 |
| `plantuml-ext` | PlantUML 配置 |
| `iedit` | 多光标编辑 |
| `fcitx` | 输入法切换 |
| `revert-whitespace` | 空白字符处理 |

### `:custom-ai` 模块

| 模块 | 状态 | 管理的配置 |
|------|------|-----------|
| `claude-code` | 启用 | claude-code 包集成 |
| `codeium` | 禁用 | AI 代码补全 |
| `gptel` | 禁用 | ChatGPT 集成 |

### 语言模块 (`init.el` 中启用)

启用 LSP + Tree-sitter：Go、Python(+uv)、JavaScript、Rust、Java、PHP、Lua、JSON、YAML、Web、Zig、Dart(+flutter)

已禁用：Kotlin

## 模块文件结构

```
modules/custom/example/
├── .doommodule      # 模块标识
├── config.el        # 模块配置
├── packages.el      # 包声明（可选）
└── README.org       # 文档（可选）
```

## 修改配置

1. 确定配置归属的模块
2. 修改对应模块的 `config.el` 或 `packages.el`
3. 运行 `doom sync`
4. 重启 Emacs
