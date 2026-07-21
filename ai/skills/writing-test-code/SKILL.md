---
name: writing-test-code
description: Spring Boot 2.7 / 3.2, Java 17, JPA 프로젝트에서 상태 기반(classical) 테스트 컨벤션을 따라 JUnit 5 테스트를 작성한다. Spring service·repository·controller의 테스트 코드를 생성·리뷰·수정할 때, 또는 사용자가 테스트 컨벤션·@Nested 구조·CUD 테스트 케이스를 언급할 때 사용한다.
---

# 테스트 코드 컨벤션

Spring Boot 2.7 / 3.2, Java 17, JUnit 5, JPA (Hibernate)에서 상태 기반(classical) 스타일로 테스트를 작성한다. 이 컨벤션은 버전에 무관하며, import 네임스페이스만 다르다(2.7은 `javax.*`, 3.2는 `jakarta.*`).

## 핵심 규칙 (항상 적용)

- 테스트 대상 인스턴스는 `sut`(System Under Test)로 명명한다.
- **상태 / 반환값**을 검증하고, 행위(behavior)는 검증하지 않는다. `Mockito.verify()`를 쓰지 않는다.
- `@MockBean` / `@SpyBean`을 쓰지 않는다. 실제 협력 객체를 사용하고, Stub/Fake는 외부 시스템에만 사용한다.
- `@Nested` + BDD로 구조화하며 **최대 3단계**(Context → Describe → It)로 제한한다.
- 메서드명은 **영문**, `@DisplayName`은 한글로 작성한다.
- **CUD만** 테스트하며, 조회(Read)는 테스트 대상에서 제외한다.
- **하드코딩된 기대값**을 사용하고, 검증(assertion)에 프로덕션 로직을 재사용하지 않는다.
- 테스트 내부에 `if/else` / `switch`를 쓰지 않는다.
- AssertJ를 사용한다. `@Transactional`로 롤백한다.

## 빠른 시작

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

## 참고 문서 (필요할 때 로드)

- **구조 및 네이밍**: 패키지 구성, @Nested 깊이, 네이밍 규칙 → [reference/structure-and-naming.md](reference/structure-and-naming.md)
- **상태 기반(classical) 스타일**: verify/MockBean을 쓰지 않는 이유, 상태 vs 행위 → [reference/classical-style.md](reference/classical-style.md)
- **테스트 범위**: CUD 한정, 연산별 필수 케이스 → [reference/test-scope.md](reference/test-scope.md)
- **검증 및 데이터**: 하드코딩된 기대값, 조건문 금지, 팩토리 메서드, 롤백 → [reference/assertions-and-data.md](reference/assertions-and-data.md)
- **외부 의존성**: Stub/Fake, 시간·랜덤값 주입 → [reference/external-dependencies.md](reference/external-dependencies.md)
- **레이어별 애노테이션**: unit / integration / e2e 설정 → [reference/layer-annotations.md](reference/layer-annotations.md)

## 안티패턴 체크리스트

- [ ] `verify()` 사용 → 제거하고 상태 검증(assertion)으로 대체한다.
- [ ] `@MockBean` / `@SpyBean` 사용 → 제거하고 실제 객체 또는 Stub/Fake로 대체한다.
- [ ] 검증부에 프로덕션 로직 복사 → 하드코딩된 기대값으로 대체한다.
- [ ] 테스트 내부 `if/else` → 별도 테스트로 분리한다.
- [ ] `@Nested` 3단계 초과 → 평탄화한다.
- [ ] 메서드명 한글 → 메서드명은 영문, `@DisplayName`은 한글로 한다.
- [ ] 조회(Read) 테스트 → 제거한다(CUD만 대상).
