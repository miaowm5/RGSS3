=begin
===============================================================================
  对话时背景变暗 By喵呜喵5
===============================================================================

  【说明】

  游戏中对话时背景将淡入一张图片作为背景，对话结束后图片淡出
  【删除】其实就是一个在进行对话时自动执行的显示图片指令而已【删除】

=end
$m5script ||= {} ;$m5script[:M5MB20131101] = 20131101
module M5MB20131101
#==============================================================================
#  设定部分
#==============================================================================

  NAME = "BattleStart"

  # 在游戏中进行对话时显示的图片，放在 Graphics\System 里

  BLEND = 2

  # 图片的合成方式，0为正常，1为加法，2为减法

  Z = 20

  # 调整图片的Z坐标高度，
  # 如果在你对话中使用了显示图片作为立绘效果而背景遮住了立绘的话，调大这个数值即可

  SWI = 0

  # 如果对应ID的开关状态为打开，在对话开始时不会显示图片
  # （不需要的话，填写0就好了）

#==============================================================================
#  设定结束
#==============================================================================
end
class Window_Message
  alias m5_20131101_initialize initialize
  def initialize
    m5_20131101_initialize
    @m5_20131101_m_back = Sprite.new
    @m5_20131101_m_back.bitmap = Cache.system(M5MB20131101::NAME)
    @m5_20131101_m_back.blend_type = M5MB20131101::BLEND
    @m5_20131101_m_back.opacity = 0
    @m5_20131101_m_back.z = z - 1 - M5MB20131101::Z
    def @m5_20131101_m_back.update_open(openness)
      return self.opacity = 0 if $game_switches[M5MB20131101::SWI]
      self.opacity = openness
    end
  end
  alias m5_20131101_update update
  def update
    m5_20131101_update
    @m5_20131101_m_back.update_open(openness)
  end
  alias m5_20131101_dispose dispose
  def dispose
    m5_20131101_dispose
    @m5_20131101_m_back.dispose
  end
end