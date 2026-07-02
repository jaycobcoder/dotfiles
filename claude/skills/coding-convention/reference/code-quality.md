# Code Quality

## Readability

- Code is read far more often than it is written. Readability comes first.
- Reading the Master Service alone should reveal the entire use-case flow.
- Prefer direct method calls over implicit behavior (events, AOP overuse).

## Complexity

- Cyclomatic complexity **9 or below** is recommended.
- Avoid exceeding 9 where possible; tolerate it only when unavoidable.
- Introducing excessive abstraction just to lower complexity is counterproductive.

## Extraction threshold for shared logic

- When a private method is used in **3 or more places**, extract it into a shared component (Processor, etc.).
- When used in 2 places or fewer, keep it as a private method within each class.

## Javadoc rules

1. **Write in ubiquitous language.** Use terms that domain experts and developers understand identically.
2. **Keep interface Javadoc abstract.** Do not describe implementation details.
3. **Do not write closing HTML tags (`</>`).** Use only opening tags such as `<p>`, `<li>`.

### Good Javadoc example

```java
/**
 * 정액의 등지방두께에 따른 등급을 평가한다.
 * <p> 등지방두께는 값이 작을수록 좋다. 따라서 다른 Epd Value와는 달리, 등지방두께는 Epd Standard와 비교하는 조건식이 반대로 적용된다.
 *
 * @param backfat 정액의 등지방두께;
 * @return 등지방두께에 따른 등급;
 */
```

Why this is good:
- Uses domain terms (정액, 등지방두께, Epd) directly, so a domain expert can read it.
- Explains the intent **and why it behaves differently**.
- Uses `<p>` with no closing tag.
