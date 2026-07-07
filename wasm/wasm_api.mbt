// WASM API exports for moonchart.
// Uses JSON-in/JSON-out pattern to bridge JS ↔ WASM.

///|
/// Main WASM export: takes a JSON config string, returns an SVG string.
/// On error, returns a string starting with "Error:".
pub fn render_chart(config_json : String) -> String {
  let json = @json5.parse(config_json) catch {
    e => return "Error: JSON parse failed: \{e.to_string()}"
  }

  let root_obj = match json {
    Object(obj) => obj
    _ => return "Error: root JSON must be an object"
  }

  // ── Extract top-level config ──
  let width = getNum(root_obj, "width", 600.0)
  let height = getNum(root_obj, "height", 400.0)
  let bg = getColor(
    root_obj,
    "background",
    @moonchart.Color::rgb(255, 255, 255),
  )
  let title = getStrOpt(root_obj, "title")
  let x_label = getStrOpt(root_obj, "xLabel")
  let y_label = getStrOpt(root_obj, "yLabel")
  let y_min = getNum(root_obj, "yMin", 0.0)
  let y_max = getNum(root_obj, "yMax", 100.0)
  let x_tick_positions = getNumArray(root_obj, "xTickPositions")
  let x_tick_labels = getStrArray(root_obj, "xTickLabels")
  let show_legend = getBool(root_obj, "showLegend", false)
  let legend_pos = parseLegendPos(
    getStr(root_obj, "legendPosition", "topRight"),
  )
  let show_y_grid = getBool(root_obj, "showYGrid", false)
  let show_x_grid = getBool(root_obj, "showXGrid", false)
  let bar_width_ratio = getNum(root_obj, "barWidthRatio", 0.7)
  let bar_gap = getNum(root_obj, "barGap", 0.0)
  let font_family = getStr(root_obj, "fontFamily", "sans-serif")
  let tick_font_size = getNum(root_obj, "tickFontSize", 11.0)
  let label_font_size = getNum(root_obj, "labelFontSize", 13.0)
  let legend_font_size = getNum(root_obj, "legendFontSize", 12.0)

  // ── Build chart ──
  let mut chart = @moonchart.Chart::new()
    .size(width, height)
    .background(bg)
    .fontFamily(font_family)
    .yRange(y_min, y_max)
    .barWidthRatio(bar_width_ratio)
    .barGap(bar_gap)
    .tickFontSize(tick_font_size)
    .labelFontSize(label_font_size)
    .legendFontSize(legend_font_size)

  match title {
    Some(t) => chart = chart.title(t)
    None => ()
  }
  match x_label {
    Some(l) => chart = chart.xLabel(l)
    None => ()
  }
  match y_label {
    Some(l) => chart = chart.yLabel(l)
    None => ()
  }
  if x_tick_positions.length() > 0 {
    chart = chart.xTicks(x_tick_positions, x_tick_labels)
  }
  chart = chart.legend(show_legend, legend_pos)
  if show_y_grid {
    chart = chart.yGrid(true)
  }
  if show_x_grid {
    chart = chart.xGrid(true)
  }

  // ── Parse and add series ──
  let series_arr = getArray(root_obj, "series")
  for si = 0; si < series_arr.length(); si = si + 1 {
    match series_arr[si] {
      Object(so) => {
        let s = buildSeries(so)
        chart = chart.series(s)
      }
      _ => ()
    }
  }

  // ── Render ──
  match chart.toSvg() {
    Ok(svg) => svg
    Err(msg) => "Error: \{msg}"
  }
}

// ──── JSON helpers (use pattern matching via `is` syntax) ────

///|
fn getStr(json : Map[String, Json], key : String, default : String) -> String {
  match json.get(key) {
    Some(String(s)) => s
    _ => default
  }
}

///|
fn getStrOpt(json : Map[String, Json], key : String) -> String? {
  match json.get(key) {
    Some(String(s)) => Some(s)
    _ => None
  }
}

