=begin
===============================================================================
  事件计时器 By喵呜喵5
===============================================================================

【说明】

  随着时间的推移自动操作特定事件的独立开关

  利用本脚本可以实现类似种菜这样的效果


  在事件指令的脚本中，输入以下代码来使用本脚本：

    m5_20150912_set_time("A",300)

      本事件的独立开关【A】将打开，时间是【300】帧后

    m5_20150912_set_time("A",false,300)

      本事件的独立开关【A】将【关闭】，时间是【300】帧后

    m5_20150912_set_time("A",300,"MAP")

      本事件的独立开关【A】将打开，时间是【300】帧后，
      【若主角不在本地图则时间顺延】

    m5_20150912_set_time("A",false,300,"MAP")

      本事件的独立开关【A】将【关闭】，时间是【300】帧后，
      【若主角不在本地图则时间顺延】

    m5_20150912_set_time(1,2,"A",300)

      【1】号地图【2】号事件的独立开关【A】将打开，时间是【300】帧后

    m5_20150912_set_time(1,2,"A",false,300)

      【1】号地图【2】号事件的独立开关【A】将【关闭】，时间是【300】帧后

    m5_20150912_set_time(1,2,"A",300,"MAP")

      【1】号地图【2】号事件的独立开关【A】将打开，时间是【300】帧后，
      【若主角不在该地图则时间顺延】

    m5_20150912_set_time(1,2,"A",false,300,"MAP")

      【1】号地图【2】号事件的独立开关【A】将【关闭】，时间是【300】帧后，
      【若主角不在该地图则时间顺延】

=end
$m5script ||= {};$m5script[:M5Timer20150824] = 20150912
module M5Timer20150824
#==============================================================================
#  设定部分
#==============================================================================

  SCENE_LIST = [Scene_Map, Scene_Battle]

  # 设置要让时间流逝的场景
  #
  # 默认的设置里，除了地图场景和战斗场景外，在其他场景中（例如打开菜单时），
  # 计时器会暂停计时

#==============================================================================
#  设定结束
#==============================================================================
class << self
  def init
    @scene = [NilClass, false]
    clear_all
  end
  def clear_all
    @map_list, @map_id = {}, 0
    @all_list, @next_update, @next_count = {}, 0, 0
  end
  def creat_key(data)
    "m#{data[:m]}e#{data[:e]}s#{data[:s]}v#{data[:v]}".to_sym
  end
  def add_map_list(time, data)
    @map_list[data[:m]] ||= {}
    @map_list[data[:m]][creat_key(data)] = [time, data]
  end
  def update_map_list
    @map_id = $game_map.map_id
    return unless @map_list[@map_id]
    return if @map_list[@map_id].size == 0
    @map_list[@map_id].each do |key,value|
      if ( value[0] -= 1 ) <= 0
        operate_switch(@map_list[@map_id], key)
      end
    end
  end
  def add_all_list(time, data)
    refresh_all_list
    @all_list[creat_key(data)] = [time, data]
    @next_count = @next_update = time if time < @next_count
  end
  def update_all_list
    return if @all_list.size == 0
    refresh_all_list if ( @next_count -= 1 ) <= 0
  end
  def refresh_all_list
    past_time = @next_update - @next_count
    min_time = 1.0 / 0
    @all_list.each do |key, value|
      time = ( value[0] -= past_time )
      if time <= 0 then operate_switch(@all_list, key)
      else
        min_time = time if min_time > time
      end
    end
    @next_count = @next_update = min_time
  end
  def operate_switch(list, key)
    data = list.delete(key)
    return unless data
    data = data[1]
    $game_self_switches[[data[:m], data[:e], data[:s]]] = data[:v]
  end
  def clear_all_list(data, skip = false)
    clear_list(@all_list, creat_key(data), skip)
  end
  def clear_map_list(data, skip = false)
    clear_list(@map_list[data[:m]] || {}, creat_key(data), skip)
  end
  def clear_list(list,key,skip)
    skip ? operate_switch(list, key) : list.delete(key)
  end
  def update
    return unless check_scene
    update_map_list
    update_all_list
  end
  def check_scene
    return @scene[1] if SceneManager.scene_is?(@scene[0])
    scene = SceneManager.scene.class
    SCENE_LIST.each {|s| return (@scene = [s,true])[1] if s == scene }
    (@scene = [scene,false])[1]
  end
end
self.init
end
class << Graphics
  alias m5_20150824_update update
  def update; m5_20150824_update;  M5Timer20150824.update; end
end
class Game_Interpreter
  def m5_20150912_set_time *args
    args = [@map_id, @event_id].concat args if args[0].is_a?(String)
    args.insert(3,true) if args[3].is_a?(Numeric)
    args[5] = "A" unless args.size == 6
    mo = M5Timer20150824
    data = { :m => args[0], :e => args[1], :s => args[2], :v => args[3] }
    args[5] == "A" ? mo.add_all_list(args[4], data) : mo.add_map_list(
      args[4], data)
  end
end