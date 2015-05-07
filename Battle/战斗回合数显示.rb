=begin
===============================================================================
  战斗回合数显示 By喵呜喵5
===============================================================================

【说明】

  在战斗界面显示当前的回合数

=end
$m5script ||= {}
raise("需要喵呜喵5地图显示变量脚本的支持") unless $m5script[:M5Var20140815]
$m5script[:M5Round20141210] = 20150507
M5script.version(20150507,"喵呜喵5地图显示变量脚本版本过低",:M5Var20140815)
module M5Round20141210
#==============================================================================
#  设定部分
#==============================================================================

  X = nil

  # 设置窗口左侧的X坐标（不需要设置而是由脚本自动计算的话，填写nil）

  Y = nil

  # 设置窗口上方的Y坐标（不需要设置而是由脚本自动计算的话，填写nil）

  X2 = 544

  # 设置窗口右侧的X坐标（不需要设置而是由脚本自动计算的话，填写nil）

  Y2 = 308

  # 设置窗口下方的Y坐标（不需要设置而是由脚本自动计算的话，填写nil）

  SWI = 1

  # 对应ID的开关打开时，不显示战斗回合数

  BACK = "BattleRound"

  # 设置窗口的背景图片，不需要则填入nil。背景图片素材放到 Graphics\System 目录下

  BACK_X = 416

  # 设置背景图片的X坐标

  BACK_Y = 266

  # 设置背景图片的Y坐标

  START_TEXT = "战斗开始"

  # 第零回合（战斗开始角色选择指令时）的提示文字

  TURN_TEXT = "第%s回合"

  # 第N回合的提示文字，%s代表对应的回合数

#==============================================================================
#  脚本部分
#==============================================================================
  def self.round_text
    if $game_troop.turn_count == 0 then return START_TEXT
    else return sprintf(TURN_TEXT, $game_troop.turn_count)
    end
  end
end
class Scene_Battle
  alias m5_20141210_start start
  def start
    m5_20141210_start
    if !M5Var20140815.check_scene
      @m5_20140815_cal_size_window = Window_M5CalText.new
    end
    config = {
      EVAL: "M5Round20141210.round_text",
      X: M5Round20141210::X,
      Y: M5Round20141210::Y,
      X2: M5Round20141210::X2,
      Y2: M5Round20141210::Y2,
      BACK: M5Round20141210::BACK,
      SX: M5Round20141210::BACK_X,
      SY: M5Round20141210::BACK_Y,
      SWI: M5Round20141210::SWI,
    }
    window = M5Var20140815::Window_Var.new(config,@m5_20140815_cal_size_window)
    @m5_20140815_var_windows.push window
  end
end