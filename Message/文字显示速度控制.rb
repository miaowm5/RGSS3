=begin
===============================================================================
  文字显示速度控制 By喵呜喵5
===============================================================================

【说明】

  1、通过一个变量控制显示文字的速度

  2、通过一个按键来快进对话

  3、对话中自由停顿指定时长

【说明】

  关于自由停顿：

  使用转义字符\w[x]对话将停顿x帧，停顿过程中可以按键跳过停顿

  使用转义字符\nw[x]对话将停顿x帧，无法跳过停顿

=end
$m5script ||= {} ;$m5script[:M5MT20131130] = 20131130
module M5MT20131130
#==============================================================================
#  设定部分
#==============================================================================

  SPE = 1

  #在这里设置控制对话速度的变量ID

  BUT = :CTRL

  #在这里设置快进对话的按键

#==============================================================================
#  设定结束
#==============================================================================
end
class Window_Message
  alias m5_20131130_update_show_fast update_show_fast
  def update_show_fast
    m5_20131130_update_show_fast
    @show_fast = true if Input.press?(M5MT20131130::BUT)
  end
  alias m5_wait_for_one_character wait_for_one_character
  def wait_for_one_character
    [$game_variables[M5MT20131130::SPE], 0].max.times do |i|
      m5_wait_for_one_character
    end
  end
  alias m5_20131130_process_escape_character process_escape_character
  def process_escape_character(code, text, pos)
    case code.upcase
    when 'W'
      [obtain_escape_param(text),0].max.times do |i|
        update_show_fast
        Fiber.yield unless @show_fast || @line_show_fast
      end
    when 'NW'
      ([obtain_escape_param(text),0].max).times { Fiber.yield }
    else
      m5_20131130_process_escape_character(code, text, pos)
    end
  end
  def wait(duration)
    [duration,0].max.times do |i|
      Fiber.yield unless Input.press?(M5MT20131130::BUT)
    end
  end
  def input_pause
    self.pause = true
    wait(10)
    Fiber.yield until Input.trigger?(:B) || Input.trigger?(:C)||\
      Input.press?(M5MT20131130::BUT)
    Input.update
    self.pause = false
  end
end