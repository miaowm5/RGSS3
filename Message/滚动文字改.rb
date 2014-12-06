=begin
===============================================================================
  滚动文字改 By喵呜喵5
===============================================================================

【说明】

  （※ 这个脚本需要同时插入 喵呜喵5基础脚本 后才能使用）

  指定的开关打开的时候，滚动文字时玩家可以随意移动

  滚动文字过程中切换场景（例如打开菜单）的话滚动文字将会强制结束

  【删除】意义不明的脚本【删除】

  毫无意外的，和我的阅读系统脚本并不兼容，【删除】因为我懒【删除】

=end
$m5script ||= {};raise("需要喵呜喵5基础脚本的支持") unless $m5script[:M5Base]
$m5script[:M5ST20140731] = 20140731;M5script.version(20140731)
module M5ST20140731
#==============================================================================
# 设定部分
#==============================================================================

  Z = 199

  # Z坐标，滚动文字被什么遮住或者遮住什么东西时修改这个数值

  X = 12

  # X坐标，控制滚动文字的左右位置

  SWI = 1

  # 使用脚本的开关编号ID，对应开关打开时脚本生效

#==============================================================================
# 设定结束
#==============================================================================
class Sprite_M5_ScrollText < Sprite_M5
  def initialize
    super(nil)
    @cal = Window_M5CalText.new
    self.bitmap = Bitmap.new(1,1)
    @cal.font_height = @font_size = self.bitmap.text_size("口").height
    @cal.font_width = self.bitmap.text_size("口").width
    self.x,self.z = X,Z
    @speed = 1
    @start = false
  end
  def start(text,speed)
    @speed = speed
    @height = @cal.cal_all_text_height(text)
    self.bitmap.dispose
    self.bitmap = Bitmap.new(Graphics.width*2,@height)
    rect = self.bitmap.rect.clone
    rect.height = @font_size
    text.each_line("\n") do |line|
      line.slice!("\n")
      self.bitmap.draw_text(rect,line)
      rect.y += @font_size
    end
    self.y = Graphics.height
    @start = true
  end
  def update
    super
    return unless @start
    self.y -= @speed
    @start = false if self.y <= -@height
  end
  def dispose
    super
    @cal.dispose
  end
end
end # module M5ST20140731
class Scene_Map
  attr_accessor :sprite_m5_scroll
  alias m5_20140731_start start
  def start
    m5_20140731_start
    @sprite_m5_scroll = M5ST20140731::Sprite_M5_ScrollText.new
  end
end
class Window_ScrollText
  alias m5_20140731_update update
  def update
    if $game_switches[M5ST20140731::SWI]
      if $game_message.scroll_mode && SceneManager.scene_is?(Scene_Map)
        SceneManager.scene.sprite_m5_scroll.start($game_message.all_text,
          $game_message.scroll_speed)
        $game_message.clear
      end
    end
    m5_20140731_update
  end
end