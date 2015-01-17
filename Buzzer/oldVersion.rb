#=============================================================================
# Buzzer => Permet d'appliquer une légère transformation sur les evenements
# Script par FABIEN (Factory) pour XP légèrement modifié par Molok (pour VX)
#==============================================================================
 
#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Buzz event
  #--------------------------------------------------------------------------
  def buzz id, amplitude = 0.1, duration = 16, periode = 16
    event = (id == 0 ? $game_player : $game_map.events[id])
    event.buzz = duration
    event.buzz_length = duration
    event.buzz_amplitude = amplitude
  end
  #--------------------------------------------------------------------------
  # * Buzz events
  #--------------------------------------------------------------------------
  def buzz_group *ids
    ids.each{|event|buzz(event)}
  end
end
 
#==============================================================================
# ** Game_Character
#------------------------------------------------------------------------------
#  This class deals with characters. It's used as a superclass of the
# Game_Player and Game_Event classes.
#==============================================================================
class Game_Character
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :buzz
  attr_accessor :buzz_amplitude
  attr_accessor :buzz_length
end
class Sprite_Character
  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias old_initialize initialize
  alias old_update update
  #--------------------------------------------------------------------------
  # * Object initialization
  #--------------------------------------------------------------------------
  def initialize(viewport, character = nil)
    old_initialize(viewport, character)
    self.character.buzz = 0
    self.character.buzz_amplitude = 0.1
    self.character.buzz_length = 16
  end
  #--------------------------------------------------------------------------
  # * compute Buzz Transformation
  #--------------------------------------------------------------------------
  def calc_buzz
    self.character.buzz_amplitude*Math.sin(self.character.buzz*6.283/self.character.buzz_length)
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    self.zoom_x = self.zoom_y = 1
    old_update
    unless self.character.buzz== nil || self.character.buzz == 0
      transformation = self.calc_buzz
      self.zoom_x += transformation
      self.zoom_y -= transformation
      self.character.buzz -= 1
    end
  end
end