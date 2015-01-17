#==============================================================================
# ** Keys
#------------------------------------------------------------------------------
# Module relatif aux touches
#==============================================================================

module Keys
  #--------------------------------------------------------------------------
  # * Listes de toutes les touches 
  #--------------------------------------------------------------------------
  n = :none
  All = [
    n, :mouse_left, :mouse_right, :cancel, :mouse_center, :mouse_x1,
    :mouse_x2, n, :backspace, :tab] + ([n]*2) + [:clear, :enter] + ([n]*2) + 
    [:shift, :control, :alt, :pause, :caps_lock, :hangul, n,
    :junja, :final, :kanji, n, :esc, :convert, :nonconvert,
    :accept, :modechange, :space, :page_up, :page_down, :end, :home, :left,
    :up, :right, :down, :select, :print, :execute, :snapshot, :insert, 
    :delete, :help] + (0..9).to_a + ([n]*7) + (:a..:z).to_a + [
    :lwindow, :rwindow, :apps, n, :sleep] + (:num_0 .. :num_9).to_a + [
    :multiply, :add, :separator, :substract, :decimal, :divide] + (:f1..:f9).to_a + 
    (:f10..:f19).to_a+(:f9..:f19).to_a + (:f20..:f24).to_a + ([n]*8) + 
    [:num_lock, :scroll_lock] + ([n]*14) + [:lshift, :rshift, :lcontrol, 
    :rcontrol, :lmenu, :rmenu, :browser_back, :browser_forward, 
    :browser_refresh, :browser_stop, :browser_search, :browser_favorites, 
    :browser_home, :volume_mute, :volume_down, :volume_up, :media_next_track, 
    :media_prev_track, :media_stop, :media_play_pause, :launch_mail, 
    :launch_media_select, :launch_app1, :launch_app2] + ([n]*2) + [
    :oem_1, :oem_plus, :oem_comma,:oem_minus, :oem_period, :oem_2, :oem_3] + 
    ([n]*26) + (:oem_4..:oem_8).to_a + ([n]*2) + [:oem_102] + ([n]*2) + 
    [:process, n, :packet] + ([n]*14) + [:attn, :crsel, :exsel, :ereof, 
    :play, :zoom, :noname, :pa1, :oem_clear, n, :DOWN, :LEFT, :RIGHT, :UP,
    :A, :B, :C, :X, :Y, :Z, :L, :R, :SHIFT, :CTRL, :ALT] + (:F5..:F9).to_a
  #--------------------------------------------------------------------------
  # * Accès rapide a un code en fonction de sa valeur
  #--------------------------------------------------------------------------
  define_singleton_method(:get) do |k| 
    Keys::All.index(k)
  end
end

#==============================================================================
# ** AbstractKeyboard
#------------------------------------------------------------------------------
# Représentation logique du clavier 
#==============================================================================

class AbstractKeyboard

  #--------------------------------------------------------------------------
  # * Win32API's 
  #--------------------------------------------------------------------------
  GetKeyboardState = Win32API.new('user32', 'GetKeyboardState', 'p', 'i')

  #--------------------------------------------------------------------------
  # * Initialisation de l'objet
  #--------------------------------------------------------------------------
  def initialize
    @buffer = [].pack('x256')
    @count = Array.new(256, 0)
    @release = []
    @keys = Keys::All.dup
  end
  #--------------------------------------------------------------------------
  # * Mise à jours du clavier 
  #--------------------------------------------------------------------------
  def update_statement
    @release.clear 
    @keys.each_index do |code|
      if state?(code)
        @count[code] += 1
      elsif @count[code] != 0
        @count[code] = 0
        @release << code
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Mise à jours du buffer
  #--------------------------------------------------------------------------
  def update_buffer
    GetKeyboardState.(@buffer)
  end
  #--------------------------------------------------------------------------
  # * Mise à jours générale
  #--------------------------------------------------------------------------
  def update
    update_buffer
    update_statement
  end
  #--------------------------------------------------------------------------
  # * Vérifie l'état d'une touche
  #--------------------------------------------------------------------------
  def state?(code)
    if code > 255
      return Input.press?(Keys::All[code])
    end
    @buffer.getbyte(code)[7] == 1
  end
  #--------------------------------------------------------------------------
  # * Routine relative à la pression des touches
  #--------------------------------------------------------------------------
  def ktrigger?(code); @count[code.to_i] == 1; end
  def kpress?(code);   @count[code.to_i] > 0; end
  def krelease?(code); @release.include?(code.to_i); end
  def krepeat?(code)
    (@count[code.to_i] == 1) || (@count[code.to_i] >= 24 && @count[code.to_i]%6 == 0)
  end
  #--------------------------------------------------------------------------
  # * Api
  #--------------------------------------------------------------------------
  [:trigger?, :press?, :release?, :repeat?].each do |m|
    define_method(m){|k|send("k#{m}", Keys.get(k))}
  end
end 

#==============================================================================
# ** ConcretKeyboard
#------------------------------------------------------------------------------
# Représentation Physique du clavier 
#==============================================================================

