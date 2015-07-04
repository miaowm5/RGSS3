=begin
===============================================================================
  【插件】不公开配方的合成脚本 - 界面背景控制
===============================================================================

  【说明】

  可以控制《不公开配方的合成脚本 By喵呜喵5》中合成界面的背景

  不需要这个插件的话，直接把这个脚本删掉就好了

=end
module M5Combin20141204;module Tool1
#==============================================================================
#  设定部分
#==============================================================================

  BACKGROUND = "Background"

  # 界面背景图片的文件名，放在 Graphics\System 目录下

  MAP = true

  # 是否保留地图（true：保留，false：不保留）

  COLOR = Color.new(16, 16, 16, 128)

  # 地图的颜色改变（默认：R 16，G 16，B 16，Alpha 128）

#==============================================================================
#  设定结束
#==============================================================================
end;end
class Scene_Combin
  alias m5_20141204_create_background create_background
  def create_background
    m5_20141204_create_background
    if Tool1::MAP
      @background_sprite.color.set(Tool1::COLOR)
    else
      @background_sprite.bitmap = Bitmap.new(1,1)
    end
    @background_sprite2 = Sprite.new
    @background_sprite2.bitmap = Cache.system(Tool1::BACKGROUND)
  end
  alias m5_20141204_dispose_background dispose_background
  def dispose_background
    m5_20141204_dispose_background
    @background_sprite2.dispose
  end
end
