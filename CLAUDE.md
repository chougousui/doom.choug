# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概述

Doom Emacs 个人配置仓库（克隆到 `~/.config/doom`），使用 Emacs 默认键绑定风格，未启用 Evil。
Leader 键改为 `M-m`。仓库无构建系统、无测试框架。

## 常用命令

- `doom sync` - 修改 `init.el` 或任意 `packages.el` 后必须运行；仅改 `config.el` 不需要
- `doom doctor` - 诊断缺失的外部依赖和无效配置
- `M-x doom/reload` - 从运行中的 Emacs 重载；包或模块变更仍需重启

验证变更的方式：`doom sync` → `doom doctor` → 重载或重启 → 手动触发受影响的 mode/hook/键绑定/格式化器/LSP。

## 架构

### 模块系统

配置全部拆进 `modules/custom/<name>/` 与 `modules/custom-ai/<name>/`，由 `init.el` 末尾的
`:custom` / `:custom-ai` 两个分类列表启用。**禁用模块的做法是在 `init.el` 中注释掉该行，目录保留**，
所以磁盘上存在的模块目录不等于已启用的模块 —— 判断是否生效必须查 `init.el`。

当前已存在但被禁用的模块：`company-ext`、`kotlin-ext`、`diff`、`codeium`、`gptel`。

模块目录内约定：

- `config.el` - 主体配置，唯一必需文件
- `packages.el` - 该模块的包声明；包只写在使用它的模块里，不集中到根 `packages.el`
- `doctor.el` - 依赖检查，用 `(unless (modulep! :lang go) (warn! "..."))` 声明前置模块（见 `modules/custom/go-ext/doctor.el`）
- `.doommodule` - 内容为空，且并非必需（`dart-ext`、`lua-ext`、`zig-ext`、`diff` 都没有）
- `README.org` - 可选，`#+title: :custom <name>` + `* Description`
- 模块内代码拆分用 `load!`（不带扩展名），如 `choug/config.el` 里的 `(load! "funcs")`

命名：语言/UI 扩展模块统一 `-ext` 后缀；文件用 kebab-case。

### 跨模块的关键约定

**条件守卫**：依赖 Doom 模块的配置必须用 `modulep!` 包裹，因为模块可能在 `init.el` 中被关掉。
例如 `syntax-ext` 同时写了 `(modulep! :checkers syntax -flymake)` 和 `+flymake` 两套键绑定，
`calendar-ext` 整个包在 `(when (modulep! :app calendar) ...)` 里。

**格式化统一走 apheleia**，注册模式固定为三步，且必须在 `after! apheleia` 内：

```elisp
(after! apheleia
  (add-to-list 'apheleia-formatters '(golines . ("golines" "-m" "120" "--base-formatter=gofumpt")))
  (setf (alist-get 'go-ts-mode apheleia-mode-alist) 'golines))
```

原因是 `apheleia-formatters` 和 `apheleia-mode-alist` 都不是 autoload 变量，包加载前不存在。
`go-ext/config.el` 顶部有一段详细注释解释了为什么交互式命令要定义在 `after!` **外面**，改这一块前先读它。

**LSP 处于 lsp-mode → eglot 的迁移中**（见 commit `9149d25`、`8dd6666`）。`init.el` 现为 `(lsp +eglot +booster)`，
但 `lsp-ext/config.el` 里 `after! lsp-mode` 那段旧配置仍保留、当前不生效；eglot 部分在
`(when (modulep! :tools lsp +eglot) ...)` 中用 `set-eglot-client!` 注册。
`javascript-ext` 的 `lsp-biome`、`lsp-oxlint.el`（`lsp-register-client`）同样只在 lsp-mode 下生效。
新增语言服务器时先确认目标是哪一侧，不要混改。

**函数命名前缀不统一**，跟随所在模块即可：`choug/`、`+calendar-ext--`、`my/`（`javascript-ext`）、
`lsp-oxlint--`、`custom-modeline-ext/`、`lisp-ext/`。

### 全局文件的边界

`config.el` 只放主题、`display-line-numbers-type`、`org-directory` 这类 Doom 模板自带项；
`packages.el` 只放 spacemacs-theme 和 `ws-butler :disable t`。**新配置应落到对应模块，不要扩张根文件。**

`custom.el` 由 Emacs 生成，已 gitignore，且 `.claude/settings.json` 中显式 deny 读取。

## 配置归属速查

只列出归属不明显的：

| 关注点 | 位置 |
|--------|------|
| 字体、Leader 键、全局键绑定、projectile、auto-revert、trailing-whitespace、fill-column | `choug` |
| 自定义交互命令（搜索、删词、对齐注释、合并行） | `choug/funcs.el` |
| eglot 客户端注册、breadcrumb、lsp-mode 遗留设置 | `lsp-ext` |
| JS/TS 格式化器按项目配置文件动态选择（oxfmt > biome > prettier） | `javascript-ext/formatter-detect.el` |
| oxlint LSP 客户端 | `javascript-ext/lsp-oxlint.el` |
| 撤销 Doom 上游对 whitespace 的定制 | `revert-whitespace` |
| doom-modeline 显示项排布 | `modeline-ext` |
| 农历与中日节假日 ICS 数据源 | `calendar-ext/lunar.el`、`calendar-ext/sources.el` |
| Node.js PATH 注入（仅 GUI） | `fnm` |
| jsonc-mode 的文件名映射 | `json-ext` |

各语言模块（`go-ext`/`python-ext`/`php-ext`/`lua-ext`/`dart-ext`/`zig-ext`）基本只做两件事：
注册 apheleia 格式化器、修正 tree-sitter 缩进或语法源。

## 提交规范

Conventional Commits 前缀（`feat:`/`fix:`/`chore:`/`docs:`/`refactor:`），描述用中文，可选 scope
（如 `feat(go):`）。一次提交一个逻辑变更。
