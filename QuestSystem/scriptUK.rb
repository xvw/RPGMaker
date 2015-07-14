# -*- coding: utf-8 -*-
#--------------------------------------------------------------------------
# * Quest System ~ V 1.0

#   Par Nuki 
#   Merci à Zangther, Hiino, Altor
#--------------------------------------------------------------------------

#==============================================================================
# ** Quest_Config
#------------------------------------------------------------------------------
#  Module de configuration du système
#==============================================================================

module Quest_Config
  #--------------------------------------------------------------------------
  # * Message de succès par défaut
  #--------------------------------------------------------------------------
  DEFAULT_SUCESS = lambda{|name| "#{name} : successed!"}
  #--------------------------------------------------------------------------
  # * Message d'échec par défaut
  #--------------------------------------------------------------------------
  DEFAULT_FAIL = lambda{|name| "#{name} : failed!"}
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
    def quest_menu_name; "Quests";      end
    def quest_incurse;   "On the road";    end
    def quest_success;   "successed";    end
    def quest_fail;      "Failed";    end
    def quest_pended;    "Completed";  end
    def quest_buy;       "Buy";     end
    def quest_confirm;   "Confirm";   end
    def quest_cancle;    "Back";      end
    def quest_gold;       "#{Vocab::currency_unit} given"; end
    def quest_exp;        "Exp given"; end
    def quest_items;      "Items given"; end
  end
end



#==============================================================================
# ** Goal
#------------------------------------------------------------------------------
#  Module de description des objectifs
#==============================================================================

module Goal
  #--------------------------------------------------------------------------
  # * Constantes
  #--------------------------------------------------------------------------
  ITEMS     = load_data("Data/Items.rvdata2")
  WEAPONS   = load_data("Data/Weapons.rvdata2")
  ARMORS    = load_data("Data/Armors.rvdata2")
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  class << self
    #--------------------------------------------------------------------------
    # * Déclencheur personnalisé
    #--------------------------------------------------------------------------
    def trigger(tags = [], &block)
      Goal::Simple.new(block, tags)
    end
    #--------------------------------------------------------------------------
    # * Déclencheur des variables
    #--------------------------------------------------------------------------
    def variable(id, value, operator = :==)
      trigger([:var]) do |*obj|
        $game_variables[id].send(operator, value)
      end
    end
    #--------------------------------------------------------------------------
    # * Déclencheur des interrupteurs
    #--------------------------------------------------------------------------
    def switch(id, state = :active)
      trigger([:switch]) do |*obj|
          (state == :activated) ? 
            $game_switches[id] : !$game_switches[id]
      end
    end
    #--------------------------------------------------------------------------
    # * Déclencheur des Objets
    #--------------------------------------------------------------------------
    def get_abstract_item(item, count, tags)
      trigger(tags) do |*obj|
        $game_party.item_number(item) >= count 
      end
    end
    #--------------------------------------------------------------------------
    # * Déclencheur des Objets simple
    #--------------------------------------------------------------------------
    def get_item(id, count)
      get_abstract_item(ITEMS[id], count, [:object, :item])
    end
    #--------------------------------------------------------------------------
    # * Déclencheur des Armes
    #--------------------------------------------------------------------------
    def get_weapon(id, count)
      get_abstract_item(WEAPONS[id], count, [:object, :weapon])
    end
    #--------------------------------------------------------------------------
    # * Déclencheur des Armures
    #--------------------------------------------------------------------------
    def get_armor(id, count)
      get_abstract_item(ARMORS[id], count, [:object, :armor])
    end
    #--------------------------------------------------------------------------
    # * Déclencheur des monstres
    #--------------------------------------------------------------------------
    def kill_monster(id, value)
      g = trigger([:monster]) do |*obj|
        storage = obj[0].storage
        storage[id].finished?
      end
      g.storage[id] = Goal::Engagement.new(value)
      return g
    end
  end

  #==============================================================================
  # ** Engagement
  #------------------------------------------------------------------------------
  #  Contrat numeroté
  #==============================================================================

  class Engagement < Struct.new(:current, :goal)
    #--------------------------------------------------------------------------
    # * Constructeur
    #--------------------------------------------------------------------------
    def initialize(g)
      super(0, g)
    end
    #--------------------------------------------------------------------------
    # * Etat
    #--------------------------------------------------------------------------
    def finished?
      self.current >= self.goal
    end
    #--------------------------------------------------------------------------
    # * Ajout d'un objectif
    #--------------------------------------------------------------------------
    def up(i = 1)
      self.current += i
    end
    #--------------------------------------------------------------------------
    # * Augmentation de l'objectif
    #--------------------------------------------------------------------------
    def increase(i)
      self.goal += i
      return self
    end
    #--------------------------------------------------------------------------
    # * Restauration à zéro
    #--------------------------------------------------------------------------
    def to_zero
      self.current = 0
    end
  end

  #==============================================================================
  # ** Simple
  #------------------------------------------------------------------------------
  #  Objectif simple (et non composé)
  #==============================================================================

  class Simple
    #--------------------------------------------------------------------------
    # * Variables d'instances
    #--------------------------------------------------------------------------
    attr_accessor :finished
    attr_accessor :lambda
    attr_accessor :tags
    attr_accessor :storage
    alias         :finished?  :finished
    alias         :finish     :finished=
    #--------------------------------------------------------------------------
    # * Constructeur
    #--------------------------------------------------------------------------
    def initialize(lambda, tags = [])
      @storage  = Hash.new
      @tags     = tags
      @lambda   = Proc.new(&lambda)
      @finished = false
    end
    #--------------------------------------------------------------------------
    # * Opérateurs ET
    #--------------------------------------------------------------------------
    def &(other)
      @tags     = (@tags + other.tags).uniq
      @finished = @finished && other.finished?
      temp      = @lambda.clone
      obj       = self
      @lambda   = Proc.new{temp.call(obj) && other.lambda.clone.call(obj)}
      @storage.merge!(other.storage){|k, o, n|o.increase(n.goal)}
      self
    end
    #--------------------------------------------------------------------------
    # * Opérateurs OU
    #--------------------------------------------------------------------------
    def |(other)
      @tags     = (@tags + other.tags).uniq
      @finished = @finished || other.finished?
      temp      = @lambda.clone
      obj       = self
      @lambda   = Proc.new{temp.call(obj) || other.lambda.clone.call(obj)}
      @storage.merge!(other.storage){|k, o, n|o.increase(n.goal)}
      self
    end
    #--------------------------------------------------------------------------
    # * Evaluation
    #--------------------------------------------------------------------------
    def eval
      @finished = @lambda.call(self)
      self
    end

    #--------------------------------------------------------------------------
    # * Clone
    #--------------------------------------------------------------------------
    def clone
      child = super()
      child.storage.each{|i, k| k.to_zero}
      child
    end
  end
