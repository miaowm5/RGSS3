=begin
===============================================================================
  对话显示姓名 By喵呜喵5
===============================================================================

【说明】

  通过在对话开头加入

    \name[姓名]

  可以在对话中显示姓名（请注意对话框高度太小时系统会强制翻页）

=end
$m5script ||= {};$m5script[:M5Name20141004] = 20220425
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

  STYLE = {
    COLOR: Color.new(0,0,0,255),      # 姓名的文本颜色(RGB)
    BOLD: false,                      # 姓名是否加粗(true/false)
    ITALIC: false,                    # 姓名是否斜体(true/false)
    SHADOW: false,                    # 姓名是否有阴影(true/false)
    BORDER: true,                     # 姓名是否有边框(true/false)
    OUT: Color.new(255, 255, 255, 0), # 姓名的边框颜色(RGB)
    ALIGN: 0,                         # 姓名的对齐方式(0:左对齐 1:居中 2:右对齐)
  }

  POS = {
    X: 0,         # 姓名的 X 坐标，数值越大姓名位置越靠近屏幕右侧
    Y: 3,         # 姓名的 Y 坐标，数值越大姓名位置越靠近屏幕底部
    DISTANCE: 10, # 姓名与对话正文的间距
  }

  BACK = {
    SHOW: true,                            # 是否显示姓名的背景(true/false)
    Y: 0,                                  # 姓名背景的Y坐标
    WIDTH: -1,                             # 姓名背景的宽度，负数表示使用对话框宽度
    HEIGHT: 6,                             # 姓名背景的高度
    COLOR1: Color.new(255, 255, 255, 200), # 姓名背景左侧颜色(RGB)
    COLOR2: Color.new(255, 255, 255, 0),   # 姓名背景右侧颜色1(RGB)
  }

  IGNORE_N = true # 是否自动忽略 \name[姓名] 后的换行符(true/false)

  FACE = [
    ["Actor4", 0, "艾里克"], # Actor4 索引 0 的头像说话时，姓名自动显示为艾里克
    ["Actor4", 1, "娜塔丽"], # Actor4 索引 1 的头像说话时，姓名自动显示为娜塔丽
  ]
  # 自动根据对话配置的脸图显示角色名，配置格式为：
  # ["脸图文件名", 脸图索引（从 0 开始）, "对应的角色名"],
  # 在对话中使用 \name[姓名] 可以覆盖上述自动规则

#==============================================================================
#  设定结束
#==============================================================================
  def self.draw(contents, name, x)
    return nil if !name || name == ''
    bitmap = Bitmap.new(contents.width, contents.height)
    bitmap.font = Font.new(FONT, SIZE).tap do |f|
      f.color = STYLE[:COLOR]
      f.out_color = STYLE[:OUT]
      f.bold = STYLE[:BOLD]
      f.italic = STYLE[:ITALIC]
      f.shadow = STYLE[:SHADOW]
      f.outline = STYLE[:BORDER]
    end
    text = sprintf(VOCAB, name)
    name_height = bitmap.text_size(text).height
    if BACK[:SHOW]
      back_width = BACK[:WIDTH] > 0 ? BACK[:WIDTH] : bitmap.width
      bitmap.gradient_fill_rect(0, BACK[:Y], back_width,
        name_height + BACK[:HEIGHT], BACK[:COLOR1], BACK[:COLOR2])
    end
    bitmap.draw_text(x + POS[:X], POS[:Y], bitmap.width - x, name_height,
      text, STYLE[:ALIGN])
    contents.blt(0, 0, bitmap, bitmap.rect)
    bitmap.dispose
    name_height + POS[:DISTANCE]
  end
end
class Window_Message
  alias m5_20141004_convert_escape_characters convert_escape_characters
  def convert_escape_characters *arg
    @m5_name_20150304 = nil
    result = m5_20141004_convert_escape_characters *arg
    if M5Name20141004::IGNORE_N
      result.gsub!(/\eNAME\[(.*?)\]\n/i) { @m5_name_20150304 = $1; "" }
    end
    result.gsub!(/\eNAME\[(.*?)\]/i) { @m5_name_20150304 = $1; "" }
    result
  end
  alias m5_20141004_draw_face draw_face
  def draw_face *arg
    set = M5Name20141004
    if @m5_name_20150304 == nil
      face = set::FACE.find{|f| f[0] == arg[0] && f[1] == arg[1] }
      @m5_name_20150304 = face[2] if face
    end
    @m5_name_20150304 = set.draw(contents, @m5_name_20150304, new_line_x)
    m5_20141004_draw_face *arg
  end
  alias m5_20141004_new_page new_page
  def new_page(text, pos)
    m5_20141004_new_page(text, pos)
    return unless @m5_name_20150304
    pos[:y] += @m5_name_20150304
    @m5_name_20150304 = nil
  end
end
