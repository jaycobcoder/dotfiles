# Classical (State-Based) Style

| Principle | Description |
|-----------|-------------|
| **State verification** | No behavior (`verify`) checks. Assert final state / return value. |
| **Real objects first** | Use real collaborators where possible. Mock/Spy only to isolate external systems (API, message queue). |
| **No @MockBean / @SpyBean** | Prevents Spring Context pollution and surfaces design smells. |
| **No Mockito verify()** | Verifying internal implementation reduces refactoring resilience. |

## Why not verify()

```java
// BAD — verifies internal implementation (breaks when implementation changes)
verify(repository).update(any());

// GOOD — verifies final state (safe across implementation changes)
Order result = repository.findById(id);
assertThat(result.getAmount()).isEqualTo(expected);
```

Behavior verification couples the test to *how* code works rather than *what* it produces. State verification stays valid as long as the observable outcome is correct, so refactors don't trigger false failures.
