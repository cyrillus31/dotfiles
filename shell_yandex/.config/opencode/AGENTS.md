# Global Agent Instructions

## Communication Style with User

**IMPORTANT:** Follow this communication pattern when explaining concepts or answering questions:

1. **Keep it short and simple** - Avoid long paragraphs and overexplaining
2. **Don't assume prior knowledge** - Explain things as if the user is new to the system
3. **Structure clearly:**
   - Give a brief title or label for each concept
   - One short sentence explaining what problem it solves
   - One simple example or comparison
   - Leave room for the user to ask follow-up questions

4. **Use the format:**

   ```
   ## Concept Name - Brief description

   **Problem it solves:** One sentence about the purpose

   **Example or explanation:** Keep it concrete and short

   ---

   ## Next Concept

   [Repeat format]
   ```

5. **When explaining relationships:**
   - Show how concepts connect in simple terms
   - Use arrows or simple diagrams
   - One sentence summary of the relationship

6. **Never:**
   - Use jargon without explaining it first
   - Give multiple complex paragraphs when one would do
   - Assume the user knows about other parts of the system
   - Include information "just in case" - let them ask

---

## Version Control

When working with version control:

1. **Try `git` first**: Always attempt to use `git` commands for version control operations
2. **Fallback to `arc`**: If the directory is not a git repository, use `arc` as an in-place replacement for version control operations

## Container Runtime

When working with containers:

1. **Try `docker` first**: Always attempt to use `docker` commands for container operations
2. **Fallback to `podman`**: If docker is not available, try `podman` as a drop-in replacement for container operations

## Commit Guidelines

- **Never create commits automatically**: Do not create commits without explicitly asking the user first
- **Exception**: Only create commits when directly specified by the user in their request
- **Allow manual review**: Let the user review changes themselves using `git diff` in the command line
- **Check for uncommitted changes**: If there are uncommitted changes and the user asks for new work, ask if they want to commit those changes first

## Git History Guidelines

- **NEVER modify git history**: Absolutely do not delete commits, rebase, force push, amend previous commits, or perform any history-altering operations without explicit user request
- **Explicit user consent required**: Any operation that modifies git history (beyond creating new commits) must be directly and explicitly specified by the user
- **No automatic history cleanup**: Never automatically clean up, squash, rebase, or reorder commits without being asked
- **Generate commands for users**: You may generate git commands for the user to execute manually (e.g., `git rebase -i`, `git reset`, `git push --force`), but never execute these commands yourself
- **No force pushes**: Never execute force push commands (`git push --force`, `git push --force-with-lease`) under any circumstances
- **No destructive resets**: Never execute hard resets (`git reset --hard`) or other destructive git operations without explicit user approval
- **Clarify the difference**: Creating a new commit with user permission is allowed; modifying, deleting, or reordering existing commits is forbidden without explicit request

## Go Code Linting & Formatting

When working with Go code, be aware of these common linting rules and violations:

### Common Linter Rules

- **nlreturn**: Return statements should have a blank line before them when the block has more than two lines
  - ❌ Bad: Immediate return after closing brace of multi-line block
  - ✅ Good: Add blank line between closing brace and return statement
- **wsl (Whitespace Linting)**: Whitespace should follow specific patterns around control structures
  - ❌ Bad: Return statements cuddled directly after closing braces: `if condition { ... } return value`
  - ✅ Good: Add blank line before return: `if condition { ... }\n\nreturn value`
  - ❌ Bad: Variable declaration directly before for loop used in iteration: `var x = value\nfor _, item := range x { ... }`
  - ✅ Good: Add blank line between assignment and for loop: `var x = value\n\nfor _, item := range x { ... }`
  - ❌ Bad: Nested for loops without blank line before inner loop declaration
  - ✅ Good: Keep nested for loops cuddled if they're semantically related, but outer loop must have blank line before it if assignment precedes it

- **gofmt**: Standard Go formatting via `go fmt`
  - Always run formatting before committing
  - `ya style --check` will catch formatting issues in Yandex/Arcadia repos

### Guidelines for Go Development

1. **Always format before committing**: Run `ya style` or `go fmt` to catch linting issues early
2. **Blank lines before returns**: When a return statement follows a multi-line block (if/for/switch), add a blank line between them
3. **Check style locally**: Use `ya style --check` to verify code style before pushing
4. **Run tests**: Always verify tests pass after formatting changes
5. **Commit formatting fixes separately**: If linter issues are found, create a follow-up commit specifically for formatting fixes

### Example Pattern

```go
// ❌ WRONG: No blank line before return
if condition {
    doSomething()
    doSomethingElse()
}
return result

// ✅ CORRECT: Blank line before return
if condition {
    doSomething()
    doSomethingElse()
}

return result
```

## Go Mocking Strategy

When writing tests in Go, **NEVER write complex mocks manually**. Always use mock generation tools:

### Rule: Use Mock Generators, Not Manual Mocks

❌ **WRONG**: Writing mock implementations by hand

```go
type MockRepository struct {
    GetUserFunc func(ctx context.Context, id string) (*User, error)
    // ... lots of boilerplate ...
}

func (m *MockRepository) GetUser(ctx context.Context, id string) (*User, error) {
    return m.GetUserFunc(ctx, id)
}
```

✅ **CORRECT**: Generate mocks using `mockgen` or `ya tool mockgen`

### Setup Mocks Using mockgen

**When to use each approach:**

