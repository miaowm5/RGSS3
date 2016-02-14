=begin
===============================================================================
  防止错按选项 By喵呜喵5
===============================================================================

【说明】

  事件指令的显示选项功能必须按下方向键后才能进行选择

  防止手贱党按键太快结果误选了列表中的第一个选项

=end
$m5script ||= {}; $m5script[:M5NC20140915] = 20160214
class Window_ChoiceList
  alias m5_20140915_start start
  def start
    m5_20140915_start
    unselect
  end
  alias m5_20160214_cursor_up cursor_up
  def cursor_up(wrap = false)
    @index < 0 && @index = 1
    m5_20160214_cursor_up(wrap)
  end
end