///|
fn getNum(json : Map[String, Json], key : String, default : Double) -> Double {
  match json.get(key) {
    Some(Number(n, ..)) => n
    _ => default
  }
}

///|
fn getBool(json : Map[String, Json], key : String, default : Bool) -> Bool {
  match json.get(key) {
    Some(True) => true
    Some(False) => false
    _ => default
  }
}

///|
fn getArray(json : Map[String, Json], key : String) -> Array[Json] {
  match json.get(key) {
    Some(Array(a)) => a
    _ => []
  }
}

///|
fn getStrArray(json : Map[String, Json], key : String) -> Array[String] {
  let raw = getArray(json, key)
  let result : Array[String] = []
  for i = 0; i < raw.length(); i = i + 1 {
    match raw[i] {
      String(s) => result.push(s)
      _ => ()
    }
  }
  result
}

///|
fn getNumArray(json : Map[String, Json], key : String) -> Array[Double] {
  let raw = getArray(json, key)
  let result : Array[Double] = []
  for i = 0; i < raw.length(); i = i + 1 {
    match raw[i] {
      Number(n, ..) => result.push(n)
      _ => ()
    }
  }
  result
}

///|
fn getColor(
  json : Map[String, Json],
  key : String,
  default : @moonchart.Color,
) -> @moonchart.Color {
  match json.get(key) {
    Some(String(hex)) => hexToColor(hex)
    _ => default
  }
}

// ──── Color parsing ────

///|
fn hexToColor(hex : String) -> @moonchart.Color {
  let s = if hex.length() > 0 && hex[0:1] == "#" {
    hex[1:].to_owned()
  } else {
    hex
  }
  let r = parseHexByte(s, 0)
  let g = parseHexByte(s, 2)
  let b = parseHexByte(s, 4)
  @moonchart.Color::rgb(r, g, b)
}

///|
fn parseHexByte(s : String, offset : Int) -> Int {
  if offset + 2 > s.length() {
    0
  } else {
    let hi = hexVal(s[offset])
    let lo = hexVal(s[offset + 1])
    hi * 16 + lo
  }
}

///|
fn hexVal(c : UInt16) -> Int {
  let code = c.to_int()
  if code >= 48 && code <= 57 {
    code - 48
  } else if code >= 65 && code <= 70 {
    code - 55
  } else if code >= 97 && code <= 102 {
    code - 87
  } else {
    0
  }
}

// ──── Legend position ────

///|
fn parseLegendPos(s : String) -> @moonchart.Position {
  if s == "topLeft" {
    @moonchart.TopLeft
  } else if s == "topRight" {
    @moonchart.TopRight
  } else if s == "topCenter" {
    @moonchart.TopCenter
  } else if s == "bottomLeft" {
    @moonchart.BottomLeft
  } else if s == "bottomRight" {
    @moonchart.BottomRight
  } else if s == "bottomCenter" {
    @moonchart.BottomCenter
  } else if s == "left" {
    @moonchart.Left
  } else if s == "right" {
    @moonchart.Right
  } else {
    @moonchart.TopRight
  }
}

// ──── Style parsing ────

///|
fn parseLineStyle(s : String) -> @moonchart.LineStyle {
  if s == "dashed" {
    @moonchart.Dashed
  } else if s == "dotted" {
    @moonchart.Dotted
  } else if s == "dashDot" {
    @moonchart.DashDot
  } else {
    @moonchart.Solid
  }
}

///|
fn parsePointShape(s : String) -> @moonchart.PointShape {
  if s == "square" {
    @moonchart.Square
  } else if s == "triangle" {
    @moonchart.Triangle
  } else if s == "diamond" {
    @moonchart.Diamond
  } else if s == "cross" {
    @moonchart.Cross
  } else {
    @moonchart.Circle
  }
}

// ──── Series builder ────

