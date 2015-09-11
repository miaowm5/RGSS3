=begin
===============================================================================
  独立变量 By喵呜喵5
===============================================================================

【说明】

  设定的变量变为事件的独立变量

  与独立开关类似，例如，设置ID为1的变量为独立变量，
  在【事件1】中操作【变量1】并不会改变【事件2】中【变量1】的值

  在并行的公共事件或者显示变量脚本等无法确定属于哪个事件的场合使用独立变量时，
  将可能出现非预期的数值

  针对有一定脚本基础的人，在脚本中，
  使用 M5SV20150801.s(地图ID,事件ID,变量ID) 来获取特定事件的独立变量
  使用 M5SV20150801.s(地图ID,事件ID,变量ID,值) 来为特定事件的独立变量赋值

=end
$m5script ||= {};$m5script[:M5SV20150801] = 20150801
module M5SV20150801
#==============================================================================
#  设定部分
#==============================================================================

  VAR = [1, 2, 3]

  # 在两个中括号中间设定需要作为独立变量使用的变量ID
  # 在事件A中操作对应ID的变量不会影响事件B中该变量的值
  # 多个变量ID之间请用英文逗号隔开

  DEFAULT = 100

  # 设定独立变量的初始值

#==============================================================================
#  设定结束
#==============================================================================
  def self.s(map, ev, var, value = nil)
    return $game_variables.m5_20150801_sv(map, ev, var, value)
  end
end
class Game_Variables
  def m5_20150801_sv(map, ev, var, value = nil)
    key = [map, ev, var]
    result = value || @m5_20150801_selfvar[key] || M5SV20150801::DEFAULT
    @m5_20150801_selfvar[key] = result
  end
  def m5_20150801_condition(var)
    !$game_party.in_battle && M5SV20150801::VAR.include?(var)
  end

  alias m5_20150801_initialize initialize
  def initialize
    m5_20150801_initialize
    @m5_20150801_selfvar = {}
  end
  alias m5_20150801_get []
  def [](var)
    if m5_20150801_condition(var)
      return m5_20150801_sv( $game_map.interpreter.map_id,
        $game_map.interpreter.event_id, var)
    else
      return m5_20150801_get(var)
    end
  end
  alias m5_20150801_set []=
  def []=(var, value)
    if m5_20150801_condition(var)
      m5_20150801_sv( $game_map.interpreter.map_id,
        $game_map.interpreter.event_id, var, value)
      on_change
    else
      return m5_20150801_set(var, value)
    end
  end
end
class Game_Event
  alias m5_20150801_conditions_met? conditions_met?
  def conditions_met?(page)
    c = page.condition
    var = c.variable_id
    if c.variable_valid && M5SV20150801::VAR.include?(var)
      return false if $game_variables.m5_20150801_sv(@map_id, @id,
        var) < c.variable_value
      c.variable_valid = false
    end
    result = m5_20150801_conditions_met? page
    c.variable_valid = true
    return result
  end
end