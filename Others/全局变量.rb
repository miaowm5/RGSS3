=begin
================================================================================
 全局变量 By 喵呜喵5
================================================================================

【说明】

  在事件中使用脚本命令 save_var 可以把设置好的变量单独储存到一个新文件中

  在事件中使用脚本命令 load_var 可以在其他地方
  （例如其他存档、或者开始新游戏时……）载入保存了的变量的值

  使用全局变量可以用来制作类似记录通关次数或者进入二周目这样的功能

=end
$m5script ||= {};$m5script[:M5GV20140811] = 20150319
$m5script[:ScriptData] ||= {}
module M5GV20140811
#==============================================================================
#  设定部分
#==============================================================================

  VAR = [1,3]

  # 在这里设置需要储存的全局变量ID

  FILENAME = "System.rvdata2"

  # 在这里设置储存全局变量的文件名

  AUTO = false

  # 设置为 true 的话，变量的值发生改变时自动保存全局变量

#==============================================================================
#  设定结束
#==============================================================================
  def self.save_var
    var = []
    ext = $m5script[:ScriptData][:M5GV20140811]
    VAR.each {|index| var.push $game_variables[index] }
    save_data([var,ext], FILENAME)
  end
  def self.save_ext(ext = $m5script[:ScriptData][:M5GV20140811])
    var = File.exist?(FILENAME) ? load_data(FILENAME)[0] : []
    save_data([var,ext], FILENAME)
  end
  def self.load_var
    return unless File.exist?(FILENAME)
    var = load_data(FILENAME)[0]
    var.each_with_index{|v,i| $game_variables.m5_20140811_set(VAR[i], v)}
  end
  def self.load_ext
    return {} unless File.exist?(FILENAME)
    return load_data(FILENAME)[1]
  end
  def self.get_ext
    return $m5script[:ScriptData][:M5GV20140811]
  end
end
class Game_Variables
  alias m5_20140811_set []=
  def []=(variable_id, value)
    m5_20140811_set(variable_id, value)
    return unless M5GV20140811::AUTO
    M5GV20140811.save_var if M5GV20140811::VAR.include?(variable_id)
  end
end
class Game_Interpreter
  def save_var; M5GV20140811.save_var; end
  def load_var; M5GV20140811.load_var; end
end
$m5script[:ScriptData][:M5GV20140811] = M5GV20140811.load_ext