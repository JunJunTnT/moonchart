// Line chart rendering with point shape and line style support.

///|
/// Render a line series into SVG given layout, chart options, and series index.
pub fn renderLine(
  layout : Layout,
  opt : ChartOption,
  seriesIndex : Int,
) -> String {
  let series = opt.series[seriesIndex]
  let color = match series.color {
    Some(c) => c
    None => seriesColor(seriesIndex)
  }
  let stroke = color.toSvg()
  let lineWidth = series.lineWidth
  let pointSize = series.pointSize
  let plot = layout.plot
  let mut svg = ""

  // Sort data points by x for clean line
  let sorted = series.data.copy()
  for i = 0; i < sorted.length(); i = i + 1 {
    for j = i + 1; j < sorted.length(); j = j + 1 {
      if sorted[i].x > sorted[j].x {
        let tmp = sorted[i]
        sorted[i] = sorted[j]
        sorted[j] = tmp
      }
    }
  }

  // Build points string for polyline — use continuous mapping for line
  let pts : Array[(Double, Double)] = []
  for i = 0; i < sorted.length(); i = i + 1 {
    let dp = sorted[i]
    let px = plot.left() + layout.xScale.map(dp.x)
    let py = plot.bottom() - layout.yScale.map(dp.y)
    pts.push((px, py))
  }

  if pts.length() >= 2 {
    let ptsStr = formatPoints(pts)
    let dash = lineDashAttr(series.lineStyle)
    svg = svg +
      "<polyline points='\{ptsStr}' stroke='\{stroke}' stroke-width='\{lineWidth}' fill='none' stroke-linejoin='round' stroke-linecap='round'\{dash} />" +
      "\n"
  }

  // Draw data point markers — use continuous mapping
  if pointSize > 0.0 {
    let ptFill = match series.pointFill {
      Some(c) => c.toSvg()
      None => color.toSvg()
    }
    for i = 0; i < sorted.length(); i = i + 1 {
      let dp = sorted[i]
      let cx = plot.left() + layout.xScale.map(dp.x)
      let cy = plot.bottom() - layout.yScale.map(dp.y)
      svg = svg +
        pointMarker(cx, cy, pointSize, series.pointShape, ptFill) +
        "\n"
    }
  }

  svg
}

///|
/// Get SVG stroke-dasharray attribute string for the given line style.
fn lineDashAttr(style : LineStyle) -> String {
  match style {
    Solid => ""
    Dashed => " stroke-dasharray='8,4'"
    Dotted => " stroke-dasharray='2,3'"
    DashDot => " stroke-dasharray='8,4,1,4'"
  }
}
