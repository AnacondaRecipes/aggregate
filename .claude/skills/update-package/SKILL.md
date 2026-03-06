---
name: update-package
description: "Update any conda feedstock package to a new version. Handles pure Python, C/C++, CUDA, and multi-output packages. Auto-detects package type and follows appropriate playbook. For ecosystem-wide updates (LLVM, llama-index), use specialized agents instead. Examples: '/update-package catboost 1.2.9', '/update-package whisper.cpp b8100', '/update-package striprtf 0.0.29'."
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(git:*)
  - Bash(curl:*)
  - Bash(shasum:*)
  - Bash(sha256sum:*)
  - Bash(patch:*)
  - Bash(diff:*)
  - Bash(ls:*)
  - Bash(cat:*)
  - Bash(head:*)
  - Bash(tail:*)
  - Bash(mkdir:*)
  - Bash(cd:*)
  - Bash(conda:*)
  - Bash(pip:*)
  - Bash(python3:*)
  - Bash(gh:*)
  - Bash(tar:*)
  - Bash(wget:*)
  - WebFetch
  - WebSearch
---

# Package Update Skill

## Arguments

`$ARGUMENTS` — Expected format: `<package-name> [version]`

If version is omitted, checks for the latest upstream release.

Examples:
- `/update-package catboost 1.2.9`
- `/update-package whisper.cpp` (auto-detect latest)
- `/update-package numpy 2.3.3`

## Shared Knowledge

**CRITICAL:** Before starting, read the shared knowledge files:
1. `/Users/xkong/Repos/aggregate/.claude/knowledge/COOKBOOK.md` — common patterns and rules
2. `~/.claude/projects/-Users-xkong-Repos-aggregate/memory/package-patterns.md` — per-package quirks

## Specialized Skills Redirect

Check if the package has a dedicated skill — these have deep domain knowledge:

| Package | Redirect To |
|---------|------------|
| llama.cpp | `/update-llama-cpp` |
| llama-index (any sub-package) | `/update-llama-index` |
| LLVM packages (llvmdev, clangdev, etc.) | `llvm-update` agent |

If matched, inform the user and suggest using the specialized skill instead.

---

## Phase 0: Classify Package Type

Read the existing recipe:
```
/Users/xkong/Repos/aggregate/<package>-feedstock/recipe/meta.yaml
```

If the feedstock doesn't exist yet, this is a **new feedstock** — see [New Feedstock](#new-feedstock) section.

Classify based on these indicators:

| Indicator | Type |
|-----------|------|
| `{{ compiler('c') }}` or `{{ compiler('cxx') }}` in build requirements | **C/C++** |
| `pip install .` in script, no compilers | **Pure Python** |
| `gpu_variant` or `cuda_compiler_version` references | **CUDA Variant** |
| `outputs:` section in meta.yaml | **Multi-Output** |
| Only pip/setuptools/hatchling/poetry-core in host | **Pure Python** |

A package can be multiple types (e.g., C++ with CUDA variants and multi-output).

---

## Phase 1: Research

### 1.1 Current State
```bash
# Read current recipe
cat /Users/xkong/Repos/aggregate/<pkg>-feedstock/recipe/meta.yaml

# Check recent feedstock history
cd /Users/xkong/Repos/aggregate/<pkg>-feedstock
git log --oneline -10

# Check for local conda_build_config.yaml
cat recipe/conda_build_config.yaml 2>/dev/null
```

### 1.2 Find Target Version

**Python packages (PyPI):**
```bash
curl -s https://pypi.org/pypi/<package>/json | python3 -c "
import json, sys
d = json.load(sys.stdin)
v = d['info']['version']
print(f'Latest: {v}')
print(f'Python: {d[\"info\"][\"requires_python\"]}')
print(f'License: {d[\"info\"][\"license\"]}')
# Get sdist hash
for f in d['urls']:
    if f['packagetype'] == 'sdist':
        print(f'SHA256: {f[\"digests\"][\"sha256\"]}')
        print(f'URL: {f[\"url\"]}')
"
```

**C/C++ packages (GitHub):**
```bash
# Latest release
curl -s https://api.github.com/repos/<org>/<repo>/releases/latest | python3 -c "
import json, sys
d = json.load(sys.stdin)
print(f'Tag: {d[\"tag_name\"]}')
print(f'URL: {d[\"tarball_url\"]}')
"
# Get SHA256
curl -sL https://github.com/<org>/<repo>/archive/<tag>.tar.gz | shasum -a 256
```

### 1.3 Compare Conda-Forge Recipe
```bash
# Check if conda-forge has a recipe
gh api repos/conda-forge/<pkg>-feedstock/contents/recipe/meta.yaml --jq '.content' | base64 -d 2>/dev/null
# Some use recipe.yaml (v2 format)
gh api repos/conda-forge/<pkg>-feedstock/contents/recipe/recipe.yaml --jq '.content' | base64 -d 2>/dev/null
```

