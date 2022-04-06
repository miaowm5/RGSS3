=begin
===============================================================================
  防止错按选项 By喵呜喵5
===============================================================================

【说明】

  事件指令的显示选项功能必须按下方向键后才能进行选择

  防止手贱党按键太快结果误选了列表中的第一个选项

=end
$m5script ||= {}; $m5script[:M5NC20140915] = 20220407
module M5NC20140915
#==============================================================================
#  设定部分
#==============================================================================

  SWI = 0

  # 当对应ID的开关打开时，不使用本脚本的功能

#==============================================================================
#  设定结束
#==============================================================================
end
class Window_ChoiceList
  alias m5_20140915_start start
  def start
    m5_20140915_start
    switch = M5NC20140915::SWI
    return if switch != 0 && $game_switches[switch]
    unselect
  end
  alias m5_20160214_cursor_up cursor_up
  def cursor_up(wrap = false)
    @index < 0 && @index = 1
    m5_20160214_cursor_up(wrap)
  end
end
