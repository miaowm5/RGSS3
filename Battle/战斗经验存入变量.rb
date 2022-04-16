=begin
===============================================================================
  战斗经验存入变量 By喵呜喵5
===============================================================================

【说明】

  战斗结束后不获取经验值而是将经验值保存到变量中

=end
$m5script ||= {};$m5script[:M5RE20220416] = 20220416
module M5RE20220416
#==============================================================================
#  设定部分
#==============================================================================

  VAR = 1

  # 用于储存战斗后经验值的变量的 ID

  EXR = 0

  # 如何处理角色的经验获取加成能力(角色经验加成默认值为100%)
  #   0 : 忽略此能力
  #   1 : 所有角色经验加成的最大值作为最终加成
  #   2 : 参战角色经验加成的最大值作为最终加成
  #   3 : 所有角色经验加成的总和作为最终加成
  #   4 : 参战角色经验加成的总和作为最终加成

  SWI = 0

  # 对应 ID 的开关打开时，关闭本脚本的功能

#==============================================================================
#  设定结束
#==============================================================================
  def self.get_exr
    party = $game_party
    exr = ((EXR == 1 || EXR == 3) ? party.all_members : party.battle_members)
      .collect{|actor| actor.exr }
    return 1 unless exr.size > 0
    return exr.max if EXR == 1 || EXR == 2
    exr.inject(1){|r, v| r + v - 1 }
  end
end

class << BattleManager
  alias m5_20220416_gain_exp gain_exp
  def gain_exp
    return m5_20220416_gain_exp if $game_switches[M5RE20220416::SWI]
    $game_variables[M5RE20220416::VAR] += $game_troop.exp_total
  end
end
class Game_Troop
  alias m5_20220416_exp_total exp_total
  def exp_total
    return m5_20220416_exp_total if M5RE20220416::EXR == 0
    return m5_20220416_exp_total if $game_switches[M5RE20220416::SWI]
    (m5_20220416_exp_total * M5RE20220416.get_exr).to_i
  end
end
