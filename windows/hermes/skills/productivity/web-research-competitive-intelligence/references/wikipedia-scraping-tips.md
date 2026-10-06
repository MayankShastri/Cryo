# Wikipedia & Public API Fetching Guidelines

When scraping or fetching text from Wikipedia or public API endpoints, follow these best practices to ensure reliable operation without triggering rate limits:

1. **User-Agent Header**: Always specify a descriptive `User-Agent` header in HTTP requests. Without it, Wikipedia and similar services block requests with HTTP 429 ("Too Many Requests") or HTTP 403.
   - Example: `User-Agent: ResearchBot/1.0 (contact@example.com)`

2. **Rate Limiting & Throttle Control**: Insert explicit sleep intervals (e.g., 0.5 to 1.0 seconds) between consecutive API calls.

3. **Local Caching Strategy**:
   - Save fetched content locally (e.g., in a local JSON file or SQLite database).
   - Verify local cached data before executing remote calls to minimize network overhead and avoid repeated rate-limit issues.
