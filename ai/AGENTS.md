## 프로젝트 개요

- 주력 스택: Java 17 + Spring Boot, MariaDB 10.11.2
- Spring Boot 버전: `restful_api`, `restful_api_admin`은 **2.7 (javax.*)**, 그 외 모든 프로젝트는 **3.2 (jakarta.*)**
- 백엔드 팀 규모: 1~3명
- 실용성 최우선. 지나친 추상화와 과도한 아키텍처 패턴 적용을 금지한다.
- 레이어드 아키텍처 + 클린 아키텍처 부분 적용

---

## 핵심 금지 사항

1. **지나친 추상화 금지** — 인터페이스-구현 분리 패턴 남용 금지.
   구현체가 하나뿐이면 인터페이스를 만들지 않는다.
2. **이벤트 기반 개발 금지** — 모든 흐름은 명시적 호출로 추적 가능해야 한다.
   비동기가 필요하면 이벤트 대신 명시적 서비스 호출을 우선한다.
   (도메인 이벤트/메시지 큐는 외부 연동 등 꼭 필요한 경우 팀 합의 후에만)
3. **도메인 엔티티 중복 분리 금지** — 같은 개념은 하나의 엔티티로 관리
4. **불필요한 MSA 금지** — 모놀리식으로 충분하면 모놀리식을 유지
5. **약어 금지** — 변수명, 메서드명, 클래스명에서 단어를 축약하지 않는다.
   단, id·url·http·dto·api 등 널리 통용되는 약어는 허용한다.
6. **커밋 시 Co-Authored-By 금지** — 커밋 메시지에 Co-Authored-By를 남기지 않는다.

---

## 문서 맵

지식 원본은 `skills/` 한 곳에서만 관리한다. Claude는 이 스킬들을 자동으로 로드하고,
그 외 도구(Codex·opencode 등)는 아래 링크를 참고한다. 각 `SKILL.md`는 요약이며,
세부 내용은 그 안의 `reference/` 링크에 있다.

| 스킬 | 설명 |
|---|---|
| [skills/coding-convention/SKILL.md](skills/coding-convention/SKILL.md) | 백엔드 코딩 컨벤션 — 클래스/DTO 네이밍, 레이어 아키텍처, 복잡도·분리·Javadoc 등 코드 품질 |
| [skills/writing-test-code/SKILL.md](skills/writing-test-code/SKILL.md) | 테스트 코드 작성 컨벤션 — JUnit 5, 상태 기반(classical) 스타일, `@Nested` 구조, CUD 테스트 |
| [skills/preventing-duplicate-requests/SKILL.md](skills/preventing-duplicate-requests/SKILL.md) | 동시 중복 요청("따닥") 방지 — 인메모리 키 락 + 트랜잭션 + 멱등 제약 처리 |
