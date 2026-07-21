# 외부 의존성

| 의존성 유형 | 처리 방법 |
|-------------|-----------|
| Repository (JPA) | 실제 객체 사용 (`@Autowired`) |
| 외부 API / 메시지 큐 | 직접 구현한 Stub 또는 Fake 객체 |
| 시간 (`LocalDateTime.now()`) | 파라미터로 주입하거나 `Clock` 사용 |
| 랜덤값 | 파라미터로 주입하거나 시드 고정 |

## Stub 예시 — 외부 결제 API

```java
public class FakePaymentClient implements PaymentClient {
    private Payment lastPayment;

    @Override
    public void pay(Payment payment) {
        this.lastPayment = payment;
    }

    public Payment getLastPayment() {
        return lastPayment;
    }
}
```

Fake는 상태(`lastPayment`)를 저장하므로, 호출을 검증하는 대신 최종 상태를 검증(assert)할 수 있다. 이는 상태 기반(classical) 스타일과 일치한다.