///|
fn buildSeries(so : Map[String, Json]) -> @moonchart.Series {
  let name = getStr(so, "name", "Series")
  let chart_type_str = getStr(so, "chartType", "bar")

  // Parse data points and box groups
  let data_points = parseDataPoints(getArray(so, "data"))
  let box_groups = parseBoxGroups(getArray(so, "boxData"))

  // Create series based on chart type string
  let s = if chart_type_str == "line" {
    @moonchart.Series::line(name, data_points)
  } else if chart_type_str == "scatter" {
    @moonchart.Series::scatter(name, data_points)
  } else if chart_type_str == "boxplot" {
    @moonchart.Series::boxplot(name, box_groups)
  } else {
    @moonchart.Series::bar(name, data_points)
  }

  // Apply style overrides
  let s = match so.get("color") {
    Some(String(hex)) => s.withColor(hexToColor(hex))
    _ => s
  }

  let lw = getNum(so, "lineWidth", 2.0)
  let ps = getNum(so, "pointSize", 4.0)
  let ls = parseLineStyle(getStr(so, "lineStyle", "solid"))
  let psh = parsePointShape(getStr(so, "pointShape", "circle"))
  let ew = getNum(so, "errorLineWidth", 1.0)
  let ec = getNum(so, "errorCapWidth", 6.0)

  let s = s
    .withLineWidth(lw)
    .withPointSize(ps)
    .withLineStyle(ls)
    .withPointShape(psh)
    .withErrorLineWidth(ew)
    .withErrorCapWidth(ec)

  // Bar stroke
  let s = match so.get("barStroke") {
    Some(String(hex)) =>
      s.withBarStroke(hexToColor(hex), getNum(so, "barStrokeWidth", 0.0))
    _ => s
  }

  // Error color
  let s = match so.get("errorColor") {
    Some(String(hex)) => s.withErrorColor(Some(hexToColor(hex)))
    _ => s
  }

  // Point fill
  let s = match so.get("pointFill") {
    Some(String(hex)) => s.withPointFill(hexToColor(hex))
    _ => s
  }

  // Show outliers (boxplot)
  if getBool(so, "showOutliers", true) {
    s
  } else {
    s.withShowOutliers(false)
  }
}

///|
fn parseDataPoints(arr : Array[Json]) -> Array[@moonchart.DataPoint] {
  let result : Array[@moonchart.DataPoint] = []
  for i = 0; i < arr.length(); i = i + 1 {
    match arr[i] {
      Array(inner) =>
        if inner.length() >= 2 {
          let x = getJsonNum(inner, 0, 0.0)
          let y = getJsonNum(inner, 1, 0.0)
          if inner.length() >= 3 {
            let err_y = getJsonNum(inner, 2, 0.0)
            result.push(@moonchart.DataPoint::withErrY(x, y, err_y))
          } else {
            result.push(@moonchart.DataPoint::new(x, y))
          }
        }
      _ => ()
    }
  }
  result
}

///|
fn parseBoxGroups(arr : Array[Json]) -> Array[@moonchart.BoxGroup] {
  let result : Array[@moonchart.BoxGroup] = []
  for i = 0; i < arr.length(); i = i + 1 {
    match arr[i] {
      Object(obj) => {
        let x = getNum(obj, "x", i.to_double())
        let label = getStr(obj, "label", "Gp\{i.to_string()}")
        let vals_arr = getArray(obj, "values")
        let vals : Array[Double] = []
        for j = 0; j < vals_arr.length(); j = j + 1 {
          match vals_arr[j] {
            Number(n, ..) => vals.push(n)
            _ => ()
          }
        }
        if vals.length() > 0 {
          result.push(@moonchart.BoxGroup::new(x, label, vals))
        }
      }
      _ => ()
    }
  }
  result
}

///|
fn getJsonNum(arr : Array[Json], idx : Int, default : Double) -> Double {
  match arr[idx] {
    Number(n, ..) => n
    _ => default
  }
}
