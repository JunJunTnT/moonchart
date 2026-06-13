# MoonChart vs ECharts vs matplotlib — Frontend Render Pipeline Benchmark

**Generated:** 2026-06-14 00:18:04
**Methodology:** Measure full render pipeline: input data → SVG output
**Iterations:** 50 (per library x chart), 5 warmup discarded
**Environment:** Node.js v24.16, Python 3.13, MoonBit WASM-GC, ECharts 5.6, matplotlib 3.11
**Hardware:** Windows 11, AMD Ryzen AI 12-core, 31.2 GB RAM

---

## 1. Aggregate Summary (all 5 chart types)

| Rank | Library | Mean Time | StdDev | P50 | P95 | P99 | vs Fastest |
|------|---------|-----------|--------|-----|-----|-----|------------|
| 🥇 1 | **MoonChart (WASM)** | 98.3 us | 142.8 us | 80.6 us | 151.1 us | 291.8 us | 1.0x |
| 🥈 2 | **ECharts (SSR)** | 1.972 ms | 403.0 us | 1.907 ms | 2.703 ms | 3.539 ms | 20.1x |
| 🥉 3 | **matplotlib (Agg)** | 49.21 ms | 6.365 ms | 46.45 ms | 61.20 ms | 67.65 ms | 500.8x |

**Key finding:** MoonChart renders in **98.3 us**, making it **20x faster** than ECharts and **501x faster** than matplotlib.

---

## 2. Per-Chart Comparison

### Bar Chart

| Library | Mean Time | StdDev | P50 | P95 | Output Size |
|---------|-----------|--------|-----|-----|-------------|
| MoonChart (WASM) | **132.5 us** 🏆 | 48.3 us | 119.3 us | 215.8 us | **7.0 KB** 🏆 |
| ECharts (SSR) | 2.179 ms | 476.0 us | 2.059 ms | 3.100 ms | 8.7 KB |
| matplotlib (Agg) | 45.50 ms | 3.939 ms | 44.52 ms | 50.55 ms | 34.3 KB |

> Winner: **MoonChart (WASM)**

### Line Chart

| Library | Mean Time | StdDev | P50 | P95 | Output Size |
|---------|-----------|--------|-----|-----|-------------|
| MoonChart (WASM) | **101.7 us** 🏆 | 106.3 us | 96.5 us | 124.6 us | **5.9 KB** 🏆 |
| ECharts (SSR) | 1.998 ms | 255.8 us | 1.948 ms | 2.646 ms | 10.1 KB |
| matplotlib (Agg) | 47.31 ms | 5.508 ms | 45.97 ms | 54.78 ms | 29.5 KB |

> Winner: **MoonChart (WASM)**

### Scatter

| Library | Mean Time | StdDev | P50 | P95 | Output Size |
|---------|-----------|--------|-----|-----|-------------|
| MoonChart (WASM) | **98.6 us** 🏆 | 31.9 us | 82.9 us | 143.8 us | **8.0 KB** 🏆 |
| ECharts (SSR) | 2.053 ms | 489.5 us | 1.935 ms | 2.902 ms | 13.7 KB |
| matplotlib (Agg) | 57.57 ms | 3.177 ms | 57.02 ms | 62.88 ms | 30.1 KB |

> Winner: **MoonChart (WASM)**

### BoxPlot

| Library | Mean Time | StdDev | P50 | P95 | Output Size |
|---------|-----------|--------|-----|-----|-------------|
| MoonChart (WASM) | **116.9 us** 🏆 | 287.3 us | 76.5 us | 92.7 us | **6.4 KB** 🏆 |
| ECharts (SSR) | 1.609 ms | 205.5 us | 1.564 ms | 1.804 ms | 6.5 KB |
| matplotlib (Agg) | 48.35 ms | 4.729 ms | 46.72 ms | 57.77 ms | 32.1 KB |

> Winner: **MoonChart (WASM)**

### Mixed

| Library | Mean Time | StdDev | P50 | P95 | Output Size |
|---------|-----------|--------|-----|-----|-------------|
| MoonChart (WASM) | **41.6 us** 🏆 | 1.1 us | 41.3 us | 43.5 us | **6.4 KB** 🏆 |
| ECharts (SSR) | 2.021 ms | 231.8 us | 1.966 ms | 2.460 ms | 8.7 KB |
| matplotlib (Agg) | 47.34 ms | 5.730 ms | 45.51 ms | 54.96 ms | 32.3 KB |

> Winner: **MoonChart (WASM)**

---

## 3. Output Size Comparison

| Chart | MoonChart | ECharts | matplotlib | Smallest |
|-------|-----------|---------|------------|----------|
| Bar Chart | 7.0 KB | 8.7 KB | 34.3 KB | **MoonChart** |
| Line Chart | 5.9 KB | 10.1 KB | 29.5 KB | **MoonChart** |
| Scatter | 8.0 KB | 13.7 KB | 30.1 KB | **MoonChart** |
| BoxPlot | 6.4 KB | 6.5 KB | 32.1 KB | **MoonChart** |
| Mixed | 6.4 KB | 8.7 KB | 32.3 KB | **MoonChart** |

MoonChart SVG output is **smallest in all 5 chart types** — averaging ~6.7KB.

---

## 4. Speed Comparison Matrix

|  | MoonChart | ECharts | matplotlib |
|--|-----------|---------|------------|
| **MoonChart** | — | 20x faster | 501x faster |
| **ECharts** | 20x slower | — | 25x faster |
| **matplotlib** | 501x slower | 25x slower | — |

---

## 5. Latency Distribution (all iterations)

| Library | Min | P50 | Mean | P95 | P99 | Max |
|---------|-----|-----|------|-----|-----|-----|
| MoonChart (WASM) | 40.2 us | 80.6 us | 98.3 us | 151.1 us | 291.8 us | 2.127 ms |
| ECharts (SSR) | 1.415 ms | 1.907 ms | 1.972 ms | 2.703 ms | 3.539 ms | 4.298 ms |
| matplotlib (Agg) | 41.14 ms | 46.45 ms | 49.21 ms | 61.20 ms | 67.65 ms | 78.70 ms |

---

## 6. Conclusions

1. **MoonChart WASM** is the clear winner, rendering in **~100 microseconds** — sub-millisecond performance suitable for real-time interactive charts.
2. **ECharts SSR** is solid at ~2ms, 20x slower than MoonChart but still fast enough for most use cases. V8 JIT helps but the JS object construction overhead is significant.
3. **matplotlib** is ~49ms — 500x slower than MoonChart. Designed for publication-quality output, not speed. Reasonable for batch/server-side use.
4. **Output size**: MoonChart SVG is consistently smallest (5.9-8.0KB), ECharts 6.5-13.7KB, matplotlib 29-34KB.
5. **Measurement fairness**: All three measured identically — "input data → SVG string" pipeline, within the same process, excluding library-loading overhead.

<!-- ---

## 7. Reproducing

```bash
# MoonChart + ECharts (Node.js)
cd benchmark/wasm_frontend && node bench_node.mjs 50 5

# matplotlib (Python)
cd benchmark/wasm_frontend && python bench_matplotlib.py 50 5

# Generate report
python generate_report.py
``` -->