=begin
===============================================================================
  读档后执行公共事件 By 喵呜喵5
===============================================================================

【说明】

  成功读取存档后执行指定的公共事件（例如，删除某个进入赌场的道具以防止玩家不停S/L）

  并不是所有的公共事件指令都支持，例如等待、显示文字等指令将被忽略

  增减物品、修改开关、变量、显示图片这样简单的指令还是能用的

=end
$m5script ||= {}; $m5script[:M5LE20150720] = 20150720
module M5LE20150720
#==============================================================================
#  设定部分
#==============================================================================

  ID = 1

  # 读档成功后要执行的公共事件ID


#==============================================================================
#  设定结束
#==============================================================================
class Interpreter < Game_Interpreter
  [101,102,402,403,103,104,105,203,204,205,213,214,221,222].each do |c|
    undef_method "command_#{c}".to_sym
  end
end
end
class Game_System
  alias m5_20150720_on_after_load on_after_load
  def on_after_load
    m5_20150720_on_after_load
    interpreter = M5LE20150720::Interpreter.new
    interpreter.setup $data_common_events[M5LE20150720::ID].list
    while interpreter.running? do
      interpreter.update
      $game_player.perform_transfer if $game_player.transfer?
    end
  end
end