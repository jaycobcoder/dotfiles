# 상태 기반(classical) 스타일

| 원칙 | 설명 |
|------|------|
| **상태 검증** | 행위(`verify`) 검증을 하지 않는다. 최종 상태 / 반환값을 검증(assert)한다. |
| **실제 객체 우선** | 가능하면 실제 협력 객체를 사용한다. Mock/Spy는 외부 시스템(API, 메시지 큐)을 격리할 때만 사용한다. |
| **@MockBean / @SpyBean 금지** | Spring Context 오염을 방지하고 설계 smell을 드러낸다. |
| **Mockito verify() 금지** | 내부 구현 검증은 리팩토링 내성을 떨어뜨린다. |

## 왜 verify()를 쓰지 않는가

```java
// BAD — verifies internal implementation (breaks when implementation changes)
verify(repository).update(any());

// GOOD — verifies final state (safe across implementation changes)
Order result = repository.findById(id);
assertThat(result.getAmount()).isEqualTo(expected);
```

행위(behavior) 검증은 코드가 *무엇을* 만들어내는지가 아니라 *어떻게* 동작하는지에 테스트를 결합시킨다. 상태 검증은 관찰 가능한 결과가 올바른 한 유효하게 유지되므로, 리팩토링이 거짓 실패를 유발하지 않는다.
