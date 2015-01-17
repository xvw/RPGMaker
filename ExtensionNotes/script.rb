#==============================================================================
# ** NoteTag
#------------------------------------------------------------------------------
# Représente les tags dans les notes
#==============================================================================

module NoteTag
  #--------------------------------------------------------------------------
  # * Système de type
  #--------------------------------------------------------------------------
  BoolCoers = ->(x) do 
    value = begin eval(x) rescue true end
    !!value
  end
  Types = {
    int:          {ext:[:int, :integer],    coers:->(x){x.to_i}},
    float:        {ext:[:float, :double],   coers:->(x){x.to_f}},
    string:       {ext:[:string, :text],    coers:->(x){x.to_s}},
    bool:         {ext:[:bool, :boolean],   coers:BoolCoers},
    string_list:  {ext:[:strings, :string_list, :texts, :text_list], 
      coers:->(x) do 
        x.scan(/[^,|^\s]+/)
      end
    },
    int_list:     {ext:[:int_list, :integer_list, :ints, :integers],
      coers:->(x) do
        x.scan(/[^,|^\s]+/).collect{|i|i.to_i}
      end
    },
    float_list:   {ext:[:float_list, :floats],
      coers:->(x) do
        x.scan(/[^,|^\s]+/).collect{|i|i.to_f}
      end
    },
    bool_list:   {ext:[:bool_list, :bools, :booleans, :boolean_list],
      coers:->(x) do
        x.scan(/[^,|^\s]+/).collect{|i|BoolCoers.(x)}
      end
    }, 
  }
  #--------------------------------------------------------------------------
  # * API pour les classes
  #--------------------------------------------------------------------------
  module API
    #--------------------------------------------------------------------------
    # * Renvoi les tags de la méthode note
    #--------------------------------------------------------------------------
    def tags
      @note.to_tags
    end
  end
  #--------------------------------------------------------------------------
  # * Méthodes publiques
  #--------------------------------------------------------------------------
  class << self
    #--------------------------------------------------------------------------
    # * Inférence de type (produit la bonne cellulue en fonction d'un symbole)
    #--------------------------------------------------------------------------
    def get_coersion(k)
      return Types[k][:coers] if Types.has_key?(k)
      i = Types.find{|e| e[1][:ext].include?(k)}
      return Types[i[0]][:coers] if i
      return Types[:string][:coers]
    end
    #--------------------------------------------------------------------------
    # * Convertit une valeur en fonction de son type
    #--------------------------------------------------------------------------
    def cast(value, type)
      get_coersion(type).(value)
    end
    #--------------------------------------------------------------------------
    # * Convertit une ligne en Tag
    #--------------------------------------------------------------------------
    def convert(line)
      return nil unless line =~ /^<.*>$/
      if line =~ /^<(.+)>(.*)<\/\w+>/
        type = :string
        key = $1
        value = $2
        if key =~ /^(\w+)\s*:\s*(\w+)$/
          key, type = $1, $2.to_sym
        end
        return Simple.new(key, value, type)
      end
      body = line =~ /^<\s*(.*)\s*\/>$/ && $1
      return nil unless body
      head, tail = body =~ /^(\w*)/ && [$1, $']
      attributes = parse_attributes(tail)
      return Complex.new(head, attributes)
    end
    #--------------------------------------------------------------------------
    # * Construit les attributs
    #--------------------------------------------------------------------------
    def parse_attributes(str, acc = {})
      return acc.select do |key, a| 
        a && a.keyword && a.value
      end if !str || str.empty?
      type = :string
      key, value, tail = 
        str =~ /^\s*(\w+|\w+:\w+)\s*=\s*\\*"([^\\"]+)\\*"/ && [$1,$2,$']
      if key =~ /^(\w+)\s*:\s*(\w+)$/
        key, type = $1, $2.to_sym
      end
      acc[key.to_sym] = Simple.new(key, value, type) if key
      parse_attributes(tail, acc)
    end
  end

  #==============================================================================
  # ** Simple
  #------------------------------------------------------------------------------
  # Représente une entité simple
  # soit <keyword>valeur</keyword>
  # soit <keyword:type>valeur</keyword>
  #==============================================================================

  class Simple
    #--------------------------------------------------------------------------
    # * Public instances variables
    #--------------------------------------------------------------------------
    attr_reader :keyword
    attr_reader :value
    attr_reader :type 
    #--------------------------------------------------------------------------
    # * Object initialize
    #--------------------------------------------------------------------------
    def initialize(k, v, t=:string)
      @type     = t
      @keyword  = k
      @value    = NoteTag.cast(v, @type)
    end
  end

  #==============================================================================
  # ** Complex
  #------------------------------------------------------------------------------
  # Représente une entité complexe
  # soit <keyword attributA="foo" attributB="bar"/>
  # soit <keyword attributA:int="10" attributB:float="1.5"/>
  #==============================================================================

  class Complex
    #--------------------------------------------------------------------------
    # * Public instances variables
    #--------------------------------------------------------------------------
    attr_reader :keyword
    attr_reader :attributes
    #--------------------------------------------------------------------------
    # * Object initialize
    #--------------------------------------------------------------------------
    def initialize(k, a)
      @keyword = k
      @attributes = a
    end
    #--------------------------------------------------------------------------
    # * Accessor
    #--------------------------------------------------------------------------
    def method_missing(m, *rest)
      return @attributes[m].value if @attributes.has_key?(m)
      raise NoMethodError
    end
  end

end

#==============================================================================
# ** String
#------------------------------------------------------------------------------
# Ajoute la conversion des lignes en tags
#==============================================================================

class String 
  #--------------------------------------------------------------------------
  # * Conversion d'une chaine un hash de tag
  #--------------------------------------------------------------------------
  def to_tags
    tags = {}
    self.split(/\n|\r\n/).each do |ln|
      p ln
      parsed = NoteTag.convert(ln)
      tags[parsed.keyword] = parsed if parsed
    end
    tags
  end
end

#==============================================================================
# ** Ajout des notes aux instances
#------------------------------------------------------------------------------
#==============================================================================

[RPG::BaseItem, RPG::Tileset, RPG::Map].each do |cls|
  cls.send(:include, NoteTag::API)
end
