=begin
===============================================================================
  菜单中的系统指令合并 By喵呜喵5
===============================================================================

  【说明】

  将存档、读档、结束游戏这三个指令合并到了同一个界面

=end
$m5script ||= {}; $m5script[:M5Menu20140222] = 20150628
module M5Menu20140222
#==============================================================================
#  设定部分
#==============================================================================

  VOCAB1 = "系统"

  # 菜单中进入该界面的指令名称

  VOCAB2 = "读取记录"

  # 该界面中读取存档指令的名称

  SAVE = true

  # 该界面是否显示存档指令 ( true：显示 / false：不显示 )

  LOAD = true

  # 该界面是否显示读档指令 ( true：显示 / false：不显示 )

#==============================================================================
#  设定结束
#==============================================================================
end
class Window_MenuCommand
  def add_save_command; end
  alias m5_20140617_add_game_end_command add_game_end_command
  def add_game_end_command
    add_command(M5Menu20140222::VOCAB1, :game_end)
  end
end
class Window_GameEnd
  alias m5_20140222_make_command_list make_command_list
  def make_command_list
    add_command(Vocab::save,
      :m5_20150628_save, !$game_system.save_disabled) if M5Menu20140222::SAVE
    add_command(M5Menu20140222::VOCAB2,
      :m5_20150628_load) if M5Menu20140222::LOAD
    m5_20140222_make_command_list
  end
end
class Scene_End
  alias m5_20140222_create_command_window create_command_window
  def create_command_window
    m5_20140222_create_command_window
    @command_window.set_handler(:m5_20150628_save,
      Proc.new { SceneManager.call Scene_Save })
    @command_window.set_handler(:m5_20150628_load,
      Proc.new { SceneManager.call Scene_Load })
  end
end