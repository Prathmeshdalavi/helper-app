# Git workflow (two developers)

- `main` is always deployable; work on short-lived branches:
  `feature/<module>-<what>`, `fix/<what>`, `chore/<what>`.
- Open a pull request for every change; the other developer reviews. CI must pass.
- Conventional commits: `feat(booking): add slot lookup`.
- Split ownership to avoid conflicts, e.g. dev A: `backend/` + `database/`; dev B: `mobile/` + `admin-web/`. Anything in `shared/` or a DB migration needs both to agree.
- Migrations: pull `main` first; if two migrations collide on a version number, the later PR renumbers.
