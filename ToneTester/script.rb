#==============================================================================
# ** Configuration du script
#------------------------------------------------------------------------------
# RChoix de la touche d'activation du testeur
#==============================================================================

module ToneConfig

  #--------------------------------------------------------------------------
  # * Touche d'activation du testeur de teinte
  #--------------------------------------------------------------------------
  KEY = :f3

end

#==============================================================================
# ** Slider
#------------------------------------------------------------------------------
# Représente une barre déplacable à la souris
#==============================================================================

class Slider

  #--------------------------------------------------------------------------
  # * Variables publiques
  #--------------------------------------------------------------------------
  attr_reader :x, :y, :value, :disposed
  alias :disposed? :disposed

  #--------------------------------------------------------------------------
  # * Constructeur
  #--------------------------------------------------------------------------
  def initialize(w, h, min, max, *assets)
    @disposed = false
    @width, @height = w, h
    @min, @max = *[min, max].sort
    @colorA = assets[0] || Color.new(120, 120, 120)
    @colorB = assets[1] || Color.new(0, 0, 0)
    @value = @min
    @total = @max - @min
    @total_width = @width - @height
    @x = assets[2] || 0 
    @y = assets[3] || 0
    @clicked = false
    @track_x = 0
    setup_graphics
  end
  #--------------------------------------------------------------------------
  # * Construction de la barre
  #--------------------------------------------------------------------------
  def setup_graphics
    @bg = Sprite.new
    @bg.bitmap = Bitmap.new(@width, @height)
    @bg.bitmap.fill_rect(0, 0, @width, @height, @colorA)
    @button = Sprite.new
    @button.bitmap = Bitmap.new(@height, @height)
    @button.bitmap.fill_rect(0, 0, @height, @height, @colorB)
    self.x = @x
    self.y = @y
  end

  #--------------------------------------------------------------------------
  # * Mutateur de Value
  #--------------------------------------------------------------------------
  def value=(nval)
    @value = [0, [nval, @max].min].max
  end
  #--------------------------------------------------------------------------
  # * Mutateur de x
  #--------------------------------------------------------------------------
  def x=(n)
    @x = n
    @bg.x = @button.x = @x
  end
  #--------------------------------------------------------------------------
  # * Mutateur de y
  #--------------------------------------------------------------------------
  def y=(n)
    @y = n
    @bg.y = @button.y = @y
  end
  #--------------------------------------------------------------------------
  # * Modification de la position du bouton
  #--------------------------------------------------------------------------
  def update_position
    pc_val = @value.to_f / @max.to_f
    n_pos = (pc_val * @total_width.to_f).to_i 
    @button.x = @x + n_pos if @button.x != @x + n_pos
  end
  #--------------------------------------------------------------------------
  # * Evenement du click
  #--------------------------------------------------------------------------
  def click_event
    Mouse.trigger?(:mouse_left) && 
      (Mouse.x.between?(@button.x, @button.x+@button.bitmap.width)) &&
        (Mouse.y.between?(@button.y, @button.y+@button.bitmap.height))
  end
  #--------------------------------------------------------------------------
  # * Update du drag in
  #--------------------------------------------------------------------------
  def update_drag
    if !@clicked 
      @clicked = click_event
      if @clicked
        @track_x = Mouse.x
        @old_val = @value
      end
    else
      coeff = (((Mouse.x - @track_x).to_f)*@max.to_f)/@total_width.to_f
      self.value = @old_val + coeff.to_i
      @clicked = !Mouse.release?(:mouse_left)
    end
  end
  #--------------------------------------------------------------------------
  # * Update générale
  #--------------------------------------------------------------------------
  def update
    return if disposed?
    update_position
    update_drag
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    @disposed = true
    @button.dispose
    @bg.dispose
  end

end

#==============================================================================
# ** Tone_Tester
#------------------------------------------------------------------------------
# Représente un testeur de teinte
#==============================================================================

