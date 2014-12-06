=begin
===============================================================================
  对话中切换字体 By喵呜喵5
===============================================================================

【说明】

  对话中使用转义字符

    \font[字体的名字]

  即可切换之后显示的对话的字体

  字体将在对话进入新一页后恢复成默认字体

=end
#==============================================================================
# 脚本部分
#==============================================================================
$m5script ||= {};raise("需要喵呜喵5基础脚本的支持") unless $m5script[:M5Base]
$m5script[:M5CF20140524] = 20140524;M5script.version(20141205)
class Window_Message
  alias m5_20140524_reset_font_settings reset_font_settings
  def reset_font_settings
    m5_20140524_reset_font_settings
    contents.font.name = Font.default_name
  end
  alias m5_20140524_process_escape_character process_escape_character
  def process_escape_character(code, text, pos)
    case code.upcase
    when 'FONT'
      name = m5_obtain_escape_param(text)
      contents.font.name = Font.exist?(name) ? name : Font.default_name
    else
      m5_20140524_process_escape_character(code, text, pos)
    end
  end
end