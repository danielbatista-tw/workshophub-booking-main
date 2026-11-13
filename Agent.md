# Agent.md — WorkshopHub

## Project Context

WorkshopHub is an internal training registration system. Employees browse and register for internal training sessions.

- Monorepo managed with pnpm workspaces (`pnpm-workspace.yaml`): `app/`, `api/`
- `api/`: Express + TypeScript backend, Prisma ORM with SQLite (`DATABASE_URL=file:../database/workshophub.sqlite` in dev). Endpoints: `GET /health`, `GET /api/training-sessions`, `GET /api/training-sessions/:id`
- `app/`: React 18 + TypeScript + Vite 5 frontend (dev port 5173, API port 3001, prod 8080)
- Testing: Jest + Supertest (`api/`). Linting: ESLint + Prettier. Git hooks: Husky (pre-push: test + lint). CI: GitHub Actions (`pr-check`, `security`, `build-and-prod`)
- Stable command interface is the `Makefile`: `make setup`, `make dev`, `make test`, `make lint`, `make format-check`, `make build`, `make seed`, `make reset-db`, `make smoke-test`

## Team Norms

1. No `any`: never use TypeScript `any` (including `as any`). Use explicit types, `unknown` with narrowing, or generics.
2. No direct Prisma in routes: Express route handlers must not import or call Prisma directly. Put all DB access in a service/repository layer and keep routes thin (validation, auth, HTTP mapping only).
3. All code must pass `make test` and `make lint`: run both before opening a PR or pushing. Fix failures; do not disable rules or skip tests to get green.

## MCP Permissions

<!-- Keep in sync with CLAUDE.md. Servers are defined in .mcp.json. -->

Permitted servers: `trello` and `GitLab`.

- **Allowed without asking (read-only):**
  - Trello: `trelloRead*` tools and `trelloSearch`.
  - GitLab: `get_*`, `list_*`, `search`, `search_labels` and `semantic_search`.
- **Ask for explicit approval first (writes):**
  - Trello: every `trelloWrite*` tool (boards, lists, cards, checklists, inbox, planner).
  - GitLab: `accept_merge_request`, `add_branch`, `add_commit`, `fork_repository`, `link_work_items` and every `save_*` tool (merge requests, reviews, notes, pipelines, projects, work items).
- **Denied:** any other MCP server, and secret access or production writes through any MCP tool.

## AGENT_BOUNDARY

<!-- PLACEHOLDER: define what the agent may/may not change autonomously. -->

- TODO: allowed paths/actions.
- TODO: actions requiring human approval (e.g. schema resets, prod deploys, secret handling).
