# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

WorkshopHub is an internal training-session registration app and the baseline repo for a 3-day AI-assisted delivery training. It is a pnpm monorepo with `api/` (Express + Prisma + SQLite) and `app/` (React 18 + Vite). Team norms and project context also live in `Agent.md`.

## Commands

The `Makefile` is the stable interface. Run everything from the repo root.

```bash
make setup         # pnpm install, copy .env -> api/.env, prisma generate + db push, seed
make dev           # app on :5173 (proxies /api and /health to :3001) + api on :3001
make test          # all Jest tests in api/ (unit + integration)
make test-unit     # unit tests only, no DB needed
make lint          # ESLint for app + api
make format-check  # Prettier check (no semicolons, single quotes, width 100)
make build         # tsc + vite build for app, tsc for api
make reset-db      # prisma db push --force-reset + seed
make smoke-test    # curl checks against a running server (needs `make dev`)
make reasons-lint  # validate spdd/prompt/*.md structure
```

Run a single test (Jest runs inside `api/`):

```bash
cd api && pnpm exec jest tests/unit/trainingSessionService.test.ts
cd api && pnpm exec jest -t "returns 409"        # by test name
```

Only the API has tests. The frontend has lint and format checks only.

## Architecture

**API layering** (`api/src`): `routes/` → `services/` → `lib/prisma.ts`, a shared PrismaClient singleton. Routes do validation and HTTP mapping only. All DB access goes through services (see the Agent.md norms below).

- Services signal expected failures by throwing plain objects shaped `{ status, error }`. Route handlers catch them and send `res.status(err.status).json({ error: err.error })`; anything else becomes a 500. Follow this pattern for new endpoints.
- Registration capacity is enforced in `createRegistration` with a conditional `updateMany` (`registered < capacity`) inside a `$transaction`. The affected-row count decides whether the insert happens. `TrainingSession.registered` is a stored counter, not a count of `Registration` rows, so any write that adds or removes registrations must keep it in sync.
- `app.ts` serves `app/dist` and an SPA fallback when that folder exists. This is how prod runs both app and API on a single port (8080).

**Database**: SQLite through Prisma with `prisma db push`. There are no migration files. `DATABASE_URL` is resolved relative to `api/prisma/schema.prisma`, so `file:../database/workshophub.sqlite` points to `api/database/`. `make setup` copies the root `.env` to `api/.env`. In prod, `docker-entrypoint.sh` runs `db push` on every container start.

**Tests**:
- Unit tests mock `../../src/lib/prisma` with `jest.mock`.
- Integration tests use Supertest against `app` and the **real dev SQLite DB**. They need a seeded DB, and they depend on `prisma/seed.ts`, which creates a purpose-made full session (registered === capacity) for 409 cases.
- Tests clean up after themselves by deleting registrations whose email starts with `test-`. Use that prefix in new integration tests.
- If integration tests fail with DB errors, run `make reset-db`.

**Frontend** (`app/src`): one page (`pages/TrainingSessionsPage.tsx`) that renders `components/TrainingSessionCard.tsx`. API calls use `fetch` with `API_BASE = import.meta.env.VITE_API_URL || ''`. `app/src/types/index.ts` is a hand-maintained copy of the Prisma models with dates as strings. Update it whenever the schema changes.

## Team norms (from Agent.md)

- No TypeScript `any`, including `as any`.
- Routes must not import Prisma directly. Put DB access in a service.
- `make test` and `make lint` must pass. Don't disable rules or skip tests.

## Intentional security seeds

Some vulnerabilities and norm violations are planted on purpose for a later workshop exercise. Examples include the raw-SQL `/search` route, stack traces in the global error handler, and the unauthenticated `routes/admin.ts`, which also uses Prisma directly. Details are in `docs/trainer-only/security-seeds.md`. Don't fix them as a side effect of other work unless the user asks.

## Git workflow and hooks

- Husky `pre-commit` runs `scripts/branch-name-check.sh`, which requires branch names matching `^wh-<x>-<y>$`, e.g. `wh-2-session-registration`. It also runs `scripts/reasons-lint.sh`. Commits on `main` or on badly named branches fail.
- `hooks/pre-push` runs test, lint, format-check and Trivy when it is installed.
- `opencode.json` denies pushing to `main`. Work on feature branches.
- CI (`.github/workflows/pr-check.yml`) runs on PRs to main. It runs test, lint and format-check against a freshly seeded `workshophub-ci.sqlite`.

## Spec-driven (SPDD) workflow

Features go from Trello card to story to analysis to structured prompt to code:

- `stories/`: story files named `wh-<card>-<slug>.md`.
- `spdd/analysis/`: analysis documents.
- `spdd/prompt/`: REASONS-Canvas prompts. Each needs the sections `## Requirements`, `## Entities`, `## Approach`, `## Structure`, `## Operations`, `## Norms` and `## Safeguards`, exactly and in that order. `## Entities` must contain a mermaid diagram. No TODO, PLACEHOLDER or [TBD] markers, and no `## Business Context` section. `make reasons-lint` enforces these rules.

The step-by-step command definitions are in `.opencode/commands/` (kickoff, spdd-analysis, spdd-reasons-canvas, spdd-generate, spdd-sync, finish-dev). They are written for OpenCode, but they describe the intended process. When a prompt file exists for a feature, keep the code and the prompt in sync.

## MCP Permissions

<!-- Keep in sync with Agent.md. Servers are defined in .mcp.json. -->

Permitted servers: `trello` and `GitLab`.

- **Allowed without asking (read-only):**
  - Trello: `trelloRead*` tools and `trelloSearch`.
  - GitLab: `get_*`, `list_*`, `search`, `search_labels` and `semantic_search`.
- **Ask for explicit approval first (writes):**
  - Trello: every `trelloWrite*` tool (boards, lists, cards, checklists, inbox, planner).
  - GitLab: `accept_merge_request`, `add_branch`, `add_commit`, `fork_repository`, `link_work_items` and every `save_*` tool (merge requests, reviews, notes, pipelines, projects, work items).
- **Denied:** any other MCP server, and secret access or production writes through any MCP tool.

## AGENT_BOUNDARY

<!-- PLACEHOLDER: define what the agent may/may not change autonomously. Keep in sync with Agent.md. -->

- TODO: allowed paths/actions.

Claude must ask for explicit approval before:

- Any push to `main`.
- Any call to an external API, except the read-only MCP tools listed under MCP Permissions.
- Any migration (`prisma migrate`).
