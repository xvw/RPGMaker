#==============================================================================
#
# Petit système de Quête. Par Nuki
# Dépend de : https://github.com/nukiFW/RPGMaker/tree/master/CustomDatabase
# Page du script : https://github.com/nukiFW/RPGMaker/tree/master/MicroQuestSystem
#
#==============================================================================

#==============================================================================
# ** Config
#------------------------------------------------------------------------------
# Configuration du script
#==============================================================================

module Config
  #--------------------------------------------------------------------------
  # * Ajouter le journal dans le menu
  # * Ne fonctionne bien que s'il s'agit du menu de base. (ou correctemment codé)
  # Cependant, je peux l'insérer dans d'autres menus à la demande.
  #--------------------------------------------------------------------------
  QUEST_IN_MENU = true
end

#==============================================================================
# ** Vocab
#------------------------------------------------------------------------------
# Vocabulaire utilisé pour la scene
#==============================================================================

module Vocab
  class << self
    def quest_title; "Journal des quêtes"; end
    def quest_menu_name; "Quêtes"; end
    def quest_empty; "Il n 'y a pas de quêtes"; end
  end
end

#==============================================================================
# ** Quest
#------------------------------------------------------------------------------
# Descripton d'une quête
#==============================================================================

class Quest < Static::Table
  pk integer :id
  string :name
  string :desc 
  integer :gold 
  integer :exp
  list :integer, :items
  list :integer, :weapons
  list :integer, :armors
end

#==============================================================================
# ** Game_Quest
#------------------------------------------------------------------------------
# Descripton d'une quête dynamique
#==============================================================================

class Game_Quest < Dynamic::Table
  pk integer :quest_id
  boolean :finished
  #--------------------------------------------------------------------------
  # * Finir une quête
  #--------------------------------------------------------------------------
  def finish
    @finished = true
    $game_party.gain_gold(static.gold)
    $game_party.members.each{|actor| actor.gain_exp(static.exp)}
    static.items.each{|id| $game_party.gain_item($data_items[id], 1)}
    static.armors.each{|id| $game_party.gain_item($data_armors[id], 1)}
    static.weapons.each{|id| $game_party.gain_item($data_weapons[id], 1)}
  end
  #--------------------------------------------------------------------------
  # * Renvoi la quête parente
  #--------------------------------------------------------------------------
  def static 
    Quest[@quest_id]
  end
  #--------------------------------------------------------------------------
  # * Vérifie si une quête est finie
  #--------------------------------------------------------------------------
  def finished?; @finished; end
end

#==============================================================================
# ** Kernel
#------------------------------------------------------------------------------
# Ajout des méthodes de quêtes dans Kernel pour qu'elles soient accessibles
# de partout
#==============================================================================

module Kernel
  #--------------------------------------------------------------------------
  # * Démarre une quête
  #--------------------------------------------------------------------------
  def start_quest(id)
    if !Game_Quest.all.has_key?(id)
      Game_Quest.insert(id, false)
    end
  end
  #--------------------------------------------------------------------------
  # * Récupère une quêtes
  #--------------------------------------------------------------------------
  def quest(id)
    Game_Quest[id]
  end
  #--------------------------------------------------------------------------
  # * finir une quête
  #--------------------------------------------------------------------------
  def finish_quest(id)
    if quest_on_the_road?(id)
      quest(id).finish
    end
  end
  #--------------------------------------------------------------------------
  # * Une quête est-elle en court?
  #--------------------------------------------------------------------------
  def quest_on_the_road?(id)
    Game_Quest.all.has_key?(id) && !quest(id).finished
  end
  alias :quest_in_curse? :quest_on_the_road?
  #--------------------------------------------------------------------------
  # * Vérifie si une quête a été finie
  #--------------------------------------------------------------------------
  def quest_done?(id)
    Game_Quest.all.has_key?(id) && quest(id).finished
  end
  alias :quest_finished? :quest_done?
end

#==============================================================================
# ** Window_QuestList
#------------------------------------------------------------------------------
# Représente la fenêtre de la liste des quêtes
#==============================================================================

