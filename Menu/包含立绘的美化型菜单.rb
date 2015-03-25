=begin
===============================================================================
  包含立绘的美化型菜单 By喵呜喵5
===============================================================================

  【说明】

  一个可以显示立绘的游戏菜单，
  如果会脚本的话可以直接动手修改脚本的代码使这个菜单更加适应你的游戏，
  如果不会脚本的话……默认的样式我也挺满意的啦。

  立绘的文件名为队伍中第一名角色的昵称（称号、nickname），
  游戏中昵称改变后显示的立绘也会随之变化，放在“Graphics/m5lihui/”文件夹下。

  这个菜单主要用于解谜游戏，所以我不负责调整针对装备、技能功能的兼容。

=end
$m5script ||= {}; $m5script[:M5Menu20150325] = 20150325
module M5Menu20150325
#==============================================================================
#  设定部分
#==============================================================================

  COMMAND = ["查看物品", "读取存档"]

  # 这里设置在菜单中显示的指令名称
  # 如果不懂脚本的话，不建议增加更多的指令

  SCENE = [Scene_Item, Scene_Load]

  # 这里设置执行每条指令后游戏需要跳转到的场景，与上面的指令名称一一对应
  # 如果不懂脚本的话，不建议修改这里
  # （如果一定要添加某个指令的话，可以尝试这么做：
  #   在对应的脚本中搜索 SceneManager.call ，然后填入这条代码里括号中的文字）

  WIDTH = 272

  # 这里设置指令窗口的宽度

  HEIGHT = 60

  # 这里设置指令窗口的高度

  FONT = 28

  # 这里设置指令字体的大小

  X = 220

  # 这里设置指令窗口的X坐标

  Y = 148

  # 这里设置指令窗口的Y坐标

  Y_OFF = 60

  # 这里设置两条指令之间的距离

  SWI = 1

  # 这里设置一个开关的ID，当这个开关打开的时候显示正常的菜单

#==============================================================================
#  设定结束
#==============================================================================
class Window_M5MenuCommand < Window_Base
  def initialize(index)
    super(X, Y, WIDTH, HEIGHT)
    self.y += (Y_OFF + HEIGHT) * index
    self.arrows_visible = false
    contents.font.size = FONT
    draw_text(0, 0, contents.width, contents.height , COMMAND[index], 1)
    @selected = false
  end
  def selected=(selected)
    @selected = selected
    update_cursor
  end
  def update_cursor
    if @selected
      cursor_rect.set(0, 0, contents.width, contents.height)
    else
      cursor_rect.empty
    end
  end
end
class Scene_M5Menu < Scene_MenuBase
  def start
    super
    create_lihui
    create_command_windows
    @index ||= 0
    update_cursor
  end
  def create_lihui
    @lihui_sprite = Sprite.new
    @lihui_sprite.bitmap = Bitmap.new(
      "Graphics/m5lihui/#{$game_party.members[0].nickname}") rescue nil
  end
  def create_command_windows
    @command_windows = Array.new(item_max) do |i|
      Window_M5MenuCommand.new(i)
    end
  end
  def update
    super
    @command_windows.each(&:update)
    update_selection
  end
  def update_selection
    last_index = @index
    ( @index += 1 ) if Input.repeat?(:DOWN)
    ( @index -= 1 ) if Input.repeat?(:UP)
    @index %= item_max
    if @index != last_index
      Sound.play_cursor
      update_cursor
    end
    return on_command_ok     if Input.trigger?(:C)
    return on_command_cancel if Input.trigger?(:B)
  end
  def update_cursor
    @command_windows.each {|window| window.selected = false }
    @command_windows[@index].selected = true
  end
  def on_command_ok
    SceneManager.call( SCENE[@index] )
    Input.update
  end
  def on_command_cancel
    Sound.play_cancel
    return_scene
  end
  def item_max
    COMMAND.size
  end
  def terminate
    super
    @lihui_sprite.bitmap.dispose if @lihui_sprite.bitmap
    @lihui_sprite.dispose
    @command_windows.each(&:dispose)
  end
end
end # M5Menu20150325
class Game_Interpreter
  alias m5_20140220_command_351 command_351
  def command_351
    return m5_20140220_command_351 if $game_switches[M5Menu20150325::SWI]
    return if $game_party.in_battle
    SceneManager.call(M5Menu20150325::Scene_M5Menu)
    Fiber.yield
  end
end
class Scene_Map
  alias m5_20140220_call_menu call_menu
  def call_menu
    return m5_20140220_call_menu if $game_switches[M5Menu20150325::SWI]
    Sound.play_ok
    SceneManager.call(M5Menu20150325::Scene_M5Menu)
  end
end