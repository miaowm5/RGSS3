=begin
===============================================================================
  阅读系统 By喵呜喵5
===============================================================================

【说明】

  将游戏中滚动文字的显示方式换成了可以上下移动的对话框窗口
  
  上下键用于翻页，左右键用于快速翻页，取消键可以回到开头部分，
  确定键可以用来快速翻页，当翻到页底时关闭窗口
  
  描绘文字需要耗费一定的时间，请尽量避免显示太多的文字
  
=end
$m5script ||= {};$m5script["M5Read20140811"] = 20140811
module M5Read20140811
#==============================================================================
#  设定部分
#==============================================================================
  
  WIDTH = 60
  
  # 设置窗口的宽度，数字越大窗口越小
  
  HEIGHT = 60
  
  # 设置窗口的高度，数字越大窗口越小
  
  SPEED = 3
  
  # 设置文字滚动的速度，数字越大速度越快
  
  SPACE = 9
  
  # 设置在文字开头和结尾部分的留空大小，数字越大留空越多
  
  EFFECT = 1
  
  # 设置窗口的打开/关闭效果
  # 0 表示展开效果，1 表示淡化效果
  
  COME = 15
  
  # 设置窗口的打开、关闭速度，值越大速度越快
  
  BACK = true
  
  # 设置窗口背景是否透明，为 false 时窗口背景透明
  # 背景透明时可以用显示图片指令来显示图片作为窗口的背景
  
  SWI = 1
  
  # 对应ID的开关打开时，恢复原本的滚动文字
  
#==============================================================================
#  设定结束
#==============================================================================
end

class Window_M5Read20140811 < Window_Base  
  include M5Read20140811
  def initialize
    super(WIDTH/2, HEIGHT/3, Graphics.width - WIDTH, Graphics.height - HEIGHT)
    self.opacity = 0 unless BACK
    case EFFECT
    when 0 then self.openness = 0
    else
      self.opacity = 0
      self.contents_opacity = 0
    end
    set_mouse
  end
  def update
    super
    return if effecting
    if $game_message.scroll_mode
      update_direction
      update_ok
      self.oy = -SPACE if Input.repeat?(:B)
      start_message if !@text && $game_message.has_text?
    end
  end
  #--------------------------------------------------------------------------
  # ● 更新玩家的按键操作
  #--------------------------------------------------------------------------
  def update_direction
    update_message_up if Input.press?(:UP)
    update_message_down if Input.press?(:DOWN)
    15.times {update_message_up} if Input.press?(:LEFT) || mouse_up
    15.times {update_message_down} if Input.press?(:RIGHT) || mouse_down
  end
  def update_ok
    if Input.trigger?(:C)
      if self.oy < contents.height - self.height + standard_padding * 2 + SPACE
        30.times {update_message_down}
      else
        terminate_message
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● Sion 鼠标脚本的相关处理
  #--------------------------------------------------------------------------
  def mouse_up
    return false unless @mouse
    if @mouse < Mouse.z
      @mouse = Mouse.z
      return true
    end
    false
  end
  def mouse_down
    return false unless @mouse
    if @mouse > Mouse.z
      @mouse = Mouse.z
      return true
    end
    false
  end
  def set_mouse
    if $SINOVA and $SINOVA[:mouseBase] and ($SINOVA[:mouseBase] >= 3.00)
      Mouse.reset_z
      @mouse = Mouse.z
    else
      @mouse = nil
    end
  end
  #--------------------------------------------------------------------------
  # ● 文字开始/结束显示
  #--------------------------------------------------------------------------
  def start_message
    @text = $game_message.all_text
    self.oy = -SPACE
    refresh
    set_mouse
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
  # ● 文字滚动效果的处理
  #--------------------------------------------------------------------------  
  def update_message_down    
    self.oy = [self.oy + SPEED,
    contents.height - self.height + standard_padding * 2 + SPACE ].min
  end
  def update_message_up    
    self.oy = [self.oy - SPEED,- SPACE ].max
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
  def effecting;return @opening || @closing;end
end

class Window_ScrollText
  alias m5_20140811_initialize initialize
  def initialize
    m5_20140811_initialize
    @m5_20140811_read = Window_M5Read20140811.new
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
