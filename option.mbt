// Moonchart data model types.
// All core option types used for chart configuration.

// ──── Color (value type for performance) ────

///|
/// An RGBA color with components in 0-255 range.
#valtype
pub(all) struct Color {
  r : Int
  g : Int
  b : Int
  a : Int
}

///|
/// Construct an opaque color from RGB (alpha = 255).
pub fn Color::rgb(r : Int, g : Int, b : Int) -> Color {
  { r, g, b, a: 255 }
}

///|
/// Construct a color with explicit alpha.
pub fn Color::rgba(r : Int, g : Int, b : Int, a : Int) -> Color {
  { r, g, b, a }
}

///|
/// Convert color to SVG "rgb(r,g,b)" or "rgba(r,g,b,a)" string.
pub fn Color::toSvg(self : Color) -> String {
  if self.a == 255 {
    "rgb(\{self.r},\{self.g},\{self.b})"
  } else {
    let aDouble = Double::from_int(self.a) / 255.0
    "rgba(\{self.r},\{self.g},\{self.b},\{aDouble})"
  }
}

///|
/// Convert color to hex string like "#FF0000".
pub fn Color::toHex(self : Color) -> String {
  "#\{hexByte(self.r)}\{hexByte(self.g)}\{hexByte(self.b)}"
}

// Format an Int in 0..255 as two uppercase hex digits.

///|
fn hexByte(n : Int) -> String {
  hexDigit(n / 16) + hexDigit(n % 16)
}

// Format a single hex digit 0..15 as uppercase hex char.

///|
fn hexDigit(d : Int) -> String {
  if d < 10 {
    d.to_string()
  } else {
    match d {
      10 => "A"
      11 => "B"
      12 => "C"
      13 => "D"
      14 => "E"
      _ => "F"
    }
  }
}

// ──── Font ────

///|
/// Font configuration for text elements.
pub struct Font {
  family : String
  size : Double
  color : Color
  bold : Bool
  italic : Bool
}

///|
/// Default font: 12px sans-serif, black, normal weight.
pub fn Font::default() -> Font {
  {
    family: "sans-serif",
    size: 12.0,
    color: Color::rgb(0, 0, 0),
    bold: false,
    italic: false,
  }
}

///|
/// Create a title font (16px, bold).
pub fn Font::title() -> Font {
  {
    family: "sans-serif",
    size: 16.0,
    color: Color::rgb(0, 0, 0),
    bold: true,
    italic: false,
  }
}

///|
/// Build full SVG text style attributes string.
pub fn Font::svgAttrs(self : Font) -> String {
  let base = "font-family='\{self.family}' font-size='\{self.size}' fill='\{self.color.toSvg()}'"
  if self.bold && self.italic {
    base + " font-weight='bold' font-style='italic'"
  } else if self.bold {
    base + " font-weight='bold'"
  } else if self.italic {
    base + " font-style='italic'"
  } else {
    base
  }
}

// ──── Error value ────

///|
/// Represents the error/uncertainty of a data point.
pub(all) enum ErrorValue {
  /// Symmetric error: ±value (most common in scientific plots).
  Symmetric(Double)
  /// Asymmetric error: [lo, hi] range (e.g., confidence intervals).
  Asymmetric(Double, Double)
}

///|
/// Get the lower bound of an error value relative to the data point.
pub fn ErrorValue::lo(self : ErrorValue) -> Double {
  match self {
    Symmetric(v) => -v
    Asymmetric(lo, _) => lo
  }
}

///|
/// Get the upper bound of an error value relative to the data point.
pub fn ErrorValue::hi(self : ErrorValue) -> Double {
  match self {
    Symmetric(v) => v
    Asymmetric(_, hi) => hi
  }
}

// ──── Data point ────

///|
/// A single data point in a series.
pub struct DataPoint {
  /// X value (numeric, interpreted by the x-axis scale).
  x : Double
  /// Y value.
  y : Double
  /// Optional Y-axis error bar.
  error_y : ErrorValue?
  /// Optional X-axis error bar (reserved for future use).
  error_x : ErrorValue?
  /// Optional text label to display near this point.
  label : String?
}

