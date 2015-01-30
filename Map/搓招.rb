=begin
===============================================================================
  搓招 By喵呜喵5
===============================================================================

【说明】

  在地图上按照特定的顺序按键的话对应变量的值就会发生改变

  通过这个脚本搭配事件可以实现搓招的效果

=end
$m5script ||= {};$m5script[:M5IC20150130] = 20150130
module M5IC20150130
#==============================================================================
# 设定部分
#==============================================================================

  COMMAND = {

    [:LEFT,:RIGHT,:A] => 1,
    [:DOWN,:DOWN,:A] => 2,
    [:DOWN,:UP,:A] => 3,
    [:C,:C,:A] => 4,
    [:DOWN,:LEFT,:UP,:UP,:A] => 5,
    [:DOWN,:LEFT,:UP,:RIGHT,:A] => 6,
    [:UP,:UP,:RIGHT,:LEFT,:A] => 7,

  # 搓招列表设置格式：
  # [ 按键列表(逗号隔开) ] => 数字 ,

  }

  VAR = 1

  # 变量ID，成功搓招后对应ID的变量数值会变成搓招列表上设置的数字

  TIME = 45

  # 搓招速度，数字越小要求搓招速度越快

  SWI = 1

  # 开关ID，对应ID的开关打开后脚本失效

#==============================================================================
# 设定结束
#==============================================================================
end
class Scene_Map
  alias m5_20150130_start start
  def start
    m5_20150130_start
    @m5ic20150130 = {
      :command => M5IC20150130::COMMAND,
      :list => M5IC20150130::COMMAND.keys,
      :input => M5IC20150130::COMMAND.keys,
      :index => -1,:time => 0,
    }
    max_size = 0
    @m5ic20150130[:list].each { |key| max_size = [max_size,key.size].max }
    @m5ic20150130[:size] = max_size
  end
  alias m5_20150130_update update
  def update
    m5_20150130_update
    return if $game_switches[M5IC20150130::SWI]
    update_20150130_input
    if Graphics.frame_count - @m5ic20150130[:time] > M5IC20150130::TIME
      clear_20150130_input
    end
  end
  def clear_20150130_input
    data = @m5ic20150130
    return if data[:time] == 0
    data[:time] = 0
    data[:index] = -1
    data[:input] = data[:list].clone
  end
  def update_20150130_input
    list = [:DOWN, :LEFT, :RIGHT, :UP, :A, :B, :C, :X, :Y, :Z, :L,
      :R, :SHIFT, :CTRL, :ALT]
    data = @m5ic20150130
    list.each do |key|
      if Input.trigger?(key)
        data[:time] = Graphics.frame_count
        data[:index] += 1
        data[:input].reject!{|c_list| c_list[data[:index]] != key }
        if data[:input].size == 1 && data[:input][0].size == data[:index] + 1
          $game_variables[M5IC20150130::VAR] = data[:command][data[:input][0]]
          clear_20150130_input
          return
        elsif data[:input].size == 0
          clear_20150130_input
          return
        end
        return
      end
    end
  end
end