=begin
===============================================================================
  事件提示 By喵呜喵5
===============================================================================

【说明】

  在地图上显示主角面前事件的提示文字

  在要显示文字的事件在事件指令列表的开头插入一个 注释 指令，注释的内容为：

    <提示 要显示的文字>

  即可

=end
$m5script ||= {}
raise("需要喵呜喵5地图显示变量脚本的支持") unless $m5script[:M5Var20140815]
$m5script[:M5EC20150129] = 20150507
M5script.version(20150507,"喵呜喵5地图显示变量脚本版本过低",:M5Var20140815)
module M5EC20150129
#==============================================================================
#  设定部分
#==============================================================================

  X = 0

  # 设置窗口左侧的X坐标（不需要设置而是由脚本自动计算的话，填写nil）

  Y = nil

  # 设置窗口上方的Y坐标（不需要设置而是由脚本自动计算的话，填写nil）

  X2 = 544

  # 设置窗口右侧的X坐标（不需要设置而是由脚本自动计算的话，填写nil）

  Y2 = 416

  # 设置窗口下方的Y坐标（不需要设置而是由脚本自动计算的话，填写nil）

  POSX = 10

  # 设置提示文字的起始X坐标

  POSY = 0

  # 设置提示文字的起始Y坐标

  SWI = 0

  # 对应ID的开关打开时，不显示窗口

  BACK = ""

  # 设置窗口的背景图片，不需要则填入nil。背景图片素材放到 Graphics\System 目录下

  BACK_X = 0

  # 设置背景图片的X坐标

  BACK_Y = 0

  # 设置背景图片的Y坐标

  Z = -50

  # 如果窗口遮住不希望遮住的内容了，调小这个数值（可以为负数）

#==============================================================================
#  脚本部分
#==============================================================================
  def self.text
    x = $game_map.round_x_with_direction($game_player.x, $game_player.direction)
    y = $game_map.round_y_with_direction($game_player.y, $game_player.direction)
    event = $game_map.events[$game_map.event_id_xy(x, y)]
    return "" unless event && event.list
    return M5script.read_event_note($game_map.map_id, event.id, "提示","")
  end
end
class Scene_Map
  alias m5_20150129_start start
  def start
    m5_20150129_start
    if !M5Var20140815.check_scene
      @m5_20140815_cal_size_window = Window_M5CalText.new
    end
    config = {
      EVAL: "M5EC20150129.text",
      X: M5EC20150129::X,
      Y: M5EC20150129::Y,
      X2: M5EC20150129::X2,
      Y2: M5EC20150129::Y2,
      BACK: M5EC20150129::BACK,
      SX: M5EC20150129::BACK_X,
      SY: M5EC20150129::BACK_Y,
      SWI: M5EC20150129::SWI,
      POSX: M5EC20150129::POSX,
      POSY: M5EC20150129::POSY,
      Z: M5EC20150129::Z,
    }
    window = M5Var20140815::Window_Var.new(config,@m5_20140815_cal_size_window)
    @m5_20140815_var_windows.push window
  end
end