///|
/// Create a simple (x, y) data point with no extras.
pub fn DataPoint::new(x : Double, y : Double) -> DataPoint {
  { x, y, error_y: None, error_x: None, label: None }
}

///|
/// Create a data point with a symmetric Y error bar.
pub fn DataPoint::withErrY(x : Double, y : Double, err : Double) -> DataPoint {
  { x, y, error_y: Some(Symmetric(err)), error_x: None, label: None }
}

///|
/// Create a data point with an asymmetric Y error bar.
pub fn DataPoint::withAsymErrY(
  x : Double,
  y : Double,
  lo : Double,
  hi : Double,
) -> DataPoint {
  { x, y, error_y: Some(Asymmetric(lo, hi)), error_x: None, label: None }
}

// ──── Chart type ────

///|
/// The type of chart to render for a series.
pub enum ChartType {
  Bar
  Line
  Scatter
  BoxPlot
}

// ──── Point shape (for line/scatter markers) ────

///|
/// Shape of data point markers.
pub(all) enum PointShape {
  Circle
  Square
  Triangle
  Diamond
  Cross
}

// ──── Line style ────

///|
/// Line dash pattern.
pub(all) enum LineStyle {
  Solid
  Dashed
  Dotted
  DashDot
}

// ──── Axis kind ────

///|
/// The type of axis scale.
pub enum AxisKind {
  /// Linear numeric scale with min/max range.
  Linear(Double, Double)
}

// ──── Axis option ────

///|
/// Configuration for a single axis (X or Y).
pub struct AxisOption {
  /// The scale type for this axis.
  kind : AxisKind
  /// Optional axis label text (e.g., "Time (days)").
  label : String?
  /// X-axis tick positions (data coordinates). Empty = auto-infer from data.
  tickPositions : Array[Double]
  /// X-axis tick labels. Must match tickPositions length if set. Empty = auto-generate.
  tickLabels : Array[String]
  /// Whether to show tick marks. Default: true.
  showTick : Bool
  /// Desired number of ticks (None = auto). Default: None.
  tickCount : Int?
  /// Whether to draw grid lines from this axis. Default: false.
  gridLine : Bool
  /// Tick label font size. Default: 11.
  tickFontSize : Double
  /// Axis label (title) font size. Default: 13.
  labelFontSize : Double
  /// Tick label color. Default: dark gray.
  tickColor : Color
  /// Grid line color. Default: light gray.
  gridColor : Color
  /// Grid line width. Default: 0.5.
  gridWidth : Double
}

///|
/// Create a default linear Y axis [0, 100].
pub fn AxisOption::linearY() -> AxisOption {
  {
    kind: Linear(0.0, 100.0),
    label: None,
    tickPositions: [],
    tickLabels: [],
    showTick: true,
    tickCount: None,
    gridLine: false,
    tickFontSize: 11.0,
    labelFontSize: 13.0,
    tickColor: Color::rgb(60, 60, 60),
    gridColor: Color::rgb(224, 224, 224),
    gridWidth: 0.5,
  }
}

///|
/// Create a default X axis (auto-infer ticks from data).
pub fn AxisOption::defaultX() -> AxisOption {
  {
    kind: Linear(0.0, 1.0),
    label: None,
    tickPositions: [],
    tickLabels: [],
    showTick: true,
    tickCount: None,
    gridLine: false,
    tickFontSize: 11.0,
    labelFontSize: 13.0,
    tickColor: Color::rgb(60, 60, 60),
    gridColor: Color::rgb(224, 224, 224),
    gridWidth: 0.5,
  }
}

///|
/// Set the axis label for this axis. Returns a new AxisOption.
pub fn AxisOption::withLabel(self : AxisOption, label : String) -> AxisOption {
  { ..self, label: Some(label) }
}

// ──── Series ────
// ──── Box group (for box plots) ────

///|
/// A group of raw data for box plot computation.
pub(all) struct BoxGroup {
  /// X-axis position (data coordinate).
  x : Double
  /// Group label (shown on X axis tick).
  label : String
  /// Raw data values.
  values : Array[Double]
}

