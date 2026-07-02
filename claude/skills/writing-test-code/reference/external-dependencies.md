# External Dependencies

| Dependency type | Handling |
|-----------------|----------|
| Repository (JPA) | Real object (`@Autowired`) |
| External API / message queue | Hand-written Stub or Fake object |
| Time (`LocalDateTime.now()`) | Inject as parameter or use `Clock` |
| Random values | Inject as parameter or fix the seed |

## Stub example — external payment API

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

The Fake captures state (`lastPayment`) so the test can assert on the final state rather than verifying calls — consistent with the classical style.
