=begin
===============================================================================
  自动换行 By喵呜喵5
===============================================================================

  【说明】

  显示文章的自动换行，当字体放大/缩小后可能会出现异常

=end
$m5script ||= {};$m5script[:M5AM20140815] = 20150704
module M5AM20140815
#==============================================================================
#  设定部分
#==============================================================================

  SWI = 0

  # 这里设置一个开关的ID，开关开启则不使用自动换行
  # 不需要的话直接设置成0就好了

  SPA = -4

  # 这里设置自动换行的位置，数字越大，每行显示的文字越少

#==============================================================================
#  设定结束
#==============================================================================
end
class Window_Message
  alias m5_20131105_process_normal_character process_normal_character
  def process_normal_character(c, pos)
    m5_20131105_process_normal_character(c, pos)
    if (pos[:x] + M5AM20140815::SPA + contents.text_size(c).width) >\
      contents.width && !$game_switches[M5AM20140815::SWI]
      @m5_20150704_flag = true
      process_new_line(c, pos)
      @m5_20150704_flag = false
      pos[:height] = calc_line_height(c)
    end
  end
  alias m5_20150704_reset_font_settings reset_font_settings
  def reset_font_settings
    return if @m5_20150704_flag
    m5_20150704_reset_font_settings
  end
end