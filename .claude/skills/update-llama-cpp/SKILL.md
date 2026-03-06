---
name: update-llama-cpp
description: "Monthly update of llama.cpp feedstock. Handles version updates, patch regeneration, CUDA configuration, and platform-specific issues. Use when updating llama.cpp to a new upstream release."
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash(git:*)
  - Bash(curl:*)
  - Bash(sha256sum:*)
  - Bash(patch:*)
  - Bash(diff:*)
  - Bash(ls:*)
  - Bash(cat:*)
  - Bash(head:*)
  - Bash(tail:*)
  - Bash(mkdir:*)
  - Bash(cd:*)
  - WebFetch
  - TodoWrite
---

# llama.cpp Monthly Update Skill

## Overview

This skill guides the monthly update of the llama.cpp conda feedstock. llama.cpp is an actively developed LLM inference engine with frequent releases (tagged as b####).

## Quick Start

```
/update-llama-cpp b7710
/update-llama-cpp          # Will check for latest release
```

Arguments: `$ARGUMENTS`

## Feedstock Location

```
/Users/xkong/Repos/aggregate/llama.cpp-feedstock/
```

Reference llama.cpp repo (for patch development):
```
/Users/xkong/Repos/llama.cpp/
```

## Update Workflow

### Phase 1: Preparation

#### 1.1 Identify Target Version

If no version specified in arguments, find latest:

```bash
curl -s https://api.github.com/repos/ggml-org/llama.cpp/releases/latest | jq -r '.tag_name'
```

#### 1.2 Get Commit Hash and SHA256

```bash
# Get commit hash for the tag
curl -s https://api.github.com/repos/ggml-org/llama.cpp/git/refs/tags/b{VERSION} | jq -r '.object.sha'

# Get SHA256 of source tarball
curl -sL https://github.com/ggml-org/llama.cpp/archive/b{VERSION}.tar.gz | sha256sum
```

#### 1.3 Review Upstream Changes

```bash
cd /Users/xkong/Repos/llama.cpp
git fetch --tags
git log --oneline b{OLD}..b{NEW} | wc -l  # Count commits
git log --oneline b{OLD}..b{NEW} | head -20  # Notable changes
```

### Phase 2: Update Recipe

#### 2.1 Update meta.yaml

Edit `/Users/xkong/Repos/aggregate/llama.cpp-feedstock/recipe/meta.yaml`:

```yaml
{% set upstream_release = "b{NEW_VERSION}" %}
{% set upstream_commit = "{FULL_COMMIT_HASH}" %}
```

Update SHA256:
```yaml
source:
  url: https://github.com/ggml-org/llama.cpp/archive/{{ upstream_release }}.tar.gz
  sha256: {NEW_SHA256}
```

#### 2.2 Check Python Dependencies

Compare upstream `gguf-py/pyproject.toml` with recipe:

```bash
cd /Users/xkong/Repos/llama.cpp
git checkout b{VERSION}
cat gguf-py/pyproject.toml
```

Ensure all dependencies are in meta.yaml gguf section:
- numpy >=1.17
- tqdm >=4.27
- pyyaml >=5.1
- requests >=2.25  # Often missing!
- sentencepiece >=0.1.98,<=0.2.0

### Phase 3: Patch Management

#### 3.1 Test All Patches with Quilt

```bash
cd /tmp
curl -L https://github.com/ggml-org/llama.cpp/archive/b{VERSION}.tar.gz | tar -xz
cd llama.cpp-b{VERSION}
mkdir -p patches && export QUILT_PATCHES=patches

# Import all existing patches
for p in /Users/xkong/Repos/aggregate/llama.cpp-feedstock/recipe/patches/*.patch; do
    quilt import "$p"
done
# Verify series order matches meta.yaml
cat patches/series

# Apply all — note failures
quilt push -a
```

#### 3.2 Regenerate Failed Patches

Common patches requiring updates:

| Patch | Purpose | Why it fails |
|-------|---------|--------------|
| `increase-nmse-tolerance.patch` | Adjust test precision | Line numbers shift |
| `increase-nmse-tolerance-aarch64.patch` | ARM64 extra tolerance | Line numbers shift |
| `disable-metal-bf16.patch` | Disable BF16 on old macOS | Code structure changes |
| `disable-metal-flash-attention.patch` | Disable FA precision issues | Code structure changes |
| `fix-macos-dylib-version.patch` | macOS library versioning | CMake changes |

**Regeneration with quilt (preferred):**

```bash
# For a patch that failed to apply:
quilt push -f                    # Force-apply, creates .rej files
# Fix the rejects manually
quilt refresh -p ab --no-timestamps --no-index

# For a completely new patch:
quilt push <previous-patch>      # Apply up to the patch before
quilt new fix-something.patch
quilt add path/to/file.cpp       # BEFORE editing!
# ... make changes ...
quilt refresh -p ab --no-timestamps --no-index

# Verify full stack, then copy
quilt pop -a && quilt push -a
cp patches/<patch>.patch /Users/xkong/Repos/aggregate/llama.cpp-feedstock/recipe/patches/
```

**Fallback (without quilt):**

```bash
cp -r llama.cpp-b{VERSION} llama.cpp-b{VERSION}-patched
# Make changes in -patched copy
diff -Naur llama.cpp-b{VERSION}/path/to/file llama.cpp-b{VERSION}-patched/path/to/file > new.patch
```

### Phase 4: CUDA Configuration

#### 4.1 Check Available CUDA Packages

**CRITICAL**: libcublas-dev has its own version that doesn't match cuda_compiler_version!

Check https://anaconda.org/nvidia/libcublas-dev/files

| CUDA Version | libcublas-dev | Status (Jan 2026) |
|--------------|---------------|-------------------|
| 12.4 | 12.4.5.8 | Available |
| 12.8 | 12.8.4.1 | Available |
| 13.0 | N/A | NOT AVAILABLE |
| 13.1 | 13.1.0.3 | Check PBP |

**IMPORTANT**: Do NOT pin libcublas-dev to cuda_compiler_version!
```yaml
# WRONG
- libcublas-dev {{ cuda_compiler_version }}

# CORRECT
- libcublas-dev
```

#### 4.2 Update conda_build_config.yaml

```yaml
cuda_compiler_version:         # [win or (linux and x86_64)]
  - none                       # [win or (linux and x86_64)]
  - 12.8                       # [win or (linux and x86_64)]
```

#### 4.3 CUDA Architecture Handling

**IMPORTANT**: Do NOT set CMAKE_CUDA_ARCHITECTURES manually!

llama.cpp's CMakeLists.txt handles this automatically:
- Uses `120a-real` for CUDA 12.8+ (fixes MXFP4 compilation)
- Uses `121a-real` for CUDA 12.9+
- Has post-selection correction to normalize "12X" to "12Xa"

Reference: https://github.com/ggml-org/llama.cpp/pull/18672

In `build-llama-cpp.sh` and `bld-llama-cpp.bat`, just enable CUDA:
```bash
# Let llama.cpp handle architecture selection
GGML_ARGS="${GGML_ARGS} -DGGML_CUDA=ON"
# Do NOT set CMAKE_CUDA_ARCHITECTURES
```

**Why this works**: The upstream fix (PR #18672) addressed the MXFP4 compilation
error by using `120a` (Ahead-of-Time) instead of plain `120` for Blackwell.

#### 4.4 Build Numbers

```yaml
# CPU variants
number: {{ build_number }}        # [gpu_variant == "none"]  -> 0

# GPU variants (preferred by solver)
number: {{ build_number + 100 }}  # [gpu_variant != "none"]  -> 100

# Future: Multiple CUDA versions
# CUDA 12.8: build_number + 100 -> 100
# CUDA 13.0: build_number + 110 -> 110
```

### Phase 5: Build Configuration

#### 5.1 Task Timeout

CPU builds compile 15 variants (`GGML_CPU_ALL_VARIANTS=ON`), exceeding 2-hour default.

In `abs.yaml`:
```yaml
task_timeout: 14400  # 4 hours
```

#### 5.2 Test Skips

Document any test skips in build scripts:

```bash
# Metal (macOS) - precision issues
ctest -E "(test-tokenizers-ggml-vocabs|test-thread-safety)"

# CUDA on old GPUs (<=sm_75) - shared memory limits
ctest -E "(test-tokenizers-ggml-vocabs|test-backend-ops)"
```

### Phase 6: Validation

#### 6.1 Local Build Test (Optional)

```bash
# CPU build
cd /Users/xkong/Repos/aggregate/llama.cpp-feedstock
conda build recipe/ --variants "{output_set: llama, gpu_variant: none, blas_impl: openblas}"

# CUDA build (requires dev machine)
export ANACONDA_ROCKET_ENABLE_CUDA=1
conda build recipe/ --variants "{output_set: llama, gpu_variant: cuda-12, cuda_compiler_version: 12.8}"
```

#### 6.2 Commit and Push

```bash
git add recipe/ abs.yaml
git commit -m "Update llama.cpp to b{VERSION}

- Update from b{OLD} to b{NEW} ({N} commits)
- CUDA 12.8 (exclude Blackwell sm_120 for MXFP4 compatibility)
- Regenerate patches for new line numbers
- [Other changes]"

git push origin {branch}
```

### Phase 7: PR Description

Use this template:

```markdown
## llama.cpp 0.0.{VERSION}

**Destination channel:** defaults

### Links

- [PKG-XXXXX](https://anaconda.atlassian.net/browse/PKG-XXXXX)
- [Upstream repository](https://github.com/ggml-org/llama.cpp)
- [Upstream changelog/diff](https://github.com/ggml-org/llama.cpp/compare/b{OLD}...b{NEW})

### Explanation of changes:

- Update llama.cpp from b{OLD} to b{NEW} ({N} commits)
- CUDA {VERSION} (list limitations if any)
- Supported architectures: Maxwell(50), Pascal(60), Volta(70), Turing(75), Ampere(80,86), Ada(89), Hopper(90)
- Regenerated patches: {list}
- Added dependencies: {list if any}

### Notable upstream changes:

- {5-6 significant changes from git log}

### Future work:

- {Deferred items}
```

## Common Issues & Solutions

### Issue 1: Build Timeout
**Symptom**: `task aborted - max run time exceeded`
**Fix**: Add `task_timeout: 14400` to abs.yaml

### Issue 2: MXFP4 Compilation Error
**Symptom**: `ptxas error: Feature '.kind::mxf4' not supported on .target 'sm_120'`
**Fix**: Do NOT set CMAKE_CUDA_ARCHITECTURES - let llama.cpp handle it.
Upstream fix (PR #18672) uses `120a-real` instead of plain `120` for Blackwell.

### Issue 3: Missing gguf Dependency
**Symptom**: `pip check` fails with `requires requests, which is not installed`
**Fix**: Add `requests >=2.25` to gguf requirements in meta.yaml

### Issue 4: Patch Hunk Failed
**Symptom**: `Hunk #1 FAILED at line XXX`
**Fix**: Regenerate patch for new source structure

### Issue 5: CUDA Package Not Found
**Symptom**: `libcublas-dev=13.0 does not exist`
**Fix**: Check anaconda.org for available versions, use what exists

### Issue 6: NMSE Test Failure
**Symptom**: `NMSE = 0.074 > 0.005`
**Fix**: Increase tolerance in patch (5e-3 base, 1e-1 for aarch64)

## Historical Reference

### PR #28: b7229 → b7710
- CUDA 12.8 only (13.0 unavailable)
- Excluded Blackwell (sm_120)
- Added task_timeout, requests dependency

### PR #25: b6872 → b7229
- Fixed macOS dylib versioning
- Disabled Metal bf16/flash attention
- Reviewer: "LGTM, suggestions in patches"

### PR #24: b6082 → b6188
- llama-cpp-python compatibility branch
- Platform-specific test handling
- Fixed Jinja2 selector syntax

## Reviewer Expectations

Based on past reviews (cbouss), reviewers check:

1. **CUDA Configuration**
   - Correct versions available on channel
   - Build numbers differentiated (100, 110, etc.)
   - Architecture list matches CUDA version

2. **Patches**
   - Apply cleanly (no fuzz warnings)
   - Minimal and documented
   - Remove obsolete ones

3. **Dependencies**
   - Use Jinja2 variables for pins
   - Include all upstream requirements

4. **Tests**
   - Platform-specific skips documented
   - Timeouts appropriate
