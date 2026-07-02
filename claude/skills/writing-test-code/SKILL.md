---
name: writing-test-code
description: Writes JUnit 5 tests for Spring Boot 2.7 / 3.2, Java 17, JPA projects following a classical (state-based) testing convention. Use when generating, reviewing, or fixing test code for Spring services, repositories, or controllers, or when the user mentions test conventions, @Nested structure, or CUD test cases.
---

# Test Code Convention

Classical-style test authoring for Spring Boot 2.7 / 3.2, Java 17, JUnit 5, JPA (Hibernate). The convention is version-agnostic; only import namespaces differ (`javax.*` on 2.7, `jakarta.*` on 3.2).

## Core rules (always apply)

- Name the test target instance `sut` (System Under Test).
- Verify **state / return values**, never behavior. No `Mockito.verify()`.
- No `@MockBean` / `@SpyBean`. Use real collaborators; Stub/Fake only for external systems.
- Structure with `@Nested` + BDD, **max 3 levels** (Context → Describe → It).
- Method names in **English**; `@DisplayName` in Korean.
- Test **CUD only** — exclude Read (queries).
- Use **hardcoded expected values**; never reuse production logic in assertions.
- No `if/else` / `switch` inside tests.
- Use AssertJ. Roll back with `@Transactional`.

## Quick start

```java
@SpringBootTest
@Transactional
class UserServiceTest {

    @Autowired private UserService sut;
    @Autowired private UserRepository userRepository;

    @Nested
    @DisplayName("사용자 생성")              // Context
    class CreateUser {

        @Nested
        @DisplayName("유효한 입력이 주어지면")  // Describe
        class WithValidInput {

            @Test
            @DisplayName("사용자가 저장된다")    // It
            void success() {
                // Given
                CreateUserRequest request = new CreateUserRequest("test@email.com", "홍길동");
                // When
                Long userId = sut.create(request);
                // Then
                User found = userRepository.findById(userId).orElseThrow();
                assertThat(found.getEmail()).isEqualTo("test@email.com");
            }
        }
    }
}
```

## Reference (load as needed)

- **Structure & naming**: package layout, @Nested depth, naming rules → [reference/structure-and-naming.md](reference/structure-and-naming.md)
- **Classical style**: why no verify/MockBean, state vs behavior → [reference/classical-style.md](reference/classical-style.md)
- **Test scope**: CUD-only, required cases per operation → [reference/test-scope.md](reference/test-scope.md)
- **Assertions & data**: hardcoded values, no conditionals, factory methods, rollback → [reference/assertions-and-data.md](reference/assertions-and-data.md)
- **External dependencies**: Stub/Fake, time & randomness injection → [reference/external-dependencies.md](reference/external-dependencies.md)
- **Layer annotations**: unit / integration / e2e setup → [reference/layer-annotations.md](reference/layer-annotations.md)

## Anti-pattern checklist

- [ ] `verify()` used → remove, replace with state assertion.
- [ ] `@MockBean` / `@SpyBean` used → remove, use real object or Stub/Fake.
- [ ] Production logic copied into assertions → replace with hardcoded expected value.
- [ ] `if/else` inside a test → split into separate tests.
- [ ] `@Nested` deeper than 3 levels → flatten.
- [ ] Korean method name → method names English, `@DisplayName` Korean.
- [ ] Read (query) test → remove (CUD only).
