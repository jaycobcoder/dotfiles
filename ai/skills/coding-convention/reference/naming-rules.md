# 네이밍 규칙

## 공통 규칙

- 변수, 메서드, 클래스 이름에서 약어를 쓰지 않는다. 널리 통용되는 약어(`id`, `url`, `http`, `dto`, `api`)는 허용한다.
- 나쁜 예: `farmRec`, `calcEpd`, `smnInfo`, `val`, `btn`
- 좋은 예: `farmRecord`, `calculateEpd`, `semenInfo`, `value`, `button`

## 클래스 네이밍

### Bean 클래스 접미사

| 접미사 | 네이밍 |
|---|---|
| Controller | `{domain}Controller` |
| Service | `{useCase}Service` |
| Repository | `{domain}Repository` |
| Processor | `{domain}Processor` |
| Cache | `{domain}Cache` |
| ApiClient | `{domain}ApiClient` |
| Mapper | `{domain}Mapper` |

#### Service 네이밍

- 클래스 이름은 `{useCase}Service`이며, **동사 + 대상 + Service**를 표현해야 한다.
- 유즈케이스에 따른 동사 컨벤션:
  - 목록 조회: `GetAll`로 시작한다.
  - 단건 조회: `Get`으로 시작한다.
  - 검색(검색 이력 기록 등 추가 로직이 있는 경우): `Search`로 시작한다.
  - 그 외: 자유롭게 정하되, 동사 + 대상이 명확해야 한다.

### DTO 클래스 접미사

접미사는 레이어마다 다르다.

| 접미사 | 레이어 | 용도 |
|---|---|---|
| Request | Presentation | 요청 DTO |
| Response | Presentation | 응답 DTO |
| Data | Domain | infrastructure에서 반환 |
| Result | Domain | slave service가 master service에 반환하는 응답 객체 |
