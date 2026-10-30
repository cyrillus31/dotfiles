---
name: xlsx
description: "Create, read, clean, or edit spreadsheet files such as .xlsx, .csv, and .tsv."
---

Inspect sheets, headers, types, formulas, formatting, and the requested output. Use openpyxl for Excel structure and formulas, pandas for tabular transformations, or standard CSV tools for plain tables. Preserve formulas and styles outside the requested area and avoid overwriting the input by default. Keep identifiers and leading zeros as text where required. Reopen the output and verify row counts, representative values, and formulas. Use an available spreadsheet engine for recalculation when needed; do not claim formulas were recalculated by openpyxl. Return the file with any remaining verification limits.
