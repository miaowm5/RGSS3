=begin
===============================================================================
  竖排显示对话 By喵呜喵5
===============================================================================

【说明】

  指定的开关打开的时候，使用竖排的方式显示对话

  竖排显示对话和部分对话脚本兼容性并不好，请将脚本插入到其他对话脚本之上

  只是随手写的脚本，暂时并不会对脚本的功能（以及代码的换行）进行太多的调整

=end
$m5script ||= {};$m5script[:M5VT20140731] = 20140731
module M5VT20140731
#==============================================================================
# 设定部分
#==============================================================================

  LINE = 11

  # 这里修改使用竖排文字时对话框的行数

  SWI = 1

  # 对应编号的开关开启时脚本才生效

  OFFSET = 5

  # 如果你对脚本的自动换列功能不满意（太早换列或者太迟换列），调整这个数字

#==============================================================================
# 设定结束
#==============================================================================
end
class Window_Message
  alias m5_20140731_clear_flags clear_flags
  def clear_flags
    m5_20140731_clear_flags
    @m5_line_width = 0
  end
  alias m5_20140731_visible_line_number visible_line_number
  def visible_line_number
    $game_switches[M5VT20140731::SWI] ? M5VT20140731::LINE : m5_20140731_visible_line_number
  end
  alias m5_20140731_process_normal_character process_normal_character
  def process_normal_character(c, pos)
    m5_update_window_setting if fitting_height(visible_line_number) != self.height
    return m5_20140731_process_normal_character(c, pos) unless $game_switches[M5VT20140731::SWI]
    text_width = text_size(c).width
    text_height = text_size(c).height
    @m5_line_width = [@m5_line_width,text_size(c).width].max
    draw_text(pos[:x], pos[:y], text_width * 2, pos[:height], c)
    if pos[:y] + text_height > contents.height - standard_padding * 2 + M5VT20140731::OFFSET
      pos[:x] += @m5_line_width
      pos[:y] = 0
      @m5_line_width = 0
    else
      pos[:y] += text_height
    end
    wait_for_one_character
  end
  def m5_update_window_setting
    self.height = fitting_height(visible_line_number)
    create_contents
    update_placement
  end
  alias m5_20140731_process_new_line process_new_line
  def process_new_line(text, pos)
    return m5_20140731_process_new_line(text, pos) unless $game_switches[M5VT20140731::SWI]
    pos[:x] += @m5_line_width
    pos[:y] = 0
    @m5_line_width = 0
  end
end
