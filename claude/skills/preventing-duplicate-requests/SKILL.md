---
name: preventing-duplicate-requests
description: Guards against duplicate ("따닥") concurrent requests using an in-memory per-key lock combined with a transaction and idempotent constraint handling. Use when writing or reviewing a Service that must process a request once per key (user/resource) under concurrent submission, especially for unlock/grant/issue-once operations on a single-instance (non-MSA) deployment.
---

# Preventing Duplicate Requests

A structural pattern for processing near-simultaneous duplicate requests ("따닥") that arrive under the same key (usually `userId`) exactly once.

## Preconditions

- **Single-instance operation.** During deployment two instances briefly run, but afterward operation is a single instance. This is not MSA.
- Because of this precondition, a **JVM in-memory lock** is sufficient — no distributed lock (Redis, etc.) is needed.
- The in-memory lock cannot cover the brief multi-instance window during deployment, so a **DB unique constraint + idempotent exception handling** is the final safety net. These two layers must always go together.

## Core structure (4 steps)

1. **Acquire a per-key in-memory lock** — obtain a per-key lock from `ConcurrentHashMap<Key, ReentrantLock>` and `lock()`. Only requests with the same key are serialized; other keys are not blocked.
2. **Run the transaction inside the lock** — open an explicit transaction with `TransactionTemplate`, then decide state and branch inside it.
3. **Handle unique-constraint violation idempotently** — if a concurrent request that bypassed the in-memory lock (during the deployment window, etc.) saved the record first, `DataIntegrityViolationException` is thrown. Catch it, **treat it as already processed**, and return the normal (accessible) result.
4. **Unlock in `finally`** — always `unlock()`, regardless of exceptions.

## Skeleton template

```java
@Service
@RequiredArgsConstructor
public class SomeRequestService {

    private static final Map<UUID, ReentrantLock> KEY_LOCKS = new ConcurrentHashMap<>();

    private final SomeCommandRepository commandRepository;
    private final SomeProcessor processor;
    private final TransactionTemplate transactionTemplate;

    public SomeResult request(final UUID key, /* ...inputs */) {
        ReentrantLock lock = KEY_LOCKS.computeIfAbsent(key, k -> new ReentrantLock());
        lock.lock();
        try {
            return transactionTemplate.execute(status -> {
                var resolved = processor.resolve(key /* , ...inputs */);
                return switch (resolved.status()) {
                    case ALREADY_DONE, BLOCKED -> resolved;          // already processed / blocked state
                    case PROCESSABLE -> {                            // write only on first processing
                        commandRepository.save(/* idempotency record */);
                        yield SomeResult.ofProcessed(/* ... */);
                    }
                };
            });
        } catch (DataIntegrityViolationException e) {
            // a concurrent request saved the record first → treat as effectively processed
            return SomeResult.ofProcessed();
        } finally {
            lock.unlock();
        }
    }
}
```

## Required rules

- Set the lock key to the **minimum unit that must be serialized** (no global lock, usually `userId`).
- Keep the lock `static` so it is shared across the whole instance.
- The write-target table must have a **unique constraint** that guarantees idempotency (the precondition for step 3).
- Put the transaction **inside** the lock (lock → transaction order). Reversing the order breaks serialization.
- `try` immediately after `lock()`; release only in `finally`.

## Limitations

- If lock keys grow without bound, the `KEY_LOCKS` map accumulates like a leak. If the key domain has a realistic ceiling (like `userId`), leaving it is fine (one `ReentrantLock` is tiny); but for endlessly new keys (one-time tokens, request IDs) a cleanup strategy (expiring cache, etc.) is needed. A plain `remove` creates a race condition, so be careful.
- If you truly move to multiple instances (MSA / scale-out), this pattern is void. Replace it with a distributed lock.

## Anti-pattern checklist

- [ ] **Single global lock** → split per key (`computeIfAbsent`). Other keys must not be serialized.
- [ ] **Transaction outside the lock** → use lock → transaction order.
- [ ] **Trusting only the in-memory lock without a unique constraint** → cannot block multi-instance during deployment. Pair a DB unique constraint + idempotent handling.
- [ ] **`unlock()` outside `finally`** → the lock is not released on exception.
- [ ] **Calling `lock.lock()` inside `try`** → call `lock()` just before `try`.
- [ ] **Treating `DataIntegrityViolationException` as a failure** → it means "already processed", so return an idempotent normal result.
- [ ] **Using this pattern in a distributed environment** → replace with a distributed lock.
