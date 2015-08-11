=begin
===============================================================================
  【插件】不公开配方的合成脚本 - 界面加入菜单
===============================================================================

  【说明】

  将《不公开配方的合成脚本 By喵呜喵5》中的合成界面加入到菜单中

  不需要这个插件的话，直接把这个脚本删掉就好了

=end
raise "本脚本需要放在合成脚本下方" unless $m5script[:M5Combin20141204]
raise "合成脚本版本过低！" if $m5script[:M5Combin20141204] < 20150706
module M5Combin20141204;module Tool4
#==============================================================================
#  设定部分
#==============================================================================

  COMMAND = "物品合成"

  # 菜单中的指令名称

#==============================================================================
#  设定结束
#==============================================================================
end;end
class Window_MenuCommand
  alias m5_20141205_add_original_commands add_original_commands
  def add_original_commands
    m5_20141205_add_original_commands
    add_command(M5Combin20141204::Tool4::COMMAND, :m5_20141205_combin)
  end
end
class Scene_Menu
  alias m5_20141205_create_command_window create_command_window
  def create_command_window
    m5_20141205_create_command_window
    @command_window.set_handler(:m5_20141205_combin,method(:m5_20141205_combin))
  end
  def m5_20141205_combin
    SceneManager.call(Scene_Combin)
  end
end