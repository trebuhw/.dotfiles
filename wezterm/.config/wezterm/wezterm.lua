local wezterm = require 'wezterm'  -- Zaimportowanie API wezterm
local act = wezterm.action  -- Skróty do akcji wezterm

-- Używamy konfiguratora wezterm, jeśli dostępny
local config = wezterm.config_builder and wezterm.config_builder() or {}

-- Ustawienie marginesów
config.window_padding = {
  top = 0,    -- Usuwa dodatkową pustą linię na górze
  right = 0,  -- Brak marginesu po prawej
  bottom = 0, -- Brak marginesu na dole
  left = 0,   -- Brak marginesu po lewej
}

-- Konfiguracja kolorów zakładek
config.colors = {
  tab_bar = {
    -- Tło paska zakładek
    background = "#1e1e2e",  -- Kolor tła paska zakładek (ciemny odcień szarości)

    -- Aktywna zakładka
    active_tab = {
      bg_color = "#313244",  -- Kolor tła aktywnej zakładki
      fg_color = "#cdd6f4",  -- Kolor tekstu aktywnej zakładki
    },

    -- Nieaktywne zakładki
    inactive_tab = {
      bg_color = "#1e1e2e",  -- Kolor tła nieaktywnych zakładek
      fg_color = "#cdd6f4",  -- Kolor tekstu nieaktywnych zakładek
    },

    -- Zakładki, na które najeżdżasz myszką
    inactive_tab_hover = {
      bg_color = "#313244",  -- Kolor tła nieaktywnej zakładki po najechaniu myszką
      fg_color = "#cdd6f4",  -- Kolor tekstu nieaktywnej zakładki po najechaniu myszką
      italic = true,  -- Ustawienie kursywy na zakładkach podczas najeżdżania
    },

    -- Nowy przycisk tab (np. '+')
    new_tab = {
      bg_color = "#313244",  -- Kolor tła nowej zakładki
      fg_color = "#cdd6f4",  -- Kolor tekstu przycisku nowej zakładki
    },

    -- Nowy przycisk tab po najechaniu myszką
    new_tab_hover = {
      bg_color = "#313244",  -- Kolor tła przycisku nowej zakładki po najechaniu myszką
      fg_color = "#cdd6f4",  -- Kolor tekstu przycisku nowej zakładki po najechaniu myszką
    },
  },
}

-- Umiejscowienie paska zakładek na dole okna
config.tab_bar_at_bottom = true  -- Ustawienie paska zakładek na dole okna

-- Ukrywanie paska zakładek, jeśli jest tylko jedna zakładka
config.hide_tab_bar_if_only_one_tab = true  -- Ukrywa pasek zakładek, jeśli jest tylko jedna zakładka

-- Wyłączenie zaawansowanego paska zakładek (mniej ozdobny)
config.use_fancy_tab_bar = false  -- Wyłącza ozdobny pasek zakładek

-- Pozostałe ustawienia konfiguracyjne
config.use_dead_keys = false  -- Wyłącza klawisze martwe (przydatne dla niektórych aplikacji CLI)
config.scrollback_lines = 5000  -- Ustala liczbę linii historii terminala, które będą przechowywane
config.color_scheme = 'catppuccin-mocha'  -- Ustawienie schematu kolorów na 'catppuccin mocha'
config.font_size = 13  -- Ustawienie rozmiaru czcionki
config.font = wezterm.font('CaskaydiaCove Nerd Font', { weight = 'Regular', italic = false })  -- Czcionka tylko 'JetBrainsMono Nerd Font'
config.max_fps = 60
config.animation_fps = 1
config.line_height = 1.1
config.window_background_opacity = 0.9
config.enable_scroll_bar = false
config.term = "xterm-256color"
config.warn_about_missing_glyphs = false
config.adjust_window_size_when_changing_font_size = false
config.enable_wayland = false
 
-- Styl kursora dostępne opcje (SteadyBlock, BlinkingBlock, SteadyUnderline, BlinkingUnderline, SteadyBar,BlinkingBar)
config.default_cursor_style = 'BlinkingBar'  -- Ustawienie kursora na migającą linię

-- Konfiguracja kolorów kursora 
config.colors = {
  cursor_bg = '#cdd6f4',
  cursor_fg = '#cdd6f4',
  cursor_border = '#cdd6f4', 
}

