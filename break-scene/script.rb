#==============================================================================
# Custom Break System
# Nuki :D
#
# Instructions
# In event, use : Call script "have_a_break" to run the scene
# Or : SceneManager.call(Scene_Break)
# You can configure the scene in the Break_Config module (using Lambda for action)
#==============================================================================

#==============================================================================
# ** Font
#------------------------------------------------------------------------------
# The font class. Font is a property of the Bitmap class.
# If there is a "Fonts" folder directly under the game folder, the font files
# in it can be used even if they are not installed on the system.
#==============================================================================

class Font
  class << self
    def default(size = nil)
      font            = self.new(default_name, size || default_size)
      font.bold       = default_bold
      font.italic     = default_italic
      font.shadow     = default_shadow
      font.color      = default_color
      font.out_color  = default_out_color
      font
    end
  end
end

#==============================================================================
# ** Module Configuration
#------------------------------------------------------------------------------
# Configuration of the script
#==============================================================================

module Break_Config

  # Display a title on the screen
  ENABLE_TITLE  = true
  # Display choice
  ENABLE_CHOICE = true

  # Title value
  TITLE_VALUE   = "Break"
  # Use ":default" for the default typo convention
  TITLE_TYPO    = Font.default(48)

  # Substitute original menu
  SUBSTITUTE_MENU = true

  COMMANDS = {
    "Resume"  => lambda {SceneManager.return},
    "Exit"    => lambda {SceneManager.exit}
  }

  # update callback
  UPDATE_CALLBACK     = lambda {SceneManager.return if Input.trigger?(:B)}
  BITMAP_TRANSFORMER  = lambda {|bitmap| bitmap.blur}


end

#==============================================================================
# ** SceneManager
#------------------------------------------------------------------------------
#  This module manages scene transitions. For example, it can handle
# hierarchical structures such as calling the item screen from the main menu
# or returning from the item screen to the main menu.
#==============================================================================

module SceneManager
  class << self
    attr_accessor :raw_background_bitmap
    alias_method :Break_snapshot, :snapshot_for_background
    def snapshot_for_background
      @background_bitmap.dispose if @background_bitmap
      @background_bitmap = Graphics.snap_to_bitmap
      @raw_background_bitmap = @background_bitmap.clone
      @background_bitmap.blur
    end
  end
end

#==============================================================================
# ** Window_Break
#------------------------------------------------------------------------------
#  Command for the Break selection
#==============================================================================

class Window_Break < Window_Command
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    Break_Config::COMMANDS.keys.each do |key|
      add_command(key, key.to_sym)
    end
  end
end

#==============================================================================
# ** Scene_Break
#------------------------------------------------------------------------------
#  This class performs a Break during the game
#==============================================================================

class Scene_Break < Scene_Base
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  def start
    super
    init_data
    create_background
    create_title
    create_choice_box
    center_components
  end
  #--------------------------------------------------------------------------
  # * Init scene
  #--------------------------------------------------------------------------
  def init_data
    @time = Graphics.frame_count
    $game_system.save_bgm
    Audio.bgm_stop
  end
  #--------------------------------------------------------------------------
  # * Create title
  #--------------------------------------------------------------------------
  def create_title
    return unless Break_Config::ENABLE_TITLE
    bmp           = Bitmap.new(1, 1)
    bmp.font      = Break_Config::TITLE_TYPO
    rect          = bmp.text_size(Break_Config::TITLE_VALUE)
    @title        = Sprite.new
    @title.bitmap = Bitmap.new(rect.width, rect.height)
    @title.bitmap.font = Break_Config::TITLE_TYPO
    @title.bitmap.draw_text(rect, Break_Config::TITLE_VALUE, 1)
    @title.ox = rect.width/2
    @title.oy = rect.height/2
  end
  #--------------------------------------------------------------------------
  # * Create choice box
  #--------------------------------------------------------------------------
  def create_choice_box
    return unless Break_Config::ENABLE_CHOICE
    @choices = Window_Break.new(0, 0)
    Break_Config::COMMANDS.each do |key, callback|
      @choices.set_handler(key.to_sym, callback)
    end
  end
  #--------------------------------------------------------------------------
  # * Create background
  #--------------------------------------------------------------------------
  def create_background
    @background = Sprite.new
    @background.bitmap = SceneManager.raw_background_bitmap
    Break_Config::BITMAP_TRANSFORMER.call(@background.bitmap)
  end
  #--------------------------------------------------------------------------
  # * Center components
  #--------------------------------------------------------------------------
  def center_components
    if Break_Config::ENABLE_TITLE
      @title.x = Graphics.width/2
      @title.y = Graphics.height/2
      @title.y -= (@choices.height/2) if Break_Config::ENABLE_CHOICE
    end
    if Break_Config::ENABLE_CHOICE
      @choices.x = Graphics.width/2 - @choices.width/2
      @choices.y = Graphics.height/2 - @choices.height/2
      @choices.y += @title.src_rect.height if Break_Config::ENABLE_TITLE
    end
  end
  #--------------------------------------------------------------------------
  # * Frame update
  #--------------------------------------------------------------------------
  def update
    super
    Break_Config::UPDATE_CALLBACK.call
  end
  #--------------------------------------------------------------------------
  # * Termination Processing
  #--------------------------------------------------------------------------
  def terminate
    super
    @title.dispose if @title
    @background.dispose
    $game_system.replay_bgm
    Graphics.frame_count = @time
  end
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * call a Break sequence
  #--------------------------------------------------------------------------
  def have_a_break
    SceneManager.call(Scene_Break)
  end
end
