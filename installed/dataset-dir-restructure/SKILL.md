---
name: dataset-dir-restructure
description: Use when reorganizing a data project's directory structure to match a standard layout — moving hardcoded output paths, fixing script references, and syncing README. Triggered by requests like "重组目录", "迁移数据路径", "目录结构对齐", or scripts referencing wrong paths.
---

## Workflow (must follow order)

**Step 1: define target structure**  
Use `paths_template.yaml` or `README.md` as authority. List "actual → target" mapping before touching anything.

**Step 2: move directories (mv, not cp)**
```bash
mv data/old-name data/processed/new-name
mkdir -p data/dataset/splits && mv data/splits/split.json data/dataset/splits/
```
Use `mv` to preserve inodes. No data duplication.

**Step 3: create missing placeholder dirs**
```bash
mkdir -p data/dataset/train data/dataset/val data/dataset/test
touch data/dataset/train/.gitkeep
```

**Step 4: find and fix hardcoded paths in scripts**
```bash
grep -rn "old_path_keyword" src/ --include="*.py"
```
Fix with Edit tool one by one — do NOT use sed (risks corrupting comments or string concatenation).

**Step 5: update README and config templates**
- Directory tree, file names, script list

## Pitfalls

| Issue | Cause | Fix |
|-------|-------|-----|
| Edit fails to match README tree | Full-width chars `│` must match exactly | Read the line first, copy verbatim into old_string |
| Some scripts already use new path | Mixed state during development | grep then verify each hit, don't bulk replace |
| git doesn't see moved data dirs | data/ in .gitignore | Only commit script/doc changes; move data on server directly |
