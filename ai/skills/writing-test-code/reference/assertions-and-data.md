# 검증 및 데이터

## 하드코딩된 기대값

```java
// GOOD — expectation is explicit
assertThat(result.getAmount()).isEqualTo(1000L);

// BAD — reuses production logic in the test (meaningless verification)
long expected = price * quantity;
assertThat(result.getAmount()).isEqualTo(expected);
```

## 조건문 금지

- 테스트 코드 내부에 `if/else`나 `switch`를 쓰지 않는다.
- 조건별 케이스는 별도의 `@Test` 메서드 또는 `@ParameterizedTest`로 분리한다.

## AssertJ

```java
assertThat(actual).isEqualTo(expected);
assertThat(list).hasSize(3);
assertThatThrownBy(() -> sut.execute())
        .isInstanceOf(IllegalStateException.class)
        .hasMessage("expected message");
```

## 데이터 격리 및 롤백

```java
@SpringBootTest
@Transactional   // auto rollback after each test (works against a real DB too)
class SomeServiceTest { ... }
```

- 인메모리 DB(H2)를 사용하지 않고 `@Transactional` 롤백에 의존한다.
- 테스트 데이터는 `@BeforeEach`에서 초기화한다.
- 테스트 간 데이터 간섭이 없어야 한다(멱등성 보장).

## 테스트 데이터 생성

### 팩토리 메서드 패턴

```java
private User createUser(String email, String name) {
    return new User(email, name);
}

private CreateUserRequest createRequest() {
    return new CreateUserRequest("test@email.com", "홍길동");
}
```

- 중복되는 생성 로직은 `private` 헬퍼 메서드로 추출한다.
- 헬퍼 메서드 내부에 조건문을 넣지 않는다.

### @BeforeEach

- 공통 테스트 데이터는 `@Nested` 클래스 내부의 `@BeforeEach`에서 준비한다.
- Given 섹션이 비어 있더라도 주석을 남긴다: `// Given — prepared in @BeforeEach`.
