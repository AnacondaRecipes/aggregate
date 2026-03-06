# Anaconda Feedstock Cookbook

> **Living document.** Updated by `review-pr` and `update-package` skills when new
> patterns are discovered. See [Learning Protocol](#learning-protocol) at bottom.
> **Cap: 300 lines.** Package-specific overflow goes to `memory/package-patterns.md`.

## Quick Classification

| Type | Indicators | Key Concerns |
|------|-----------|--------------|
| Pure Python | `pip install .`, no compilers, setuptools/hatch/poetry/flit | Host: ONLY pip + python + build backend. No runtime deps in host |
| C/C++ Library | `{{ compiler('c') }}`, cmake/meson/autotools | Libraries in host not build; `ninja-base` not `ninja`; version pins |
| CUDA Variant | `gpu_variant`, `cuda_compiler_version` | Build number +100/+200; CUDA gating; libcublas versioning |
| Multi-Output | `outputs:` section in meta.yaml | Install phase `$PREFIX` scoping; per-output tests; `exact=True` deps |
| Ecosystem | Many interdependent packages | Dependency ordering (leaves first); version pin alignment |

## Dependency Rules

### Global Pins (Jinja2 variables from aggregate CBC)

Use these instead of hardcoded versions. Check `/Users/xkong/Repos/aggregate/conda_build_config.yaml`.

| Variable | Example Usage | Notes |
|----------|--------------|-------|
| `{{ mkl }}` | `mkl-devel {{ mkl }}` | BLAS variant |
| `{{ openblas }}` | `openblas-devel {{ openblas }}` | BLAS variant |
| `{{ libcurl }}` | `libcurl {{ libcurl }}` | |
| `{{ boost }}` | `libboost-devel {{ boost }}` | |
| `{{ protobuf }}` | `libprotobuf {{ protobuf }}` | |
| `{{ openssl }}` | `openssl {{ openssl }}` | |
| `{{ zlib }}` | `zlib {{ zlib }}` | |
| `{{ sqlite }}` | `sqlite {{ sqlite }}` | |
| `{{ icu }}` | `icu {{ icu }}` | |
| `{{ glib }}` | `glib {{ glib }}` | Has run_exports (prefer over libglib) |
| `{{ freetype }}` | `freetype {{ freetype }}` | |
| `{{ libpng }}` | `libpng {{ libpng }}` | |
| `{{ libtiff }}` | `libtiff {{ libtiff }}` | |
| `{{ hdf5 }}` | `hdf5 {{ hdf5 }}` | |
| `{{ fftw }}` | `fftw {{ fftw }}` | |
| `{{ cxx_compiler_version }}` | `llvm-openmp {{ cxx_compiler_version }}` | macOS OpenMP |
| `{{ cuda_compiler_version }}` | `cuda-cudart-dev {{ cuda_compiler_version }}` | CUDA libs |

### Build vs Host vs Run

| Section | What Goes Here | Examples |
|---------|---------------|----------|
| **build** | Compilers + build tools ONLY | `{{ compiler('c') }}`, cmake, meson, ninja-base, pkg-config, make |
| **host** | Libraries linked against + Python build tools | glib, zlib, openssl, python, pip, setuptools, hatchling |
| **run** | Runtime dependencies | python, numpy, requests |

**Common mistakes:** Libraries in build (wrong!), python/setuptools in build for C++ packages (unnecessary), runtime deps in host for pure Python (unnecessary).

### Packages with run_exports (prefer these)

| Use This | Instead Of | Why |
|----------|-----------|-----|
| `glib` | `libglib` | glib has run_exports that auto-adds libglib to run |
| `gettext` | `libgettext` | Same reason |
| `curl` | `libcurl` | Same reason |

### Pure Python Host Section

For packages using `pip install`:
```yaml
host:
  - python >=3.9        # Only python
  - pip                  # Only pip
  - setuptools           # Only build backend
  # NO runtime deps here! pip handles them from package metadata
```

Build backends: `setuptools`, `hatchling` (+hatch-vcs), `poetry-core`, `flit-core`, `maturin` (Rust)

## Build Script Patterns

### pip install (standard for all Python)
```
{{ PYTHON }} -m pip install . -vv --no-deps --no-build-isolation
```

### CMake (C/C++)
```bash
cmake ${CMAKE_ARGS} -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTING=OFF \
  ..
cmake --build . --config Release
cmake --install . --prefix $PREFIX
```

### Meson (C/C++)
```bash
meson setup ${MESON_ARGS:-} builddir \
  -Dtests=false \
  -Ddocs=false
meson compile -C builddir
meson install -C builddir
```
**Rule:** Use `-D` flags to disable features, NOT file removal/touching.

## CUDA Patterns

### Build Number Convention
- CPU variant: `number: 0`
- GPU/CUDA variant: `number: {{ build_number + 100 }}` or `+200`

### CUDA Gating
```yaml
build:
  skip: true  # [not (ANACONDA_ROCKET_ENABLE_CUDA | default("") == "1")]
```

### libcublas-dev Versioning
**NEVER** pin libcublas-dev to `{{ cuda_compiler_version }}` — it has its own versioning.
Check actual available versions before pinning.

### Compiler ABI (from catboost experience)
Mixing GCC (NVCC host) + Clang (C++) causes ABI mismatch → segfaults.
Solution: Single compiler strategy — use `clangxx` as NVCC host compiler (`-ccbin=clang++`).

## Test Patterns

### File Existence (Unix vs Windows)
```yaml
test:
  commands:
    - mycli --help                                    # Entry point
    - test -f $PREFIX/lib/libmylib${SHLIB_EXT}       # [unix] Shared lib
    - test -f $PREFIX/include/mylib.h                 # [unix] Headers
    - test -f $PREFIX/lib/pkgconfig/mylib.pc          # [unix] pkg-config
    - if not exist %LIBRARY_BIN%\\mylib.dll exit 1    # [win] DLL
    - if not exist %LIBRARY_LIB%\\mylib.lib exit 1    # [win] Import lib
```

### Python Package Tests
```yaml
test:
  imports:
    - mypackage
  requires:
    - pip
  commands:
    - pip check
    - mycommand --version  # If package has entry_points
```

### Discovery
Use [conda-metadata-app](https://conda-metadata-app.streamlit.app/) to find all files a package installs.

## Top 10 Common Mistakes

1. **Deps don't match upstream pyproject.toml/setup.py** — Always cross-reference at the exact version tag. Link to upstream source line in PR. *(Source: cbouss on numpy#119, scikit-learn#43, #38)*
2. **Hardcoded versions instead of Jinja2 CBC variables** — Use `{{ mkl }}`, `{{ openblas }}`, etc. *(Source: opencv#42 kups-conda)*
3. **Duplicate CBC entries** — If `recipe/conda_build_config.yaml` only contains entries matching aggregate CBC, delete the file entirely
4. **Missing code comments for non-obvious decisions** — Skips, workarounds, pin overrides all need explanatory comments *(Source: onurbingol on opencv#41)*
5. **Unnecessary build deps** — Verify each dep is actually used. Don't add numpy to host for wheel installs. Don't add cython if not compiling. *(Source: skupr-anaconda on catboost#8)*
6. **Libraries in build section** — Libraries (glib, zlib, openssl) go in host, not build
7. **Disabling tests without justification** — Document exact error, root cause, and plan to re-enable *(Source: cbouss on scikit-learn#38)*
8. **Misspelled sections** — `run_constraint` (wrong) vs `run_constrained` (right); `run_export` vs `run_exports`
9. **Hardcoded paths** — `/usr/local`, `/opt/homebrew` → use `$PREFIX`, `$BUILD_PREFIX`
10. **Missing downstream testing** — Major version bumps need `ddb get-impact` results *(Source: cbouss on scikit-learn#43)*
11. **`ignore_run_exports` anti-pattern** — Almost always wrong. Suppresses version bounds → unbounded run deps → future segfaults. Fix the build script or deps instead. *(Source: cbouss on librsvg#13)*
12. **Host deps without provenance comments (C/C++)** — For compiled packages, link to upstream meson.build/CMakeLists.txt/pkgconfig showing why each host dep is needed. *(Source: cbouss on librsvg#13)*

## AnacondaRecipes Conventions

These are **mandatory** for all recipes submitted to defaults:

1. **DO NOT use `noarch: python`** — use `skip: true  # [py<39]` instead
2. Source URL: `https://pypi.org/packages/source/` (prefer `pypi.org` over `pypi.io`)
3. Both `doc_url` and `dev_url` required in about section
4. `pip check` required in test commands (with `pip` in test requires)
5. `license_family` required in about section
6. `description` field required in about section (linter checks for it; use PyPI description if available)
7. Build order in meta.yaml: `number`, `skip`, `script`
8. Entry points declared if package has CLI scripts
9. For conda-forge-derived recipes: preserve original `recipe-maintainers`

**Exception:** The `noarch: python` rule applies to AnacondaRecipes defaults channel.
Some feedstocks (like llama-index sub-packages) may use noarch when building for
conda-forge compatibility — check the target channel.

## Reviewer Intelligence

See detailed reviewer focus areas: `~/.claude/projects/-Users-xkong-Repos-aggregate/memory/reviewer-preferences.md`

**Quick summary:**
- **cbouss**: Upstream dep compliance (links to pyproject.toml), CBC variable usage
- **ifitchet**: Downstream testing, PR description quality
- **onurbingol**: Code comments, documentation, patch attribution
- **skupr-anaconda**: Unnecessary deps, test quality, minimal changes

## Platform-Specific Notes

### macOS
- OpenMP: `llvm-openmp {{ cxx_compiler_version }}` in host (not build)
- Linux libgomp: auto-exported by GCC compiler — don't specify manually
- Windows OpenMP: `llvm-openmp` (no version pin)

### Cross-compilation
- Use `target_platform` (conda-set), NOT `$OSTYPE` (shell-specific)
- Remove obsolete platforms (ppc64le, s390x) unless specifically needed

### Multi-Output Prefix Scoping
- `build.sh`: `$PREFIX` = top-level host prefix (NOT packaged!)
- `install_pkg.sh`: `$PREFIX` = output package prefix (packaged!)
- If a build tool is unavailable in output phase, stage to `$SRC_DIR/staged/` in build.sh, then copy in install_pkg.sh

## Patch Management

**Prefer `quilt`** over hand-writing patches. It generates correct context, line
counts, and blank line handling automatically.

### Quilt Workflow (Preferred)
```bash
curl -L https://github.com/org/repo/archive/vX.Y.Z.tar.gz | tar -xz
cd pkg-X.Y.Z
mkdir -p patches && export QUILT_PATCHES=patches

# Import existing patches
for p in /path/to/<pkg>-feedstock/recipe/patches/*.patch; do quilt import "$p"; done
# Fix series order if needed: cat patches/series

# Apply all — see which fail
quilt push -a

# Create new patch
quilt new fix-something.patch
quilt add src/file.cpp          # BEFORE editing!
# ... make changes ...
quilt refresh -p ab --no-timestamps --no-index

# Verify full stack
quilt pop -a && quilt push -a

# Copy result
cp patches/fix-something.patch /path/to/<pkg>-feedstock/recipe/patches/
```

### Fallback: Manual Workflow (when quilt unavailable)
```bash
cp -r pkg-X.Y.Z pkg-X.Y.Z-patched
# Make changes in -patched
diff -Naur pkg-X.Y.Z/path/file pkg-X.Y.Z-patched/path/file > recipe/patches/fix.patch
# Test: patch -p1 --dry-run < recipe/patches/fix.patch
```

### Before Regenerating
Check if the issue is already fixed upstream — remove obsolete patches instead of regenerating.

### Test ALL Patches Together
```bash
# With quilt:
quilt pop -a && quilt push -a
# Without quilt:
for p in recipe/patches/*.patch; do patch -p1 --dry-run < "$p" || echo "FAILED: $p"; done
```

## Learning Protocol

### When to Update This File

| Trigger | Action |
|---------|--------|
| Reviewer catches issue not documented here | Add to appropriate section |
| Build fails due to undocumented pattern | Add to Common Mistakes or relevant section |
| User says "remember this" | Add where appropriate |

### Rules
1. **Read first** — check for duplicates before adding
2. **Evidence required** — include source (PR#, reviewer, build log)
3. **Keep concise** — 1-3 lines per pattern
4. **Package-specific** quirks go to `memory/package-patterns.md`, not here
5. **Cap at 300 lines** — prune or move to memory if exceeding

### Sources
- numpy#119, scikit-learn#38/#40/#43, opencv#39/#41/#42, catboost#8, cmake#14/#16 (AnacondaRecipes)
- PR review analysis across 9 feedstocks, ~60 merged PRs (2026-03)
