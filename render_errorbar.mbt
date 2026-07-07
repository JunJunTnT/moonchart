// Error bar rendering: draws error stems and caps on data points.

///|
/// Render error stems and caps for a series, matching bar, box, line, or scatter chart positions. Parameters: layout, chart options, and the series index within the options.
pub fn renderErrorBars(
  layout : Layout,
  opt : ChartOption,
  seriesIndex : Int,
) -> String {
  let series = opt.series[seriesIndex]
  let errorColor = match series.errorColor {
    Some(c) => c
    None =>
      match series.color {
        Some(c) => c
        None => seriesColor(seriesIndex)
      }
  }
  let stroke = errorColor.toSvg()
  let lineWidth = series.errorLineWidth
  let capWidth = series.errorCapWidth / 2.0
  let plot = layout.plot
  let mut svg = ""

  for i = 0; i < series.data.length(); i = i + 1 {
    let dp = series.data[i]
    match dp.error_y {
      Some(err) => {
        // Use bandCenter for bar/box, continuous map for line/scatter
        let baseX = plot.left() +
          (match series.chartType {
            Bar => layout.xScale.bandCenter(dp.x)
            BoxPlot => layout.xScale.bandCenter(dp.x)
            _ => layout.xScale.map(dp.x)
          })
        // Only apply dodge offset for bar/box charts
        let cx = match series.chartType {
          Bar => baseX + layout.dodgeOffsets[seriesIndex]
          BoxPlot => baseX + layout.dodgeOffsets[seriesIndex]
          _ => baseX
        }
        let yLo = plot.bottom() - layout.yScale.map(dp.y + err.lo())
        let yHi = plot.bottom() - layout.yScale.map(dp.y + err.hi())

        // Clamp to plot area
        let yLoClamped = yLo.max(plot.top()).min(plot.bottom())
        let yHiClamped = yHi.max(plot.top()).min(plot.bottom())

        // Vertical stem
        svg = svg +
          line(
            x1=cx,
            y1=yLoClamped,
            x2=cx,
            y2=yHiClamped,
            stroke~,
            strokeWidth=lineWidth,
          ) +
          "\n"

        // Top cap
        svg = svg +
          line(
            x1=cx - capWidth,
            y1=yHiClamped,
            x2=cx + capWidth,
            y2=yHiClamped,
            stroke~,
            strokeWidth=lineWidth,
          ) +
          "\n"

        // Bottom cap
        svg = svg +
          line(
            x1=cx - capWidth,
            y1=yLoClamped,
            x2=cx + capWidth,
            y2=yLoClamped,
            stroke~,
            strokeWidth=lineWidth,
          ) +
          "\n"
      }
      None => ()
    }
  }

  svg
}
