=begin
===============================================================================
  横向移动 By喵呜喵5
===============================================================================

【说明】

  人物的朝向始终向右或者向左
  
  这个脚本并不影响事件指令中的设置人物朝向功能
  
  另外，由于人物始终朝着左右方向，所以无法在事件的下方或者上方通过确定键触发事件
  
=end
$m5script ||= {};$m5script[:M5FD20140914] = 20140914
$m5script[:ScriptData] ||= {}
module M5FD20140914
#==============================================================================
# 设定部分
#==============================================================================

  
  SWI = 1
  
  # 对应ID的开关开启时关闭横向移动
  

#==============================================================================
#  脚本部分
#==============================================================================
end
class Game_CharacterBase
  alias m5_20140914_set_direction set_direction
  def set_direction(d)
    if $m5script[:ScriptData][:M5FD20140914] && 
        !$game_switches[M5FD20140914::SWI]
      d = 6 if @direction == 8 || @direction == 2
      return if d == 8 || d == 2
    end
    m5_20140914_set_direction(d)
  end
  alias m5_20140914_move_straight move_straight
  def move_straight(d, turn_ok = true)
    $m5script[:ScriptData][:M5FD20140914] = true
    m5_20140914_move_straight(d, turn_ok)
    $m5script[:ScriptData][:M5FD20140914] = false
  end
end