1. **For Yandex/Arcadia projects** (using ya.make build system):
   - Use `ya tool mockgen` — it's integrated with the build system
   - Configure mocks via `mockgen.inc` file in mocks directory

2. **For standalone Go projects**:
   - Use `mockgen` command directly (install via `go install github.com/golang/mock/cmd/mockgen@latest`)

### Step-by-Step: Adding Mocks to a Yandex Project

**Example: Creating mocks for `CorpClientsRepository` interface**

1. **Create mockgen.inc file** in `internal/repositories/corp_clients/mocks/`:

   ```makefile
   GO_MOCKGEN_FROM(taxi/backend-go/taxi/b2b/services/corp-payments/internal/repositories/corp_clients)
   GO_MOCKGEN_TYPES(
       CorpClientsRepository
   )
   ```

2. **Create mocks/ya.make** with mock generation rules:

   ```makefile
   GO_LIBRARY()

   SUBSCRIBER(g:taxi-corp)

   PEERDIR(
       ${GOSTD}/context
       taxi/backend-go/taxi/b2b/services/corp-payments/internal/repositories/corp_clients
       taxi/backend-go/taxi/b2b/services/corp-payments/internal/pkg/mongobase
   )

   INCLUDE(mockgen.inc)

   GO_MOCKGEN_MOCKS()

   END()

   RECURSE(
       gen
   )
   ```

3. **Create mocks/gen/ya.make** with reflection helper:

   ```makefile
   GO_PROGRAM()

   SUBSCRIBER(g:taxi-corp)

   INCLUDE(../mockgen.inc)

   GO_MOCKGEN_REFLECT()

   END()
   ```

4. **Generate mocks**:
   ```bash
   ya tool mockgen
   ```

### Mockgen Flags Reference (Command Line)

If using `mockgen` directly, common flags:

```bash
mockgen \
  -source=path/to/interface.go \           # Source file containing interface
  -destination=path/to/mock.go \           # Where to write generated mock
  -package=mocks \                         # Package name for mock
  InterfaceType                            # Interface name to mock
```

### Using Generated Mocks in Tests

Once generated, mocks are automatically available via the mock package:

```go
import "path/to/corp_clients/mocks"

func TestSomething(t *testing.T) {
    mockRepo := mocks.NewMockCorpClientsRepository(ctrl)

    // Set expectations
    mockRepo.EXPECT().
        GetClients(gomock.Any(), gomock.Any()).
        Return(expectedResult, nil)

    // Use in test
    result, err := mockRepo.GetClients(ctx, ids)
}
```

### Key Principles

1. **One interface = one mock** — Each interface gets auto-generated mocks
2. **Update mockgen.inc, not mock files** — Always modify the `.inc` file, then regenerate
3. **Never manually edit generated mocks** — They get overwritten on regeneration
4. **Use gomock for assertions** — `.EXPECT()`, `.Times()`, `.Return()` API for expectations
5. **Keep mocks in separate package** — `mocks/` subdirectory keeps code clean

### When Mocking is Not Needed

- **Testing pure functions** — No mocks needed
- **Testing with real dependencies** — Integration tests using real database/services
- **Testing interfaces at the boundary** — Use real implementations when possible

### Common Pitfall: Manual Config Mocks

⚠️ **DO NOT do this** (like we did in checkers_test.go):

```go
type mockConfigV1 struct {
    allowInactiveOrdersSourceApps []configsv1.CorpAllowOrdersForInactiveUsersSourceAppItemEnum
}
func (m *mockConfigV1) GetCorpAllowOrdersForInactiveUsers() *configsv1.CorpAllowOrdersForInactiveUsers {
    // manual implementation...
}
```

This creates maintenance burden. Use `mockgen` instead and let the tool handle complexity.

## Yandex Build System (ya.make)

When working with Yandex/Arcadia projects:

### ⛔ PROHIBITED: Creating or Editing ya.make Files

- **NEVER create new ya.make files** — This is a build system configuration that must be created and reviewed by humans
- **NEVER edit existing ya.make files** — Any changes to build configuration must be done by developers
- **Why**: ya.make files define critical build dependencies (PEERDIR, SRCS, etc.) and incorrect configurations can break the entire build system

### ✅ ALLOWED: Noting Missing ya.make Files

If a directory requires a ya.make file but doesn't have one:

1. **Identify the missing file** and note it in your work
2. **Ask the user** if they want you to create it or if they'll handle it
3. **If user approves**, create only a minimal, standard ya.make based on the directory structure

### Example Scenario

❌ **WRONG**: Silently create ya.make without asking

```bash
# Don't do this automatically
touch internal/constants/ya.make
# ... edit it with build configuration ...
```

✅ **CORRECT**: Ask user first

```
I notice internal/constants/ doesn't have a ya.make file.
The build system requires this. Should I create a minimal one,
or would you prefer to handle this?
```

## Token Efficiency

- **Proactive reminders**: Periodically remind the user about token usage, especially when working with large codebases or complex tasks
- **Suggest optimizations**: When you notice inefficient requests or large context usage, offer tips to save tokens:
  - Use glob patterns to narrow file searches instead of reading entire directories
  - Use the Task tool with specialized agents for exploratory work instead of running multiple searches
  - Request specific file paths instead of broad directory reads
  - Break complex tasks into smaller focused requests
  - Use grep/search tools to narrow down locations before reading files
- **Be proactive**: If a task seems like it could consume significant tokens, suggest a more efficient approach upfront
