Backend notes and Redis caching

Optional Redis cache
--------------------
This backend ships with a simple in-memory TTL cache by default. To enable a Redis-backed cache (recommended for multi-worker deployments), set the `REDIS_URL` environment variable before starting the server. Example:

Windows (PowerShell):

```powershell
$env:REDIS_URL = 'redis://localhost:6379/0'
uvicorn app.main:app --workers 4 --host 0.0.0.0 --port 8000
```

Linux / macOS:

```bash
export REDIS_URL=redis://localhost:6379/0
uvicorn app.main:app --workers 4 --host 0.0.0.0 --port 8000
```

Notes:
- The code uses `redis-py` when `REDIS_URL` is present. Install it with `pip install redis`.
- The cache keys use the function name and hashed args. Use `invalidate_functions(["fn_name"])` to evict keys for specific cached functions, or `cache_clear()` to clear everything.

Invalidation hooks
------------------
- Endpoints that mutate state (e.g. `/update-twin`, `/generate-plan`) call targeted invalidation (`invalidate_functions(["get_profile","get_dashboard"])`) so clients see fresh data without clearing unrelated caches.

Development
-----------
- For local testing you can run a Redis server with Docker:

```bash
docker run -p 6379:6379 --name redis-local -d redis:7
```

After that, set `REDIS_URL` as above and start the backend.
