=begin
===============================================================================
  对话框内显示选项 By喵呜喵5
===============================================================================

【说明】

  仿照RMVX的模式，在对话框中显示选择的选项

  原理很简单，只不过是把原来显示选项的窗口背景弄成透明的放在显示文字的对话框上而已

  文字+选项的总行数超过对话最大允许行数时将在新一页中显示选项

=end
$m5script ||= {};$m5script[:M5CIM20141206] = 20141206
class Window_Message
  attr_reader :m5_20141206_cim
  alias m5_20141206_process_character process_character
  def process_character(c, text, pos)
    m5_20141206_process_character(c, text, pos)
    @m5_20141206_cim = pos
  end
end
class Window_ChoiceList
  alias m5_20141206_initialize initialize
  def initialize(message_window)
    m5_20141206_initialize(message_window)
    self.z = 201
  end
  def update_placement
    pos = @message_window.m5_20141206_cim.clone
    self.height = fitting_height($game_message.choices.size)
    self.opacity = 255
    self.width = Graphics.width
    if pos[:y] + self.height > @message_window.height && @message_window.open?
      @message_window.input_pause
      @message_window.close
      self.y = @message_window.y
    elsif @message_window.open?
      self.width -= @message_window.new_line_x
      self.opacity = 0
      self.y = @message_window.y + pos[:y]
    else
      self.y = Graphics.height - self.height
    end
    self.x = Graphics.width - width
  end
end