### 1.4 Check Recent PRs and Reviews
```bash
# Recent PRs with any review comments
gh pr list --repo AnacondaRecipes/<pkg>-feedstock --state merged --limit 5 --json number,title
# Get reviewer comments from most recent PR
gh api repos/AnacondaRecipes/<pkg>-feedstock/pulls/<N>/comments
```

### 1.5 Diff Upstream Dependencies (CRITICAL)

This is the **#1 reviewer complaint**. Compare dependencies between old and new versions.

**Python packages:**
```bash
# Old version
curl -s https://pypi.org/pypi/<package>/<old_version>/json | python3 -c "
import json, sys; d=json.load(sys.stdin)
for r in (d['info']['requires_dist'] or []): print(r)
"
# New version
curl -s https://pypi.org/pypi/<package>/<new_version>/json | python3 -c "
import json, sys; d=json.load(sys.stdin)
for r in (d['info']['requires_dist'] or []): print(r)
"
```

**C/C++ packages:** Compare `CMakeLists.txt` or `pyproject.toml` between tags on GitHub.

---

## Phase 2: Update Recipe

### 2.1 Version and Hash
```yaml
{% set version = "X.Y.Z" %}
# Update sha256 to match new version's source tarball
```

### 2.2 Build Number
- **Version update:** Reset to `number: 0`
- **Recipe-only change (same version):** Increment build number

### 2.3 Dependencies

Cross-reference upstream source (pyproject.toml/setup.py/CMakeLists.txt) at the exact version tag.

Rules from COOKBOOK:
- Use Jinja2 variables for global pins (check aggregate CBC)
- Match upstream version bounds — don't add/remove upper bounds without reason
- Comment any deviation from upstream with explanation

### 2.4 Build Scripts (if applicable)

Check for:
- New/removed cmake flags
- New/removed optional features
- Changed dependency names upstream

---

## Phase 3: Patch Management (C/C++ only)

**Use `quilt` for patch management.** It tracks file changes and generates patches
with correct context, line counts, and blank line handling — avoiding the malformed
hunk errors common with hand-written patches.

### 3.1 Test All Existing Patches with Quilt
```bash
# Download and extract new source
curl -sL <source_url> | tar -xz
cd <extracted_dir>

# Setup quilt
mkdir -p patches
export QUILT_PATCHES=patches

# Import existing patches in order
for p in /Users/xkong/Repos/aggregate/<pkg>-feedstock/recipe/patches/*.patch; do
    quilt import "$p"
done
# Verify series order matches meta.yaml patch order
cat patches/series

# Apply all patches — note which ones fail
quilt push -a
```

### 3.2 Handle Failed Patches

For each failed patch, determine:
1. **Fixed upstream?** → Remove the patch (`quilt delete <patch>`)
2. **Context shifted?** → Regenerate: `quilt push -f`, fix rejects, `quilt refresh -p ab --no-timestamps --no-index`
3. **Code restructured?** → Rewrite (see 3.3)

### 3.3 Create or Regenerate Patches with Quilt
```bash
cd <extracted_dir>
export QUILT_PATCHES=patches

# Apply patches up to the one before the new/modified patch
quilt push <previous-patch>   # or skip if creating first patch

# Create a new patch
quilt new fix-something.patch

# Register files you will modify (BEFORE editing them)
quilt add src/path/to/file.cpp src/path/to/other.h

# Make changes using any tool (Edit, sed, etc.)
# ...

# Generate the patch — quilt handles context and line counts correctly
quilt refresh -p ab --no-timestamps --no-index

# Verify: pop all and re-apply
quilt pop -a && quilt push -a

# Copy to recipe
cp patches/fix-something.patch /Users/xkong/Repos/aggregate/<pkg>-feedstock/recipe/patches/
```

**Key quilt flags for `refresh`:**
- `-p ab` — Use `--- a/` and `+++ b/` prefixes (standard unified diff)
- `--no-timestamps` — Omit timestamps from diff headers
- `--no-index` — Omit `Index:` lines

**Important:** Always `quilt add <file>` BEFORE editing. Quilt needs the original
to generate the diff. If you forget, `quilt add` won't work after the file is modified.

### 3.4 Fallback: Manual Patch Generation (when quilt unavailable)
```bash
cp -r <pkg>-<version> <pkg>-<version>-patched
# Make changes in -patched copy
diff -Naur <pkg>-<version>/path/to/file <pkg>-<version>-patched/path/to/file > recipe/patches/fix.patch
# Or use git diff if source is a git repo:
# git diff > recipe/patches/fix.patch
```

### 3.5 Clean Up
- Remove orphaned .patch files not referenced in meta.yaml
- Remove patches for issues fixed upstream

---

## Phase 4: Validate

Run through the COOKBOOK checklist:

### 4.1 Common Mistakes Check
- [ ] Deps match upstream pyproject.toml/setup.py at exact version tag?
- [ ] Using Jinja2 variables for global pins (not hardcoded versions)?
- [ ] No duplicate entries in recipe/conda_build_config.yaml vs aggregate CBC?
- [ ] Code comments explain non-obvious decisions (skips, workarounds, pin overrides)?
- [ ] No unnecessary build dependencies?
- [ ] Libraries in host section (not build)?
- [ ] Tests enabled and include pip check?
- [ ] Section names spelled correctly (run_constrained, run_exports)?
- [ ] No hardcoded paths (/usr/local, /opt/homebrew)?
- [ ] Downstream testing considered for major version bumps?

