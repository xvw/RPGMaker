# Propose une classe pour traiter des lignes graphiques

#==============================================================================
# ** Sprite_Line
#------------------------------------------------------------------------------
# Proposition d'une classe pour afficher des lignes
#==============================================================================

class Sprite_Line < Sprite
  #--------------------------------------------------------------------------
  # * Privatisation des fonctions
  #--------------------------------------------------------------------------
  private :zoom_x
  private :zoom_y
  private :x 
  private :y
  private :ox
  private :oy
  #--------------------------------------------------------------------------
  # * Variables d'instances
  #--------------------------------------------------------------------------
  attr_reader :height
  attr_reader :width
  attr_reader :color
  attr_reader :origin
  attr_reader :destination
  #--------------------------------------------------------------------------
  # * Constructeur
  #--------------------------------------------------------------------------
  def initialize(xa, ya, xb, yb, len, color, *viewport)
    super(*viewport)
    @width        = len 
    @color        = color
    @origin       = [xa, ya]
    @destination  = [xb, yb]
    calc_origin
    create_bitmap
    change_line_form
  end
  #--------------------------------------------------------------------------
  # * Calcul de l'origine
  #--------------------------------------------------------------------------
  def calc_origin
    self.ox       =  @width / 2
    self.x,self.y = *@origin
  end
  #--------------------------------------------------------------------------
  # * Renvoi la soustraction des coordonnées
  #--------------------------------------------------------------------------
  def group_coords
    xa, ya  = *@origin
    xb, yb  = *@destination
    return (xa-xb), (ya-yb)
  end
  #--------------------------------------------------------------------------
  # * Calcul de la hauteur
  #--------------------------------------------------------------------------
  def calc_height
    @height =  Math.hypot(*group_coords).to_i
  end
  #--------------------------------------------------------------------------
  # * Création de la Bitmap
  #--------------------------------------------------------------------------
  def create_bitmap
    self.bitmap = Bitmap.new(@width, 1)
    self.bitmap.fill_rect(0, 0, @width, 1, @color)
  end
  #--------------------------------------------------------------------------
  # * Calcul le Zoom
  #--------------------------------------------------------------------------
  def process_zoom
    xa, ya = *@origin
    xb, yb = *@destination
    self.zoom_y = @height.to_f
    if xa == xb && yb > ya
      self.angle = 180
    elsif xa == xb
      self.angle = 0
    elsif ya == yb && xb > xa
      self.angle = 90
    elsif ya == yb 
      self.angle = 270
    else
      self.angle  = ((Math.atan2(*group_coords))*(180.0/Math::PI))-180
    end 
  end
  #--------------------------------------------------------------------------
  # * Routine générale
  #--------------------------------------------------------------------------
  def change_line_form
    calc_height
    process_zoom
  end
  #--------------------------------------------------------------------------
  # * Changement de la destination
  #--------------------------------------------------------------------------
  def set_destination(x, y)
    @destination = [x, y]
    change_line_form
  end
  #--------------------------------------------------------------------------
  # * Changement de l'origine
  #--------------------------------------------------------------------------
  def set_origin(x, y)
    @origin       = [x, y]
    self.x,self.y = *@origin
    change_line_form
  end
end