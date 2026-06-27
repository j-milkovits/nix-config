-- This file  needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "catppuccin",
  -- transparency = true,
  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
    NvDashAscii = {
      bg = "none",
      fg = "#7FBBB3",
    },
  },
}

M.ui = {
  tabufline = {
    order = { "treeOffset", "buffers", "tabs", "btns" },
  },
  statusline = {
    theme = "default",
    separator_style = "block",
  },
}

M.nvdash = {
  load_on_startup = true,
  header = {
    [[                                                   ]],
    [[                                              ___  ]],
    [[                                           ,o88888 ]],
    [[                                        ,o8888888' ]],
    [[                  ,:o:o:oooo.        ,8O88Pd8888"  ]],
    [[              ,.::.::o:ooooOoOo:. ,oO8O8Pd888'"    ]],
    [[            ,.:.::o:ooOoOoOO8O8OOo.8OOPd8O8O"      ]],
    [[           , ..:.::o:ooOoOOOO8OOOOo.FdO8O8"        ]],
    [[          , ..:.::o:ooOoOO8O888O8O,COCOO"          ]],
    [[         , . ..:.::o:ooOoOOOO8OOOOCOCO"            ]],
    [[          . ..:.::o:ooOoOoOO8O8OCCCC"o             ]],
    [[             . ..:.::o:ooooOoCoCCC"o:o             ]],
    [[             . ..:.::o:o:,cooooCo"oo:o:            ]],
    [[          `   . . ..:.:cocoooo"'o:o:::'            ]],
    [[          .`   . ..::ccccoc"'o:o:o:::'             ]],
    [[         :.:.    ,c:cccc"':.:.:.:.:.'              ]],
    [[       ..:.:"'`::::c:"'..:.:.:.:.:.'               ]],
    [[     ...:.'.:.::::"'    . . . . .'                 ]],
    [[    .. . ....:."' `   .  . . ''                    ]],
    [[  . . . ...."'                                     ]],
    [[  .. . ."'                                         ]],
    [[ .                                                 ]],
    [[                                                   ]],
  },
}

return M