class Tone_Tester

  #--------------------------------------------------------------------------
  # * API Windows (Merci à Grim :v)
  #--------------------------------------------------------------------------
  OpenClipboard     = Win32API.new('user32',    'OpenClipboard',    'i',    'i')
  EmptyClipboard    = Win32API.new('user32',    'EmptyClipboard',   'v',    'i')
  GlobalAlloc       = Win32API.new('kernel32',  'GlobalAlloc',      'ii',   'i')
  GlobalLock        = Win32API.new('kernel32',  'GlobalLock',       'i',    'l')
  Memcpy            = Win32API.new('msvcrt',    'memcpy',           'ppi',  'i')
  SetClipboardData  = Win32API.new('user32',    'SetClipboardData', 'ii',   'i')
  GlobalFree        = Win32API.new('kernel32',  'GlobalFree',       'i',    'i')
  CloseClipboard    = Win32API.new('user32',    'CloseClipboard',   'v',    'i')
  RegisterClipboardFormat = Win32API.new('user32', 'RegisterClipboardFormat', 'p', 'i')
  #--------------------------------------------------------------------------
  # *  Ajoute commande dans le presse Papier
  #--------------------------------------------------------------------------
  def push_command(*commands)
    clip_data = Marshal.dump(commands)
    clip_data.insert(0, [clip_data.size].pack('L'))
    OpenClipboard.(0)
    EmptyClipboard.()
    hmem = GlobalAlloc.(0x42, clip_data.length)
    mem = GlobalLock.(hmem)
    Memcpy.(mem, clip_data, clip_data.length)
    SetClipboardData.(RegisterClipboardFormat.("VX Ace EVENT_COMMAND"), hmem)
    GlobalFree.(hmem)
    CloseClipboard.()
    return true
  end
  #--------------------------------------------------------------------------
  # * Sauve la teinte dans le presse papier
  #--------------------------------------------------------------------------
  def save_tone
    red = @red.value - 255
    gre = @gre.value - 255
    blu = @blu.value - 255
    gra = @gra.value
    tone = Tone.new(red, gre, blu, gra)
    command = RPG::EventCommand.new(223, 0, [tone, 0, false])
    push_command(command)
    msgbox("La ligne d'évènement pour changer la teinte \n est dans le presse-papier")
  end
  #--------------------------------------------------------------------------
  # * Variables d'instances
  #--------------------------------------------------------------------------
  attr_reader :disposed
  alias :disposed? :disposed
  #--------------------------------------------------------------------------
  # * Constructeur
  #--------------------------------------------------------------------------
  def initialize
    @tone = $game_map.screen.tone.dup
    @menu = $game_system.menu_disabled
    $game_system.menu_disabled = true
    @disposed = false
    @ore, @ogr, @obl, @oga = @tone.red, @tone.green, @tone.blue, @tone.gray
    create_bg
    create_tracks
    create_label
  end
  #--------------------------------------------------------------------------
  # * Crée les labels
  #--------------------------------------------------------------------------
  def create_label
    @redl = Sprite.new
    @redl.bitmap = Bitmap.new(@w, 18)
    @redl.x, @redl.y = @red.x, 12
    @redl.bitmap.font.outline = false
    @redl.bitmap.font.size = 15
    @grel = Sprite.new
    @grel.x, @grel.y = @gre.x, 12
    @blul = Sprite.new
    @blul.x, @blul.y = @blu.x, 12
    @gral = Sprite.new
    @gral.x, @gral.y = @gra.x, 12
    @gral.bitmap = @redl.bitmap.clone
    @blul.bitmap = @redl.bitmap.clone
    @grel.bitmap = @redl.bitmap.clone
    @redl.bitmap.draw_text(0, 0, @w, 18, sprintf("%03d", 0), 2)
    @grel.bitmap.draw_text(0, 0, @w, 18, sprintf("%03d", 0), 2)
    @blul.bitmap.draw_text(0, 0, @w, 18, sprintf("%03d", 0), 2)
    @gral.bitmap.draw_text(0, 0, @w, 18, sprintf("%03d", 0), 2)
  end
  #--------------------------------------------------------------------------
  # * Crée les sliders
  #--------------------------------------------------------------------------
  def create_tracks
    space = 10
    w = (Graphics.width-(5*space))/4
    @w = w
    x = space
    n = Color.new(200, 200, 200)
    r,v = [n, Color.new(255, 0, 0)], [n,Color.new(0, 255, 0)]
    b,g = [n, Color.new(0, 0, 255)], [n,Color.new(120,120,120)]
    @red = Slider.new(w, 8, 0, 510, *r); @red.x = x; x+=w+space
    @gre = Slider.new(w, 8, 0, 510, *v); @gre.x = x; x+=w+space
    @blu = Slider.new(w, 8, 0, 510, *b); @blu.x = x; x+=w+space
    @gra = Slider.new(w, 8, 0, 255, *g); @gra.x = x; x+=w+space
    [@red, @gre, @blu, @gra].collect{|i| i.y = 4}
    @red.value = 255 + @tone.red
    @gre.value = 255 + @tone.green
    @blu.value = 255 + @tone.blue
    @gra.value = @tone.gray
  end
  #--------------------------------------------------------------------------
  # * Crée le fond
  #--------------------------------------------------------------------------
  def create_bg
    @bg = Sprite.new
    @bg.bitmap = Bitmap.new(Graphics.width, 32)
    @bg.bitmap.fill_rect(0, 0, Graphics.width, 32, Color.new(0,0,0,200))
    @button = Sprite.new 
    @button.bitmap = Bitmap.new(100, 16)
    @button.bitmap.fill_rect(@button.bitmap.rect, Color.new(20, 20, 20, 200))
    @button.bitmap.font.outline = false
    @button.bitmap.font.size = 16
    @button.bitmap.draw_text(0,0,100,16,"Save", 1)
    @button.y = 32 
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    return if @disposed 
    [@red, @gre, @blu, @gra].collect(&:update)
    update_label
    update_tone
    update_button
    dispose if Keyboard.trigger?(:esc) || Keyboard.trigger?(ToneConfig::KEY)
  end
  #--------------------------------------------------------------------------
  # * Update du bouton
  #--------------------------------------------------------------------------
  def update_button
    f = Mouse.x.between?(0, 100) && Mouse.y.between?(32, 32+16) 
    if f && Mouse.trigger?(:mouse_left)
          save_tone
    end
  end
  #--------------------------------------------------------------------------
  # * Update de la teinte
  #--------------------------------------------------------------------------
  def update_tone
    red = @red.value - 255
    gre = @gre.value - 255
    blu = @blu.value - 255
    gra = @gra.value
    $game_map.screen.tone.set(red, gre, blu, gra)
  end
  #--------------------------------------------------------------------------
  # * Update label
  #--------------------------------------------------------------------------
  def update_label
    t = [@red, @gre, @blu, @gra]
    a = [@redl, @grel, @blul, @gral]
    r = [@ore, @ogr, @obl, @oga]
    4.times do |i|
      f = (t[i] == @gra) ? 0 : 255
      v = t[i].value - f
      if v != r[i]
        a[i].bitmap.clear
        a[i].bitmap.draw_text(0, 0, @w, 18, sprintf("%03d", v), 2)
        r[i] = v
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Dispose

  #--------------------------------------------------------------------------
  def dispose
    $game_system.menu_disabled = @menu
    @disposed = true
    $game_map.screen.tone.set(@tone)
    @bg.dispose
    @button.dispose
    [@red, @gre, @blu, @gra].collect(&:dispose)
    [@redl, @grel, @blul, @gral].collect(&:dispose)
  end
end 

#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#  Ajout de la gestion du testeur de teintes
#==============================================================================

class Scene_Map

  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias :tone_start :start
  alias :tone_update :update

  #--------------------------------------------------------------------------
  # * Démarrage
  #--------------------------------------------------------------------------
  def start
    tone_start
    @tone_tester = false
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    if $TEST
      if !@tone_tester || @tone_tester.disposed?
        if Keyboard.trigger?(ToneConfig::KEY)
          @tone_tester = Tone_Tester.new
        end
      else
        @tone_tester.update
      end
    end
    tone_update
  end 
end