///|
/// Create a box plot data group.
pub fn BoxGroup::new(
  x : Double,
  label : String,
  values : Array[Double],
) -> BoxGroup {
  { x, label, values }
}

// ──── Series ────

///|
/// A data series: one group of data points with a chart type and style.
pub struct Series {
  /// Display name (shown in legend).
  name : String
  /// Chart type for this series.
  chartType : ChartType
  /// The data points.
  data : Array[DataPoint]
  /// Override the automatic color assignment.
  color : Color?
  /// Line width (for Line charts). Default: 2.0.
  lineWidth : Double
  /// Point marker size (for Line/Scatter). Default: 4.0.
  pointSize : Double
  /// Point marker shape. Default: Circle.
  pointShape : PointShape
  /// Line dash style. Default: Solid.
  lineStyle : LineStyle
  /// Point fill color (None = use series color). Default: None.
  pointFill : Color?
  /// Bar stroke color (None = no stroke). Default: None.
  barStroke : Color?
  /// Bar stroke width. Default: 0.
  barStrokeWidth : Double
  /// Error bar color (None = use series color). Default: Some(black).
  errorColor : Color?
  /// Error bar line width. Default: 1.0.
  errorLineWidth : Double
  /// Error bar cap width (total horizontal bar length). Default: 6.0.
  errorCapWidth : Double
  /// Box plot data groups (for BoxPlot type). Default: empty.
  boxGroups : Array[BoxGroup]
  /// Whether to show outlier points for box plots. Default: true.
  showOutliers : Bool
}

///|
/// Create a bar chart series.
pub fn Series::bar(name : String, data : Array[DataPoint]) -> Series {
  {
    name,
    chartType: Bar,
    data,
    color: None,
    lineWidth: 2.0,
    pointSize: 4.0,
    pointShape: Circle,
    lineStyle: Solid,
    pointFill: None,
    barStroke: None,
    barStrokeWidth: 0.0,
    errorColor: Some(Color::rgb(0, 0, 0)),
    errorLineWidth: 1.0,
    errorCapWidth: 6.0,
    boxGroups: [],
    showOutliers: true,
  }
}

///|
/// Create a line chart series.
pub fn Series::line(name : String, data : Array[DataPoint]) -> Series {
  {
    name,
    chartType: Line,
    data,
    color: None,
    lineWidth: 2.0,
    pointSize: 4.0,
    pointShape: Circle,
    lineStyle: Solid,
    pointFill: None,
    barStroke: None,
    barStrokeWidth: 0.0,
    errorColor: Some(Color::rgb(0, 0, 0)),
    errorLineWidth: 1.0,
    errorCapWidth: 6.0,
    boxGroups: [],
    showOutliers: true,
  }
}

///|
/// Create a box plot series.
pub fn Series::boxplot(name : String, groups : Array[BoxGroup]) -> Series {
  {
    name,
    chartType: BoxPlot,
    data: [],
    color: None,
    lineWidth: 2.0,
    pointSize: 4.0,
    pointShape: Circle,
    lineStyle: Solid,
    pointFill: None,
    barStroke: None,
    barStrokeWidth: 0.0,
    errorColor: Some(Color::rgb(0, 0, 0)),
    errorLineWidth: 1.0,
    errorCapWidth: 6.0,
    boxGroups: groups,
    showOutliers: true,
  }
}

///|
/// Create a scatter chart series.
pub fn Series::scatter(name : String, data : Array[DataPoint]) -> Series {
  {
    name,
    chartType: Scatter,
    data,
    color: None,
    lineWidth: 2.0,
    pointSize: 4.0,
    pointShape: Circle,
    lineStyle: Solid,
    pointFill: None,
    barStroke: None,
    barStrokeWidth: 0.0,
    errorColor: Some(Color::rgb(0, 0, 0)),
    errorLineWidth: 1.0,
    errorCapWidth: 6.0,
    boxGroups: [],
    showOutliers: true,
  }
}

///|
/// Set a custom color for this series.
pub fn Series::withColor(self : Series, c : Color) -> Series {
  { ..self, color: Some(c) }
}

