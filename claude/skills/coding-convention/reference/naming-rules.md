# Naming Rules

## Common rule

- No abbreviations in variable, method, or class names. Well-known acronyms (`id`, `url`, `http`, `dto`, `api`) are allowed.
- Bad: `farmRec`, `calcEpd`, `smnInfo`, `val`, `btn`
- Good: `farmRecord`, `calculateEpd`, `semenInfo`, `value`, `button`

## Class naming

### Bean class suffixes

| Suffix | Naming |
|---|---|
| Controller | `{domain}Controller` |
| Service | `{useCase}Service` |
| Repository | `{domain}Repository` |
| Processor | `{domain}Processor` |
| Cache | `{domain}Cache` |
| ApiClient | `{domain}ApiClient` |
| Mapper | `{domain}Mapper` |

#### Service naming

- Class name is `{useCase}Service`, and must express **verb + subject + Service**.
- Verb conventions for the use case:
  - List query: start with `GetAll`
  - Single query: start with `Get`
  - Search (with extra logic such as recording search history): start with `Search`
  - Otherwise: free choice, but verb + subject must be clear.

### DTO class suffixes

Suffix differs per layer.

| Suffix | Layer | Purpose |
|---|---|---|
| Request | Presentation | request DTO |
| Response | Presentation | response DTO |
| Data | Domain | returned from infrastructure |
| Result | Domain | response object a slave service returns to a master service |
