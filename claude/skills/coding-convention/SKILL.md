---
name: coding-convention
description: Backend coding conventions for this project — class/DTO naming rules, layer architecture, code quality (complexity, extraction, Javadoc). Use when writing or reviewing backend code (Java/Spring), naming classes (Controller, Service, Repository, Processor, Cache, ApiClient, Mapper) or DTOs, deciding which layer a component belongs in, or judging complexity and extraction.
---

# Coding Convention

Backend coding conventions for this project. Follow the references below when writing or reviewing code.

## Core rules (always apply)

- **No abbreviations** in variable, method, or class names (well-known acronyms like `id`, `url`, `http`, `dto`, `api` are allowed).
- **`application` depends on `infrastructure` directly.** No domain-interface + infra-implementation indirection (DIP). Inject implementations (Repository, ApiClient, Processor, Cache, Mapper) into `application` directly.
- Layers: `presentation` → `application` → `domain` / `infrastructure`.
- Prefer explicit method calls over implicit behavior (events, AOP overuse).

## Class naming (Bean suffixes)

| Suffix | Naming | Layer |
|---|---|---|
| Controller | `{domain}Controller` | presentation |
| Service | `{useCase}Service` (verb + subject + Service) | application |
| Repository | `{domain}Repository` | infrastructure |
| Processor | `{domain}Processor` | infrastructure |
| Cache | `{domain}Cache` | infrastructure |
| ApiClient | `{domain}ApiClient` | infrastructure |
| Mapper | `{domain}Mapper` | infrastructure |

DTO suffixes: `Request`/`Response` (presentation), `Data` (infra → application return), `Result` (slave service → master service return).

## Reference (load as needed)

- **Naming rules** — class/DTO suffixes, Service verb conventions: [reference/naming-rules.md](reference/naming-rules.md)
- **Architecture** — layer structure, component placement, Master/Slave Service, Processor/Cache/Mapper: [reference/architecture.md](reference/architecture.md)
- **Code quality** — cyclomatic complexity, extraction threshold, Javadoc rules: [reference/code-quality.md](reference/code-quality.md)
- **Design decisions** — legacy lessons and the rationale behind these rules: [reference/design-decisions.md](reference/design-decisions.md)
