# Assertions & Data

## Hardcoded expected values

```java
// GOOD — expectation is explicit
assertThat(result.getAmount()).isEqualTo(1000L);

// BAD — reuses production logic in the test (meaningless verification)
long expected = price * quantity;
assertThat(result.getAmount()).isEqualTo(expected);
```

## No conditionals

- No `if/else` or `switch` inside test code.
- Separate per-condition cases into distinct `@Test` methods or a `@ParameterizedTest`.

## AssertJ

```java
assertThat(actual).isEqualTo(expected);
assertThat(list).hasSize(3);
assertThatThrownBy(() -> sut.execute())
        .isInstanceOf(IllegalStateException.class)
        .hasMessage("expected message");
```

## Data isolation & rollback

```java
@SpringBootTest
@Transactional   // auto rollback after each test (works against a real DB too)
class SomeServiceTest { ... }
```

- No in-memory DB (H2); rely on `@Transactional` rollback.
- Initialize test data in `@BeforeEach`.
- No data interference between tests (idempotency guaranteed).

## Test data creation

### Factory method pattern

```java
private User createUser(String email, String name) {
    return new User(email, name);
}

private CreateUserRequest createRequest() {
    return new CreateUserRequest("test@email.com", "홍길동");
}
```

- Extract duplicated creation logic into `private` helper methods.
- No conditionals inside helper methods.

### @BeforeEach

- Prepare common test data in a `@BeforeEach` inside the `@Nested` class.
- Leave a comment even when the Given section is empty: `// Given — prepared in @BeforeEach`.
