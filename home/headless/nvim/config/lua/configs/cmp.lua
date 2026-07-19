local cmp = require "cmp"

return {
  mapping = cmp.mapping.preset.insert {
    -- tab accepts the selected item (or the first one if none navigated)
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm { select = true }
      else
        fallback()
      end
    end, { "i", "s" }),

    -- enter is a plain newline, never accepts
    ["<CR>"] = cmp.mapping(function(fallback)
      fallback()
    end),
  },
}
