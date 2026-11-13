---
description: Kick off a Trello story - read card, move to In Progress (or comment), save story, create branch
argument-hint: <card key or URL, e.g. WH-2>
allowed-tools: AskUserQuestion, Bash, mcp__trello__trelloSearch, mcp__trello__trelloReadCard, mcp__trello__trelloReadBoard
---

Kick off Trello card `$ARGUMENTS` for WorkshopHub.

If no card key or URL is given, use `AskUserQuestion` to ask for it and stop until answered.

## 1. Read the card

- If `$ARGUMENTS` is a Trello URL, use `mcp__trello__trelloReadCard` (`get`) with it.
- Otherwise use `mcp__trello__trelloSearch` (`search_cards`, query `$ARGUMENTS`) to find the card. If several cards match, use `AskUserQuestion` to pick one. Then `get` it with `mcp__trello__trelloReadCard`.
- Show the user: key, title, current list (status), description and acceptance criteria.

## 2. Move to In Progress, or comment

- Use `mcp__trello__trelloReadBoard` (`get`) on the card's board to find the `In Progress` list ARI.
- If the card is not in `In Progress`, move it with `mcp__trello__trelloWriteCard` (`move`, `cardId` = card ARI, `listId` = In Progress list ARI).
- If it is already in `In Progress`, do not move it. Leave a comment instead with `mcp__trello__trelloWriteCard` (`add_comment`), e.g. `Kickoff attempted again on <YYYY-MM-DD>; card was already In Progress.`
- Make no other changes to the card.

## 3. Clarify

- Use `AskUserQuestion` for anything ambiguous (scope, acceptance criteria, approach) before creating files or a branch. Do not assume.

## 4. Save the story

- Slug: `wh-{id}-{desc}`, where `{id}` is the number from the key (`WH-2` → `2`) and `{desc}` is the title lowercased and hyphenated (e.g. `wh-2-session-registration`).
- Write `./stories/wh-{id}-{desc}.md` (create `./stories` if missing) with: key, title, list/status, card ARI and URL, board, labels, branch name, description, acceptance criteria, and clarifications/notes from step 3.

## 5. Create the branch and stop

```sh
git checkout -b wh-{id}-{desc}
git branch --show-current
```

- The name must match `^wh-<x>-<y>$` (enforced by `scripts/branch-name-check.sh`).
- Show the branch name to the user to confirm it.
- Stop. Do not implement, commit or push.
