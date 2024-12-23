return {
  ["config"] = {
    ["message_timeout"] = 3,
    ["plugins"] = {
      ["autowrap"] = {
        ["enabled"] = true,
        ["files"] = {
          [10] = "%.json$",
          [11] = "%.css$",
          [12] = "%.lua$",
          [13] = "%.py$",
          [14] = "%.rasi$",
          [15] = "%.xml$",
          [16] = "%.rc$",
          [17] = "%.list$",
          [1] = "%.md$",
          [2] = "%.txt$",
          [3] = "%.sh$",
          [4] = "%.toml$",
          [5] = "%.yaml$",
          [6] = "%.fish$",
          [7] = "%.ini$",
          [8] = "%.conf$",
          [9] = "%config$"
        }
      },
      ["linewrapping"] = {
        ["enable_by_default"] = true,
        ["mode"] = "word"
      },
      ["minimap"] = {
        ["caret_color"] = {
          [1] = 248,
          [2] = 248,
          [3] = 240,
          [4] = 255
        },
        ["instant_scroll"] = true,
        ["selection_color"] = {
          [1] = 79,
          [2] = 88,
          [3] = 115,
          [4] = 255
        }
      },
      ["terminal"] = {
        ["background"] = {
          [1] = 40,
          [2] = 42,
          [3] = 54,
          [4] = 255
        },
        ["text"] = {
          [1] = 248,
          [2] = 248,
          [3] = 242,
          [4] = 255
        }
      }
    },
    ["theme"] = "dracula"
  }
}
