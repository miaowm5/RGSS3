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
$m5script ||= {};$m5script[:M5GV20140811] = 20151106
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

  LOAD = false

  # 设置为 true 的话，开始新游戏或者读取存档时，自动读取保存的全局变量

#==============================================================================
#  设定结束
#==============================================================================
class << self
  def load
    $m5script[:ScriptData][:M5GV20140811] =
      (load_data(FILENAME) rescue [nil, {}])
  end
  def save; save_data($m5script[:ScriptData][:M5GV20140811], FILENAME); end
  def load_var
    var = $m5script[:ScriptData][:M5GV20140811][0]
    return unless var
    var.each_with_index{|v,i| $game_variables.m5_20140811_set(VAR[i], v)}
  end
  def current_var
    var = []
    VAR.each {|index| var << $game_variables[index] }
    return var
  end
  def save_var
    $m5script[:ScriptData][:M5GV20140811][0] = current_var
    save
  end
  def get_ext; $m5script[:ScriptData][:M5GV20140811][1]; end
  def save_ext; save; end
  def set_ext(key, value)
    get_ext[key] = value
    save
  end
end # class << self
end

class Game_Variables
  alias m5_20140811_set []=
  def []=(variable_id, value)
    m5_20140811_set(variable_id, value)
    return unless M5GV20140811::AUTO
    M5GV20140811.save_var if M5GV20140811::VAR.include?(variable_id)
  end
end
class << DataManager
  alias m5_20150320_load_game load_game
  def load_game(index)
    result = m5_20150320_load_game(index)
    return result unless result && M5GV20140811::LOAD
    M5GV20140811.load_var
    result
  end
  alias m5_20150320_create_game_objects create_game_objects
  def create_game_objects
    m5_20150320_create_game_objects
    return unless M5GV20140811::LOAD
    M5GV20140811.load_var
  end
end
class Game_Interpreter
  def save_var; M5GV20140811.save_var; end
  def load_var; M5GV20140811.load_var; end
end
M5GV20140811.load