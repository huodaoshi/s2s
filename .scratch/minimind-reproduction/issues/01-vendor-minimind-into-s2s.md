Status: ready-for-human

# 将 MiniMind 以 vendored 形式纳入 s2s 主仓

## 要构建什么

完成 **G1**：`src/minimind/` 作为 **vendored upstream** 由 s2s 主仓跟踪，无嵌套 `.git`。仓库级忽略与目录脚手架支持后续 **MiniMind environment**（`env/.venv-minimind`）。

端到端结果：克隆本仓后，`src/minimind/` 为普通目录；`git status` 不再出现「嵌套仓库」歧义；`.gitignore` 忽略 `env/.venv-minimind/`（及既有 `.codegraph/` 等不冲突）。

## 验收标准

- [ ] 已删除 `src/minimind/.git`（及仅服务于嵌套 clone 的残留，若有）
- [ ] 根目录 `.gitignore` 包含 `env/.venv-minimind/`
- [ ] `src/minimind/SPIKE.md` 中 vendored commit 与纳入后树一致（若文件有变则更新 commit 行）
- [ ] `python -m compileall -q src/minimind` 通过（语法级）
- [ ] `docs/adr/0002` 与 `DECISIONS.md` 中 G1 落地项可勾选（实现侧自证）

## 阻塞于

无——可立即开始

## Comments

2026-06-01：已实现 — 删除 `src/minimind/.git`；`.gitignore` 增加 `env/.venv-minimind/`；`bootstrap.ps1` 脚手架含 `src/minimind`。
