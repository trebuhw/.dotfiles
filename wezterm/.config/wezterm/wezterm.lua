local wezterm = require 'wezterm'
local act = wezterm.action

-- Używamy konfiguratora wezterm, jeśli dostępny
local config = wezterm.config_builder and wezterm.config_builder() or {}

-- OPTYMALIZACJE WYDAJNOŚCI
-- Wyłączenie niepotrzebnych funkcji dla szybszego startu
config.check_for_updates = false
config.automatically_reload_config = false
config.enable_kitty_keyboard = false
config.enable_csi_u_key_encoding = false

-- Podstawowe ustawienia terminala
config.default_prog = { "/usr/bin/fish" }
config.term = "xterm-256color"

-- Ustawienia okna - zoptymalizowane
config.initial_cols = 110
config.initial_rows = 30
config.window_padding = { top = 0, right = 0, bottom = 0, left = 0 }
config.window_background_opacity = 0.9
config.adjust_window_size_when_changing_font_size = false

-- Wydajność renderowania - zoptymalizowane dla szybkości
config.max_fps = 60
config.animation_fps = 1  -- Minimalne animacje dla szybszego UI
config.cursor_blink_rate = 800  -- Rzadsze mruganie kursora
config.scrollback_lines = 3000  -- Zmniejszone z 5000 dla lepszej wydajności

-- Czcionka i wyświetlanie
config.font_size = 12
config.font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Regular' })
config.line_height = 1.1
config.warn_about_missing_glyphs = false
config.use_dead_keys = false

-- Paski i UI - zoptymalizowane
config.enable_scroll_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.enable_wayland = false

-- Kursor
config.default_cursor_style = 'BlinkingBar'

-- Schemat kolorów - kompaktowy
config.color_scheme = 'catppuccin-mocha'

-- Zoptymalizowana konfiguracja kolorów - tylko niezbędne
config.colors = {
  cursor_bg = '#cdd6f4',
  cursor_fg = '#cdd6f4',
  cursor_border = '#cdd6f4',
  tab_bar = {
    background = "#1e1e2e",
    active_tab = { bg_color = "#313244", fg_color = "#cdd6f4" },
    inactive_tab = { bg_color = "#1e1e2e", fg_color = "#cdd6f4" },
    inactive_tab_hover = { bg_color = "#313244", fg_color = "#cdd6f4", italic = true },
    new_tab = { bg_color = "#313244", fg_color = "#cdd6f4" },
    new_tab_hover = { bg_color = "#313244", fg_color = "#cdd6f4" },
  },
}

-- Ramka okna - uproszczona
config.window_frame = {
  font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Bold' }),
  font_size = 12.0,
  active_titlebar_bg = '#4c566a',
  inactive_titlebar_bg = '#2e3440',
}

-- Wyłączenie domyślnych skrótów
config.disable_default_key_bindings = true

