#!/usr/bin/env python3
"""
Simple smoke benchmark for backend startup and endpoint latency.

Usage:
  python tools/smoke_benchmark.py --endpoints / /dashboard /profile --requests 5
  python tools/smoke_benchmark.py --start-cmd "uvicorn app.main:app --reload" --wait-host 127.0.0.1:8000

This script can optionally start the backend and measure cold-start time.
"""
import argparse
import requests
import subprocess
import time
import statistics
import sys


def wait_for_url(url, timeout=30, interval=0.25):
    start = time.time()
    while True:
        try:
            r = requests.get(url, timeout=2)
            if r.status_code < 500:
                return time.time() - start
        except Exception:
            pass
        if time.time() - start > timeout:
            raise TimeoutError(f"Timeout waiting for {url}")
        time.sleep(interval)


def measure_endpoint(url, n=5):
    latencies = []
    for i in range(n):
        t0 = time.time()
        r = requests.get(url, timeout=10)
        elapsed = (time.time() - t0) * 1000.0
        latencies.append(elapsed)
        print(f"{url} -> {r.status_code} in {elapsed:.1f} ms")
    return latencies


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--start-cmd", help="Command to start backend (optional)")
    p.add_argument("--base-url", default="http://127.0.0.1:8000", help="Base URL for endpoints")
    p.add_argument("--endpoints", nargs="*", default=["/", "/dashboard", "/profile"])
    p.add_argument("--requests", type=int, default=5)
    p.add_argument("--wait-host", help="Host:port to wait for when starting (e.g. 127.0.0.1:8000)")
    p.add_argument("--flutter-project", help="Path to Flutter project to measure cold-start (optional)")
    p.add_argument("--flutter-device", help="Device id for flutter run (optional)")
    args = p.parse_args()

    proc = None
    try:
        if args.start_cmd:
            print("Starting backend:", args.start_cmd)
            proc = subprocess.Popen(args.start_cmd, shell=True)
            target = args.base_url
            if args.wait_host:
                host = args.wait_host
                url = f"http://{host}/"
            else:
                url = args.base_url + "/"
            print(f"Waiting for {url} to become healthy...")
            started_in = wait_for_url(url, timeout=60)
            print(f"Backend started in {started_in:.2f} s")
        else:
            print("Assuming backend already running at", args.base_url)

        # Optionally measure Flutter cold-start by invoking `flutter run --machine`
        if args.flutter_project:
            flutter_cmd = [
                "flutter",
                "run",
                "--machine",
                "-d",
                args.flutter_device or "",
            ]
            # Remove empty device arg if not specified
            flutter_cmd = [c for c in flutter_cmd if c]
            print("Starting flutter run to measure cold-start (this will block until you stop it)...")
            proc_flutter = subprocess.Popen(
                flutter_cmd,
                cwd=args.flutter_project,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
            )

            start_time = time.time()
            startup_time = None
            try:
                for line in proc_flutter.stdout:
                    line = line.strip()
                    try:
                        obj = json.loads(line)
                        # best-effort: look for 'event' keys indicating app started
                        evt = obj.get("event") or obj.get("type")
                        if isinstance(evt, str) and ("app.started" in evt or "app.started" == evt or "app.progress" in evt):
                            startup_time = time.time() - start_time
                            print(f"Detected flutter startup event: {evt} at {startup_time:.2f}s")
                            break
                    except Exception:
                        # Not a JSON line — look for human readable markers
                        if "Built" in line or "Syncing files to device" in line or "Running" in line:
                            startup_time = time.time() - start_time
                            print(f"Detected flutter output marker at {startup_time:.2f}s: {line}")
                            break
                if startup_time is None:
                    print("Could not detect startup event; process is still running or output format unknown.")
            finally:
                proc_flutter.terminate()
                try:
                    proc_flutter.wait(timeout=3)
                except Exception:
                    proc_flutter.kill()


        summary = {}
        for ep in args.endpoints:
            full = ep if ep.startswith("http") else args.base_url.rstrip("/") + ep
            print(f"\nMeasuring {full} ({args.requests} requests)")
            lat = measure_endpoint(full, n=args.requests)
            summary[full] = lat

        # Save results to JSON and CSV
        results = []
        for u, lat in summary.items():
            stats = {
                "url": u,
                "n": len(lat),
                "avg_ms": statistics.mean(lat),
                "median_ms": statistics.median(lat),
                "p95_ms": statistics.quantiles(lat, n=100)[94],
                "samples_ms": lat,
            }
            results.append(stats)

        import json, csv
        out_json = "tools/smoke_results.json"
        out_csv = "tools/smoke_results.csv"
        with open(out_json, "w", encoding="utf-8") as f:
            json.dump(results, f, indent=2)

        with open(out_csv, "w", newline='', encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow(["url", "n", "avg_ms", "median_ms", "p95_ms", "samples_ms"])
            for r in results:
                writer.writerow([r["url"], r["n"], f"{r['avg_ms']:.1f}", f"{r['median_ms']:.1f}", f"{r['p95_ms']:.1f}", ";".join([f"{s:.1f}" for s in r["samples_ms"])])

        print("\nResults written to:", out_json, out_csv)

        # Generate a tiny HTML dashboard
        html = [
            "<html><head><meta charset='utf-8'><title>Smoke Benchmark Results</title></head><body>",
            "<h2>Smoke Benchmark Results</h2>",
            "<table border='1' cellpadding='6'><tr><th>URL</th><th>n</th><th>avg (ms)</th><th>median (ms)</th><th>p95 (ms)</th><th>samples (ms)</th></tr>"
        ]
        for r in results:
            html.append(f"<tr><td>{r['url']}</td><td>{r['n']}</td><td>{r['avg_ms']:.1f}</td><td>{r['median_ms']:.1f}</td><td>{r['p95_ms']:.1f}</td><td>{', '.join([f'{s:.1f}' for s in r['samples_ms']])}</td></tr>")
        html.append("</table></body></html>")
        with open('tools/smoke_dashboard.html', 'w', encoding='utf-8') as f:
            f.write('\n'.join(html))
        print('HTML dashboard written to tools/smoke_dashboard.html')

    finally:
        if proc:
            print("Stopping backend process...")
            proc.terminate()


if __name__ == "__main__":
    main()
