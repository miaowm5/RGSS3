=begin
===============================================================================
  对话框内显示选项 By喵呜喵5
===============================================================================

【说明】

  仿照 RMVX 的模式，在对话框中显示选项和数值输入

  原理很简单，只不过是把原来的窗口背景弄成透明的显示在对话框上而已

  文字 + 选项的总行数超过对话最大允许行数时将在新一页中显示选项

=end
$m5script ||= {};$m5script[:M5CIM20141206] = 20220516
module M5CIM20141206
#==============================================================================
#  设定部分
#==============================================================================

  CHOICE = true

  # 是否在对话框显示对话选项，不需要时填写为 false

  NUMBER = true

  # 是否在对话框显示数值输入框，不需要时填写为 false

#==============================================================================
#  设定结束
#==============================================================================
  def self.handle(window, message_window)
    window.width = Graphics.width
    window.y = Graphics.height - window.height
    window.z = message_window.z + 1
    window.opacity = 255
    if message_window.open?
      pos = message_window.m5_20141206_cim.clone
      if pos[:y] + window.height > message_window.height
        message_window.input_pause
        message_window.close
        window.y = [message_window.y, window.y].min
      else
        window.width -= message_window.new_line_x
        window.opacity = 0
        window.y = message_window.y + pos[:y]
      end
    end
    window.x = Graphics.width - window.width
  end
end
class Window_Message
  attr_reader :m5_20141206_cim
  alias m5_20141206_process_character process_character
  def process_character(c, text, pos)
    m5_20141206_process_character(c, text, pos)
    @m5_20141206_cim = pos
  end
end
if M5CIM20141206::CHOICE
class Window_ChoiceList
  def update_placement
    self.height = fitting_height($game_message.choices.size)
    M5CIM20141206.handle(self, @message_window)
  end
end
end # if M5CIM20141206::CHOICE
if M5CIM20141206::NUMBER
class Window_NumberInput
  def update_placement
    self.height = fitting_height(1)
    M5CIM20141206.handle(self, @message_window)
  end
end
end # if M5CIM20141206::CHOICE
