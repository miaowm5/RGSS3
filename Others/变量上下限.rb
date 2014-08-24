=begin
===============================================================================
  变量上下限 By喵呜喵5
===============================================================================

【说明】

  允许设置变量的上限与下限
  
=end
$m5script ||= {};$m5script["M5VL20140824"] = 20140824
module M5VL20140824
  VAR = {
#==============================================================================
# 设定部分
#==============================================================================  

  1 => [20,2],
  
  2 => [-15,15],
  
  3 => 10,
  
  -4 => 5,
  
  # 设置格式：
  
  #  变量的ID => [变量的上、下限，用英文逗号分隔],
  
  #  变量的ID => 变量的上限（无下限）,
  
  #  - 变量的ID => 变量的下限（无上限）,
  
  # （不要忘记每条设置结尾的英文逗号）
  
#==============================================================================
# 设定结束
#==============================================================================  
  }
end
class Game_Variables
  alias m5_20140824_initialize initialize
  def initialize
    m5_20140824_initialize
    M5VL20140824::VAR.each do |id,value|
      if id > 0
        if value.is_a?(Array)
          @data[id] = [[value.min,0].max,value.max].min
        else
          @data[id] = [0,value].min
        end
      else
        @data[-id] = [value,0].max
      end
    end
  end
  alias m5_20140824_set_var []=
  def []=(variable_id, value)
    limit = M5VL20140824::VAR[variable_id]
    if limit
      if limit.is_a?(Array)
        value = [[value,limit.max].min,limit.min].max
      else
        value = [value,limit].min
      end
    end
    limit = M5VL20140824::VAR[-variable_id]
    value = [value,limit].max if limit
    m5_20140824_set_var(variable_id, value)
  end
end
