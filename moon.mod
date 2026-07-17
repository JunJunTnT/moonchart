// Learn more about moon.mod configuration:
// https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html
//
// To add a dependency, run this command in your terminal:
//   moon add moonbitlang/x
//
// Or manually declare it in `import`, for example:
// import {
//   "moonbitlang/x@0.4.6",
// }

name = "JunJunTnT/moonchart"

version = "0.1.1"

readme = "README.md"

repository = "https://github.com/JunJunTnT/moonchart"

license = "Apache-2.0"

keywords = [ "chart", "plot", "svg", "visualization", "statistics", "science" ]

description = "A statistical chart SVG generation library for MoonBit. Supports bar charts, line charts, scatter plots with error bars and multi-series rendering."

import {
  "moonbitlang/x@0.4.44",
}
