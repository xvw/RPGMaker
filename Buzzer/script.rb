# Buzzer à la Golden Sun 
# Par Fabien, Nuki


#==============================================================================
# ** Buzzer_Prop
#------------------------------------------------------------------------------
#  Renvoi les propriétés d'un buzzer
#==============================================================================

class Buzzer_Prop < Struct.new(:duration, :amplitude, :length)
  #--------------------------------------------------------------------------
  # * Applique un buzzer sur un event
  #--------------------------------------------------------------------------
  def apply_buzz(event)
    event.buzz            = self.duration
    event.buzz_length     = self.length
    event.buzz_amplitude  = self.amplitude
  end
  #--------------------------------------------------------------------------
  # * Buzz event
  #--------------------------------------------------------------------------
  def buzz(*ids)
    ids.each do |id| 
      event = (id == 0 ? $game_player : $game_map.events[id])
      apply_buzz(event) if event
    end
    return self
  end
  #--------------------------------------------------------------------------
  # * Buzz follower
  #--------------------------------------------------------------------------
  def buzz_followers(*ids)
    return if !$game_player.followers.visible
    if ids.length == 0 
      $game_player.followers.each{|flw|apply_buzz(flw)}
      return self
    end
    ids.each do |id|
      event = $game_player.followers[id]
      apply_buzz(event) if event
    end
    return self
  end
end

#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  Ajout de l'API de tressaillement
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Constantes
  #--------------------------------------------------------------------------
  BUZZER_STD_PROPP = Buzzer_Prop.new(16, 0.1, 16)
  #--------------------------------------------------------------------------
  # * buzz
  #--------------------------------------------------------------------------
  def buzz(*ids)
    BUZZER_STD_PROPP.buzz(*ids)
  end
  #--------------------------------------------------------------------------
  # * buzz des followers
  #--------------------------------------------------------------------------
  def buzz_followers(*ids)
    BUZZER_STD_PROPP.buzz_followers(*ids)
  end
  #--------------------------------------------------------------------------
  # * buzz avec configuration
  #--------------------------------------------------------------------------
  def buzz_config(duration, amplitude, length)
    Buzzer_Prop.new(duration, amplitude, length)
  end
end

#==============================================================================
# ** Game_Character
#------------------------------------------------------------------------------
#  Ajout des informations de tressaillement
#==============================================================================

class Game_Character
  #--------------------------------------------------------------------------
  # * Variables d'instances
  #--------------------------------------------------------------------------
  attr_accessor :buzz
  attr_accessor :buzz_amplitude
  attr_accessor :buzz_length
  #--------------------------------------------------------------------------
  # * Initialisation du Buzzer
  #--------------------------------------------------------------------------
  def  setup_buzzer
    @buzz           = 0
    @buzz_amplitude = 0.1
    @buzz_length    = 16
  end
end

#==============================================================================
# ** Sprite_Character
#------------------------------------------------------------------------------
#  Ajout de l'effet de tressaillement
#==============================================================================

class Sprite_Character
  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias buzzer_initialize initialize
  alias buzzer_update update
  #--------------------------------------------------------------------------
  # * Instanciation d'un caractère
  #--------------------------------------------------------------------------
  def initialize(*args)
    buzzer_initialize(*args)
    self.character.setup_buzzer if self.character
    @old_buzz = 0
  end
  #--------------------------------------------------------------------------
  # * Frame update
  #--------------------------------------------------------------------------
  def update
    buzzer_update
    update_buzz
  end
  #--------------------------------------------------------------------------
  # * Update buzzer
  #--------------------------------------------------------------------------
  def update_buzz
    return if !self.character.buzz || self.character.buzz == 0
    if @old_buzz == 0
      @origin_len_x = self.zoom_x 
      @origin_len_y = self.zoom_y 
    end
    @old_buzz             = self.character.buzz
    len                   = self.character.buzz_length
    transformation        = Math.sin(@old_buzz*6.283/len)
    transformation        *= self.character.buzz_amplitude
    self.zoom_x           = @origin_len_x + transformation
    self.zoom_y           = @origin_len_y - transformation
    self.character.buzz   -= 1
    if self.character.buzz == 0
      self.zoom_x = @origin_len_x
      self.zoom_y = @origin_len_y
      @old_buzz = 0
    end
  end
end