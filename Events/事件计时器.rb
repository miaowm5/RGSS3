=begin
===============================================================================
  事件计时器 By喵呜喵5
===============================================================================

【说明】

  随着时间的推移自动操作开关、独立开关、变量

  利用本脚本可以实现类似种菜这样的效果


  在事件指令的脚本中，输入以下代码来使用本脚本：

    m5_20151117_set_time(计时器的设置)

  计时器的设置使用如下格式：

    {
      设置的属性1: 属性1的值,
      设置的属性2: 属性2的值,
      设置的属性n: 属性n的值,
    }

    ※ 前后的中括号是必须的，每条属性名后面的英文冒号是必须的
    ※ 冒号和属性的值之间请加上空格，不要忘记每条设置最后的英文逗号
    ※ 为了防止脚本太长被编辑器强制修改，请手动在每条属性后换行

  需要设置的属性如下：

    类型    设置为 '地图' 时，计时器仅在主角处于本地图时才会继续计时
            默认值为 '全局'
            前后需要加上英文引号

    操作    设置计时器时间到以后要执行的指令，可以使用的值为：
            '变量' '开关' '独立开关'
            前后需要加上英文引号

    时间    设置计时器的倒计时时间（帧），
            当时间到了以后，将执行上面设置的操作

    ===========================================================================

    ※ 当操作部分设置为'变量'时：


    变量ID  设置计时器归零后要操作的变量ID

    变量值  设置计时器归零后，对应ID变量的值

    ===========================================================================

    ※ 当操作部分设置为'开关'时：

    开关ID  设置计时器归零后要操作的开关ID

    开关值  设置计时器归零后，对应开关的状态
            true 表示开关开启， false 表示开关关闭
            默认为 true

    ===========================================================================

    ※ 当操作部分设置为'独立开关'时：

    地图ID  设置计时器归零后要操作独立开关的事件所在的地图
            默认为当前地图

    事件ID  设置计时器归零后要操作独立开关的事件的事件ID
            默认为当前事件

    开关ID  设置计时器归零后要操作的独立开关
            可以使用的值分别是：'A' 'B' 'C' 'D'
            前后需要加上英文引号

    开关值  设置计时器归零后，对应独立开关的状态
            true 表示开关开启， false 表示开关关闭
            默认为 true

    ※ 虽然上一版中操作独立开关的设置方式仍然可以使用，但是个人建议尽快更新
    ※ 旧版脚本的操作方式预计将在未来的某个版本中被移除

    ===========================================================================

    指针    设置一个储存当前事件指针的 变量ID 用于结束该计时器
            不需要的话，不去设置即可
            关于结束计时器计时的方法请参考下方的说明


  结束某个计时器的计时：

    设置了指针属性的计时器可以提前结束计时

    例如，将某个计时器的指针属性设置为 1 时

    在计时器的计时过程中，执行指令：

      M5Timer20150824.clear(1)

    该计时器便会被删除

    执行指令：

      M5Timer20150824.start(1)

    该计时器的时间便会立刻归零

    请注意，这里设置的指针 1 表示数据被保存到了 1 号变量中，

    若之后修改了 1 号变量的值，执行结束计时器指令时将会发生错误，其他值亦同

=end
$m5script ||= {};$m5script[:M5Timer20150824] = 20170210
module M5Timer20150824
#==============================================================================
#  设定部分
#==============================================================================

  SWI = 0

  # 对应ID的开关打开时，计时器暂停

  SCENE_LIST = [Scene_Map, Scene_Battle]

  # 设置要让时间流逝的场景
  #
  # 默认的设置里，除了地图场景和战斗场景外，在其他场景中（例如打开菜单时），
  # 计时器会暂停计时

#==============================================================================
#  设定结束
#==============================================================================
class << self
  def update; $game_timer.m5timer20150824.update; end
  def start *args; $game_timer.m5timer20150824.start *args; end
  def clear *args; $game_timer.m5timer20150824.clear *args; end
  def add *args; $game_timer.m5timer20150824.add *args; end
  def refresh_scene; $game_timer.m5timer20150824.refresh_scene; end
