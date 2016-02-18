=begin
===============================================================================
  对话显示图片 By喵呜喵5
===============================================================================

【说明】

  在对话中使用转义字符：\img[图片的名字] 即可在对话中显示指定的图片

  要显示的图片素材放在 Graphics\M5Img 目录下

=end
$m5script ||= {};raise("需要喵呜喵5基础脚本的支持") unless $m5script[:M5Base]
$m5script[:M5MI20150202] = 20150202;M5script.version(20150129)
class Window_Base
  def m5_20150202_draw_image(file, pos)
    bitmap = Bitmap.new("Graphics/M5Img/#{file}")    
    rect = Rect.new(0,0,bitmap.width,bitmap.height)
    contents.blt(pos[:x], pos[:y], bitmap, rect)
    pos[:x] += rect.width
    pos[:height] = [pos[:height],rect.height].max
    bitmap.dispose
  end  
  alias m5_20150202_process_escape_character process_escape_character
  def process_escape_character(code, text, pos)    
    if code.upcase == 'IMG'
      m5_20150202_draw_image(m5_obtain_escape_param(text), pos)
    else
      m5_20150202_process_escape_character(code, text, pos)
    end
  end
end
