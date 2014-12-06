=begin
===============================================================================
  自动换行 By喵呜喵5
===============================================================================

  【说明】

  显示文章的自动换行

=end
$m5script ||= {};raise("需要喵呜喵5基础脚本的支持") unless $m5script[:M5Base]
$m5script[:M5AM20140815] = 20140815;M5script.version(20140815)
module M5AM20140815
#==============================================================================
#  设定部分
#==============================================================================

  SWI = 0

  # 这里设置一个开关的ID，开关开启则不使用自动换行
  # 不需要的话直接设置成0就好了

  SPA = -4

  # 这里设置自动换行的位置，数字越大，每行显示的文字越少

  TYPE = 1

  # 设置为 0 时脚本将切换到最大兼容模式，
  # 最大兼容模式下，放大/缩小文字可能出现问题，下方的两个设置将失效
  # 但是最大兼容模式下脚本能与更多的文字类脚本相兼容

  IGNOR = [",",".","，","。"]

  # 这里设置不需要自动换行的符号，当文章处于这个符号位置时不自动换行
  # 每个符号需要用英文双引号括起来，后面记得加上英文逗号

  HYPHEN = false

  # 设置为true时，英文单词在自动换行时会添加连字符

#==============================================================================
#  设定结束
#==============================================================================
end
#--------------------------------------------------------------------------
# ● Game_Message
#--------------------------------------------------------------------------
class Game_Message;attr_accessor   :texts;end
#--------------------------------------------------------------------------
# ● 用于自动换行的窗口
#--------------------------------------------------------------------------
class Window_M5_20140814_Message < Window_Base
  include M5AM20140815
  def initialize
    super(0, 0, 0, 0)
    self.visible = false
  end
  def draw_text(*args);end
  def new_line_x;@new_line_x;end
  #--------------------------------------------------------------------------
  # ● 调用部分
  #--------------------------------------------------------------------------
  def start(width,font,new_line_x)
    return if $game_switches[SWI]
    @width = width + SPA
    @new_line_x = new_line_x
    contents.font.m5_set_all_setting(font)
    clear_flag
    convert_text
  end
  #--------------------------------------------------------------------------
  # ● 清除标志
  #--------------------------------------------------------------------------
  def clear_flag
    @string = ""
    @text = []
    @hyphen = false
  end
  #--------------------------------------------------------------------------
  # ● 处理文字并返回结果
  #--------------------------------------------------------------------------
  def convert_text
    process_all_text
    @text.push @string if @string
    $game_message.texts = @text
  end
  def process_all_text
    text = convert_escape_characters($game_message.all_text)
    pos = {}
    new_page(text, pos)
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end
  def new_page(text, pos)
    pos[:x] = new_line_x
    pos[:y] = 0
    pos[:new_x] = new_line_x
    pos[:height] = calc_line_height(text)
  end
  #--------------------------------------------------------------------------
  # ● 控制符文字的处理
  #--------------------------------------------------------------------------
  def obtain_escape_param(text)
    result = super
    @string += "[#{result}]"
    result
  end
  def m5_obtain_escape_param(text)
    result = super
    @string += "[#{result}]"
    result
  end
  alias m5_20140815_process_escape_character process_escape_character
  def process_escape_character(code, text, pos)
    @string += '\\'
    @string += code
    more_escape_character(code, text, pos)
  end
  #--------------------------------------------------------------------------
  # ● 控制符文字的处理（兼容用）
  #--------------------------------------------------------------------------
  def more_escape_character(code, text, pos)
    case code.upcase
    when 'MOOD'
      return unless $m5script["M5FaceMood"]
      m5_obtain_escape_param(text)
    when 'NAME'
      m5_obtain_escape_param(text)
    when 'W','NW'
      return unless $m5script["M5MessageTime"]
      obtain_escape_param(text)
    when 'FONT'
      return unless $m5script["M5ChaFont"]
      name = m5_obtain_escape_param(text)
      contents.font.name = Font.exist?(name) ? name : Font.default_name
    else
      m5_20140815_process_escape_character(code, text, pos)
    end
  end
  #--------------------------------------------------------------------------
  # ● 普通文字的处理
  #--------------------------------------------------------------------------
  def process_normal_character(c, pos)
    if (pos[:x] + (text_size(c).width) > @width) && !IGNOR.include?(c)
      @hyphen = (/[a-zA-Z]/ =~ @string.slice(-1,1)) && HYPHEN
      process_new_line(c, pos)
    end
    @string += c
    super
  end
  #--------------------------------------------------------------------------
  # ● 自动换行
  #--------------------------------------------------------------------------
  def process_new_line(text, pos)
    super
    @string += "-" if (/[a-zA-Z]/ =~ text.slice(0,1)) && @hyphen
    @text.push @string
    @string = text.empty? ? nil : (@hyphen ? "-" : "")
    @hyphen = false
  end
end
if M5AM20140815::TYPE == 1
#--------------------------------------------------------------------------
# ● 自动换行处理
#--------------------------------------------------------------------------
class Window_Message
  alias m5_20140807_initialize initialize
  def initialize
    m5_20140807_initialize
    @m5_20140807_cal = Window_M5_20140814_Message.new
  end
  alias m5_20140807_dispose dispose
  def dispose
    m5_20140807_dispose
    @m5_20140807_cal.dispose
  end
  alias m5_20140807_process_all_text process_all_text
  def process_all_text
    reset_font_settings
    @m5_20140807_cal.start(contents.width,
      contents.font.m5_return_all_setting,new_line_x)
    m5_20140807_process_all_text
  end
  #--------------------------------------------------------------------------
  # ● 自动换行保留字体设置
  #--------------------------------------------------------------------------
  alias m5_20140815_need_new_page? need_new_page?
  def need_new_page?(text, pos)
    if m5_20140815_need_new_page?(text, pos)
      @m5_20140815_set = contents.font.m5_return_all_setting
      return true
    end
    false
  end
  alias m5_20140815_new_page new_page
  def new_page(text, pos)
    m5_20140815_new_page(text, pos)
    if @m5_20140815_set
      contents.font.m5_set_all_setting(@m5_20140815_set)
      pos[:height] = calc_line_height(text)
      @m5_20140815_set = nil
    end
  end
end
else # if M5AM20140815::TYPE == 1
#--------------------------------------------------------------------------
# ● 自动换行处理（最大兼容模式）
#--------------------------------------------------------------------------
class Window_Message
  alias m5_20131105_process_normal_character process_normal_character
  def process_normal_character(c, pos)
    m5_20131105_process_normal_character(c, pos)
    if (pos[:x] + M5AM20140815::SPA + contents.text_size(c).width) >\
      contents.width && !$game_switches[M5AM20140815::SWI]
      font = contents.font.m5_return_all_setting
      process_new_line(c, pos)
      contents.font.m5_set_all_setting(font)
      pos[:height] = calc_line_height(c)
    end
  end
end
end # if M5AM20140815::TYPE == 1
