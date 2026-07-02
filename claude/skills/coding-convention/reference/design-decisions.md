# Design Decisions

Records mistakes from previous projects and the rationale behind current design judgments. This is the *why* behind the rules — read it to understand the intent, not to apply new rules.

## 1. Followed the dependency direction too strictly

**Problem**: Applied "domain holds only interfaces, infrastructure implements them" everywhere. Forcing `application` to depend only on `domain` produced excessive indirection.

**Current judgment**: `application` depends on `infrastructure` directly. Interface–implementation separation is applied only where a replacement is genuinely likely.

→ See [architecture.md](architecture.md) > Core rules.

## 2. Split the same domain entity per use case

**Problem**: Split "the farm of a farm record" and "the farm of an 079 schedule" into separate classes. The same domain concept scattered across multiple classes, so every change had to touch all the split copies. The worst mistake.

**Current judgment**: One domain concept is managed as a single JPA Entity. Per-use-case splitting is forbidden.

→ See [architecture.md](architecture.md) > Entity strategy.

## 3. Applied MSA when layered was enough

**Problem**: Introduced MSA on a 1–3 person team, bloating the project. Inter-service communication, deployment pipelines, and data consistency — the incidental complexity grew larger than the core business logic.

**Current judgment**: Keep a monolithic layered architecture. Consider splitting services only with clear justification (team growth, independent deployment needs).

## 4. Event-driven made flow untraceable

**Problem**: Event publish → event publish → handling produced 3 levels of depth. Dependency management got easier, but tracing the logic flow became practically impossible. Debugging and incident response became extremely hard.

**Current judgment**: Event-driven development is forbidden. All logic flow is called explicitly from the Master Service so that reading the code reveals the whole flow.

→ See [architecture.md](architecture.md) > Service structure.
