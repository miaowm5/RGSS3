=begin
===============================================================================
  对话显示姓名 By喵呜喵5
===============================================================================

【说明】

  通过在对话开头加入

    \name[姓名]

  可以在对话中显示姓名

=end
$m5script ||= {};raise("需要喵呜喵5基础脚本的支持") unless $m5script[:M5Base]
$m5script[:M5Name20141004] = 20141208;M5script.version(20141208)
module M5Name20141004
#==============================================================================
#  设定部分
#==============================================================================

  FONT = "黑体"

  # 姓名所使用的字体

  SIZE = 20

  # 姓名字体的大小

  COLOR = Color.new(0,0,0,255)

  # 姓名的颜色，四个数值分别是R、G、B以及透明度

  SET = [false,false,false,true]

  # 中括号中以逗号分隔开的单词分别设置姓名是否加粗、斜体、有阴影、加边框
  # 需要的话填写true，不需要的话填写false

  OUT_COLOR = Color.new(255, 255, 255, 0)

  # 姓名边框的颜色，四个数值分别是R、G、B以及透明度

  ALIGN =  0

  # 姓名的对齐方式，0，1，2分别是居左、居中、居右

  NAME_X = - 10

  # 姓名的X坐标，数值越大姓名位置越靠近屏幕右侧

  NAME_Y = 2

  # 姓名的Y坐标，数值越大姓名位置越靠近屏幕底部

  DISTANCE = 10

  # 对话与姓名的间距，数字越大间距越大

  BACK_Y = 0

  # 姓名背景的Y坐标，数值越大姓名位置越靠近屏幕底部

  BACK_HEIGHT = 5

  # 姓名背景的高度，数字越大高度越大

  COLOR1 = Color.new(255, 255, 255, 200)

  # 姓名的背景框左边的颜色，四个数值分别是R、G、B以及透明度

  COLOR2 = Color.new(255, 255, 255, 0)

  # 姓名的背景框右边的颜色，四个数值分别是R、G、B以及透明度
  # 不需要背景的话，两个颜色的透明度都填0就好了

#==============================================================================
#  设定结束
#==============================================================================
end
class Window_Message
  alias m5_20141004_convert_escape_characters convert_escape_characters
  def convert_escape_characters *arg
    @m5_name = nil
    result = m5_20141004_convert_escape_characters *arg
    result.gsub!(/\eNAME\[(.+)\]/i) { @m5_name = $1; "" }
    result
  end
  alias m5_20141004_draw_face draw_face
  def draw_face *arg
    if @m5_name
      temp_font = contents.font.m5_return_all_setting      
      contents.font.name = M5Name20141004::FONT
      contents.font.size = M5Name20141004::SIZE
      contents.font.color = M5Name20141004::COLOR
      contents.font.out_color = M5Name20141004::OUT_COLOR
      contents.font.bold = M5Name20141004::SET[0]
      contents.font.italic = M5Name20141004::SET[1]
      contents.font.shadow = M5Name20141004::SET[2]
      contents.font.outline = M5Name20141004::SET[3]
      name_height = text_size(@m5_name).height
      m5_20141004_draw_back(name_height)
      draw_text([new_line_x + M5Name20141004::NAME_X,0].max,
        M5Name20141004::NAME_Y,self.width - new_line_x,
        name_height +[M5Name20141004::NAME_Y,0].max,@m5_name,
        M5Name20141004::ALIGN)      
      contents.font.m5_set_all_setting(temp_font)      
      @m5_name = name_height
    end
    m5_20141004_draw_face *arg
  end
  def m5_20141004_draw_back(height)
    rect = Rect.new(0, M5Name20141004::BACK_Y, self.width,
      height + M5Name20141004::BACK_HEIGHT)
    contents.gradient_fill_rect(rect,
      M5Name20141004::COLOR1, M5Name20141004::COLOR2)
  end
  alias m5_20141004_new_page new_page
  def new_page(text, pos)
    m5_20141004_new_page(text, pos)
    if @m5_name
      pos[:y] += @m5_name + M5Name20141004::DISTANCE
    end
  end
end
