local wezterm = require 'wezterm'
local config  = wezterm.config_builder()

-- Font: Menlo — Apple's built-in monospace, always available
config.font      = wezterm.font('Menlo', { weight = 'Regular' })
config.font_size = 14.0

-- Colors: Catppuccin Mocha palette + pure black background override
config.color_scheme = 'Catppuccin Mocha'
config.colors = {
  background = '#000000',
}

-- Window
config.window_padding = { left = 8, right = 8, top = 8, bottom = 8 }
config.hide_tab_bar_if_only_one_tab = true

-- Option key as Alt (needed for tmux Alt+arrow, M-h/l, etc.)
config.send_composed_key_when_left_alt_is_pressed  = false
config.send_composed_key_when_right_alt_is_pressed = false

-- Shell
config.default_prog = { '/opt/homebrew/bin/bash', '--login' }

return config
