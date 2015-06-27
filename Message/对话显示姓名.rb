=begin
===============================================================================
  对话显示姓名 By喵呜喵5
===============================================================================

【说明】

  通过在对话开头加入

    \name[姓名]

  可以在对话中显示姓名

  （ \name[姓名] 的后面不需要换行，另外，请注意对话框高度太小时系统会强制翻页）

=end
$m5script ||= {};$m5script[:M5Name20141004] = 20150627
module M5Name20141004
#==============================================================================
#  设定部分
#==============================================================================

  FONT = ["黑体"]

  # 姓名所使用的字体

  SIZE = 18

  # 姓名字体的大小

  VOCAB = "【%s】："

  # 姓名的显示方式，%s 表示姓名的文字，
  # 例如，默认的设置下，“\name[埃里克]”将在游戏中显示为“【埃里克】：”
  # 不需要的话，直接填写一个 %s 就好

  COLOR = Color.new(0,0,0,255)

  # 姓名的颜色，四个数值分别是R、G、B以及透明度

  SET = [false,false,false,true]

  # 中括号中以逗号分隔开的单词分别设置姓名是否加粗、斜体、有阴影、加边框
  # 需要的话填写true，不需要的话填写false

  OUT_COLOR = Color.new(255, 255, 255, 0)

  # 姓名边框的颜色，四个数值分别是R、G、B以及透明度

  ALIGN =  0

  # 姓名的对齐方式，0，1，2分别是居左、居中、居右

  NAME_X = 0

  # 姓名的X坐标，数值越大姓名位置越靠近屏幕右侧

  NAME_Y = 3

  # 姓名的Y坐标，数值越大姓名位置越靠近屏幕底部

  DISTANCE = 10

  # 对话与姓名的间距，数字越大间距越大

  BACK_Y = 0

  # 姓名背景的Y坐标，数值越大姓名位置越靠近屏幕底部

  BACK_HEIGHT = 6

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
    @m5_name_20150304 = nil
    result = m5_20141004_convert_escape_characters *arg
    result.gsub!(/\eNAME\[(.+?)\]/i) { @m5_name_20150304 = $1; "" }
    result
  end
  alias m5_20141004_draw_face draw_face
  def draw_face *arg
    if @m5_name_20150304
      set = M5Name20141004

      temp = Bitmap.new(self.width, self.height)
      temp.font.name = set::FONT
      temp.font.size = set::SIZE
      temp.font.color = set::COLOR
      temp.font.out_color = set::OUT_COLOR
      temp.font.bold = set::SET[0]
      temp.font.italic = set::SET[1]
      temp.font.shadow = set::SET[2]
      temp.font.outline = set::SET[3]

      @m5_name_20150304 = sprintf(set::VOCAB, @m5_name_20150304)
      name_height = temp.text_size(@m5_name_20150304).height
      temp.draw_text(0, 0, temp.width - new_line_x, name_height,
        @m5_name_20150304, set::ALIGN)
      contents.gradient_fill_rect(0, set::BACK_Y,
        self.width, name_height + set::BACK_HEIGHT, set::COLOR1, set::COLOR2)
      contents.blt(new_line_x + set::NAME_X, set::NAME_Y, temp, temp.rect)

      temp.dispose
      @m5_name_20150304 = name_height
    end
    m5_20141004_draw_face *arg
  end
  alias m5_20141004_new_page new_page
  def new_page(text, pos)
    m5_20141004_new_page(text, pos)
    if @m5_name_20150304
      pos[:y] += @m5_name_20150304 + M5Name20141004::DISTANCE
      @m5_name_20150304 = nil
    end
  end
end