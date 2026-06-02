// Legend rendering: draws colored markers and series names.

/// Render the chart legend.
pub fn renderLegend(layout : Layout, opt : ChartOption) -> String {
  if !opt.legend {
    return ""
  }
  if opt.series.length() == 0 {
    return ""
  }

  let plot = layout.plot
  let font = {
    family: opt.fontFamily,
    size: opt.legendFontSize,
    color: Color::rgb(0, 0, 0),
    bold: false,
    italic: false,
  }
  let pos = opt.legendPosition

  // Scale all sizes proportionally to font size
  let fs = font.size
  let markerSize = fs * 0.9
  let markerGap = fs * 0.4
  let itemSpacing = fs * 1.5
  let paddingX = fs * 0.8
  let paddingY = fs * 0.4

  let mut svg = ""

  // Calculate legend dimensions
  let mut maxTextWidth = 0.0
  for i = 0; i < opt.series.length(); i = i + 1 {
    let textW = opt.series[i].name.length().to_double() * fs * 0.6
    if textW > maxTextWidth {
      maxTextWidth = textW
    }
  }

  let totalW = paddingX * 2.0 + markerSize + markerGap + maxTextWidth
  let totalH = paddingY * 2.0 + opt.series.length().to_double() * itemSpacing

  // Position legend
  let (lx, ly) = match pos {
    TopRight => (plot.right() - totalW - 8.0, plot.top() + 8.0)
    TopLeft => (plot.left() + 8.0, plot.top() + 8.0)
    TopCenter => (plot.centerX() - totalW / 2.0, plot.top() + 8.0)
    BottomRight => (plot.right() - totalW - 8.0, plot.bottom() - totalH - 8.0)
    BottomLeft => (plot.left() + 8.0, plot.bottom() - totalH - 8.0)
    BottomCenter => (plot.centerX() - totalW / 2.0, plot.bottom() - totalH - 8.0)
    Left => (plot.left() + 8.0, plot.centerY() - totalH / 2.0)
    Right => (plot.right() - totalW - 8.0, plot.centerY() - totalH / 2.0)
  }

  // Legend background
  svg = svg + rect(
    x= lx, y= ly,
    w= totalW, h= totalH,
    fill= "white", stroke= "#ccc", strokeWidth= 1.0,
  ) + "\n"

  // Legend items
  for i = 0; i < opt.series.length(); i = i + 1 {
    let series = opt.series[i]
    let color = match series.color {
      Some(c) => c
      None => seriesColor(i)
    }

    let rowCenterY = ly + paddingY + i.to_double() * itemSpacing + itemSpacing / 2.0
    let markerX = lx + paddingX
    let markerCY = rowCenterY
    let markerTop = markerCY - markerSize / 2.0

    match series.chartType {
      Bar => {
        svg = svg + rect(
          x= markerX, y= markerTop,
          w= markerSize, h= markerSize,
          fill= color.toSvg(), stroke= "none", strokeWidth= 0.0,
        ) + "\n"
      }
      Line => {
        svg = svg + line(
          x1= markerX, y1= markerCY,
          x2= markerX + markerSize, y2= markerCY,
          stroke= color.toSvg(), strokeWidth= 2.0,
        ) + "\n"
      }
      Scatter => {
        svg = svg + circle(
          cx= markerX + markerSize / 2.0, cy= markerCY,
          r= markerSize / 2.0,
          fill= color.toSvg(), stroke= "none", strokeWidth= 0.0,
        ) + "\n"
      }
      BoxPlot => {
        svg = svg + rect(
          x= markerX, y= markerTop,
          w= markerSize, h= markerSize,
          fill= color.toSvg(), stroke= "none", strokeWidth= 0.0,
        ) + "\n"
      }
    }

    let labelX = markerX + markerSize + markerGap
    let textBaseline = rowCenterY + fs * 0.35
    svg = svg + text(
      x= labelX, y= textBaseline,
      content= series.name, font= font,
      textAnchor= "start",
    ) + "\n"
  }

  svg
}