end

#==============================================================================
# ** Static_Quest
#------------------------------------------------------------------------------
#  Description d'une quête (statique)
#==============================================================================

class Static_Quest < Static::Table
  #--------------------------------------------------------------------------
  # * Champ
  #--------------------------------------------------------------------------
  pk integer  :id
  string      :name
  string      :desc 
  integer     :gold
  integer     :exp
  integer     :cost
  boolean     :repeatable
  list        :integer, :items
  list        :integer, :weapons
  list        :integer, :armors
  poly        :success
  poly        :fail
  string      :success_message
  string      :fail_message
  poly        :verify
  poly        :end_action
  boolean     :need_confirmation
  poly        :label
  poly        :preserved_success
  poly        :preserved_fail
  #--------------------------------------------------------------------------
  # * Vérifie si une quête est lançable
  #--------------------------------------------------------------------------
  def launchable?
    verify.call && !Game_Quest.all.has_key?(self.id)
  end
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  class << self
    #--------------------------------------------------------------------------
    # * Renvoi le plus gros ID
    #--------------------------------------------------------------------------
    def max_id
      return 0 if Static_Quest.count == 0
      Static_Quest.all.keys.max
    end
  end
end

#==============================================================================
# ** Game_Quest
#------------------------------------------------------------------------------
#  Description d'une quête (dynamique)
#==============================================================================

