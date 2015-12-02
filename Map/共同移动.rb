=begin
===============================================================================
  共同移动 By喵呜喵5
===============================================================================

【说明】

  在事件中的脚本编辑器里输入

    M5MT20151126.add(1,2,3)

  1,2,3 为地图事件的ID，用英文逗号隔开，数量不限

  接着按方向键时1、2、3号事件就会跟着玩家的操作一起移动

  输入

    M5MT20151126.remove(1,2)

  可以移除上面设置的1、2号事件，仅有3号事件跟着玩家的操作一起移动

  输入

    M5MT20151126.clear

  可以清除全部共同移动的事件

  0号事件表示玩家本身

  被设置为共同移动的事件将在切换地图后失效
  （若游戏发生了更新，此时读取存档时共同移动的事件也会失效）

=end
#==============================================================================
# 脚本部分
#==============================================================================
$m5script ||= {}; $m5script[:M5MT20151126] = 20151202
class << (M5MT20151126 = Module.new)
  def init
    @list = [0]
    $game_player.m5_20151126_move_together = true
  end
  def add(*list)
    (list -= @list).each do |i|
      (event = i == 0 ? $game_player : $game_map.events[i]) || next
      event.m5_20151126_move_together = true
      @list << i
    end
  end
  def remove(*list)
    (list &= @list).each do |i|
      (event = i == 0 ? $game_player : $game_map.events[i]) || next
      event.m5_20151126_move_together = false
    end
    @list -= list
  end
  def clear
    remove *@list
    init
  end
end
class Game_Map
  alias m5_20151126_setup setup
  def setup *args
    m5_20151126_setup *args
    M5MT20151126.init
  end
end
class Game_Character; attr_writer :m5_20151126_move_together; end
class Game_Player
  alias m5_20151126_movable? movable?
  def movable?
    m5_20151126_movable? && @m5_20151126_move_together
  end
end
class Game_Event
  def m5_20151126_movable?
    return false unless @m5_20151126_move_together
    return false if moving?
    return false if $game_message.busy? || $game_message.visible
    return false if $game_map.interpreter.running?
    true
  end
  def m5_20151126_move_by_input
    return unless m5_20151126_movable?
    move_straight(Input.dir4) if Input.dir4 > 0
  end
  alias m5_20151202_update update
  def update
    m5_20151202_update
    m5_20151126_move_by_input
  end
end