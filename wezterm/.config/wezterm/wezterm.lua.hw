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
    background = "#2E3440",  -- Kolor tła paska zakładek (ciemny odcień szarości)

    -- Aktywna zakładka
    active_tab = {
      bg_color = "#4C566A",  -- Kolor tła aktywnej zakładki
      fg_color = "#ECEFF4",  -- Kolor tekstu aktywnej zakładki
    },

    -- Nieaktywne zakładki
    inactive_tab = {
      bg_color = "#3B4252",  -- Kolor tła nieaktywnych zakładek
      fg_color = "#D8DEE9",  -- Kolor tekstu nieaktywnych zakładek
    },

    -- Zakładki, na które najeżdżasz myszką
    inactive_tab_hover = {
      bg_color = "#434C5E",  -- Kolor tła nieaktywnej zakładki po najechaniu myszką
      fg_color = "#ECEFF4",  -- Kolor tekstu nieaktywnej zakładki po najechaniu myszką
      italic = true,  -- Ustawienie kursywy na zakładkach podczas najeżdżania
    },

    -- Nowy przycisk tab (np. '+')
    new_tab = {
      bg_color = "#2E3440",  -- Kolor tła nowej zakładki
      fg_color = "#D8DEE9",  -- Kolor tekstu przycisku nowej zakładki
    },

    -- Nowy przycisk tab po najechaniu myszką
    new_tab_hover = {
      bg_color = "#434C5E",  -- Kolor tła przycisku nowej zakładki po najechaniu myszką
      fg_color = "#ECEFF4",  -- Kolor tekstu przycisku nowej zakładki po najechaniu myszką
    },
  },
}

-- Umiejscowienie paska zakładek na dole okna
config.tab_bar_at_bottom = true  -- Ustawienie paska zakładek na dole okna

-- Pozostałe ustawienia konfiguracyjne
config.use_dead_keys = false  -- Wyłącza klawisze martwe (przydatne dla niektórych aplikacji CLI)
-- config.scrollback_lines = 5000  -- Ustala liczbę linii historii terminala, które będą przechowywane
config.color_scheme = 'catppuccin-mocha'  -- Ustawienie schematu kolorów na 'catppuccin mocha'
-- config.color_scheme = 'nord'  -- Ustawienie schematu kolorów na 'nord'
config.font_size = 12  -- Ustawienie rozmiaru czcionki
config.font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Regular', italic = false })  -- Czcionka tylko 'JetBrainsMono Nerd Font'

-- Konfiguracja ramki okna (np. pasek tytułowy)
config.window_frame = {
  font = wezterm.font { family = 'JetBrainsMono Nerd Font', weight = 'Bold' },  -- Czcionka w pasku tytułowym
  font_size = 12.0,  -- Rozmiar czcionki w pasku tytułowym
  active_titlebar_bg = '#4c566a',  -- Tło aktywnego paska tytułowego
  inactive_titlebar_bg = '#2e3440',  -- Tło nieaktywnego paska tytułowego
}

-- Styl kursora dostępne opcje (SteadyBlock, BlinkingBlock, SteadyUnderline, BlinkingUnderline, SteadyBar,BlinkingBar)
config.default_cursor_style = 'BlinkingBar'  -- Ustawienie kursora na migającą linię

-- Ukrywanie paska zakładek, jeśli jest tylko jedna zakładka
config.hide_tab_bar_if_only_one_tab = true  -- Ukrywa pasek zakładek, jeśli jest tylko jedna zakładka

-- Wyłączenie zaawansowanego paska zakładek (mniej ozdobny)
config.use_fancy_tab_bar = false  -- Wyłącza ozdobny pasek zakładek

-- Wyłączenie domyślnych skrótów klawiaturowych
config.disable_default_key_bindings = true  -- Wyłącza domyślne skróty klawiaturowe

-- Skróty klawiaturowe
config.keys = {
  -- Tworzenie nowej zakładki w bieżącej domenie
  { key = 't', mods = 'ALT|SHIFT', action = act.SpawnTab("CurrentPaneDomain") },

  -- Zamknięcie bieżącej zakładki
  { key = 'w', mods = 'ALT|SHIFT', action = wezterm.action.CloseCurrentPane { confirm = false } },

  -- Rozdzielanie poziomego panelu
  { key = 'h', mods = 'ALT|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- Rozdzielanie pionowego panelu
  { key = 'v', mods = 'ALT|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },

  -- Poruszanie się do panelu powyżej
  { key = 'UpArrow', mods = 'ALT|SHIFT', action = wezterm.action.ActivatePaneDirection("Up") },

  -- Poruszanie się do panelu poniżej
  { key = 'DownArrow', mods = 'ALT|SHIFT', action = wezterm.action.ActivatePaneDirection("Down") },

  -- Poruszanie się do panelu po lewej
  { key = 'LeftArrow', mods = 'ALT|SHIFT', action = wezterm.action.ActivatePaneDirection("Left") },

  -- Poruszanie się do panelu po prawej
  { key = 'RightArrow', mods = 'ALT|SHIFT', action = wezterm.action.ActivatePaneDirection("Right") },

  -- Kopiowanie do schowka
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo("Clipboard") },

  -- Wklejanie ze schowka
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom("Clipboard") },

   -- Wyświetlenie nakładki debugowania
  { key = 'L', mods = 'CTRL', action = act.ShowDebugOverlay }

}


-- Zdarzenie przy zamykaniu terminala
wezterm.on("quit", function() wezterm.shutdown() end)  -- Automatyczne zamknięcie wezterm bez potwierdzenia

-- Zwrócenie konfiguracji do wezterm
return config
