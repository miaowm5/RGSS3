=begin
===============================================================================
  文字显示速度控制 By喵呜喵5
===============================================================================

【说明】

  1、通过一个变量控制显示文字的速度

  2、通过一个按键来快进对话（可能与其他脚本存在冲突）

  3、对话中自由停顿指定时长

【说明】

  关于自由停顿：

  使用转义字符\w[x]对话将停顿x帧，停顿过程中可以按键跳过停顿

  使用转义字符\nw[x]对话将停顿x帧，无法跳过停顿

=end
$m5script ||= {};$m5script[:M5MT20131130] = 20141218
module M5MT20131130
#==============================================================================
#  设定部分
#==============================================================================

  SPE = 1

  # 在这里设置控制对话速度的变量ID

  BUT = :CTRL

  # 在这里设置快进对话的按键

    SWI = 0

    # 当对应ID的开关打开时，不使用快进对话按键的功能

    OFF = false

    # 设置为 true 时，快进对话按键功能将被关闭
    # 当快进对话按键功能与其他脚本发生冲突时，
    # 请尝试将这里设置成 true 并将本脚本放在冲突脚本之下

#==============================================================================
#  设定结束
#==============================================================================
  def self.button_off
    OFF || $game_switches[SWI]
  end
end
class Window_Message
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
  alias m5_20131130_update_show_fast update_show_fast
  def update_show_fast
    m5_20131130_update_show_fast
    return if M5MT20131130.button_off
    @show_fast = @show_fast || Input.press?(M5MT20131130::BUT)
  end
  alias m5_20141218_wait wait
  def m5_20141218_wait(duration)
    return m5_20141218_wait if M5MT20131130.button_off
    [duration,0].max.times do |i|
      Fiber.yield unless Input.press?(M5MT20131130::BUT)
    end
  end
  alias m5_20141218_input_pause input_pause
  def input_pause
    return m5_20141218_input_pause if M5MT20131130.button_off
    self.pause = true
    wait(10)
    Fiber.yield until Input.trigger?(:B) || Input.trigger?(:C)||\
      Input.press?(M5MT20131130::BUT)
    Input.update
    self.pause = false
  end
end