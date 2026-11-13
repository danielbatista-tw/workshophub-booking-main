---
name: commit
description: Commit the current WorkshopHub changes with a conventional commit message prefixed by the Jira key (e.g. WH-2) taken from the branch name. Use when the user says "commit", "/commit", or asks to commit their work. Never pushes.
---

# Commit

Commit local changes safely. Stop after `git commit`. Never push.

## 1. Check the branch

Run `git branch --show-current`.

- If it is `main`, refuse: tell the user to create a `wh-<card>-<slug>` branch first, and stop.
- Extract the Jira key: match `^wh-([0-9]+)-` and turn it into `WH-<number>` (e.g. `wh-2-session-registration` → `WH-2`).
- If there is no number (e.g. `wh-chore-mcp-permissions`), ask the user for the Jira key. Do not invent one.

## 2. Show what changed

Run `git status --short` and `git diff --stat HEAD` and show both. If there is nothing to commit, say so and stop.

## 3. Pick the files

- If files are already staged, commit only those.
- Otherwise, propose a list of relevant files to stage and stage them by name with `git add <path>...`. Never use `git add -A` or `git add .`.
- Never stage secrets: `.env`, `api/.env`, `*.pem`, `*.key`, credential or token files, `*.sqlite` databases, or any diff containing what looks like an API key, password or token. If one is already staged, unstage it with `git restore --staged <path>` and warn the user.

## 4. Suggest the message

Read `git diff --cached` and suggest one message in this form:

```
WH-<n> <type>(<scope>): <short imperative summary>
```

- `type`: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `style`, `perf`, `ci`, `build`.
- `scope`: optional; use `app`, `api`, or another area that matches the change.
- Subject in lowercase imperative, no trailing period, under 72 characters.
- Add a short body only when the why is not obvious from the subject.

Example: `WH-2 feat(api): add capacity check to session registration`

Show the message and ask the user to confirm or edit it. Do not commit until they confirm.

## 5. Commit

Run `git commit -m "<message>"` (add a second `-m` for the body).

- Never use `--no-verify`, `--amend`, or `-c core.hooksPath=...`. Hooks must run.
- If the pre-commit hook fails (branch name check or REASONS lint), show the error, explain the fix, and stop. Do not retry by bypassing the hook.

## 6. Stop

Show `git log --oneline -1` and stop. Do not run `git push`. If the user wants to push, they must ask separately.