class Game_Quest < Dynamic::Table
  #--------------------------------------------------------------------------
  # * Champs
  #--------------------------------------------------------------------------
  pk integer :quest_id
  boolean :finished
  boolean :successed
  boolean :confirmed
  #--------------------------------------------------------------------------
  # * Renvoi la quête statique
  #--------------------------------------------------------------------------
  def static
    Static_Quest[self.quest_id]
  end
  #--------------------------------------------------------------------------
  # * Fini une quête avec succes
  #--------------------------------------------------------------------------
  def finish_with_success
    self.finished = true
    self.successed = true
    self.static.end_action.call
    if !self.static.need_confirmation
      self.confirm 
      Game_Quest.delete(self.quest_id)  if self.static.repeatable
    end
  end
  #--------------------------------------------------------------------------
  # * Confirmation
  #--------------------------------------------------------------------------
  def confirm
    return if !self.successed || self.confirmed
    self.confirmed = true
    $game_party.gain_gold(static.gold)
    $game_party.members.each{|actor| actor.gain_exp(self.static.exp)}
    self.static.items.each{|id| $game_party.gain_item($data_items[id], 1)}
    self.static.armors.each{|id| $game_party.gain_item($data_armors[id], 1)}
    self.static.weapons.each{|id| $game_party.gain_item($data_weapons[id], 1)}
    if self.static.repeatable
      Game_Quest.delete(self.quest_id)
    end
  end
  #--------------------------------------------------------------------------
  # * Fini une quête avec succes
  #--------------------------------------------------------------------------
  def finish_with_fail
    self.finished = true
    self.successed = false
    self.static.end_action.call
    if self.static.repeatable
      Game_Quest.delete(self.quest_id)
    end
  end
  #--------------------------------------------------------------------------
  # * Evalue une quête
  #--------------------------------------------------------------------------
  def eval
    return if self.finished
    self.static.fail.eval
    if self.static.fail.finished?
      self.finish_with_fail
      return
    end
    self.static.success.eval
    if self.static.success.finished?
      self.finish_with_success
    end
  end
  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias :finished? :finished
  alias :successed? :successed
end

#==============================================================================
# ** Quest
#------------------------------------------------------------------------------
#  Module de traitement des quêtes
#==============================================================================

module Quest
  #--------------------------------------------------------------------------
  # * Ouverture des fonctions
  #--------------------------------------------------------------------------
  extend self
  #--------------------------------------------------------------------------
  # * Renvoi les quêtes correspondant à une couleur
  #--------------------------------------------------------------------------
  def find_by_tag(tag)
    Game_Quest.all.select do |k, v|
      v.static.success.tags.include?(tag) || 
      v.static.fail.tags.include?(tag)
    end
  end
  #--------------------------------------------------------------------------
  # * Renvoi l'id d'une quête
  #--------------------------------------------------------------------------
  def idl(k)
    return k if k.is_a?(Fixnum)
    return Static_Quest.all.find{|q| q.label == k}.id
  end
  #--------------------------------------------------------------------------
  # * Renvoi une quête
  #--------------------------------------------------------------------------
  def get(id)
    Game_Quest[idl(id)]
  end
  #--------------------------------------------------------------------------
  # * Crée une quête
  #--------------------------------------------------------------------------
  def create(hash)
    id        = hash[:id]
    name      = hash[:name]
    desc      = hash[:desc]
    gold      = hash[:gold]             || 0
    exp       = hash[:exp]              || 0
    items     = hash[:items]            || []
    weapons   = hash[:weapons]          || []
    armors    = hash[:armors]           || []
    cost      = hash[:cost]             || -1
    repeat    = hash[:repeatable]       || false
    fail      = hash[:fail_trigger]     || Goal::trigger([:nothing]){|*o|false}
    success   = hash[:success_trigger]  || Goal::trigger([:nothing]){|*o|false}
    verify    = hash[:verify]           || lambda{|*o|true}
    endt      = hash[:end_action]       || lambda{|*o|true}
    confirm   = hash[:need_confirmation]|| false
    s_m       = hash[:success_message]  || Quest_Config::DEFAULT_SUCESS.call(name)
    s_f       = hash[:fail_message]     || Quest_Config::DEFAULT_FAIL.call(name)
    label     = hash[:label]            || "quest_#{id}".to_sym

    Static_Quest.insert(
      id, name, desc, gold, exp, cost, repeat, items, weapons,
      armors, success, fail, s_m, s_f, verify, endt, confirm, label, success.clone, fail.clone)
  end
  #--------------------------------------------------------------------------
  # * Démarre une quête
  #--------------------------------------------------------------------------
  def start(i)
    id = idl(i)
    if !Game_Quest.all.has_key?(id)
      if Static_Quest[id].repeatable
        Static_Quest[id].success = Static_Quest[id].preserved_success.clone
        Static_Quest[id].fail = Static_Quest[id].preserved_fail.clone
      end
      Game_Quest.insert(id, false, false, false)
      get(id).eval
    end
  end
  #--------------------------------------------------------------------------
  # * Vérifie si une quête est finie
  #--------------------------------------------------------------------------
  def finished?(i)
    id = idl(i)
    Game_Quest.all.has_key?(id) && get(id).finished
  end
  #--------------------------------------------------------------------------
  # * Vérifie si une quête est finie avec succès
  #--------------------------------------------------------------------------
  def succeeded?(i)
    id = idl(i)
    return get(id).successed if Game_Quest.all.has_key?(id)
    return false
  end
  #--------------------------------------------------------------------------
  # * Vérifie si une quête est finie en échec
  #--------------------------------------------------------------------------
  def failed?(i)
    id = idl(i)
    return !get(id).successed if Game_Quest.all.has_key?(id)
    return false
  end
  #--------------------------------------------------------------------------
  # * Vérifie si une quête est en court
  #--------------------------------------------------------------------------
  def on_the_road?(i)
    id = idl(i)
    Game_Quest.all.has_key?(id) && !get(id).finished
  end
  alias :ongoing :on_the_road?
  #--------------------------------------------------------------------------
  # * Fini la quête lancée (avec succes)
  #--------------------------------------------------------------------------
  def finish(i)
    id = idl(i)
    get(id).finish_with_success if on_the_road?(id)
  end
  #--------------------------------------------------------------------------
  # * Fini la quête lancée (avec échec)
  #--------------------------------------------------------------------------
  def fail(i)
    id = idl(i)
    get(id).finish_with_fail if on_the_road?(id)
  end
  #--------------------------------------------------------------------------
  # * Requiert une confirmation
  #--------------------------------------------------------------------------
  def need_confirmation?(i)
    id = idl(i)
    succeeded?(id) && !get(id).confirmed
  end
  #--------------------------------------------------------------------------
  # * Confirme une quête
  #--------------------------------------------------------------------------
  def confirm(i)
    id = idl(i)
    return unless need_confirmation?(id)
    get(id).confirm
  end
  #--------------------------------------------------------------------------
  # * Vérifie si une quête est lançable
  #--------------------------------------------------------------------------
  def launchable?(i)
    id = idl(i)
    Static_Quest[id].launchable?
  end
