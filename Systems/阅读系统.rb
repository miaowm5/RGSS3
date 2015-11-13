=begin
===============================================================================
  阅读系统 By喵呜喵5
===============================================================================

【说明】

  将游戏中滚动文字的显示方式换成了可以上下移动的对话框窗口

  上下键用于滚动文字，左右键用于加速滚动文字，取消键可以回到开头部分，
  确定键同样可以用来加速滚动文字，当翻到页底时关闭窗口

  描绘文字需要耗费一定的时间，请尽量避免显示太多的文字

=end
$m5script ||= {};$m5script[:M5Read20140811] = 20151113
module M5Read20140811
#==============================================================================
#  设定部分
#==============================================================================

  WIDTH = 60

  # 设置窗口的宽度，数字越大窗口越小

  HEIGHT = 60

  # 设置窗口的高度，数字越大窗口越小

  SPEED1 = 10

  # 设置文字一次翻页的移动量，数字越大翻页时文字移动越多

  SPEED2 = 6

  # 设置文字加速翻页的移动量，数字越大加速翻页时文字移动越多

  SCROLL_TIME = 3

  # 设置文字翻页效果的持续时间，数字越小翻页速度越快

  SPACE = 9

  # 设置在文字开头和结尾部分的留空大小，数字越大留空越多

  EFFECT = 1

  # 设置窗口的打开/关闭效果
  # 0 表示展开效果，1 表示淡化效果

    COME = 15

    # 设置窗口的打开、关闭效果速度，值越大速度越快

  BACK = true

  # 设置窗口背景是否透明，为 false 时窗口背景透明
  # 背景透明时可以用显示图片指令来显示图片作为窗口的背景

  SWI = 1

  # 对应ID的开关打开时，恢复原本的滚动文字

#==============================================================================
#  设定结束
#==============================================================================

class Window < Window_Base
  def initialize
    super(WIDTH/2, HEIGHT/3, Graphics.width - WIDTH, Graphics.height - HEIGHT)
    self.opacity = 0 unless BACK
    case EFFECT
    when 0 then self.openness = 0
    else
      self.opacity = 0
      self.contents_opacity = 0
    end
    @scroll_data = nil
  end
  def update
    super
    return if effecting
    update_scroll
    if $game_message.scroll_mode
      start_message if !@text && $game_message.has_text?
      update_input
    end
  end
  def need_scroll
    contents.height + SPACE * 2 > self.height - standard_padding * 2
  end
  def reach_bottom
    return true unless need_scroll
    self.oy >= contents.height - self.height + standard_padding * 2 + SPACE
  end
  def reach_top
    return true unless need_scroll
    self.oy <= - SPACE
  end
  #--------------------------------------------------------------------------
  # ● 更新玩家的按键操作
  #--------------------------------------------------------------------------
  def update_input
    update_direction
    update_ok if Input.trigger?(:C)
    update_cancel if Input.trigger?(:B)
  end
  def update_direction
    set_scroll(-SPEED1) if Input.press?(:UP)
    set_scroll(SPEED1) if Input.press?(:DOWN)
    set_scroll(-SPEED1 * SPEED2) if Input.press?(:LEFT)
    set_scroll(SPEED1 * SPEED2) if Input.press?(:RIGHT)
  end
  def update_ok
    if reach_bottom then terminate_message
    else set_scroll(SPEED1 * SPEED2 * 2)
    end
  end
  def update_cancel
    set_scroll(-self.oy - SPACE)
  end
  #--------------------------------------------------------------------------
  # ● 文字滚动效果的处理
  #--------------------------------------------------------------------------
  def set_scroll(amount)
    return unless need_scroll
    @scroll_data = {}
    @scroll_data[:speed] = (amount.to_f / SCROLL_TIME).to_i
    @scroll_data[:target] = self.oy + @scroll_data[:speed] * SCROLL_TIME
  end
  def update_scroll
    return unless @scroll_data
    if self.oy == @scroll_data[:target]       ||
      (@scroll_data[:speed] < 0 && reach_top) ||
      (@scroll_data[:speed] > 0 && reach_bottom)
      @scroll_data = nil
      return
    end
    self.oy += @scroll_data[:speed]
    self.oy = [[-SPACE, self.oy].max,
        contents.height - self.height + standard_padding * 2 + SPACE].min
  end
  #--------------------------------------------------------------------------
  # ● 文字开始/结束显示
  #--------------------------------------------------------------------------
  def start_message
    @text = $game_message.all_text
    self.oy = -SPACE
    refresh
    open
  end
  def terminate_message
    @text = nil
    $game_message.clear
    close
  end
  def refresh
    reset_font_settings
    update_all_text_height
    create_contents
    draw_text_ex(4, 0, @text)
  end
  def update_all_text_height
    @all_text_height = 1
    convert_escape_characters(@text).each_line do |line|
      @all_text_height += calc_line_height(line, false)
    end
    reset_font_settings
  end
  def contents_height
    @all_text_height ? @all_text_height : super
  end
  #--------------------------------------------------------------------------
  # ● 打开/关闭特效的处理
  #--------------------------------------------------------------------------
  def open
    @opening = true if self.contents_opacity != 255
    super
  end
  def close
    @closing = true if self.contents_opacity != 0
    super
  end
  def update_open
    case EFFECT
    when 0
      self.openness += COME
      @opening = false if open?
    when 1
      self.contents_opacity += COME
      self.opacity = self.contents_opacity if BACK
      if self.contents_opacity >= 255
        @opening = false
        self.arrows_visible = true
      end
    end
  end
  def update_close
    case EFFECT
    when 0
      self.openness -= COME
      @closing = false if close?
    when 1
      self.contents_opacity -= COME
      self.opacity = self.contents_opacity if BACK
      if self.contents_opacity <= 0
        @closing = false
        self.arrows_visible = false
      end
    end
  end
  def effecting; @opening || @closing; end
end
end # module M5Read20140811

class Window_ScrollText
  alias m5_20140811_initialize initialize
  def initialize
    m5_20140811_initialize
    @m5_20140811_read = M5Read20140811::Window.new
  end
  alias m5_20140811_dispose dispose
  def dispose
    m5_20140811_dispose
    @m5_20140811_read.dispose
  end
  alias m5_20140811_update update
  def update
    if $game_switches[M5Read20140811::SWI]
      m5_20140811_update
      @m5_20140811_read.update if @m5_20140811_read.effecting
    else
      super
      @m5_20140811_read.update
    end
  end
end
#--------------------------------------------------------------------------
# ● Sion 鼠标脚本的相关处理
#--------------------------------------------------------------------------
if $SINOVA and $SINOVA[:mouseBase] and ($SINOVA[:mouseBase] >= 3.00)
class M5Read20140811::Window
  alias m5_20151113_open open
  def open
    Mouse.reset_z
    @mouse = Mouse.z
    m5_20151113_open
  end
  alias m5_20151113_update_input
    if @mouse != Mouse.z
      set_scroll(-SPEED1 * SPEED2) if @mouse < Mouse.z
      set_scroll(SPEED1 * SPEED2) if @mouse > Mouse.z
      @mouse = Mouse.z
    end
    m5_20151113_update_input
  end
end
end # if $SINOVA[:mouseBase]