class ConcretKeyboard < AbstractKeyboard
  #--------------------------------------------------------------------------
  # * Acces a la constante Keyboard
  #--------------------------------------------------------------------------
  ::Keyboard = self.new
  #--------------------------------------------------------------------------
  # * Variables d'instances
  #--------------------------------------------------------------------------
  attr_reader :maj, :caps_lock, :num_lock, :scroll_lock, :alt_gr
  #--------------------------------------------------------------------------
  # * Initialisation
  #--------------------------------------------------------------------------
  def initialize
    super
    @caps_lock = @scroll_lock = @num_lock = false
    @maj = @alt_gr = @ctrl = false
  end
  #--------------------------------------------------------------------------
  # * Update des états
  #--------------------------------------------------------------------------
  def update_toggle
    @caps_lock    = toggle?(:caps_lock)
    @scroll_lock  = toggle?(:scroll_lock)
    @num_lock     = toggle?(:num_lock)
  end
  #--------------------------------------------------------------------------
  # * Update Control
  #--------------------------------------------------------------------------
  def update_ctrl
    @ctrl = press?(:lcontrol) || press?(:rcontrol)
  end
  #--------------------------------------------------------------------------
  # * Update Majuscule
  #--------------------------------------------------------------------------
  def update_maj
    @maj = (@caps_lock) ? !press?(:shift) : press?(:shift)
  end
  #--------------------------------------------------------------------------
  # * Update ALTGR combinaison
  #--------------------------------------------------------------------------
  def update_altgr
    @alt_gr = press?(:ctrl) || (@ctrl && press?(:alt))
  end
  #--------------------------------------------------------------------------
  # * Update général
  #--------------------------------------------------------------------------
  def update
    super
    update_toggle
    update_ctrl
    update_maj
    update_altgr
  end
  #--------------------------------------------------------------------------
  # * Vérifie si une touche est verouillée
  #--------------------------------------------------------------------------
  def toggle?(key)
    @buffer.getbyte(Keys.get(key))[0] == 1
  end
  #--------------------------------------------------------------------------
  # * Vérifie la combinaison ctrl + k
  #--------------------------------------------------------------------------
  def ctrl?(k = nil)
    f = (k) ? trigger?(k) : true
    f && @ctrl
  end
  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias :maj?           :maj
  alias :caps_lock?     :caps_lock
  alias :num_lock?      :num_lock
  alias :scroll_lock?   :scroll_lock
  alias :alt_gr?        :alt_gr
end

#==============================================================================
# ** ConcretMouse
#------------------------------------------------------------------------------
# Représentation Physique de la souris 
#==============================================================================

class ConcretMouse

  #--------------------------------------------------------------------------
  # * Win32API
  #--------------------------------------------------------------------------
  GetCursorPos    = Win32API.new('user32', 'GetCursorPos',    'p',  'i')
  ScreenToClient  = Win32API.new('user32', 'ScreenToClient',  'lp', 'i')
  FindWindow      = Win32API.new('user32', 'FindWindow',      'pp', 'i')
  ShowCursor      = Win32API.new('user32', 'ShowCursor',      'i',  'i')
  HWND            = FindWindow.('RGSS Player', 0)
  #--------------------------------------------------------------------------
  # * Acces a la constante Mouse
  #--------------------------------------------------------------------------
  ::Mouse = self.new
  #--------------------------------------------------------------------------
  # * Api
  #--------------------------------------------------------------------------
  [:trigger?, :press?, :release?, :repeat?].each do |m|
    define_method(m){|k|Keyboard.send(m, k)}
  end
  #--------------------------------------------------------------------------
  # * Variables d'instances
  #--------------------------------------------------------------------------
  attr_accessor :x, :y, :x_square, :y_square
  #--------------------------------------------------------------------------
  # * Initialisation
  #--------------------------------------------------------------------------
  def initialize
    @x = @y = 0
    @x_square = @y_square = 0
  end
  #--------------------------------------------------------------------------
  # * Raffraichissement de la position
  #--------------------------------------------------------------------------
  def update_position
    @buffer = [0,0].pack('l2')
    GetCursorPos.(@buffer)
    ScreenToClient.(HWND, @buffer)
    @x, @y = *@buffer.unpack('l2')
    @square_x = @square_y = 0
    update_square if SceneManager.scene.is_a?(Scene_Map)
  end
  #--------------------------------------------------------------------------
  # * Inférence de case
  #--------------------------------------------------------------------------
  def update_square
    @x_square = ((($game_map.display_x * 32) + @x)/32).to_i
    @y_square = ((($game_map.display_y * 32) + @y)/32).to_i
  end
  #--------------------------------------------------------------------------
  # * Rafraichissement général
  #--------------------------------------------------------------------------
  def update
    update_position
  end
  #--------------------------------------------------------------------------
  # * Vérification si le curseur est dans la fenêtre
  #--------------------------------------------------------------------------
  def over_window?
    (@x >= 0 && @x <= Graphics.width) && 
      (@y >= 0 && @y <= Graphics.height)
  end
  #--------------------------------------------------------------------------
  # * Vérification si le curseur au dessus d'une rectangle
  #--------------------------------------------------------------------------
  def hover_rect?(rect)
    check_x = x.between?(rect.x, rect.x+rect.width)
    check_y = y.between?(rect.y, rect.y+rect.height)
    check_x && check_y
  end
  #--------------------------------------------------------------------------
  # * Désactive la souris du système
  #--------------------------------------------------------------------------
  def cursor_system(f)
    flag = (f) ? 1 : 0
    ShowCursor.(flag)
    return f
  end
end

#==============================================================================
# ** Input
#------------------------------------------------------------------------------
#  Ajout du raffraichissement des devices
#==============================================================================

module Input 
  class << self
    alias :nmk_update :update
    def update
      Keyboard.update
      Mouse.update
      nmk_update 
    end
  end
end