-- Konfiguracja ramki okna (np. pasek tytułowy)
config.window_frame = {
  font = wezterm.font { family = 'JetBrainsMono Nerd Font', weight = 'Bold' },  -- Czcionka w pasku tytułowym
  font_size = 12.0,  -- Rozmiar czcionki w pasku tytułowym
  active_titlebar_bg = '#4c566a',  -- Tło aktywnego paska tytułowego
  inactive_titlebar_bg = '#2e3440',  -- Tło nieaktywnego paska tytułowego
}

-- Wyłączenie domyślnych skrótów klawiaturowych
config.disable_default_key_bindings = true  -- Wyłącza domyślne skróty klawiaturowe

-- Efficient keybinding helper function
local function key_binding(key_table)
  local result = {}
  for i, binding in ipairs(key_table) do
    table.insert(result, {
      mods = binding[1] or "ALT",
      key = binding[2],
      action = binding[3]
    })
  end
  return result
end

-- Skróty klawiaturowe
   
-- Key bindings configuration
config.keys = key_binding({
  -- Split and manage panes
  {"ALT", "`", act.SplitPane { direction = "Right", size = { Percent = 30 }}},
  {"ALT", "Tab", act.SplitPane { direction = "Down", size = { Percent = 30 }}},
  {"ALT", "Enter", act.SplitHorizontal { domain = 'CurrentPaneDomain' }},
  {"ALT", "\\", act.SplitVertical { domain = 'CurrentPaneDomain' }},
  {"ALT", "w", act.CloseCurrentPane { confirm = true }},
  {"ALT", "LeftArrow", act.ActivatePaneDirection 'Left'},
  {"ALT", "RightArrow", act.ActivatePaneDirection 'Right'},
  {"ALT", "UpArrow", act.ActivatePaneDirection 'Up'},
  {"ALT", "DownArrow", act.ActivatePaneDirection 'Down'},
  
  -- Tab creation, navigation and management
  {"ALT", "t", act.SpawnTab 'CurrentPaneDomain'},
  {"ALT", "q", act.CloseCurrentTab { confirm = true }},
  {"ALT", "1", act.ActivateTab(0)},
  {"ALT", "2", act.ActivateTab(1)},
  {"ALT", "3", act.ActivateTab(2)},
  {"ALT", "4", act.ActivateTab(3)},
  {"ALT", "5", act.ActivateTab(4)},
  {"ALT", "6", act.ActivateTab(5)},
  {"ALT", "7", act.ActivateTab(6)},
  {"ALT", "8", act.ActivateTab(7)},
  {"CTRL|ALT", "UpArrow", act.ActivateLastTab},
  {"CTRL|ALT", "DownArrow", act.ActivateLastTab},
  {"CTRL|ALT", "1", act.MoveTab(0)},
  {"CTRL|ALT", "2", act.MoveTab(1)},
  {"CTRL|ALT", "3", act.MoveTab(2)},
  {"CTRL|ALT", "4", act.MoveTab(3)},
  {"CTRL|ALT", "5", act.MoveTab(4)},
  {"CTRL|ALT", "6", act.MoveTab(5)},
  {"CTRL|ALT", "7", act.MoveTab(6)},
  {"CTRL|ALT", "8", act.MoveTab(7)},
  {"CTRL|ALT", "LeftArrow", act.MoveTabRelative(-1)},
  {"CTRL|ALT", "RightArrow", act.MoveTabRelative(1)},
  {"CTRL|ALT", "n", act.ActivateTabRelative(1)},
  {"CTRL|ALT", "p", act.ActivateTabRelative(-1)},
  
  -- Copy and paste operations
  {"ALT", "c", act.CopyTo 'ClipboardAndPrimarySelection'},
  {"ALT", "v", act.PasteFrom 'PrimarySelection'},
  {"ALT", "v", act.PasteFrom 'Clipboard'},
  
  -- Font size adjustments
  {"ALT", "+", act.IncreaseFontSize},
  {"ALT", "-", act.DecreaseFontSize},
  {"ALT", "*", act.ResetFontSize},
})
-- { key = 'L', mods = 'CTRL', action = act.ShowDebugOverlay }

-- Zwrócenie konfiguracji do wezterm
return config
