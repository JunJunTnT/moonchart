// Scatter chart rendering.

/// Render a scatter series into SVG.
pub fn renderScatter(layout : Layout, opt : ChartOption, seriesIndex : Int) -> String {
  let series = opt.series[seriesIndex]
  let color = match series.color {
    Some(c) => c
    None => seriesColor(seriesIndex)
  }
  let fill = color.toSvg()
  let pointSize = series.pointSize
  let plot = layout.plot
  let mut svg = ""

  for i = 0; i < series.data.length(); i = i + 1 {
    let dp = series.data[i]
    let cx = plot.left() + layout.xScale.map(dp.x)
    let cy = plot.bottom() - layout.yScale.map(dp.y)
    svg = svg + circle(
      cx= cx, cy= cy, r= pointSize,
      fill= fill, stroke= "white", strokeWidth= 0.5,
    ) + "\n"
  }

  svg
}
