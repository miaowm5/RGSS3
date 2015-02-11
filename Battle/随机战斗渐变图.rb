=begin
===============================================================================
  随机战斗渐变图 By喵呜喵5
===============================================================================

【说明】

  开始战斗时可以随机使用多个中的一个图片作为战斗渐变图

  将新增的战斗开始渐变图分别命名成BattleStart1、BattleStart2……
  放到 Graphics\System 文件夹下，然后修改脚本设定部分的设定即可

=end
$m5script ||= {};$m5script[:M5BG20150211] = 20150211
$m5script[:ScriptData] ||= {}
module M5BG20150211
#==============================================================================
#  设定部分
#==============================================================================

  NUM = 4

  # 在这里填写战斗渐变图的个数

  ID = 1

  # 设置一个变量的ID，
  # 当这个ID的变量值为正数的时候，强制使用对应数字的战斗渐变图
  # 当这个ID的变量值为负数的时候，强制使用默认的战斗渐变图（BattleStart）
  # 例如，为2时，强制使用战斗渐变图2（BattleStart2）

#==============================================================================
#  设定结束
#==============================================================================
end
class << Graphics
  alias m5_20150211_transition transition
  def transition *args
    if args.size > 2 && $m5script[:ScriptData][:M5BG20150211]
      text = ""
      if $game_variables[M5BG20150211::ID] > 0
        text = $game_variables[M5BG20150211::ID]
      elsif $game_variables[M5BG20150211::ID] == 0
        text = rand( M5BG20150211::NUM ) + 1
      end
      args[1] += text.to_s
    end
    m5_20150211_transition *args
  end
end
class Scene_Map
  alias m5_20150211_perform_battle_transition perform_battle_transition
  def perform_battle_transition
    $m5script[:ScriptData][:M5BG20150211] = true
    m5_20150211_perform_battle_transition
    $m5script[:ScriptData][:M5BG20150211] = false
  end
end
