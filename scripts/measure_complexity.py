#!/usr/bin/env python3
"""Cyclomatic complexity analyzer using Python standard library ast.

Calculates cyclomatic complexity per function/method with zero external dependencies.
Also monitors file length against the enterprise standard (<= 500 lines).
"""

from __future__ import annotations

import ast
import sys
from dataclasses import dataclass
from pathlib import Path

MAX_RECOMMENDED_LINES = 500


@dataclass
class FunctionComplexity:
    name: str
    lineno: int
    complexity: int
    classification: str


class ComplexityVisitor(ast.NodeVisitor):
    """AST visitor counting decision points according to McCabe complexity."""

    def __init__(self) -> None:
        self.complexity = 1

    def visit_If(self, node: ast.If) -> None:
        self.complexity += 1
        self.generic_visit(node)

    def visit_IfExp(self, node: ast.IfExp) -> None:
        self.complexity += 1
        self.generic_visit(node)

    def visit_For(self, node: ast.For) -> None:
        self.complexity += 1
        self.generic_visit(node)

    def visit_AsyncFor(self, node: ast.AsyncFor) -> None:
        self.complexity += 1
        self.generic_visit(node)

    def visit_While(self, node: ast.While) -> None:
        self.complexity += 1
        self.generic_visit(node)

    def visit_ExceptHandler(self, node: ast.ExceptHandler) -> None:
        self.complexity += 1
        self.generic_visit(node)

    def visit_BoolOp(self, node: ast.BoolOp) -> None:
        self.complexity += max(0, len(node.values) - 1)
        self.generic_visit(node)

    def visit_Assert(self, node: ast.Assert) -> None:
        self.complexity += 1
        self.generic_visit(node)

    def visit_comprehension(self, node: ast.comprehension) -> None:
        self.complexity += 1
        self.complexity += len(node.ifs)
        self.generic_visit(node)

    def visit_Match(self, node: ast.Match) -> None:
        self.generic_visit(node)

    def visit_match_case(self, node: ast.match_case) -> None:
        self.complexity += 1
        self.generic_visit(node)


def classify_complexity(score: int) -> str:
    """Classify cyclomatic complexity according to standard thresholds."""
    if score <= 5:
        return "Low (1-5)"
    elif score <= 10:
        return "Moderate (6-10)"
    elif score <= 15:
        return "High (11-15)"
    return "Critical (16+)"


def analyze_file(filepath: Path) -> tuple[int, list[FunctionComplexity]]:
    """Parse a python file and measure cyclomatic complexity of all functions."""
    code = filepath.read_text(encoding="utf-8")
    total_lines = len(code.splitlines())
    tree = ast.parse(code, filename=str(filepath))

    results: list[FunctionComplexity] = []

    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            visitor = ComplexityVisitor()
            for child in node.body:
                if not isinstance(child, (ast.FunctionDef, ast.AsyncFunctionDef)):
                    visitor.visit(child)

            results.append(
                FunctionComplexity(
                    name=node.name,
                    lineno=node.lineno,
                    complexity=visitor.complexity,
                    classification=classify_complexity(visitor.complexity),
                )
            )

    results.sort(key=lambda item: item.complexity, reverse=True)
    return total_lines, results


def print_report(filepath: Path, total_lines: int, results: list[FunctionComplexity]) -> None:
    """Output results in Markdown table format."""
    print(f"### Cyclomatic Complexity: `{filepath.name}`\n")
    if total_lines > MAX_RECOMMENDED_LINES:
        print(f"> ⚠️ **File Size Alert**: {total_lines} lines exceeds the enterprise ceiling of {MAX_RECOMMENDED_LINES} lines. Consider splitting into modular submodules.\n")
    else:
        print(f"- **File size**: {total_lines} lines (Enterprise ceiling: <= {MAX_RECOMMENDED_LINES} lines)\n")

    if not results:
        print("No functions found.")
        return

    print("| Function / Method | Line | CC | Risk Level |")
    print("|---|---|---|---|")
    for r in results:
        print(f"| `{r.name}` | {r.lineno} | **{r.complexity}** | {r.classification} |")
    print()


def main() -> None:
    """Main CLI entrypoint."""
    if len(sys.argv) < 2:
        print("Usage: python measure_complexity.py <path-to-python-file>")
        sys.exit(1)

    target = Path(sys.argv[1])
    if not target.exists():
        print(f"Error: File not found: {target}", file=sys.stderr)
        sys.exit(1)

    total_lines, results = analyze_file(target)
    print_report(target, total_lines, results)


if __name__ == "__main__":
    main()