class Window_QuestList < Window_Command
  #--------------------------------------------------------------------------
  # * Constructeur
  #--------------------------------------------------------------------------
  def initialize(y)
    super(0, y)
  end
  #--------------------------------------------------------------------------
  # * Largeur de la fenêtre
  #--------------------------------------------------------------------------
  def window_width
    return Graphics.width
  end
  #--------------------------------------------------------------------------
  # * Création de la liste
  #--------------------------------------------------------------------------
  def make_command_list
    Game_Quest.all.each do |key, record|
      add_command(record.static.name, key)
    end
  end
  #--------------------------------------------------------------------------
  # * Nombre de ligne visible
  #--------------------------------------------------------------------------
  def visible_line_number
    10
  end
  #--------------------------------------------------------------------------
  # * Désactive la pression
  #--------------------------------------------------------------------------
  def ok_enabled?
    false
  end
  #--------------------------------------------------------------------------
  # * Change la couleur
  #--------------------------------------------------------------------------
  def draw_item(index)
    change_color(Color.new(255,255,255))
    if Game_Quest[@list[index][:symbol]].finished?
      change_color(Color.new(0,255,0))
    end
    draw_text(item_rect_for_text(index), command_name(index), alignment)
  end
end


#==============================================================================
# ** Scene_Quest
#------------------------------------------------------------------------------
# Journal de quêtes
#==============================================================================

class Scene_Quest < Scene_Base
  #--------------------------------------------------------------------------
  # * Procédure de démarrage
  #--------------------------------------------------------------------------
  def start
    super
    create_title
    if Game_Quest.count == 0
      create_no_quest
    else
      @current = Quest[Game_Quest.first[0]]
      create_command
      create_desc
    end
  end
  #--------------------------------------------------------------------------
  # * Création de la fenêtre de titre
  #--------------------------------------------------------------------------
  def create_title
    @title = Window_Help.new(1)
    @title.set_text(Vocab.quest_title)
  end
  #--------------------------------------------------------------------------
  # * Création de la fenêtre pour dire qu'il n'y a pas de quêtes
  #--------------------------------------------------------------------------
  def create_no_quest
    h = @title.fitting_height(1)
    @no_quest = Window_Base.new(0, @title.height, Graphics.width, h)
    w, h = @no_quest.contents.width, @no_quest.contents.height
    @no_quest.contents.draw_text(0, 0, w, h, Vocab.quest_empty)
  end
  #--------------------------------------------------------------------------
  # * Création de la liste des quêtes
  #--------------------------------------------------------------------------
  def create_command
    y =  @title.height
    @quest_list = Window_QuestList.new(y)
  end
  #--------------------------------------------------------------------------
  # * Création de la boite de description
  #--------------------------------------------------------------------------
  def create_desc
    y =  @title.height + @quest_list.height
    h = Graphics.height - y
    @quest_desc = Window_Base.new(0, y, Graphics.width, h)
    @quest_desc.draw_text_ex(4, 0, @current.desc)
    @current_sym = @current.id
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    super
    if Game_Quest.count > 0
      if @current_sym != @quest_list.current_symbol
        @current_sym = @quest_list.current_symbol
        @current = Quest[@current_sym]
        @quest_desc.contents.clear
        @quest_desc.draw_text_ex(4, 0, @current.desc)
      end
    end
    SceneManager.return if Input.trigger?(:B)
  end
end

if Config::QUEST_IN_MENU

  #==============================================================================
  # ** Window_MenuCommand
  #------------------------------------------------------------------------------
  #  This command window appears on the menu screen.
  #==============================================================================

  class Window_MenuCommand
    #--------------------------------------------------------------------------
    # * Alias
    #--------------------------------------------------------------------------
    alias :miniquest_cmd :add_main_commands
    #--------------------------------------------------------------------------
    # * Ajout du journal de quêtes
    #--------------------------------------------------------------------------
    def add_main_commands
      miniquest_cmd
      add_command(Vocab::quest_menu_name, :quest, main_commands_enabled)
    end
  end

  #==============================================================================
  # ** Scene_Menu
  #------------------------------------------------------------------------------
  #  Ajout des quêtes dans le menu
  #==============================================================================

  class Scene_Menu
    #--------------------------------------------------------------------------
    # * Alias
    #--------------------------------------------------------------------------
    alias :miniquest_window :create_command_window
    #--------------------------------------------------------------------------
    # * Lance le menu des quêtes
    #--------------------------------------------------------------------------
    def command_quest
      SceneManager.call(Scene_Quest)
    end
    #--------------------------------------------------------------------------
    # * Create Command Window
    #--------------------------------------------------------------------------
    def create_command_window
      miniquest_window
      @command_window.set_handler(:quest, method(:command_quest))
    end
  end

end

