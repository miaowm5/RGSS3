=begin
===============================================================================
  跳过标题画面 By喵呜喵5
===============================================================================

  【说明】

  打开游戏时，跳过标题画面，从设定部分指定的地图直接开始新游戏

  如果有使用其他的标题画面脚本的话，请将本脚本放在他们的下面

  在事件指令的脚本中输入：

    M5ST20151228.title

  可以进入原本的标题画面

  如果有使用我的全局变量脚本的话，还可以随着游戏的进度修改不同的标题画面地图

=end
$m5script ||= {}; $m5script[:M5ST20151228] = 20151228
module M5ST20151228; DATA = {
#==============================================================================
#  设定部分
#==============================================================================

  "DEFAULT" => {
    map: 1,
    x:   2,
    y:   3,
    opt: true,
  },

  # 设置跳过标题画面后开始游戏的地图
  #   该设置表示，跳过标题画面后，玩家将从 1 号地图上的坐标 (2,3) 处开始游戏，
  #   且游戏开始时玩家的行走图透明(true)

  "地图1" => {
    map: 4,
    x:   5,
    y:   6,
    opt: false,
  },

  # 在事件指令的脚本中执行 M5ST20151228.set("地图1") 后
  #   跳过标题画面后，玩家将从 4 号地图上的坐标 (5,6) 处开始游戏，
  #   且游戏开始时玩家的行走图不透明(false)

  "地图2" => {
    map: 5,
  },

  # 地图2的设置省略了部分设置内容，
  # 这些未设置的内容将直接使用 "DEFAULT" 部分的设置或者游戏内的设置
  # 所以，在事件指令的脚本中执行 M5ST20151228.set("地图2") 后
  #   跳过标题画面后，玩家将从 5 号地图上的坐标 (2,3) 处开始游戏，
  #   且游戏开始时玩家行走图透明


  # M5ST20151228.set("设置的名称") 只有在插入了我的全局变量脚本后才可以使用
  # 若要恢复最开始默认跳过标题画面的设置的话，
  # 可以在事件指令的脚本中输入 M5ST20151228.reset

  # 请注意，所有的符号都为英文符号，
  # 每条设置中出现的英文逗号以及设置名称前后的英文引号不可省略

#==============================================================================
#  设定结束
#==============================================================================
}
Origin_Scene = Scene_Title
class << self
  def title
    SceneManager.scene.fadeout_all
    SceneManager.goto(Origin_Scene)
    Fiber.yield
  end
  def check_base; (base = $m5script[:M5GV20140811]) && base >= 20151106; end
  def set(name = "DEFAULT")
    raise "本功能需要新版喵呜喵5全局变量脚本的支持" unless check_base
    M5GV20140811.set_ext(:m5st20151228, name)
  end
  alias reset set
end
class Scene < Origin_Scene
  def transition_speed; return 0; end
  def perform_transition; end
  def post_start
    super
    temp_data = load_data("Data/System.rvdata2")
    setting = { map: temp_data.start_map_id, x: temp_data.start_x,
                y: temp_data.start_y, opt: temp_data.opt_transparent }
    set = DATA["DEFAULT"]
    setting.merge!(set) if set
    if M5ST20151228.check_base
      data_name = M5GV20140811.get_ext[:m5st20151228]
      setting.merge!(set) if data_name && (set = DATA[data_name])
    end
    $data_system.start_map_id = setting[:map]
    $data_system.start_x = setting[:x]
    $data_system.start_y = setting[:y]
    $data_system.opt_transparent = setting[:opt]
    command_new_game
  end
  def play_title_music; end
  def fadeout_all(time = 1000); super(0); end
end
end # module M5ST20151228
Scene_Title = M5ST20151228::Scene