end

#==============================================================================
# ** Game_Variables
#------------------------------------------------------------------------------
#  Ajout de la vérification statique des quêtes
#==============================================================================

class Game_Variables
  #--------------------------------------------------------------------------
  # * alias
  #--------------------------------------------------------------------------
  alias :change_value :[]=
  #--------------------------------------------------------------------------
  # * Change la valeur d'une variable
  #--------------------------------------------------------------------------
  def []=(vid, value)
    change_value(vid, value)
    quests = Quest.find_by_tag(:var).select{|i, q|!q.finished}
    quests.each{|i, q| q.eval}
  end
end

#==============================================================================
# ** Game_Switches
#------------------------------------------------------------------------------
#  Ajout de la vérification statique des quêtes
#==============================================================================

class Game_Switches
  #--------------------------------------------------------------------------
  # * alias
  #--------------------------------------------------------------------------
  alias :change_value :[]=
  #--------------------------------------------------------------------------
  # * Change la valeur d'un interrupteur
  #--------------------------------------------------------------------------
  def []=(vid, value)
    change_value(vid, value)
    quests = Quest.find_by_tag(:switch).select{|i, q|!q.finished}
    quests.each{|i, q| q.eval}
  end
end

#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  Ajout de la vérification statique des quêtes
#==============================================================================

class Game_Party
  #--------------------------------------------------------------------------
  # * alias
  #--------------------------------------------------------------------------
  alias :quest_gain_item :gain_item
  #--------------------------------------------------------------------------
  # * Increase/Decrease Items
  #     include_equip : Include equipped items
  #--------------------------------------------------------------------------
  def gain_item(*args)
    quest_gain_item(*args)
    quests = Quest.find_by_tag(:object).select{|i, q|!q.finished}
    quests.each{|i, q| q.eval}
  end
end

#==============================================================================
# ** BattleManager
#------------------------------------------------------------------------------
#  Ajout de la vérification statique des quêtes
#==============================================================================

module BattleManager
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  class << self 
    #--------------------------------------------------------------------------
    # * alias
    #--------------------------------------------------------------------------
    alias :quest_process_victory :process_victory
    #--------------------------------------------------------------------------
    # * Processus de victoire
    #--------------------------------------------------------------------------
    def process_victory
      quest_process_victory
      quests = Quest.find_by_tag(:monster).select{|i, q|!q.finished}
      quests.each do |i, q|
        $game_troop.members.each do |member|
          id = member.enemy_id
          if q.static.success.storage.has_key?(id)
            q.static.success.storage[id].up
          end
          if q.static.fail.storage.has_key?(id)
            q.static.fail.storage[id].up
          end
          q.eval
        end
      end
    end
  end
end

#==============================================================================
# ** Window_QuestCategory
#------------------------------------------------------------------------------
#  Catégorie des quêtes
#==============================================================================

