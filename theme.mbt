// Default theme: colors, fonts, and style constants.

///|
/// 6-color colorblind-friendly palette.
pub fn palette(index : Int) -> Color {
  let colors = [
    Color::rgb(0x00, 0x7A, 0xB8), // Blue
    Color::rgb(0xF4, 0x86, 0x34), // Orange
    Color::rgb(0x38, 0xA4, 0x4A), // Green
    Color::rgb(0xD5, 0x39, 0x39), // Red
    Color::rgb(0x94, 0x6A, 0xBD), // Purple
    Color::rgb(0x73, 0x5C, 0x4B), // Brown
  ]
  colors[index % colors.length()]
}

///|
/// Get the color for a series by its index (0-based).
pub fn seriesColor(index : Int) -> Color {
  palette(index)
}

///|
/// Default chart width in pixels.
pub const DEFAULT_WIDTH : Double = 600.0

///|
/// Default chart height in pixels.
pub const DEFAULT_HEIGHT : Double = 400.0

///|
/// Default line width for line charts.
pub const DEFAULT_LINE_WIDTH : Double = 2.0

///|
/// Default point marker radius for scatter/line charts.
pub const DEFAULT_POINT_SIZE : Double = 4.0

///|
/// Default error bar cap width (horizontal crossbar).
pub const DEFAULT_ERROR_CAP_WIDTH : Double = 6.0

///|
/// Default error bar line width.
pub const DEFAULT_ERROR_LINE_WIDTH : Double = 1.0

///|
/// Default axis line color.
pub fn axisColor() -> Color {
  Color::rgb(50, 50, 50)
}

///|
/// Default axis tick label font.
pub fn tickFont() -> Font {
  {
    family: "sans-serif",
    size: 11.0,
    color: Color::rgb(60, 60, 60),
    bold: false,
    italic: false,
  }
}

///|
/// Default axis title font.
pub fn axisTitleFont() -> Font {
  {
    family: "sans-serif",
    size: 13.0,
    color: Color::rgb(0, 0, 0),
    bold: false,
    italic: false,
  }
}

///|
/// Default title font.
pub fn titleFont() -> Font {
  Font::title()
}

///|
/// Background color.
pub fn backgroundColor() -> Color {
  Color::rgb(255, 255, 255)
}

///|
/// Legend item font.
pub fn legendFont() -> Font {
  {
    family: "sans-serif",
    size: 12.0,
    color: Color::rgb(0, 0, 0),
    bold: false,
    italic: false,
  }
}
