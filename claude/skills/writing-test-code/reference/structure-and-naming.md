# Structure & Naming

## Package layout

```
src/test/java/{basePackage}/{domain}/
├── e2e/          # Full system flow (Controller → DB)
├── integration/  # Service + Repository integration
└── unit/         # Pure domain logic, no external dependencies
```

Split `e2e`, `integration`, `unit` packages per domain. The test target instance is always named `sut`.

## @Nested depth: max 3 levels

```
Context (outermost) → method / feature group being tested
  └─ Describe        → scenario condition group
       └─ It         → individual test case
```

## Naming rules

| Element | Language | Example |
|---------|----------|---------|
| Class (Context) | Korean `@DisplayName` | `@DisplayName("사용자 생성")` |
| Method name | **English** | `success()`, `failWhenDuplicateEmail()` |
| `@DisplayName` | Korean | `@DisplayName("유효한 입력으로 사용자를 생성한다")` |

## Full structure template

```java
@SpringBootTest
@Transactional
class UserServiceTest {

    @Autowired private UserService sut;
    @Autowired private UserRepository userRepository;

    @Nested
    @DisplayName("사용자 생성")                    // Context
    class CreateUser {

        @Nested
        @DisplayName("유효한 입력이 주어지면")       // Describe
        class WithValidInput {

            private CreateUserRequest request;

            @BeforeEach
            void setUp() {
                request = new CreateUserRequest("test@email.com", "홍길동");
            }

            @Test
            @DisplayName("사용자가 저장된다")        // It
            void success() {
                // Given — prepared in @BeforeEach

                // When
                Long userId = sut.create(request);

                // Then
                User found = userRepository.findById(userId).orElseThrow();
                assertThat(found.getEmail()).isEqualTo("test@email.com");
                assertThat(found.getName()).isEqualTo("홍길동");
            }
        }

        @Nested
        @DisplayName("중복 이메일이 주어지면")       // Describe
        class WithDuplicateEmail {

            @BeforeEach
            void setUp() {
                userRepository.save(new User("dup@email.com", "기존사용자"));
            }

            @Test
            @DisplayName("예외가 발생한다")          // It
            void failWhenDuplicateEmail() {
                CreateUserRequest request = new CreateUserRequest("dup@email.com", "신규");

                assertThatThrownBy(() -> sut.create(request))
                        .isInstanceOf(DuplicateEmailException.class);
            }
        }
    }
}
```
