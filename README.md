# Reproduction: Git index modification by opencode in git hook

## Overview

This repository reproduces an issue where **opencode modifies the git index**
when it is executed inside the `prepare-commit-msg` git hook.

The expected behavior of the `prepare-commit-msg` hook is to **edit only the
commit message**. However, when opencode is invoked from this hook, the git
index tree changes, which can be detected via `git write-tree`.

This behavior occurs **only in the git hook context** and does not reproduce
when running the same script directly from the command line.

---

## Environment

- Git
- Bash (macOS / Linux / WSL / Git Bash on Windows)
- opencode CLI

> On Windows, Git Bash or WSL is required.

---

## Repository Structure

```bash
.
├─ scripts/
│  └─ repro.sh # Reproduction script
└─ hooks/
   └─ prepare-commit-msg # Git hook that calls repro.sh
```

## Steps to Reproduce

1. Clone this repository:

   ```bash
   git clone https://github.com/atsushifx/repro-opencode-modify-git-index-by-hook.git
   cd https://github.com/atsushifx/repro-opencode-modify-git-index-by-hook
   ```

2. Install the git hook:

   ```bash
   cp hooks/prepare-commit-msg .git/hooks/prepare-commit-msg
   chmod +x ./git/hooks/prepare-commit-msg
   ```

3. Create and stage a file:

   ```bash
   echo "test" > hello2
   git add hello2
   ```

4. Run a commit:

   ```bash
   git commit -m "changed"
   ```

## Expected Behavior

- The git index should remain unchanged.
- The `prepare-commit-msg` hook should only affect the commit message.
- The index tree hash (`git write-tree`) should be identical before and after running opencode.

## Actual Behavior

- When opencode runs inside the `prepare-commit-msg` hook, the git index tree changes.
- This is detected by a different `git write-tree` hash before and after opencode execution.
- The commit is aborted by the reproduction script due to the detected index change.

### Example output

```bash
## index BEFORE
9af142bbce0effe226a22361485392917edba583

## index AFTER
24d4e051d0e457eacb0d59887d05a4e8b43f9688

ERROR: index tree CHANGED
```

## License

The MIT License
