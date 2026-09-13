---
name: cyclomatic-complexity
description: Refactor code to reduce cyclomatic complexity so it stays readable, maintainable, and aligned with the long-term vision of the codebase, not just optimized for AI comprehension. Use whenever the user asks to refactor, simplify, clean up, or review code quality; mentions complexity, maintainability, readability, spaghetti code, deeply nested logic, or god functions; or asks to check AI-generated code before merging. Also use proactively after writing any nontrivial function with heavy branching.
---

# Cyclomatic Complexity

Refactor complex code to reduce cyclomatic complexity while keeping it human-maintainable, testable, and aligned with clean architecture.

## Measure First

`CC = decision points + 1`. Decision points include: `if`, `else if`, `case`, loops (`for`, `while`), `catch`/`except`, ternary operators, and logical operators (`&&`/`and`, `||`/`or`) in conditions.

### Function Complexity Thresholds
- **1–5**: Low complexity, clean. Leave alone.
- **6–10**: Moderate complexity. Monitor; refactor if already modifying.
- **11–15**: High complexity. Refactor now.
- **16+**: Extreme complexity / God function. Must split immediately.

### File Length & Modularity Thresholds
- **Enterprise baseline**: Keep code files ideally under 300 lines; **hard upper limit of 500 lines**.
- **No God Files**: When extracting helper functions from complex logic, do not bloat an already large file. If adding extracted helpers pushes a file toward or beyond 500 lines, extract cohesive units into a dedicated submodule or helper file (e.g., `_helpers.py`, `_parsers.py`, or domain submodules) and import them.

### Tooling
Prefer automated analyzers over manual counting:
- **Python**: Use bundled helper [scripts/measure_complexity.py](./scripts/measure_complexity.py) (zero dependencies) or `radon cc -s -a <path>`
- **JavaScript / TypeScript**: ESLint `complexity` rule / `max-lines`
- **Go**: `gocyclo <path>`
- **Polyglot / Multi-language**: `lizard <path>`
- If no tool is available in the environment: count decision points and line counts manually and display the score.

---

## Refactor Tactics (Order of Preference)

1. **Guard clauses**: Invert conditions and return early to eliminate nested blocks.
2. **Extract function**: Break complex blocks into well-named functions whose names describe *what* they do, not *how*.
3. **Lookup table / map**: Replace long `if/elif` or `switch` chains with dictionary or map lookups.
4. **Named predicates**: Replace complex boolean expressions with descriptive boolean helper functions (e.g., `is_eligible_for_refund(order)`).
5. **Polymorphism / Strategy pattern**: Replace switch-on-type logic when the branch occurs across multiple places.
6. **Flatten loops**: Extract nested loop bodies into helpers; use `continue` instead of nesting inner `if` statements.
7. **Module extraction**: When a file approaches the 500-line ceiling, extract cohesive helpers into companion modules rather than accumulating helper bloat in one file.

---

## Comment Discipline (Python Files)

When working on Python files, enforce standard pythonic conventions:
- **Docstrings over Comments**: Comments should be left at just docstrings (PEP 257) for functions, classes, or at the beginning of the file to let users quickly understand the code's purpose.
- **Zero Redundant Agent Comments**: Never add narrative comments common with AI agents planning and executing code (e.g., `# step 1: initialize variables`, `# loop through items`, `# return early`, `# helper for validation`). Code should be self-explanatory.
- **Strictly Minimize `#` Comments**: Comments starting with `#` should only be used when completely needed—i.e., only when removing it could cause problems, misinterpretations, or tooling issues (e.g., `# type: ignore`, `# noqa`, or rare non-obvious workarounds).

---

## Zero-Breakage Guarantee

Every refactor must be provably behavior-preserving. Follow these rules without exception:

