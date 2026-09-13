# cyclomatic-complexity

A **Google Antigravity** skill that refactors code to reduce cyclomatic complexity. Built to tame sprawling, heavily branched code—keeping it readable, maintainable, and aligned with clean architecture.

---

## What It Does

- **Measures cyclomatic complexity per function**: Uses the bundled zero-dependency Python analyzer (`scripts/measure_complexity.py`), project linters (`radon`, `eslint`, `gocyclo`, `lizard`), or manual count.
- **Enterprise File Length Threshold (<= 500 lines)**: Monitors total lines of code per file. Prevents replacing a "god function" with a bloated "god file". When helper extraction pushes a file toward or beyond 500 lines, it guides modular extraction into cohesive submodules.
- **Respects project thresholds**: Adheres to existing linter configurations or industry defaults (1–5 clean, 6–10 watch, 11–15 refactor, 16+ split).
- **Refactors hotspots worst-first**: Applies guard clauses, helper extraction, lookup tables, and named predicates.
- **Python Comment Discipline**:
  - **Docstrings over comments**: Strictly adheres to PEP 257 docstrings for functions, classes, and modules so code purpose is clear at a glance.
  - **Zero redundant agent noise**: Completely eliminates AI narration comments (`# step 1: initialize`, `# loop through items`, `# return early`).
  - **Minimal `#` comments**: Inline `#` comments are strictly restricted to rare cases where removal could cause bugs or break tooling (e.g. `# type: ignore`).
- **Refuses to game metrics**: Complexity moves into well-named, single-responsibility functions, not dense ternary one-liners.
- **Before/after complexity reporting**: Concludes every refactor with a clear quantitative breakdown of CC scores and file line count.

---

## Installation

### 1. One-Line Quick Install (Global)

Installs the skill directly to your Antigravity global configuration (`~/.gemini/config/skills/cyclomatic-complexity`).

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/JohnJodinho/cyclomatic-complexity-skill/master/install.ps1 | iex
```

**Linux / macOS (Bash):**
```bash
curl -fsSL https://raw.githubusercontent.com/JohnJodinho/cyclomatic-complexity-skill/master/install.sh | bash
```

---

### 2. Manual Git Clone

#### Global Installation (Available across all projects)

**Linux / macOS:**
```bash
git clone https://github.com/JohnJodinho/cyclomatic-complexity-skill.git ~/.gemini/config/skills/cyclomatic-complexity
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/JohnJodinho/cyclomatic-complexity-skill.git "$HOME\.gemini\config\skills\cyclomatic-complexity"
```

#### Workspace Installation (Project-scoped)

Clone into your repository's `.agents/skills` directory:

```bash
git clone https://github.com/JohnJodinho/cyclomatic-complexity-skill.git .agents/skills/cyclomatic-complexity
```

---

## Usage in Antigravity

Antigravity uses **progressive disclosure**. Once installed, the agent automatically activates the skill whenever you discuss refactoring, code quality, or complexity.

You can trigger it naturally:

> *"Refactor `parser.py` using cyclomatic complexity."*  
> *"Clean up this spaghetti code and reduce branching."*  
> *"Review code quality and god functions in this module before merging."*

---

## Example Output

```markdown
## Complexity report
- **File line count**: 320 lines (Enterprise ceiling: <= 500 lines)

| Function | Before | After |
|----------|--------|-------|
| parse_order | 14 | 4 |
| validate_header (extracted) | - | 2 |
| resolve_discount (extracted) | - | 2 |

Extracted: validate_header, resolve_discount
Behavior verified: existing test suite passes (18/18 tests green)
```

---

## Uninstallation

**Windows (PowerShell):**
```powershell
.\uninstall.ps1
```

**Linux / macOS (Bash):**
```bash
./uninstall.sh
```

---

## License

Apache 2.0
