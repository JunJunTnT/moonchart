// Box plot rendering: box from Q1-Q3, median line, whiskers, optional outliers.

/// Render a box plot series (Q1/Q3 box, median line, whiskers with caps, and outliers) into SVG. Parameters: layout - chart layout config, opt - full chart options, seriesIndex - index of the series to render.
pub fn renderBoxplot(layout : Layout, opt : ChartOption, seriesIndex : Int) -> String {
  let series = opt.series[seriesIndex]
  let color = match series.color {
    Some(c) => c
    None => seriesColor(seriesIndex)
  }
  let fill = color.toSvg()
  let stroke = Color::rgb(40, 40, 40).toSvg()
  let medianStroke = Color::rgb(20, 20, 20).toSvg()
  let plot = layout.plot
  let mut svg = ""

  let groups = series.boxGroups
  let n = groups.length()
  if n == 0 {
    return ""
  }

  // Box width: 50% of band width
  let boxWidth = layout.barWidth
  let halfBox = boxWidth / 2.0
  let whiskerLineWidth = 1.0
  let capWidth = boxWidth * 0.4

  for i = 0; i < n; i = i + 1 {
    let group = groups[i]
    if group.values.length() < 2 {
      continue
    }
    let stats = computeBoxStats(group.values)
    // Use bandCenter for box positioning (bars/boxes align to band centers)
    let cx = plot.left() + layout.xScale.bandCenter(group.x) + layout.dodgeOffsets[seriesIndex]

    // Map data values to Y pixels
    let yQ1 = plot.bottom() - layout.yScale.map(stats.q1)
    let yQ3 = plot.bottom() - layout.yScale.map(stats.q3)
    let yMedian = plot.bottom() - layout.yScale.map(stats.median)
    let yWhiskerLow = plot.bottom() - layout.yScale.map(stats.whiskerLow)
    let yWhiskerHigh = plot.bottom() - layout.yScale.map(stats.whiskerHigh)

    let boxY = yQ3  // top of box (Q3 has lower pixel value = higher on screen)
    let boxH = yQ1 - yQ3  // box height

    // Box rect (Q1 to Q3)
    svg = svg + rect(
      x= cx - halfBox, y= boxY,
      w= boxWidth, h= boxH,
      fill= fill, stroke= stroke, strokeWidth= 1.0,
    ) + "\n"

    // Median line
    svg = svg + line(
      x1= cx - halfBox, y1= yMedian,
      x2= cx + halfBox, y2= yMedian,
      stroke= medianStroke, strokeWidth= 2.0,
    ) + "\n"

    // Whisker: vertical line from Q1 to whiskerLow
    svg = svg + line(
      x1= cx, y1= yQ1,
      x2= cx, y2= yWhiskerLow,
      stroke= stroke, strokeWidth= whiskerLineWidth,
    ) + "\n"

    // Whisker: vertical line from Q3 to whiskerHigh
    svg = svg + line(
      x1= cx, y1= yQ3,
      x2= cx, y2= yWhiskerHigh,
      stroke= stroke, strokeWidth= whiskerLineWidth,
    ) + "\n"

    // Whisker caps
    svg = svg + line(
      x1= cx - capWidth, y1= yWhiskerLow,
      x2= cx + capWidth, y2= yWhiskerLow,
      stroke= stroke, strokeWidth= whiskerLineWidth,
    ) + "\n"
    svg = svg + line(
      x1= cx - capWidth, y1= yWhiskerHigh,
      x2= cx + capWidth, y2= yWhiskerHigh,
      stroke= stroke, strokeWidth= whiskerLineWidth,
    ) + "\n"

    // Outliers
    if series.showOutliers {
      for j = 0; j < stats.outliers.length(); j = j + 1 {
        let oy = plot.bottom() - layout.yScale.map(stats.outliers[j])
        svg = svg + circle(
          cx= cx, cy= oy, r= 3.0,
          fill= stroke, stroke= "none", strokeWidth= 0.0,
        ) + "\n"
      }
    }
  }

  svg
}