///|
/// Set line width for this series.
pub fn Series::withLineWidth(self : Series, w : Double) -> Series {
  { ..self, lineWidth: w }
}

///|
/// Set point size for this series.
pub fn Series::withPointSize(self : Series, s : Double) -> Series {
  { ..self, pointSize: s }
}

///|
/// Set point shape for this series.
pub fn Series::withPointShape(self : Series, s : PointShape) -> Series {
  { ..self, pointShape: s }
}

///|
/// Set line style (dashed, dotted, etc.).
pub fn Series::withLineStyle(self : Series, s : LineStyle) -> Series {
  { ..self, lineStyle: s }
}

///|
/// Set point fill color.
pub fn Series::withPointFill(self : Series, c : Color) -> Series {
  { ..self, pointFill: Some(c) }
}

///|
/// Set bar stroke color and width.
pub fn Series::withBarStroke(self : Series, c : Color, w : Double) -> Series {
  { ..self, barStroke: Some(c), barStrokeWidth: w }
}

///|
/// Set error bar color (None to inherit series color).
pub fn Series::withErrorColor(self : Series, c : Color?) -> Series {
  { ..self, errorColor: c }
}

///|
/// Set error bar line width.
pub fn Series::withErrorLineWidth(self : Series, w : Double) -> Series {
  { ..self, errorLineWidth: w }
}

///|
/// Set error bar cap width.
pub fn Series::withErrorCapWidth(self : Series, w : Double) -> Series {
  { ..self, errorCapWidth: w }
}

///|
/// Set whether to show outlier points for box plots.
pub fn Series::withShowOutliers(self : Series, show : Bool) -> Series {
  { ..self, showOutliers: show }
}

// ──── Legend position ────

///|
/// Position of the legend within the chart.
pub(all) enum Position {
  TopLeft
  TopCenter
  TopRight
  BottomLeft
  BottomCenter
  BottomRight
  Left
  Right
}

// ──── Margin (value type) ────

///|
/// Chart margin (space around the plot area).
#valtype
pub(all) struct Margin {
  top : Double
  right : Double
  bottom : Double
  left : Double
}

///|
/// Default margin: top=40, right=20, bottom=40, left=50.
pub fn Margin::default() -> Margin {
  { top: 40.0, right: 20.0, bottom: 40.0, left: 50.0 }
}

// ──── Top-level chart option ────

///|
/// Complete chart configuration.
pub struct ChartOption {
  /// Canvas width in pixels. Default: 600.
  width : Double
  /// Canvas height in pixels. Default: 400.
  height : Double
  /// Margins around the plot area.
  margin : Margin
  /// Background color. Default: white.
  background : Color
  /// Chart title (shown centered at the top).
  title : String?
  /// Title font.
  titleFont : Font
  /// X-axis configuration.
  xAxis : AxisOption
  /// Y-axis configuration.
  yAxis : AxisOption
  /// Data series to plot.
  series : Array[Series]
  /// Whether to show the legend. Default: true when series > 1.
  legend : Bool
  /// Legend position. Default: TopRight.
  legendPosition : Position
  /// Legend font size. Default: 12.
  legendFontSize : Double
  /// Bar width ratio (0.0~1.0). Fraction of band width occupied by all bars. Default: 0.7.
  barWidthRatio : Double
  /// Bar gap ratio (0.0~1.0). Gap between bars in a group, as fraction of bar width. Default: 0.0.
  barGap : Double
  /// Global font family. Default: "sans-serif".
  fontFamily : String
}

///|
/// Create a default ChartOption with given axes and series.
pub fn ChartOption::new(
  xAxis : AxisOption,
  yAxis : AxisOption,
  series : Array[Series],
) -> ChartOption {
  {
    width: 600.0,
    height: 400.0,
    margin: Margin::default(),
    background: Color::rgb(255, 255, 255),
    title: None,
    titleFont: Font::title(),
    xAxis,
    yAxis,
    series,
    legend: series.length() > 1,
    legendPosition: TopRight,
    legendFontSize: 12.0,
    barWidthRatio: 0.7,
    barGap: 0.0,
    fontFamily: "sans-serif",
  }
}
