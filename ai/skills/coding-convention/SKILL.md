---
name: coding-convention
description: 이 프로젝트의 백엔드 코딩 컨벤션 — 클래스/DTO 네이밍 규칙, 레이어 아키텍처, 코드 품질(복잡도, 추출, Javadoc). 백엔드 코드(Java/Spring)를 작성하거나 리뷰할 때, 클래스(Controller, Service, Repository, Processor, Cache, ApiClient, Mapper)나 DTO를 네이밍할 때, 컴포넌트가 어느 레이어에 속하는지 결정할 때, 복잡도와 추출을 판단할 때 사용한다.
---

# 코딩 컨벤션

이 프로젝트의 백엔드 코딩 컨벤션이다. 코드를 작성하거나 리뷰할 때 아래 참고 문서를 따른다.

## 핵심 규칙 (항상 적용)

- 변수, 메서드, 클래스 이름에서 **약어를 쓰지 않는다** (`id`, `url`, `http`, `dto`, `api` 등 널리 통용되는 약어는 허용한다).
- **`application`은 `infrastructure`를 직접 의존한다.** 도메인 인터페이스 + 인프라 구현으로 간접화(DIP)하지 않는다. 구현체(Repository, ApiClient, Processor, Cache, Mapper)를 `application`에 직접 주입한다.
- 레이어: `presentation` → `application` → `domain` / `infrastructure`.
- 암묵적 동작(이벤트, AOP 남용)보다 명시적 메서드 호출을 선호한다.

## 클래스 네이밍 (Bean 접미사)

| 접미사 | 네이밍 | 레이어 |
|---|---|---|
| Controller | `{domain}Controller` | presentation |
| Service | `{useCase}Service` (동사 + 대상 + Service) | application |
| Repository | `{domain}Repository` | infrastructure |
| Processor | `{domain}Processor` | infrastructure |
| Cache | `{domain}Cache` | infrastructure |
| ApiClient | `{domain}ApiClient` | infrastructure |
| Mapper | `{domain}Mapper` | infrastructure |

DTO 접미사: `Request`/`Response` (presentation), `Data` (infra → application 반환), `Result` (slave service → master service 반환).

## 참고 문서 (필요 시 로드)

- **네이밍 규칙** — 클래스/DTO 접미사, Service 동사 컨벤션: [reference/naming-rules.md](reference/naming-rules.md)
- **아키텍처** — 레이어 구조, 컴포넌트 배치, Master/Slave Service, Processor/Cache/Mapper: [reference/architecture.md](reference/architecture.md)
- **코드 품질** — 순환 복잡도, 추출 기준, Javadoc 규칙: [reference/code-quality.md](reference/code-quality.md)
- **설계 결정** — 레거시 교훈과 이 규칙들의 근거: [reference/design-decisions.md](reference/design-decisions.md)
