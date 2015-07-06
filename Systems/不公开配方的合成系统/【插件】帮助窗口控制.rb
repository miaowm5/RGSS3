=begin
===============================================================================
  【插件】不公开配方的合成脚本 - 帮助窗口控制
===============================================================================

  【说明】

  可以控制《不公开配方的合成脚本 By喵呜喵5》中的帮助窗口

  不需要这个插件的话，直接把这个脚本删掉就好了

=end
module M5Combin20141204;module Tool2
#==============================================================================
#  设定部分
#==============================================================================

  SKIN = ""

  # 帮助窗口的皮肤，留空的话则使用默认皮肤

  HIDE = true

  # 是否隐藏帮助窗口背景，只显示内容（true：是，false：否）

  X = 69

  # 帮助窗口X坐标

  Y = 319

  # 帮助窗口Y坐标

  WIDTH = 405

  # 帮助窗口宽度

  HEIGHT = 78

  # 帮助窗口高度

  FONT = 20

  # 帮助窗口字体的大小

#==============================================================================
#  设定结束
#==============================================================================
end
class Window_Help
  alias m5_20141205_initialize initialize
  def initialize(*args)
    m5_20141205_initialize(*args)
    if Tool2::SKIN && Tool2::SKIN != ""
      self.windowskin = Cache.system(Tool2::SKIN)
    end
    self.opacity = 0 if Tool2::HIDE
    self.x, self.y = Tool2::X, Tool2::Y
    self.width, self.height = Tool2::WIDTH, Tool2::HEIGHT
    create_contents
    contents.font.size = Tool2::FONT
  end
end
end