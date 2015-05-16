=begin
===============================================================================
  物品选择处理时显示物品说明 By喵呜喵5
===============================================================================

【说明】

  在事件的物品选择处理部分显示一个描述物品说明的帮助窗口

  如果有修改默认的物品选择处理窗口的位置的话，
  建议也对本脚本中 update_placement 方法里的内容做出相应修改

=end
$m5script ||= {}; $m5script[:M5KH201505016] = 20150516
module M5KH201505016
#==============================================================================
#  设定部分
#==============================================================================

  LINE = 1

  # 设置帮助窗口的行数，考虑到默认物品选择窗口的大小，行数仅支持 1 或 2
  # 懂得脚本的话，可以在脚本第85行进行修改以突破这个限制

  POS2 = :mode0

  # 当不存在对话框或者对话框位置在画面下方时，帮助窗口的显示位置
  #   :mode0 ：显示在物品选择窗口【外部】的【下方】
  #   :mode1 ：显示在物品选择窗口【内部】的【下方】
  #   :mode2 ：显示在物品选择窗口【外部】的【上方】
  #   :mode3 ：显示在物品选择窗口【内部】的【上方】
  #   nil : 不显示帮助窗口


  POS1 = :mode3

  # 当对话框位置在画面中央时，帮助窗口的显示位置
  #   :mode0 ：显示在物品选择窗口【外部】的【下方】
  #   :mode1 ：显示在物品选择窗口【内部】的【下方】
  #   :mode2 ：显示在物品选择窗口【外部】的【上方】
  #   :mode3 ：显示在物品选择窗口【内部】的【上方】
  #   nil : 不显示帮助窗口

  POS0 = :mode2

  # 当对话框位置在画面上方时，帮助窗口的显示位置
  #   :mode0 ：显示在物品选择窗口【外部】的【下方】
  #   :mode1 ：显示在物品选择窗口【内部】的【下方】
  #   :mode2 ：显示在物品选择窗口【外部】的【上方】
  #   :mode3 ：显示在物品选择窗口【内部】的【上方】
  #   nil : 不显示帮助窗口

#==============================================================================
#  设定结束
#==============================================================================
end
class Window_KeyItem
  alias m5_20150501_update_placement update_placement
  def update_placement
    self.height = @m5_20150501_origin_height
    m5_20150501_update_placement
    setting = eval "M5KH201505016::POS#{$game_message.position}"
    self.height -= @help_window.height if setting == :mode1 || setting == :mode3
    case setting
    when :mode1 # 显示在物品选择窗口【内部】的【下方】
      @help_window.y = self.y + self.height
    when :mode3 # 显示在物品选择窗口【内部】的【上方】
      @help_window.y = self.y
      self.y += @help_window.height
    when :mode0 # 显示在物品选择窗口【外部】的【下方】
      self.y -= @help_window.height if self.y > 0
      @help_window.y = self.y + self.height
    when :mode2 # 显示在物品选择窗口【外部】的【上方】
      self.y -= @help_window.height if self.y > 0
      @help_window.y = self.y
      self.y += @help_window.height
    else # 不显示帮助窗口
      @help_window.y = Graphics.height
    end
  end
  alias m5_20150501_initialize initialize
  def initialize *ars
    m5_20150501_initialize *ars
    @m5_20150501_origin_height = self.height
    @help_window = Window_Help.new([[1,M5KH201505016::LINE].max,2].min)
    @help_window.openness = 0
  end
  alias m5_20150501_update update
  def update; m5_20150501_update; @help_window.update; end
  alias m5_20150501_dispose dispose
  def dispose; m5_20150501_dispose; @help_window.dispose; end
  alias m5_20150501_open open
  def open; m5_20150501_open; @help_window.open; end
  alias m5_20150501_close close
  def close; m5_20150501_close; @help_window.close; end
end