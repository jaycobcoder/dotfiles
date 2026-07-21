---
name: preventing-duplicate-requests
description: 인메모리 (키 단위) 락과 트랜잭션, 멱등 제약(조건) 처리를 결합해 중복 요청("따닥") 동시 요청을 방어한다. 동시 제출 상황에서 키(사용자/리소스)마다 한 번씩만 요청을 처리해야 하는 Service를 작성하거나 리뷰할 때, 특히 단일 인스턴스(비(非)MSA) 배포 환경의 잠금 해제/지급/1회 발급 연산에 사용한다.
---

# 중복 요청 방지

같은 키(대개 `userId`)로 거의 동시에 도착하는 중복 요청("따닥")을 정확히 한 번만 처리하기 위한 구조적 패턴이다.

## 전제 조건

- **단일 인스턴스 운영.** 배포 중에는 두 인스턴스가 잠시 함께 뜨지만, 이후 운영은 단일 인스턴스다. MSA가 아니다.
- 이 전제 조건 덕분에 **JVM 인메모리 락**으로 충분하다 — 분산 락(Redis 등)은 필요하지 않다.
- 인메모리 락은 배포 중 잠깐 생기는 다중 인스턴스 구간을 커버하지 못하므로, **DB unique constraint + 멱등 예외 처리**가 최종 안전망이다. 이 두 계층은 항상 함께 가야 한다.

## 핵심 구조 (4단계)

1. **키 단위 인메모리 락 획득** — `ConcurrentHashMap<Key, ReentrantLock>`에서 키 단위 락을 얻어 `lock()`한다. 같은 키를 가진 요청만 직렬화되고, 다른 키는 막히지 않는다.
2. **락 안에서 트랜잭션 실행** — `TransactionTemplate`으로 명시적 트랜잭션을 열고, 그 안에서 상태를 판단해 분기한다.
3. **unique constraint 위반을 멱등하게 처리** — 인메모리 락을 우회한 동시 요청(배포 구간 등)이 레코드를 먼저 저장했다면 `DataIntegrityViolationException`이 던져진다. 이를 잡아 **이미 처리된 것으로 간주**하고 정상(접근 가능) 결과를 반환한다.
4. **`finally`에서 잠금 해제** — 예외 여부와 무관하게 항상 `unlock()`한다.

## 스켈레톤 템플릿

```java
@Service
@RequiredArgsConstructor
public class SomeRequestService {

    private static final Map<UUID, ReentrantLock> KEY_LOCKS = new ConcurrentHashMap<>();

    private final SomeCommandRepository commandRepository;
    private final SomeProcessor processor;
    private final TransactionTemplate transactionTemplate;

    public SomeResult request(final UUID key, /* ...inputs */) {
        ReentrantLock lock = KEY_LOCKS.computeIfAbsent(key, k -> new ReentrantLock());
        lock.lock();
        try {
            return transactionTemplate.execute(status -> {
                var resolved = processor.resolve(key /* , ...inputs */);
                return switch (resolved.status()) {
                    case ALREADY_DONE, BLOCKED -> resolved;          // already processed / blocked state
                    case PROCESSABLE -> {                            // write only on first processing
                        commandRepository.save(/* idempotency record */);
                        yield SomeResult.ofProcessed(/* ... */);
                    }
                };
            });
        } catch (DataIntegrityViolationException e) {
            // a concurrent request saved the record first → treat as effectively processed
            return SomeResult.ofProcessed();
        } finally {
            lock.unlock();
        }
    }
}
```

## 필수 규칙

- 락 키는 **직렬화가 반드시 필요한 최소 단위**로 잡는다(전역 락 금지, 보통 `userId`).
- 락은 `static`으로 두어 인스턴스 전체에서 공유되게 한다.
- 쓰기 대상 테이블에는 멱등성을 보장하는 **unique constraint**가 있어야 한다(3단계의 전제).
- 트랜잭션은 락 **안에** 둔다(락 → 트랜잭션 순서). 순서를 뒤집으면 직렬화가 깨진다.
- `lock()` 직후에 `try`를 열고, 해제는 `finally`에서만 한다.

## 한계

- 락 키가 무한정 늘어나면 `KEY_LOCKS` 맵이 누수처럼 쌓인다. 키 도메인에 현실적인 상한이 있다면(`userId` 등) 그냥 두어도 된다(`ReentrantLock` 하나는 매우 작다). 하지만 끝없이 새로 생기는 키(일회성 토큰, 요청 ID)라면 정리 전략(만료 캐시 등)이 필요하다. 단순 `remove`는 경쟁 조건을 만들므로 주의한다.
- 실제로 다중 인스턴스(MSA / 스케일 아웃)로 넘어가면 이 패턴은 무효다. 분산 락으로 교체한다.

## 안티패턴 체크리스트

- [ ] **단일 전역 락** → 키 단위로 분리(`computeIfAbsent`)한다. 다른 키가 직렬화되면 안 된다.
- [ ] **락 밖의 트랜잭션** → 락 → 트랜잭션 순서를 쓴다.
- [ ] **unique constraint 없이 인메모리 락만 신뢰** → 배포 중 다중 인스턴스를 막지 못한다. DB unique constraint + 멱등 처리를 함께 둔다.
- [ ] **`finally` 밖의 `unlock()`** → 예외 시 락이 해제되지 않는다.
- [ ] **`try` 안에서 `lock.lock()` 호출** → `try` 바로 앞에서 `lock()`을 호출한다.
- [ ] **`DataIntegrityViolationException`을 실패로 취급** → "이미 처리됨"을 뜻하므로 멱등한 정상 결과를 반환한다.
- [ ] **분산 환경에서 이 패턴 사용** → 분산 락으로 교체한다.