### Before Touching Any Code
1. **Discover the project's verification stack**: Identify the test runner (`pytest`, `npm test`, `go test`, etc.), type checker (`mypy`, `pyright`, `tsc`), and linter (`ruff`, `eslint`, `golangci-lint`). Note what exists and what doesn't.
2. **Run the full verification stack**: Execute tests, type checks, and linters. Record any pre-existing failures. You own zero regressions—the verification stack must produce the same results (or better) after your changes.
3. **If no tests exist**: State this explicitly to the user. Do NOT proceed with aggressive refactoring. Limit changes to safe mechanical transforms only (guard clauses, renaming, reordering). Do not extract functions, split files, or restructure control flow without test coverage to prove equivalence.

### During Refactoring
4. **One function at a time**: Refactor a single function, then verify before moving to the next. Never batch multiple function refactors without intermediate verification.
5. **Cross-file dependency awareness**: Before extracting a function to a new module or renaming it, search the entire codebase for all callers and importers. Update every call site. Verify no import is left broken.
6. **Preserve all signatures**: Function names, parameter names, parameter order, return types, default values, and exception contracts must remain identical on any public or imported function. Internal-only helpers (prefixed with `_`) may be renamed if all callers are updated in the same change.
7. **Preserve side effects and ordering**: If the original code writes to a file, mutates a list, or calls an external API in a specific order, the refactored code must do exactly the same in exactly the same order.

### After Each Change
8. **Re-run the full verification stack**: Tests, type checker, linter. Compare results against the baseline from step 2. Any new failure is a regression—revert and fix before proceeding.
9. **For multi-file or whole-codebase refactors**: Complete and verify one file fully before moving to the next. Never leave the codebase in a half-refactored state. If the scope is large (5+ files), recommend the user commit after each file so any individual change can be reverted cleanly.

---

## Hard Rules

- **Zero regressions**: The verification stack (tests + type checker + linter) must produce the same results or better after your changes. New failures are unacceptable.
- **Do not game the metric**: Merging 6 branches into a dense ternary one-liner or list comprehension is worse than the original `if` chain. Complexity must move into well-named, readable units.
- **Respect file length caps**: Do not solve high cyclomatic complexity by creating a 700-line monster file. Respect the <= 500 lines enterprise ceiling.
- **Preserve public interfaces**: Never break public API signatures, exported function names, or parameter contracts without explicit permission.
- **One responsibility per function**: If a function name needs "and", split it.
- **No refactoring without verification**: If you cannot run tests or type checks and no tests exist, only apply trivially safe transforms (guard clauses, variable renames). Tell the user what you skipped and why.

---

## Workflow

1. **Discover verification stack**: Identify test runner, type checker, linter. Run them all. Record baseline results.
2. **Measure touched files & functions**: Measure total file line count (check against <= 500 line limit) and rank functions by CC descending.
3. **Report baseline hotspots**: Report the measured CC scores, file line count, and verification baseline before modifying any code.
4. **Refactor worst first**: Refactor one function at a time. After each function: re-run verification stack, confirm zero regressions. If the file is near 500 lines, extract helpers into a separate module—update all importers across the codebase. For Python code, apply the comment discipline strictly.
5. **Re-measure**: Calculate post-refactor CC scores and resulting file line count(s).
6. **Final verification**: Run the full verification stack one last time. Confirm zero regressions against the step 1 baseline.
7. **For multi-file scope**: Recommend the user commit after each completed file. Complete one file fully before starting the next.

---

## Output Format

Conclude every refactor with:

```markdown
## Complexity report
- **File line count**: 320 lines (Enterprise ceiling: <= 500 lines)
- **Verification**: tests pass (24/24), mypy clean, ruff clean

| Function | Before | After |
|----------|--------|-------|
| parse_order | 14 | 4 |
| validate_header (extracted) | - | 2 |
| resolve_discount (extracted) | - | 2 |

Extracted: validate_header, resolve_discount
Callers updated: checkout.py, api/routes.py
Behavior verified: <test command and result>
```
