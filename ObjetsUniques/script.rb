#==============================================================================
# ** Item_Config
#------------------------------------------------------------------------------
#  Configuration du script
#==============================================================================

module Item_Config
  #--------------------------------------------------------------------------
  # * Défini si les objets sont groupés ou non (dans leur affichage)
  #--------------------------------------------------------------------------
  GROUPED = false
  #--------------------------------------------------------------------------
  # * Si les objets ne sont pas groupés, le nombre d'objets maximum portables
  # (Par sac)
  #--------------------------------------------------------------------------
  MAX = 999
end

#==============================================================================
# ** Generic
#------------------------------------------------------------------------------
#  Représente les structures de données pour l'héritage transversal
#==============================================================================

module Generic

  #==============================================================================
  # ** BaseItem
  #------------------------------------------------------------------------------
  #  Représente les constituants minimaux d'un objet
  #==============================================================================
  module BaseItem
    #--------------------------------------------------------------------------
    # * Initialise un BaseItem
    #--------------------------------------------------------------------------
    def setup_base(id, list)
      current_item  = list[id]
      @id           = current_item.id 
      @name         = current_item.name.dup
      @icon_index   = current_item.icon_index
      @description  = current_item.description.dup
      @note         = current_item.note
      # Clonage un peu plus raffiné des tableaux complexes
      @features     = Array.new(current_item.features.length) do |i|
        current_feature   = current_item.features[i]
        code              = current_feature.code 
        data_id           = current_feature.data_id
        value             = current_feature.value
        RPG::BaseItem::Feature.new(code, data_id, value)
      end
    end
  end

  #==============================================================================
  # ** EquipItem
  #------------------------------------------------------------------------------
  #  Représente les constituants des objets équipables
  #==============================================================================
  module EquipItem
    #--------------------------------------------------------------------------
    # * Héritage transversal
    #--------------------------------------------------------------------------
    include BaseItem
    #--------------------------------------------------------------------------
    # * Initialise un EquipItem
    #--------------------------------------------------------------------------
    def setup_equip(id, list)
      current_item  = list[id]
      setup_base(id, list)
      @price        = current_item.price
      @etype_id     = current_item.etype_id
      @params       = current_item.params.dup
    end
  end

  #==============================================================================
  # ** UsableItem
  #------------------------------------------------------------------------------
  #  Représente les constituants des objets Consommables
  #==============================================================================
  module UsableItem
    #--------------------------------------------------------------------------
    # * Héritage transversal
    #--------------------------------------------------------------------------
    include BaseItem
    #--------------------------------------------------------------------------
    # * Initialise un UsableItem
    #--------------------------------------------------------------------------
    def setup_usable(id, list)
      current_item    = list[id]
      setup_base(id, list)
      @scope              = current_item.scope
      @occasion           = current_item.occasion
      @speed              = current_item.speed
      @success_rate        = current_item.success_rate
      @repeats            = current_item.repeats
      @tp_gain            = current_item.tp_gain
      @hit_type           = current_item.hit_type
      @animation_id       = current_item.animation_id
      @damage             = RPG::UsableItem::Damage.new
      @damage.type        = current_item.damage.type
      @damage.element_id  = current_item.damage.element_id
      @damage.formula     = current_item.damage.formula.clone
      @damage.variance    = current_item.damage.variance
      @damage.critical    = current_item.damage.critical
      # Clonage un peu plus raffiné des tableaux complexes
      @effects            = Array.new(current_item.effects.length) do |i|
        current_effect  = current_item.effects[i]
        code            = current_effect.code
        data_id         = current_effect.data_id
        value1          = current_effect.value1
        value2          = current_effect.value2
        RPG::UsableItem::Effect.new(code, data_id, value1, value2)
      end
    end
  end
end

#==============================================================================
# ** Game_Item
#------------------------------------------------------------------------------
#  Description D'un objet consommable
#==============================================================================

class Game_Item < RPG::Item
  #--------------------------------------------------------------------------
  # * Héritage transversal
  #--------------------------------------------------------------------------
  include Generic::UsableItem
  #--------------------------------------------------------------------------
  # * Initialisation de l'objet
  #--------------------------------------------------------------------------
  def  initialize(id)
    super()
    setup_usable(id, $data_items)
    @scope      = $data_items[id].scope
    @itype_id   = $data_items[id].itype_id
    @price      = $data_items[id].price
    @consumable = $data_items[id].consumable
  end 
end

#==============================================================================
# ** Game_Weapon
#------------------------------------------------------------------------------
#  Description D'une arme
#==============================================================================

