# 아키텍처

레이어: presentation → application → domain / infrastructure (레이어드 + 클린 아키텍처 부분 적용).

## 핵심 규칙 (일반 컨벤션과 다른 점)

- **`application`은 `infrastructure`를 직접 의존한다.** 도메인 인터페이스 + 인프라 구현(DIP)을 통한 간접화를 두지 않는다. Repository, ApiClient, Processor, Cache, Mapper 구현체를 `application`에 직접 주입한다.
- **Processor, Cache, Mapper는 공통 로직 / 변환을 담당하지만 `infrastructure` 레이어에 위치한다.** (`application`이 인프라를 직접 의존하므로 주입에 문제가 없다.)

## 레이어별 컴포넌트

| 레이어 | 컴포넌트 |
|---|---|
| presentation | Controller, Request/Response DTO |
| application | Master Service, Slave Service |
| domain | JPA Entity, Result DTO, Data DTO |
| infrastructure | Repository, ApiClient, Processor, Cache, Mapper |

## 서비스 구조

- **Master Service**: 유즈케이스 흐름을 제어하며, 여러 Slave Service를 조합한다.
- **Slave Service**: 단일 도메인의 CRUD 및 단순 로직을 담당한다.
- 둘 다 `application` 레이어에 위치한다.

## Processor / Cache

- **Processor**: 여러 유즈케이스에서 공통으로 쓰이는 순수 로직(조회, 집계 등)을 담당한다. 타입 간 변환은 Mapper의 역할이다.
- **Cache**:
  - 선언적 캐시(`@Cacheable` 등)가 가능한 경우 → Cache가 Processor 역할을 흡수한다.
  - 선언적 캐시가 불가능한 경우 → 순수 로직은 Processor에 두고, Cache는 히트/미스 판단과 로딩만 담당한다. 미스 시 Processor에 위임한 뒤 결과를 캐시에 저장하고, 병합한 결과를 반환한다.

## Mapper

- **DTO 변환은 Mapper의 책임이다.** Entity ↔ DTO, DTO ↔ DTO 변환을 담당한다.
- `infrastructure` 레이어에 위치한다.

## 패키지 구조

```
├── presentation
│   ├── controller
│   └── dto
│       ├── request
│       └── response
├── application
│   └── service          # Master Service, Slave Service
├── domain
│   ├── entity
│   └── dto
│       ├── result       # slave service → master service return
│       └── data         # infrastructure → application return
└── infrastructure
    ├── repository
    ├── client
    ├── querydsl
    ├── processor        # shared pure logic
    ├── cache
    └── mapper           # DTO/entity conversion
```


## 엔티티 전략

- **JPA 엔티티를 직접 사용한다.** 별도의 POJO 도메인 엔티티로 분리하지 않는다.
- 예외: 여러 도메인을 오케스트레이션하는 경우 전용 POJO 클래스를 만든다.
- **하나의 도메인 개념은 단일 Entity로 관리한다.** 같은 도메인 엔티티를 유즈케이스별로 분리하지 않는다.
