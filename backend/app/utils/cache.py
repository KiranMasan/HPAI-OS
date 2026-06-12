import time
import threading
import os
import json
from functools import wraps

_cache = {}
_lock = threading.Lock()
_key_registry = {}  # fn_name -> set(keys)

# Try to use Redis if REDIS_URL is set; fall back to in-memory cache
_redis = None
_redis_prefix = "cache:"
try:
    REDIS_URL = os.environ.get("REDIS_URL")
    if REDIS_URL:
        import redis

        _redis = redis.from_url(REDIS_URL)
except Exception:
    _redis = None


def _make_key(fn_name, args, kwargs):
    try:
        payload = json.dumps([args, kwargs], default=str, sort_keys=True)
    except Exception:
        payload = repr((args, kwargs))
    return f"{_redis_prefix}{fn_name}:{abs(hash(payload))}"


def ttl_cache(ttl: float = 5.0):
    """Decorator that uses Redis when available, otherwise in-memory TTL cache."""

    def decorator(fn):
        @wraps(fn)
        def wrapper(*args, **kwargs):
            key = _make_key(fn.__name__, args, kwargs)
            now = time.time()

            if _redis is not None:
                try:
                    data = _redis.get(key)
                    if data is not None:
                        return json.loads(data)
                except Exception:
                    pass

            with _lock:
                entry = _cache.get(key)
                if entry and entry[0] > now:
                    return entry[1]

            value = fn(*args, **kwargs)

            if _redis is not None:
                try:
                    _redis.setex(key, int(ttl), json.dumps(value, default=str))
                    # track key for this function
                    try:
                        _redis.sadd(f"{_redis_prefix}keys:{fn.__name__}", key)
                    except Exception:
                        pass
                except Exception:
                    pass
            else:
                with _lock:
                    _cache[key] = (now + ttl, value)
                    _key_registry.setdefault(fn.__name__, set()).add(key)

            return value

        return wrapper

    return decorator


def cache_clear():
    """Clear both in-memory cache and Redis keys with the cache prefix (best-effort)."""
    with _lock:
        _cache.clear()

    if _redis is not None:
        try:
            keys = _redis.keys(f"{_redis_prefix}*")
            if keys:
                _redis.delete(*keys)
        except Exception:
            pass


def invalidate_functions(fn_names: list[str]):
    """Invalidate cache keys associated with the given function names."""
    if not fn_names:
        return

    # Redis-backed invalidation
    if _redis is not None:
        for fn in fn_names:
            try:
                redis_keyset = f"{_redis_prefix}keys:{fn}"
                keys = _redis.smembers(redis_keyset) or []
                if keys:
                    _redis.delete(*keys)
                _redis.delete(redis_keyset)
            except Exception:
                pass

    # In-memory invalidation
    with _lock:
        for fn in fn_names:
            keys = _key_registry.get(fn)
            if keys:
                for k in keys:
                    _cache.pop(k, None)
                _key_registry.pop(fn, None)