class Game_Weapon < RPG::Weapon
  #--------------------------------------------------------------------------
  # * Héritage transversal
  #--------------------------------------------------------------------------
  include Generic::EquipItem
  #--------------------------------------------------------------------------
  # * Initialisation de l'objet
  #--------------------------------------------------------------------------
  def initialize(id)
    super()
    setup_equip(id, $data_weapons)
    @wtype_id     = $data_weapons[id].wtype_id
    @animation_id = $data_weapons[id].animation_id
  end
end

#==============================================================================
# ** Game_Armor
#------------------------------------------------------------------------------
#  Description D'une armure
#==============================================================================

class Game_Armor < RPG::Armor
  #--------------------------------------------------------------------------
  # * Héritage transversal
  #--------------------------------------------------------------------------
  include Generic::EquipItem
  #--------------------------------------------------------------------------
  # * Initialisation de l'objet
  #--------------------------------------------------------------------------
  def initialize(id)
    super()
    setup_equip(id, $data_armors)
    @atype_id = $data_armors[id].atype_id
    @etype_id = $data_armors[id].etype_id
  end
end

#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  Ajout de l'aspect unique des objets
#==============================================================================

class Game_Party
  #--------------------------------------------------------------------------
  # * Initialise les conteneur d'objets
  #--------------------------------------------------------------------------
  def init_all_items
    @items    = []
    @weapons  = []
    @armors   = []
  end
  #--------------------------------------------------------------------------
  # * Renvoi une liste d'élément trié par les id's
  #--------------------------------------------------------------------------
  def sort_by_id(list)
    l = list.sort{|a,b| a.id <=> b.id}
    (Item_Config::GROUPED) ? l.uniq{|i| i.id} : l
  end
  #--------------------------------------------------------------------------
  # * Renvoi les containers triés
  #--------------------------------------------------------------------------
  [:items, :weapons, :armors].each do |k|
    define_method(k){sort_by_id(instance_variable_get("@#{k}"))}
  end
  #--------------------------------------------------------------------------
  # * Retourne le Container en fonction de la classe
  #--------------------------------------------------------------------------
  def item_container(item_class)
    return @items   if [RPG::Item, Game_Item].include?(item_class)
    return @weapons if [RPG::Weapon, Game_Weapon].include?(item_class)
    return @armors  if [RPG::Armor, Game_Armor].include?(item_class)
    return nil
  end
  #--------------------------------------------------------------------------
  # * Construit un objet en fonction de sa représentation statique
  #--------------------------------------------------------------------------
  def build_item(item)
    return Game_Item.new(item.id)   if item.is_a?(RPG::Item)
    return Game_Weapon.new(item.id) if item.is_a?(RPG::Weapon)
    return Game_Armor.new(item.id)  if item.is_a?(RPG::Armor)
    return nil
  end
  #--------------------------------------------------------------------------
  # * Renvoi le nombre d'objets possédés
  #--------------------------------------------------------------------------
  def item_number(item)
    container = item_container(item.class)
    container ? container.count{|elt|elt.id == item.id} || 0 : 0
  end
  #--------------------------------------------------------------------------
  # * Determine if Specified Item Is Included in Members' Equipment
  #--------------------------------------------------------------------------
  def members_equip_include?(item)
    members.any? do |actor|
      actor.equips.find{|elt| elt.id == item.id} != nil
    end
  end
  #--------------------------------------------------------------------------
  # * Modifie le nombre d'objet possédé
  #--------------------------------------------------------------------------
  def gain_item(item, amount, include_equip = false)
    container = item_container(item.class)
    return unless container
    item = build_item(item)
    return unless item
    nitm = Item_Config::GROUPED ? item_number(item) : container.length
    newn = nitm + amount
    if amount > 0 
      nmax  = Item_Config::GROUPED ? max_item_number(item) : Item_Config::MAX
      limit = ([newn, nmax].min) - nitm
      limit.times{container << build_item(item)}
    else
      limit = nitm - ([newn, 0].max)
      limit.times do 
        item_finded = container.find{|elt|elt.id == item.id}
        container.delete(item_finded)
      end
      rest = nitm - limit
      discard_members_equip(item, rest) if rest > 0 && include_equip
      $game_map.need_refresh = true
    end
  end
end

#==============================================================================
# ** Window_ItemList
#------------------------------------------------------------------------------
#  Permet d'écrire ou non le nombre d'objets en fonction du groupage
#==============================================================================

class Window_ItemList
  #--------------------------------------------------------------------------
  # * alias
  #--------------------------------------------------------------------------
  alias :itemuniq_draw_nb draw_item_number
  #--------------------------------------------------------------------------
  # * Affiche le nombre d'objet possédé
  #--------------------------------------------------------------------------
  def draw_item_number(rect, item)
    itemuniq_draw_nb(rect, item) if Item_Config::GROUPED  
  end
end