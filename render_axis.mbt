// Axis rendering: draws axes, ticks, labels, titles, and grid lines.

/// Build a font from axis option settings.
fn tickFontFrom(axis : AxisOption, fontFamily : String) -> Font {
  {
    family: fontFamily,
    size: axis.tickFontSize,
    color: axis.tickColor,
    bold: false,
    italic: false,
  }
}

fn labelFontFrom(axis : AxisOption, fontFamily : String) -> Font {
  {
    family: fontFamily,
    size: axis.labelFontSize,
    color: Color::rgb(0, 0, 0),
    bold: false,
    italic: false,
  }
}

/// Generate a rotated SVG text element (for Y axis labels).
fn rotatedText(
  x~ : Double,
  y~ : Double,
  content~ : String,
  font~ : Font
) -> String {
  let escaped = xmlEscape(content)
  "<text x='\{x}' y='\{y}' \{font.svgAttrs()} text-anchor='middle' transform='rotate(-90,\{x},\{y})'>\{escaped}</text>"
}

/// Render the Y-axis (left side of plot area).
pub fn renderYAxis(layout : Layout, opt : ChartOption) -> String {
  let plot = layout.plot
  let yScale = layout.yScale
  let axis = opt.yAxis
  let axisColorStr = axis.tickColor.toSvg()
  let tickFontVal = tickFontFrom(axis, opt.fontFamily)
  let mut svg = ""

  // Y-axis line (vertical)
  svg = svg + line(
    x1= plot.left(), y1= plot.top(),
    x2= plot.left(), y2= plot.bottom(),
    stroke= axisColorStr, strokeWidth= 1.0,
  ) + "\n"

  // Y-axis ticks
  let tickCount = match axis.tickCount {
    Some(n) => n
    None => 6
  }
  let ticks = yScale.ticks(tickCount)
  let tickLength = 5.0
  for i = 0; i < ticks.length(); i = i + 1 {
    let (pixel, label) = ticks[i]
    let yPos = plot.bottom() - pixel

    // Grid line (horizontal across plot area)
    if axis.gridLine {
      svg = svg + line(
        x1= plot.left(), y1= yPos,
        x2= plot.right(), y2= yPos,
        stroke= axis.gridColor.toSvg(), strokeWidth= axis.gridWidth,
      ) + "\n"
    }

    // Tick line
    svg = svg + line(
      x1= plot.left() - tickLength, y1= yPos,
      x2= plot.left(), y2= yPos,
      stroke= axisColorStr, strokeWidth= 1.0,
    ) + "\n"
    // Tick label
    svg = svg + text(
      x= plot.left() - tickLength - 4.0,
      y= yPos + tickFontVal.size * 0.35,
      content= label,
      font= tickFontVal,
      textAnchor= "end",
    ) + "\n"
  }

  // Y-axis title
  match axis.label {
    Some(label) => {
      let titleFontVal = labelFontFrom(axis, opt.fontFamily)
      let centerY = plot.centerY()
      let xPos = plot.left() / 2.0
      svg = svg + rotatedText(
        x= xPos, y= centerY,
        content= label, font= titleFontVal,
      ) + "\n"
    }
    None => ()
  }

  svg
}

/// Render the X-axis (bottom of plot area).
pub fn renderXAxis(layout : Layout, opt : ChartOption) -> String {
  let plot = layout.plot
  let xScale = layout.xScale
  let axis = opt.xAxis
  let axisColorStr = axis.tickColor.toSvg()
  let tickFontVal = tickFontFrom(axis, opt.fontFamily)
  let mut svg = ""

  // X-axis line (horizontal)
  svg = svg + line(
    x1= plot.left(), y1= plot.bottom(),
    x2= plot.right(), y2= plot.bottom(),
    stroke= axisColorStr, strokeWidth= 1.0,
  ) + "\n"

  // X-axis ticks
  let tickCount = match axis.tickCount {
    Some(n) => n
    None => xScale.count()
  }
  let ticks = xScale.ticks(tickCount)
  let tickLength = 5.0
  for i = 0; i < ticks.length(); i = i + 1 {
    let (pixel, label) = ticks[i]
    let xPos = plot.left() + pixel

    // Grid line (vertical across plot area)
    if axis.gridLine {
      svg = svg + line(
        x1= xPos, y1= plot.top(),
        x2= xPos, y2= plot.bottom(),
        stroke= axis.gridColor.toSvg(), strokeWidth= axis.gridWidth,
      ) + "\n"
    }

    // Tick line
    svg = svg + line(
      x1= xPos, y1= plot.bottom(),
      x2= xPos, y2= plot.bottom() + tickLength,
      stroke= axisColorStr, strokeWidth= 1.0,
    ) + "\n"
    // Tick label
    svg = svg + text(
      x= xPos,
      y= plot.bottom() + tickLength + tickFontVal.size + 2.0,
      content= label,
      font= tickFontVal,
      textAnchor= "middle",
    ) + "\n"
  }

  // X-axis title
  match axis.label {
    Some(label) => {
      let titleFontVal = labelFontFrom(axis, opt.fontFamily)
      let centerX = plot.centerX()
      let yPos = plot.bottom() + tickLength + tickFontVal.size + titleFontVal.size + 6.0
      svg = svg + text(
        x= centerX, y= yPos,
        content= label, font= titleFontVal,
        textAnchor= "middle",
      ) + "\n"
    }
    None => ()
  }

  svg
}

/// Render the chart title (centered at top).
pub fn renderTitle(opt : ChartOption) -> String {
  match opt.title {
    Some(title) => {
      let fontVal = titleFont()
      let centerX = opt.width / 2.0
      let yPos = opt.margin.top / 2.0 + fontVal.size * 0.35
      text(
        x= centerX, y= yPos,
        content= title, font= fontVal,
        textAnchor= "middle",
      )
    }
    None => ""
  }
}
