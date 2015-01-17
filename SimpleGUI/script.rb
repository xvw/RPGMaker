#==============================================================================
# ** GUI
#------------------------------------------------------------------------------
#  GUI Super simple
#==============================================================================

module GUI 

  #------------------------------------------------------------------------
  # * Constantes
  #------------------------------------------------------------------------
  UPARROW     = "▲"
  DOWNARROW   = "▼"
  LEFTARROW   = "◄"
  RIGHTARROW  = "►"

  #------------------------------------------------------------------------
  # * Colors
  #------------------------------------------------------------------------
  BGCOMP = Color.new(180, 180, 180)
  TXCOMP = Color.new(60 , 60 , 60 )
  BTCOMP = Color.new(100, 100, 100)
  TBCOMP = Color.new(80 , 80 , 80 )

  #------------------------------------------------------------------------
  # * Font
  #------------------------------------------------------------------------
  SIMPLE = Font.new("Arial", 15)
  SIMPLE.outline = SIMPLE.bold = SIMPLE.shadow = SIMPLE.italic = false
  SIMPLE.color = TXCOMP

  #============================================================================
  # ** Sprite
  #----------------------------------------------------------------------------
  # Représentation d'un sprite cliquable
  #============================================================================

  class Sprite < ::Sprite
    #----------------------------------------------------------------------
    # * Vérifie si la souris est sur le sprite
    #----------------------------------------------------------------------
    def hover? 
      return false unless bitmap
      t_x, t_y = x, y 
      if viewport
        t_x = viewport.rect.x - viewport.ox + x
        t_y = viewport.rect.y - viewport.oy + y
      end
      check_x = Mouse.x.between?(t_x, x+bitmap.width)
      check_y = Mouse.y.between?(t_y, x+bitmap.height)
      check_x && check_y
    end
    #----------------------------------------------------------------------
    # * API UI
    #----------------------------------------------------------------------
    [:trigger?, :press?, :release?, :repeat?].each do |m|
      define_method(m) do |key|
        hover? && Mouse.send(m, k)
      end
    end
  end

  # Scrollbarre par Grim, Joke et Nuki
  #============================================================================
  # ** Scrollbar
  #----------------------------------------------------------------------------
  # Représentation des scrollbars
  #============================================================================

  class Scrollbar 
    #----------------------------------------------------------------------
    # * Variables d'instances
    #----------------------------------------------------------------------
    attr_reader :index
    #----------------------------------------------------------------------
    # * Initialisation
    #----------------------------------------------------------------------
    def initialize(x, y, min, max)

      @index      = 0
      @x          = x
      @y          = y 
      @min, @max  = *[min, max].sort
      @total      = @max - @min
      @old_x      = @x
      @old_y      = @y
      @clicked    = false
      @old_index  = 0

      create_viewport
      create_background
      create_buttons 
      create_trackbar

    end
    #----------------------------------------------------------------------
    # * Update
    #----------------------------------------------------------------------
    def update
      update_buttons
      update_position
      update_drag
      update_trackbarre_click
    end
    #----------------------------------------------------------------------
    # * Update des bouttons
    #----------------------------------------------------------------------
    def update_buttons
      index -= 2 if @buttonA.press(:mouse_left)
      index += 2 if @buttonB.press(:mouse_left)
    end
    #----------------------------------------------------------------------
    # * Update du dragg
    #----------------------------------------------------------------------
    def update_drag
      if @sprite_trackbar.trigger?(:mouse_left)
        @clicked = true
        @old_x, @old_y = Mouse.x-@x, Mouse.y-@y
        @old_index = index
      end
      if @clicked && Mouse.press?(:mouse_left)
        update_drag_position
      else
        @clicked = false
      end
    end
    #----------------------------------------------------------------------
    # * Création du viewport
    #----------------------------------------------------------------------
    def create_viewport
      @viewport = Viewport.new(@x, @y, @width, @height)
    end
    #----------------------------------------------------------------------
    # * Création du fond
    #----------------------------------------------------------------------
    def create_background
      @sprite_background = Sprite.new(@viewport)
      @sprite_background.bitmap = Bitmap.new(@width, @height)
      @sprite_background.bitmap.fill_rect(0, 0, @width, @height, BGCOMP)
    end
    #----------------------------------------------------------------------
    # * Disposition
    #----------------------------------------------------------------------
    def dispose
      instance_variables.each do |varname|
        ivar = instance_variable_get(varname)
        ivar.dispose if ivar.respond_to?(:dispose)
      end
    end
  end

  #============================================================================
  # ** VScrollbar
  #----------------------------------------------------------------------------
  # Scrollbarre Verticale
  #============================================================================

  class VScrollbar < Scrollbar
    #----------------------------------------------------------------------
    # * Initialisation
    #----------------------------------------------------------------------
    def initialize(x, y, min, max, h)
      @height = h
      @width  = 16
      @content_height = @height - (2*@width)
      super(x, y, min, max)
    end
    #----------------------------------------------------------------------
    # * Création des bouttons
    #----------------------------------------------------------------------
    def create_buttons 
      @buttonA = Sprite.new(@viewport)
      @buttonA.bitmap = Bitmap.new(16, 16)
      @buttonA.bitmap.font = SIMPLE
      @buttonA.bitmap.fill_rect(0, 0, 16, 16, BTCOMP)
      @buttonA.bitmap.draw_text(0, 0, 16, 16, UPARROW, 1)
      @buttonB = Sprite.new(@viewport)
      @buttonB.bitmap = Bitmap.new(16, 16)
      @buttonB.bitmap.font = SIMPLE
      @buttonB.bitmap.fill_rect(0, 0, 16, 16, BTCOMP)
      @buttonB.bitmap.draw_text(0, 0, 16, 16, DOWNARROW, 1)
      @buttonB.y = @height - 16
    end
    #----------------------------------------------------------------------
    # * Création de la trackbarre
    #----------------------------------------------------------------------
    def create_trackbar

    end
  end

  #============================================================================
  # ** HScrollbar
  #----------------------------------------------------------------------------
  # Scrollbarre Horizontale
  #============================================================================

  class HScrollbar < Scrollbar
    #----------------------------------------------------------------------
    # * Initialisation
    #----------------------------------------------------------------------
    def initialize(x, y, min, max, w)
      @height = 16
      @width  = w
      @content_width = @width - 2*@height
      super(x, y, min, max)
    end
    #----------------------------------------------------------------------
    # * Création des bouttons
    #----------------------------------------------------------------------
    def create_buttons 
      @buttonA = Sprite.new(@viewport)
      @buttonA.bitmap = Bitmap.new(16, 16)
      @buttonA.bitmap.font = SIMPLE
      @buttonA.bitmap.fill_rect(0, 0, 16, 16, BTCOMP)
      @buttonA.bitmap.draw_text(0, 0, 16, 16, LEFTARROW, 1)
      @buttonB = Sprite.new(@viewport)
      @buttonB.bitmap = Bitmap.new(16, 16)
      @buttonB.bitmap.font = SIMPLE
      @buttonB.bitmap.fill_rect(0, 0, 16, 16, BTCOMP)
      @buttonB.bitmap.draw_text(0, 0, 16, 16, RIGHTARROW, 1)
      @buttonB.x = @width - 16
    end
  end

end