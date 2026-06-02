// Bar chart rendering.

/// Render all bar series into SVG strings.
pub fn renderBars(layout : Layout, opt : ChartOption, seriesIndex : Int) -> String {
  let series = opt.series[seriesIndex]
  let color = match series.color {
    Some(c) => c
    None => seriesColor(seriesIndex)
  }
  let fill = color.toSvg()
  let mut svg = ""
  let plot = layout.plot

  for i = 0; i < series.data.length(); i = i + 1 {
    let dp = series.data[i]
    let centerX = plot.left() + layout.xScale.map(dp.x)
    let barX = centerX + layout.dodgeOffsets[seriesIndex] - layout.barWidth / 2.0

    // Y position: invert for SVG coordinate system
    let yVal = dp.y
    let yBase = layout.yScale.map(0.0.max(layout.yScale.unmap(0.0)))
    let yTop = layout.yScale.map(yVal)
    let barY = plot.bottom() - yTop.max(yBase)
    let mut barH = (yTop - yBase).abs()

    if barH < 0.5 {
      barH = 0.5
    }

    svg = svg + rect(
      x= barX,
      y= barY,
      w= layout.barWidth,
      h= barH,
      fill= fill,
      stroke= "none",
      strokeWidth= 0.0,
    ) + "\n"
  }

  svg
}
