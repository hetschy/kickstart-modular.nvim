return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      local hipatterns = require 'mini.hipatterns'

      -- Returns hex color group for matching short hex color.
      --
      ---@param match string
      ---@return string
      local hex_color_short = function(_, match)
        local style = 'fg' -- 'fg' or 'bg', for extmark_opts_inline use 'fg'
        local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
        local hex = string.format('#%s%s%s%s%s%s', r, r, g, g, b, b)
        return hipatterns.compute_hex_color_group(hex, style)
      end

      -- Returns hex color group for matching rgb() color.
      --
      ---@param match string
      ---@return string
      local rgb_color = function(_, match)
        local style = 'fg' -- 'fg' or 'bg', for extmark_opts_inline use 'fg'
        local red, green, blue = match:match 'rgb%((%d+), ?(%d+), ?(%d+)%)'
        local hex = string.format('#%02x%02x%02x', red, green, blue)
        return hipatterns.compute_hex_color_group(hex, style)
      end

      -- Returns hex color group for matching rgba() color
      -- or false if alpha is nil or out of range.
      -- The use of the alpha value refers to a black background.
      --
      ---@param match string
      ---@return string|false
      local rgba_color = function(_, match)
        local style = 'fg' -- 'fg' or 'bg', for extmark_opts_inline use 'fg'
        local red, green, blue, alpha = match:match 'rgba%((%d+), ?(%d+), ?(%d+), ?(%d*%.?%d*)%)'
        alpha = tonumber(alpha)
        if alpha == nil or alpha < 0 or alpha > 1 then
          return false
        end
        local hex = string.format('#%02x%02x%02x', red * alpha, green * alpha, blue * alpha)
        return hipatterns.compute_hex_color_group(hex, style)
      end

      -- Returns extmark opts for highlights with virtual inline text.
      --
      ---@param data table Includes `hl_group`, `full_match` and more.
      ---@return table
      local extmark_opts_inline = function(_, _, data)
        return {
          virt_text = { { ' ', data.hl_group } },
          virt_text_pos = 'inline',
          -- priority = 200,
          right_gravity = false,
        }
      end

      hipatterns.setup {
        highlighters = {
          -- `#rrggbb`
          -- hex_color = hipatterns.gen_highlighter.hex_color({ style = 'full' }),
          hex_color = hipatterns.gen_highlighter.hex_color { style = 'inline', inline_text = ' ' },
          -- `#rgb`
          hex_color_short = { pattern = '#%x%x%x%f[%X]', group = hex_color_short, extmark_opts = extmark_opts_inline },
          -- `rgb(255, 255, 255)`
          rgb_color = { pattern = 'rgb%(%d+, ?%d+, ?%d+%)', group = rgb_color, extmark_opts = extmark_opts_inline },
          -- `rgba(255, 255, 255, 0.5)`
          rgba_color = {
            pattern = 'rgba%(%d+, ?%d+, ?%d+, ?%d*%.?%d*%)',
            group = rgba_color,
            extmark_opts = extmark_opts_inline,
          },
        },
      }

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