class Window_QuestCategory < Window_ItemCategory
  #--------------------------------------------------------------------------
  # * Largeur de la fenêtre
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  #--------------------------------------------------------------------------
  # * Nombre de colones
  #--------------------------------------------------------------------------
  def col_max
    return 4
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::quest_incurse, :incurse)
    add_command(Vocab::quest_pended,  :pended)
    add_command(Vocab::quest_success, :success)
    add_command(Vocab::quest_fail,    :fail)
  end

end

#==============================================================================
# ** Window_QuestList
#------------------------------------------------------------------------------
#  Affiche la fenêtre de listing des quêtes
#==============================================================================

class Window_QuestList < Window_ItemList

  #--------------------------------------------------------------------------
  # * Etat d'une quête
  #--------------------------------------------------------------------------
  def enable?(item)
    return true

  end
  #--------------------------------------------------------------------------
  # * Cree la liste de quête
  #--------------------------------------------------------------------------
  def make_item_list
    @data = case @category
      when :incurse
        Game_Quest.all.select{|i, q| !q.finished}.values
      when :pended
        Game_Quest.all.select{|i, q| q.finished && q.successed && !q.confirmed}.values
      when :success
        Game_Quest.all.select{|i, q| q.finished && q.successed && q.confirmed}.values
      when :fail
        Game_Quest.all.select{|i, q| q.finished && !q.successed}.values
      end

  end
  #--------------------------------------------------------------------------
  # * Ecrit une quête
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y)
    end
  end
  #--------------------------------------------------------------------------
  # * Ecrit le nom de la quête
  #--------------------------------------------------------------------------
  def draw_item_name(q, x, y)
    return unless q
    change_color(normal_color, true)
    draw_text(x, y, width, line_height, q.static.name)
  end
  #--------------------------------------------------------------------------
  # * Update Help Text
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(item ? item.static.desc : "")
  end
  #--------------------------------------------------------------------------
  # * Renvoi à la première quête
  #--------------------------------------------------------------------------
  def select_last
    select(0)
  end
end

#==============================================================================
# ** Scene_Quest
#------------------------------------------------------------------------------
#  Journal Scene_Quest
#==============================================================================

class Scene_Quest < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Start
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_quest_category
    create_quest_window
  end
  #--------------------------------------------------------------------------
  # * Création de la fenêtre de catégorie
  #--------------------------------------------------------------------------
  def create_quest_category
    @category_window = Window_QuestCategory.new
    @category_window.viewport = @viewport
    @category_window.help_window = @help_window
    @category_window.y = @help_window.height
    @category_window.set_handler(:ok,     method(:on_category_ok))
    @category_window.set_handler(:cancel, method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # * Création de la liste
  #--------------------------------------------------------------------------
  def create_quest_window
    wy = @category_window.y + @category_window.height
    wh = Graphics.height - wy
    @item_window = Window_QuestList.new(0, wy, Graphics.width, wh)
    @item_window.viewport = @viewport
    @item_window.help_window = @help_window
    @item_window.set_handler(:cancel, method(:on_item_cancel))
    @category_window.item_window = @item_window
  end
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    super 
    return_scene if Input.trigger?(:B)
  end
  #--------------------------------------------------------------------------
  # * Category [OK]
  #--------------------------------------------------------------------------
  def on_category_ok
    @item_window.activate
    @item_window.select_last
  end
  #--------------------------------------------------------------------------
  # * Item [Cancel]
  #--------------------------------------------------------------------------
  def on_item_cancel
    @item_window.unselect
    @category_window.activate
  end
end

#==============================================================================
# ** Window_ShopCommand
#------------------------------------------------------------------------------
#  This window is for selecting buy/sell on the shop screen.
#==============================================================================

class Window_QuestCommand < Window_HorzCommand
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(window_width)
    @window_width = window_width
    super(0, 0)
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    @window_width
  end
  #--------------------------------------------------------------------------
  # * Get Digit Count
  #--------------------------------------------------------------------------
  def col_max
    return 3
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab.quest_buy, :buy)
    add_command(Vocab.quest_confirm, :sell)
    add_command(Vocab.quest_cancle, :cancel)
  end
end

#==============================================================================
# ** Window_QuestBuy
#------------------------------------------------------------------------------
#  Affiche la liste des quêtes achetables
#==============================================================================