### 4.2 AnacondaRecipes Conventions
- [ ] No `noarch: python` (use `skip: true  # [py<39]` instead)?
- [ ] Source URL uses `pypi.org` (not `pypi.io`)?
- [ ] `doc_url` and `dev_url` in about section?
- [ ] `license_family` in about section?
- [ ] `pip check` in test commands?
- [ ] Conda-forge maintainers preserved if recipe is derived from conda-forge?

### 4.3 CBC Cross-Check
```bash
# If recipe has its own conda_build_config.yaml, check for duplicates
diff <(grep "^[a-z]" /Users/xkong/Repos/aggregate/<pkg>-feedstock/recipe/conda_build_config.yaml 2>/dev/null) \
     <(grep "^[a-z]" /Users/xkong/Repos/aggregate/conda_build_config.yaml)
```
If the file only contains duplicates of aggregate CBC entries, flag it for deletion.

---

## Phase 5: Commit and PR

### 5.1 Commit
```bash
cd /Users/xkong/Repos/aggregate/<pkg>-feedstock
git checkout -b <branch-name>
git add recipe/
git commit -m "Update <package> to <version>"
```

### 5.2 PR Description Template
```markdown
## <package> <version>

**Destination channel:** defaults

### Links
- [PKG-XXXXX](https://anaconda.atlassian.net/browse/PKG-XXXXX)
- [PyPI](https://pypi.org/project/<package>/<version>/) or [GitHub](https://github.com/<org>/<repo>)

### Explanation of changes:
- Updated <package> from <old_version> to <version>
- [List dependency changes]
- [List patch changes]
- [List any notable upstream changes]
```

```bash
gh pr create --repo AnacondaRecipes/<pkg>-feedstock \
  --title "<package> <version>" \
  --body "$(cat <<'EOF'
<PR body from template above>
EOF
)"
```

---

## Phase 6: Knowledge Update (Self-Learning)

After completing the update, check for new patterns:

1. **Build failure not in COOKBOOK?**
   → Read `/Users/xkong/Repos/aggregate/.claude/knowledge/COOKBOOK.md`
   → If pattern is new and generalizable, add it to the appropriate section

2. **Package-specific quirk discovered?**
   → Read `~/.claude/projects/-Users-xkong-Repos-aggregate/memory/package-patterns.md`
   → If package not listed or quirk is new, add it (max 7 bullets per package)

3. **Upstream build system changed in a way that affects recipes?**
   → Update COOKBOOK's "Build Script Patterns" section

**Rules:**
- Read file first to avoid duplicates
- Include source reference (PR#, error message)
- Keep entries concise (1-3 lines)
- Don't add speculative patterns — evidence required

---

## Type-Specific Playbooks

### Pure Python Playbook

1. Detect build backend from pyproject.toml: `hatchling`, `poetry-core`, `flit-core`, `setuptools`
2. Host section: ONLY `python`, `pip`, and build backend (+ optional: `hatch-vcs`, `setuptools-scm`)
3. NO runtime deps in host section
4. Check for entry_points/scripts in pyproject.toml → add to test commands
5. Build script: `{{ PYTHON }} -m pip install . -vv --no-deps --no-build-isolation`

### C/C++ Library Playbook

1. Build tools in build section: `{{ compiler('c') }}`, `cmake`/`meson`, `ninja-base`, `pkg-config`, `make`
2. Libraries in host section with Jinja2 pins
3. Test all outputs: executables (--help), shared libs, headers, pkg-config files
4. Patch management (Phase 3)
5. Check for vendored libraries that should use external conda packages

### CUDA Variant Playbook

1. Build number: `{{ build_number + 100 }}` for CUDA variants
2. CUDA gating: `ANACONDA_ROCKET_ENABLE_CUDA`
3. libcublas-dev: check actual available version, NEVER use `{{ cuda_compiler_version }}`
4. Skip invalid combinations (e.g., cublas + mkl)
5. GCC version: must be <13 for CUDA 12.4 (`cuda-nvcc-impl` constraint)
6. Compiler ABI: single compiler strategy preferred (avoid GCC/Clang mixing)

### Multi-Output Playbook

1. Each output needs its own test section
2. Use `{{ pin_subpackage('name', exact=True) }}` for inter-output deps
3. Remember: `$PREFIX` in install scripts points to the output prefix, not the build prefix
4. For circular deps: stage files in build.sh, copy in install_pkg.sh

---

## New Feedstock

If the feedstock doesn't exist yet:

1. Check if conda-forge has a recipe to adapt
2. Create repo: `gh repo create AnacondaRecipes/<pkg>-feedstock --private`
3. Create recipe directory with meta.yaml following conventions above
4. Follow the appropriate type-specific playbook
5. Ensure conda-forge maintainers preserved if adapting their recipe
