=begin
===============================================================================
  空存档提示 By喵呜喵5
===============================================================================

【说明】

  存档为空时显示提示文字

=end
$m5script ||= {}; $m5script[:M5EH20160925] = 20160925
module M5EH20160925
#==============================================================================
#  设定部分
#==============================================================================

  WORD = '\i[4]这个存档没有记录内容！'
  #单引号中间设置提示的文字，支持符号、姓名等转义字符

  X_OFF = 140
  #提示文字的X坐标

  Y_OFF = 20
  #提示文字的Y坐标

  FONT = ["黑体"]
  #提示文字所使用的字体

  SIZE = 20
  #提示文字字体的大小

  COLOR = Color.new(255, 255, 255, 210)
  #提示文字的颜色，四个数值分别是R、G、B以及透明度

  BOLD = false
  #提示文字是否加粗

  ITALIC = false
  #提示文字是否斜体

  SHADOW = false
  #提示文字是否有阴影

  OUT = true
  #提示文字是否加边框

  OUT_COLOR = Color.new(255, 255, 255, 100)
  #提示文字边框的颜色，四个数值分别是R、G、B以及透明度

#==============================================================================
#  设定结束
#==============================================================================
  class Content < ::Window_Base
    def initialize(window)
      super(0, 0, window.width, window.height)
      draw_text_ex(X_OFF, Y_OFF, WORD)
      window.contents.blt(0,0, self.contents, Rect.new(0,0,width,height))
      dispose
    end
    def reset_font_settings
      contents.font.name = FONT
      contents.font.size = SIZE
      contents.font.bold = BOLD
      contents.font.italic = ITALIC
      contents.font.outline = OUT
      contents.font.shadow = SHADOW
      contents.font.color = COLOR
      contents.font.out_color = OUT_COLOR
    end
  end
end
class Window_SaveFile
  alias m5_20160925_refresh refresh
  def refresh
    m5_20160925_refresh
    return if DataManager.load_header(@file_index)
    M5EH20160925::Content.new(self)
  end
end