class Window_QuestBuy < Window_Selectable
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :status_window            # Status window
  attr_accessor :shop_goods
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, height, shop_goods, f=true)
    super(x, y, window_width, height)
    @shop_goods = shop_goods
    @money = 0
    @f = f
    refresh
    select(0)
  end
  #--------------------------------------------------------------------------
  # * Largeur de la fenêtre
  #--------------------------------------------------------------------------
  def window_width
    return Graphics.width/2
  end
  #--------------------------------------------------------------------------
  # * Donne le nombre d'objets
  #--------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #--------------------------------------------------------------------------
  # * Renvoi l'indice courant
  #--------------------------------------------------------------------------
  def item
    @data[index]
  end
  #--------------------------------------------------------------------------
  # * Attribue la monaie
  #--------------------------------------------------------------------------
  def money=(money)
    @money = money
    refresh
  end
  #--------------------------------------------------------------------------
  # * Renvoi l'état d'activation d'un objet
  #--------------------------------------------------------------------------
  def current_item_enabled?
    enable?(@data[index])
  end
  #--------------------------------------------------------------------------
  # * Donne le prix d'un objet
  #--------------------------------------------------------------------------
  def price(item)
    return 0 unless item
    item.cost
  end
  #--------------------------------------------------------------------------
  # * Affiche l'accès
  #--------------------------------------------------------------------------
  def enable?(item)
    return item && item.cost <= @money && !Game_Quest.all.has_key?(item.id) if @f
    true
  end
  #--------------------------------------------------------------------------
  # * Rafraichis
  #--------------------------------------------------------------------------
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
  #--------------------------------------------------------------------------
  # * Crée la liste des quêtes
  #--------------------------------------------------------------------------
  def make_item_list
    @data = []
    @shop_goods.each do |goods|
      @data.push(goods)
    end
  end
  #--------------------------------------------------------------------------
  # * Ecrit une quête
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    rect = item_rect(index)
    draw_item_name(item, rect.x, rect.y, enable?(item))
    rect.width -= 4
    draw_text(rect, price(item), 2) if @f
  end
  #--------------------------------------------------------------------------
  # * Ecrit le nom de la quête
  #--------------------------------------------------------------------------
  def draw_item_name(q, x, y, e)
    return unless q
    change_color(normal_color, e)
    draw_text(x, y, width, line_height, (q.name.length >= 18) ? 
      q.name[0..15]+"..." : q.name)
  end
  #--------------------------------------------------------------------------
  # * Change le status
  #--------------------------------------------------------------------------
  def status_window=(status_window)
    @status_window = status_window
    call_update_help
  end
  #--------------------------------------------------------------------------
  # * Modifie le header
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(item ?  item.desc : "")
    @status_window.quest = item if @status_window
  end
  #--------------------------------------------------------------------------
  # * Modifie la liste des quêtes
  #--------------------------------------------------------------------------
  def quests=(k)
    @shop_goods = k
    refresh
  end
end

#==============================================================================
# ** Window_QuestStatus
#------------------------------------------------------------------------------
#  Fenêtre pour afficher les gains d'une quête
#==============================================================================

class Window_QuestStatus < Window_Base
  #--------------------------------------------------------------------------
  # * Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @quest = nil
    @page_index = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_gold
    draw_exp
    draw_items 
  end
  #--------------------------------------------------------------------------
  # * accès a une propriété
  #--------------------------------------------------------------------------
  def get(meth, i = 0)
    (@quest) ? @quest.send(meth) : i
  end
  #--------------------------------------------------------------------------
  # * Ecrit l'or reçu
  #--------------------------------------------------------------------------
  def draw_gold
    change_color(system_color)
    draw_text(0, 0, contents.width - 4 , line_height, Vocab.quest_gold)
    change_color(normal_color)
    draw_text(0, 0, contents.width - 4 , line_height, get(:gold), 2)
  end
  #--------------------------------------------------------------------------
  # * Ecrit l'exp reçu
  #--------------------------------------------------------------------------
  def draw_exp
    change_color(system_color)
    draw_text(0, 20, contents.width - 4 , line_height, Vocab.quest_exp)
    change_color(normal_color)
    draw_text(0, 20, contents.width - 4 , line_height, get(:exp), 2)
  end
  #--------------------------------------------------------------------------
  # * Ecrit les objets reçus
  #--------------------------------------------------------------------------
  def draw_items
    return unless @quest
    it = get(:items).uniq
    we = get(:weapons).uniq
    ar = get(:armors).uniq
    change_color(system_color)
    draw_text(0, 40, contents.width - 4 , line_height, Vocab.quest_items)
    change_color(normal_color)
    y = 68
    it.each do |i|
      item = $data_items[i]
      draw_item_name(item, 0, y, true, contents.width)
      r = Rect.new(0, y, contents.width - 4, 22)
      draw_text(r, sprintf("%2d", get(:items).count{|q|q == i}), 2)
      y += 22
    end
    we.each do |i|
      item = $data_weapons[i]
      draw_item_name(item, 0, y, true, contents.width)
      r = Rect.new(0, y, contents.width - 4, 22)
      draw_text(r, sprintf("%2d", get(:weapons).count{|q|q == i}), 2)
      y += 22
    end
    ar.each do |i|
      item = $data_armors[i]
      draw_item_name(item, 0, y, true, contents.width)
      r = Rect.new(0, y, contents.width - 4, 22)
      draw_text(r, sprintf("%2d", get(:armors).count{|q|q == i}), 2)
      y += 22
    end
  end
  #--------------------------------------------------------------------------
  # * Attribue une quête
  #--------------------------------------------------------------------------
  def quest=(item)
    @quest = item
    refresh
  end
