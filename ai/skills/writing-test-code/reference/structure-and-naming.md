# 구조 및 네이밍

## 패키지 구조

```
src/test/java/{basePackage}/{domain}/
├── e2e/          # 전체 시스템 흐름 (Controller → DB)
├── integration/  # Service + Repository 통합 검증
└── unit/         # 순수 도메인 로직, 외부 의존성 없음
```

도메인 단위로 `e2e`, `integration`, `unit` 패키지를 분리한다. 테스트 대상 인스턴스는 항상 `sut`로 명명한다.

## @Nested 깊이: 최대 3단계

```
Context (최외곽)  → 테스트 대상 메서드 / 기능 그룹
  └─ Describe     → 시나리오 조건 그룹
       └─ It      → 개별 테스트 케이스
```

## 네이밍 규칙

| 요소 | 언어 | 예시 |
|------|------|------|
| 클래스 (Context) | 한글 `@DisplayName` | `@DisplayName("사용자 생성")` |
| 메서드명 | **영문** | `success()`, `failWhenDuplicateEmail()` |
| `@DisplayName` | 한글 | `@DisplayName("유효한 입력으로 사용자를 생성한다")` |

## 전체 구조 템플릿

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
