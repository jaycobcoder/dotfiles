# Layer Annotations

| Layer | Annotations | Notes |
|-------|-------------|-------|
| unit | none (plain JUnit) | No Spring Context |
| integration | `@SpringBootTest` + `@Transactional` | Service + Repository |
| e2e | `@SpringBootTest(webEnvironment = RANDOM_PORT)` + `@Transactional` | TestRestTemplate or MockMvc |
