module Graphics
  class << self
    alias_method :blur_update, :update
    def blur_screen(time, delete=false)
      @blured = time
      @deleted_blur = delete
    end
    def update
      @blured ||= 0
      blur_update
      if @blured != 0
        unless @snapshot
          @snapshot = Sprite.new
          @snapshot.x = @snapshot.ox = Graphics.width/2
          @snapshot.y = @snapshot.oy = Graphics.height/2
          @snapshot.z = 99999
          @snapshot.bitmap = Graphics.snap_to_bitmap
        end
        @snapshot.bitmap.perform_blur(2)
        @blured -= 1
      end
      delete_snap if @deleted_blur && @blured <= 0
    end
    def delete_snap
      @snapshot.dispose if @snapshot
      @snapshot = nil
    end
    def interrupt_blur
      delete_snap
      @blured = 0
    end
  end
end

#==============================================================================
# ** Bitmap
#------------------------------------------------------------------------------
# Add the perform_blur function
# By Zeus, Grim and Hiino
#==============================================================================

class Bitmap
  #--------------------------------------------------------------------------
  # * Blur a bitmap
  #--------------------------------------------------------------------------
  def perform_blur(decal)
    clone_bmp = self.clone
    8.times do |index|
      case index
      when 0; x, y = -decal, decal
      when 1; x, y = 0, decal
      when 2; x, y = 0, -decal
      when 3; x, y = -decal, -decal
      when 4; x, y = decal, decal
      when 5; x, y = -decal, 0
      when 6; x, y = decal, 0
      when 7; x, y = decal, -decal
      end
      fact_opacity = (index == 7) ? 255/2 : 255/(index+1)
      self.blt(x, y, clone_bmp, rect, fact_opacity)
    end
    clone_bmp.dispose
  end

end