end

#==============================================================================
# ** Scene_QuestShop
#------------------------------------------------------------------------------
#  Magasins de quêtes
#==============================================================================

class Scene_QuestShop < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Prepare
  #--------------------------------------------------------------------------
  def prepare(quests)
    @q = quests
    q = Array.new(quests.length + 1){|i|Static_Quest[Quest.idl(i)]}.compact
    @quests = q.select{|quest| quest.cost > 0}
  end
  #--------------------------------------------------------------------------
  # * Start
  #--------------------------------------------------------------------------
  def start
    super
    create_help_window
    create_gold_window
    create_command_window
    create_dummy_window
    create_status_window
    create_buy_window
    create_sell_window
  end
  #--------------------------------------------------------------------------
  # * Création de la fenêtre d'or
  #--------------------------------------------------------------------------
  def create_gold_window
    @gold_window = Window_Gold.new
    @gold_window.viewport = @viewport
    @gold_window.x = Graphics.width - @gold_window.width
    @gold_window.y = @help_window.height
  end
  #--------------------------------------------------------------------------
  # * Creation de la fenêtre de commande
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_QuestCommand.new(@gold_window.x)
    @command_window.viewport = @viewport
    @command_window.y = @help_window.height
    @command_window.set_handler(:buy,    method(:command_buy))
    @command_window.set_handler(:sell,   method(:command_sell))
    @command_window.set_handler(:cancel, method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # * Cree le fond
  #--------------------------------------------------------------------------
  def create_dummy_window
    wy = @command_window.y + @command_window.height
    wh = Graphics.height - wy
    @dummy_window = Window_Base.new(0, wy, Graphics.width, wh)
    @dummy_window.viewport = @viewport
  end
  #--------------------------------------------------------------------------
  # * Cree la fenêtre de status
  #--------------------------------------------------------------------------
  def create_status_window
    wx = Graphics.width/2
    wy = @dummy_window.y
    ww = Graphics.width - wx
    wh = @dummy_window.height
    @status_window = Window_QuestStatus.new(wx, wy, ww, wh)
    @status_window.viewport = @viewport
    @status_window.hide
  end
  #--------------------------------------------------------------------------
  # * Crée la fenêtre d'achat
  #--------------------------------------------------------------------------
  def create_buy_window
    wy = @dummy_window.y
    wh = @dummy_window.height
    @buy_window = Window_QuestBuy.new(0, wy, wh, @quests)
    @buy_window.viewport = @viewport
    @buy_window.help_window = @help_window
    @buy_window.status_window = @status_window
    @buy_window.hide
    @buy_window.set_handler(:ok,     method(:on_buy_ok))
    @buy_window.set_handler(:cancel, method(:on_buy_cancel))
  end
  #--------------------------------------------------------------------------
  # * Crée la fenêtre de confirmation
  #--------------------------------------------------------------------------
  def create_sell_window
    wy = @dummy_window.y
    wh = @dummy_window.height
    @sell_window = Window_QuestBuy.new(0, wy, wh, get_quests, false)
    @sell_window.viewport = @viewport
    @sell_window.help_window = @help_window
    @sell_window.status_window = @status_window
    @sell_window.hide
    @sell_window.set_handler(:ok,     method(:on_sell_ok))
    @sell_window.set_handler(:cancel, method(:on_sell_cancel))
  end
  #--------------------------------------------------------------------------
  # * Renvoi la liste des quêtes
  #--------------------------------------------------------------------------
  def get_quests
    quests = Game_Quest.all.select do |i, q| 
      @q.include?(q.quest_id) && q.static.need_confirmation && !q.confirmed
    end.values
    return quests.collect{|k|k.static}
  end
  #--------------------------------------------------------------------------
  # * [Buy] Command
  #--------------------------------------------------------------------------
  def command_buy
    @dummy_window.hide
    @buy_window.money = money
    @buy_window.show.activate
    @status_window.show
  end
  #--------------------------------------------------------------------------
  # * [Sell] Command
  #--------------------------------------------------------------------------
  def command_sell
    @dummy_window.hide
    @sell_window.show
    @sell_window.unselect
    @sell_window.refresh
    @sell_window.show.activate
    @status_window.show
    @sell_window.select(0)
  end
  #--------------------------------------------------------------------------
  # * Buy [OK]
  #--------------------------------------------------------------------------
  def on_buy_ok
    q = @buy_window.item
    $game_party.lose_gold(q.cost)
    Quest.start(q.id)
    @gold_window.refresh
    @status_window.refresh
    Sound.play_shop
    on_buy_cancel
  end
  #--------------------------------------------------------------------------
  # * Buy [Cancel]
  #--------------------------------------------------------------------------
  def on_buy_cancel
    @command_window.activate
    @dummy_window.show
    @buy_window.hide
    @status_window.hide
    @status_window.quest = nil
    @help_window.clear
  end
  #--------------------------------------------------------------------------
  # * Sell [OK]
  #--------------------------------------------------------------------------
  def on_sell_ok
    q = @sell_window.item
    Quest.confirm(q.id)
    @gold_window.refresh
    @status_window.refresh
    Sound.play_shop
    @sell_window.quests = get_quests
    on_sell_cancel
  end
  #--------------------------------------------------------------------------
  # * Sell [Cancel]
  #--------------------------------------------------------------------------
  def on_sell_cancel
    @command_window.activate
    @dummy_window.show
    @sell_window.hide
    @status_window.hide
    @status_window.quest = nil
    @help_window.clear
  end
  #--------------------------------------------------------------------------
  # * Or
  #--------------------------------------------------------------------------
  def money
    @gold_window.value
  end
end


#==============================================================================
# ** Kernel
#------------------------------------------------------------------------------
#  Point d'entrée du script
#==============================================================================

module Kernel
  #--------------------------------------------------------------------------
  # * Déclencheur des variables
  #--------------------------------------------------------------------------
  def var_check(id, value, operator = :==)
    Goal::variable(id, value, operator)
  end
  #--------------------------------------------------------------------------
  # * Déclencheur des interrupteurs
  #--------------------------------------------------------------------------
  def switch_check(id, state = :active)
    Goal::switch(id, state)
  end
  #--------------------------------------------------------------------------
  # * Déclencheur des Objets simple
  #--------------------------------------------------------------------------
  def has_item(id, count)
    Goal::get_item(id, count)
  end
  #--------------------------------------------------------------------------
  # * Déclencheur des Armes
  #--------------------------------------------------------------------------
  def has_weapon(id, count)
    Goal::get_weapon(id, count)
  end
  #--------------------------------------------------------------------------
  # * Déclencheur des Armures
  #--------------------------------------------------------------------------
  def has_armor(id, count)
    Goal::get_armor(id, count)
  end
  #--------------------------------------------------------------------------
  # * Déclencheur des monstres
  #--------------------------------------------------------------------------
  def monster_killed(id, value)
    Goal::kill_monster(id, value)
  end
  #--------------------------------------------------------------------------
  # * Représente une action
  #--------------------------------------------------------------------------
  def action(&block)
    block
  end
  alias :check :action
end


# Insertion dans le menu de base

if Quest_Config::QUEST_IN_MENU

  #==============================================================================
  # ** Window_MenuCommand
  #------------------------------------------------------------------------------
  #  This command window appears on the menu screen.
  #==============================================================================

  class Window_MenuCommand
    #--------------------------------------------------------------------------
    # * Alias
    #--------------------------------------------------------------------------
    alias :quest_cmd :add_main_commands
    #--------------------------------------------------------------------------
    # * Ajout du journal de quêtes
    #--------------------------------------------------------------------------
    def add_main_commands
      quest_cmd
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
    alias :quest_window :create_command_window
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
      quest_window
      @command_window.set_handler(:quest, method(:command_quest))
    end
  end

end

#==============================================================================
# ** SceneManager
#------------------------------------------------------------------------------
#  Ajout du lancement du magasin de quêtes
#==============================================================================

module SceneManager
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  class << self
    #--------------------------------------------------------------------------
    # * Lance un magasin de quête
    #--------------------------------------------------------------------------
    def questShop(ids)
      call(Scene_QuestShop)
      scene.prepare(ids)  
    end
  end
end
