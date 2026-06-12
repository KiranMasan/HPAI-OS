# frontend

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Emulator & Performance Tips

Quick tips to make the frontend fast to launch and responsive on emulators and low-end devices:

- **Use profile or release builds for realistic performance:**
	- `flutter run --profile -d <device>` — good for profiling and faster runtime.
	- `flutter run --release -d <device>` — fastest, closest to production.
- **Enable Low Resource Mode in the app:** open the app, go to the Profile tab and toggle **Low Resource Mode** to disable heavy voice features and animations for faster iteration on emulators.
- **Reduce emulator load:** allocate more CPU and RAM to the Android emulator and enable GPU acceleration (Intel HAXM or Windows Hypervisor). Cold-boot the emulator for a clean state.
- **Hot reload / restart:** use `r` (hot reload) and `R` (full restart) in `flutter run` to iterate quickly without cold-start overhead.
- **Analyze performance:** use `flutter run --profile` and the DevTools performance tab to locate slow frames and heavy widgets.
- **Disable debug paint & banner:** use `debugShowCheckedModeBanner: false` in `MaterialApp` for cleaner rendering during runs.
- **Backend tips:** run the backend with Uvicorn in production mode and enable gzip compression for faster responses:

```bash
# Development (auto-reload)
uvicorn app.main:app --reload --port 8000

# Production (use multiple workers behind a reverse proxy)
uvicorn app.main:app --workers 4 --host 0.0.0.0 --port 8000
```

These simple steps should make iteration and testing much faster on local machines and emulators. Toggle `Low Resource Mode` when developing on slow hosts to avoid heavy audio initialization and other costly features.
