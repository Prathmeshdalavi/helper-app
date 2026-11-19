# Shared resources

Language-neutral contracts that the backend, mobile app and admin web must agree
on. Code lives in each app; these files are the reference they are kept in sync with.

- `contracts/` JSON: roles, booking statuses, error codes.
- `env/variables.md` every environment variable, who reads it, where it is set.

When you change a contract, update the backend enum, the Flutter enum and the
admin TypeScript type in the same pull request.
