# Architecture

Layers: presentation → application → domain / infrastructure (layered + partial clean architecture).

## Core rules (differ from common convention)

- **`application` depends on `infrastructure` directly.** No indirection via a domain interface + infra implementation (DIP). Repository, ApiClient, Processor, Cache, Mapper implementations are injected into `application` directly.
- **Processor, Cache, and Mapper hold shared logic / transformation but live in the `infrastructure` layer.** (No problem for injection, since `application` depends on infra directly.)

## Components per layer

| Layer | Components |
|---|---|
| presentation | Controller, Request/Response DTO |
| application | Master Service, Slave Service |
| domain | JPA Entity, Result DTO, Data DTO |
| infrastructure | Repository, ApiClient, Processor, Cache, Mapper |

## Service structure

- **Master Service**: controls the use-case flow, composing multiple Slave Services.
- **Slave Service**: single-domain CRUD and simple logic.
- Both live in the `application` layer.

## Processor / Cache

- **Processor**: pure logic shared across use cases (query, aggregation, etc.). Type-to-type conversion is the Mapper's job.
- **Cache**:
  - Declarative cache (`@Cacheable`, etc.) possible → Cache absorbs the Processor role.
  - Declarative cache not possible → pure logic stays in Processor; Cache only decides hit/miss and loads. On miss, delegate to Processor, then store the result in cache and return the merged result.

## Mapper

- **DTO conversion is the Mapper's responsibility.** It owns Entity ↔ DTO, DTO ↔ DTO conversions.
- Lives in the `infrastructure` layer.

## Package structure

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


## Entity strategy

- **Use JPA entities directly.** Do not split off a separate POJO domain entity.
- Exception: when orchestrating multiple domains, create a dedicated POJO class.
- **One domain concept is managed as a single Entity.** Do not split the same domain entity per use case.
