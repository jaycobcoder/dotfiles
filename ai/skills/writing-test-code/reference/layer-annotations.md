# 레이어별 애노테이션

| 레이어 | 애노테이션 | 비고 |
|--------|-----------|------|
| unit | 없음 (순수 JUnit) | Spring Context 불필요 |
| integration | `@SpringBootTest` + `@Transactional` | Service + Repository 연동 |
| e2e | `@SpringBootTest(webEnvironment = RANDOM_PORT)` + `@Transactional` | TestRestTemplate 또는 MockMvc |