end
class Timer
  def collect_event_id(id)
    value = $game_variables[id]
    return [] unless value.is_a? Array
    return [] unless value[0] == :m5_20151117
    ev_id = value[1]
    return [] unless @event_list[ev_id].object_id == value[2]
    [ev_id]
  end
  def start(id)
    operate_event(collect_event_id(id), true, true)
  end
  def clear(id)
    operate_event(collect_event_id(id), false, true)
  end
  def initialize
    @scene = false
    clear_all
  end
  def clear_all
    @map_timeline = []
    @global_timeline = []
    @event_list = []
    @timeline_list = []
  end
  def add_event(value)
    ev_id = @event_list.index(nil) || @event_list.size
    @event_list[ev_id] = value
    return ev_id
  end
  def add_timeline(ev_id, time_id)
    if !time_id
      time_id = @timeline_list.index(nil) || @timeline_list.size
      @timeline_list[time_id] = []
    end
    @timeline_list[time_id] << ev_id
    return time_id
  end
  def add(global, time, event)
    timeline = global ? @global_timeline : @map_timeline[event[:_MAP]]
    timeline ||= []
    ev_id = add_event(event)
    time_id = add_timeline(ev_id, timeline[time])
    event[:_TIME] = timeline[time] = time_id
    if event[:指针]
      $game_variables[event[:指针]] = [:m5_20151117, ev_id, event.object_id]
    end
  end
  def operate_timeline(time_id)
    index_list = @timeline_list[time_id]
    operate_event(index_list, true)
    @timeline_list[time_id] = nil
  end
  def operate_event(index_list, start, update_timeline = false)
    index_list.each do |ev_id|
      next unless @event_list[ev_id]
      if update_timeline
        time_id = @event_list[ev_id][:_TIME]
        @timeline_list[time_id].delete(ev_id)
      end
      start ? start_event(ev_id) : clear_event(ev_id)
    end
  end
  def clear_event(index)
    @event_list[index] = nil
  end
  def refresh_scene
    scene = SceneManager.scene.class
    SCENE_LIST.each {|s| return (@scene = true) if s == scene }
    @scene = false
  end
  def update
    return unless @scene
    return if $game_switches[SWI]
    update_list @map_timeline[$game_map.map_id]
    update_list @global_timeline
  end
  def update_list(list)
    return unless list
    time_id = list.shift
    return unless time_id
    operate_timeline(time_id)
  end
  def start_event(index)
    event = @event_list[index]
    return unless event
    case event[:操作]
    when "变量" then operate_variable(event)
    when "开关" then operate_switches(event)
    when "脚本" then operate_script(event)
    when "独立开关" then operate_self_switches(event)
    end
    $game_variables[event[:指针]] = 0 if event[:指针]
    clear_event(index)
  end
  def operate_variable(event)
    $game_variables[event[:变量ID]] = event[:变量值]
  end
  def operate_switches(event)
    $game_switches[event[:开关ID]] = event[:开关值]
  end
  def operate_self_switches(event)
    key = [event[:地图ID], event[:事件ID], event[:开关ID]]
    $game_self_switches[key] = event[:开关值]
  end
  def operate_script(event)
    eval(event[:代码])
  end
end
end # M5Timer20150824

class Game_Timer
  attr_reader :m5timer20150824
  alias m5_20151117_initialize initialize
  def initialize
    m5_20151117_initialize
    @m5timer20150824 = M5Timer20150824::Timer.new
  end
end
class << Graphics
  alias m5_20150824_update update
  def update; m5_20150824_update; M5Timer20150824.update; end
end
class Game_Interpreter
  def m5_20151117_set_time(param)
    event = {
      :类型 => '全局',    :_MAP => @map_id,
      :地图ID => @map_id, :事件ID => @event_id, :开关值 => true,
    }
    event.merge!(param)
    global = event[:类型] == '全局'
    time = event[:时间] || (raise '未设置计时器时间！')
    event[:操作] || (raise '未设置操作类型！')
    case event[:操作]
    when '变量'
      raise '未设置变量ID！' unless event[:变量ID]
      raise '未设置变量值！' unless event[:变量值]
    when '开关', '独立开关'
      raise '未设置开关ID！' unless event[:开关ID]
    end
    M5Timer20150824.add(global, time, event)
  end
  def m5_20150912_set_time *args
    args = [@map_id, @event_id].concat args if args[0].is_a?(String)
    args.insert(3,true) if args[3].is_a?(Numeric)
    args[5] = "A" unless args.size == 6
    type = args[5] == "A" ? '全局' : '地图'
    event = {
      :地图ID => args[0],  :事件ID => args[1], :类型 => type,
      :操作 => '独立开关', :开关ID => args[2], :开关值 => args[3],
      :时间 => args[4]
    }
    m5_20151117_set_time(event)
  end
end
class Scene_Base
  alias m5_20170210_start start
  def start
    M5Timer20150824.refresh_scene
    m5_20170210_start
  end
end