-- Zoptymalizowana funkcja tworzenia skrótów
local function create_keybinds(bindings)
  local keys = {}
  for _, bind in ipairs(bindings) do
    keys[#keys + 1] = { mods = bind[1], key = bind[2], action = bind[3] }
  end
  return keys
end

-- Skróty klawiaturowe - szczegółowe komentarze
config.keys = create_keybinds({
  -- ZARZĄDZANIE PANELAMI (podziały okna)
  {"ALT", "`", act.SplitPane { direction = "Right", size = { Percent = 30 }}},        -- ALT+` - podział w prawo (30%)
  {"ALT", "Tab", act.SplitPane { direction = "Down", size = { Percent = 30 }}},       -- ALT+Tab - podział w dół (30%)
  {"ALT", "Enter", act.SplitHorizontal { domain = 'CurrentPaneDomain' }},             -- ALT+Enter - podział poziomy (50/50)
  {"ALT", "\\", act.SplitVertical { domain = 'CurrentPaneDomain' }},                  -- ALT+\ - podział pionowy (50/50)
  {"ALT", "w", act.CloseCurrentPane { confirm = true }},                              -- ALT+w - zamknij aktywny panel (z potwierdzeniem)
  
  -- NAWIGACJA MIĘDZY PANELAMI
  {"ALT", "LeftArrow", act.ActivatePaneDirection 'Left'},                             -- ALT+← - przejdź do panelu po lewej
  {"ALT", "RightArrow", act.ActivatePaneDirection 'Right'},                           -- ALT+→ - przejdź do panelu po prawej
  {"ALT", "UpArrow", act.ActivatePaneDirection 'Up'},                                 -- ALT+↑ - przejdź do panelu powyżej
  {"ALT", "DownArrow", act.ActivatePaneDirection 'Down'},                             -- ALT+↓ - przejdź do panelu poniżej
  
  -- TWORZENIE I ZAMYKANIE ZAKŁADEK
  {"ALT", "t", act.SpawnTab 'CurrentPaneDomain'},                                     -- ALT+t - nowa zakładka
  {"ALT", "q", act.CloseCurrentTab { confirm = true }},                               -- ALT+q - zamknij zakładkę (z potwierdzeniem)
  
  -- PRZEŁĄCZANIE MIĘDZY ZAKŁADKAMI (numery)
  {"ALT", "1", act.ActivateTab(0)},                                                   -- ALT+1 - przejdź do zakładki 1
  {"ALT", "2", act.ActivateTab(1)},                                                   -- ALT+2 - przejdź do zakładki 2
  {"ALT", "3", act.ActivateTab(2)},                                                   -- ALT+3 - przejdź do zakładki 3
  {"ALT", "4", act.ActivateTab(3)},                                                   -- ALT+4 - przejdź do zakładki 4
  {"ALT", "5", act.ActivateTab(4)},                                                   -- ALT+5 - przejdź do zakładki 5
  {"ALT", "6", act.ActivateTab(5)},                                                   -- ALT+6 - przejdź do zakładki 6
  {"ALT", "7", act.ActivateTab(6)},                                                   -- ALT+7 - przejdź do zakładki 7
  {"ALT", "8", act.ActivateTab(7)},                                                   -- ALT+8 - przejdź do zakładki 8
  
  -- PRZEŁĄCZANIE MIĘDZY ZAKŁADKAMI (specjalne)
  {"CTRL|ALT", "UpArrow", act.ActivateLastTab},                                       -- CTRL+ALT+↑ - przejdź do ostatnio używanej zakładki
  {"CTRL|ALT", "DownArrow", act.ActivateLastTab},                                     -- CTRL+ALT+↓ - przejdź do ostatnio używanej zakładki
  
  -- PRZENOSZENIE ZAKŁADEK (pozycje numeryczne)
  {"CTRL|ALT", "1", act.MoveTab(0)},                                                  -- CTRL+ALT+1 - przenieś zakładkę na pozycję 1
  {"CTRL|ALT", "2", act.MoveTab(1)},                                                  -- CTRL+ALT+2 - przenieś zakładkę na pozycję 2
  {"CTRL|ALT", "3", act.MoveTab(2)},                                                  -- CTRL+ALT+3 - przenieś zakładkę na pozycję 3
  {"CTRL|ALT", "4", act.MoveTab(3)},                                                  -- CTRL+ALT+4 - przenieś zakładkę na pozycję 4
  {"CTRL|ALT", "5", act.MoveTab(4)},                                                  -- CTRL+ALT+5 - przenieś zakładkę na pozycję 5
  {"CTRL|ALT", "6", act.MoveTab(5)},                                                  -- CTRL+ALT+6 - przenieś zakładkę na pozycję 6
  {"CTRL|ALT", "7", act.MoveTab(6)},                                                  -- CTRL+ALT+7 - przenieś zakładkę na pozycję 7
  {"CTRL|ALT", "8", act.MoveTab(7)},                                                  -- CTRL+ALT+8 - przenieś zakładkę na pozycję 8
  
  -- PRZENOSZENIE ZAKŁADEK (relatywnie)
  {"CTRL|ALT", "LeftArrow", act.MoveTabRelative(-1)},                                 -- CTRL+ALT+← - przenieś zakładkę w lewo
  {"CTRL|ALT", "RightArrow", act.MoveTabRelative(1)},                                 -- CTRL+ALT+→ - przenieś zakładkę w prawo
  {"CTRL|ALT", "n", act.ActivateTabRelative(1)},                                      -- CTRL+ALT+n - następna zakładka
  {"CTRL|ALT", "p", act.ActivateTabRelative(-1)},                                     -- CTRL+ALT+p - poprzednia zakładka
  
  -- OPERACJE SCHOWKA
  {"ALT", "c", act.CopyTo 'ClipboardAndPrimarySelection'},                            -- ALT+c - kopiuj do schowka i primary selection
  {"ALT", "v", act.PasteFrom 'Clipboard'},                                            -- ALT+v - wklej ze schowka
  
  -- KONTROLA ROZMIARU CZCIONKI
  {"ALT", "+", act.IncreaseFontSize},                                                  -- ALT++ - zwiększ rozmiar czcionki
  {"ALT", "-", act.DecreaseFontSize},                                                  -- ALT+- - zmniejsz rozmiar czcionki
  {"ALT", "*", act.ResetFontSize},                                                     -- ALT+* - resetuj rozmiar czcionki do domyślnego
})

return config
