=begin
===============================================================================
  对话框内显示选项 By喵呜喵5
===============================================================================

【说明】

  仿照RMVX的模式，在对话框中显示选择的选项

  原理很简单，只不过是把原来显示选项的窗口背景弄成透明的放在显示文字的对话框上而已

  文字+选项的总行数超过对话最大允许行数时将在新一页中显示选项

=end
$m5script ||= {};$m5script[:M5CIM20141206] = 20160101
class Window_Message
  attr_reader :m5_20141206_cim
  alias m5_20141206_process_character process_character
  def process_character(c, text, pos)
    m5_20141206_process_character(c, text, pos)
    @m5_20141206_cim = pos
  end
end
class Window_ChoiceList
  def update_placement
    self.width = Graphics.width
    self.height = fitting_height($game_message.choices.size)
    self.y = Graphics.height - self.height
    self.z = @message_window.z + 1
    self.opacity = 255
    if @message_window.open?
      pos = @message_window.m5_20141206_cim.clone
      if pos[:y] + self.height > @message_window.height
        @message_window.input_pause
        @message_window.close
        self.y = [@message_window.y, self.y].min
      else
        self.width -= @message_window.new_line_x
        self.opacity = 0
        self.y = @message_window.y + pos[:y]
      end
    end
    self.x = Graphics.width - width
  end
end