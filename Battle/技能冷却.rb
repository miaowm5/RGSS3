=begin
===============================================================================
  技能冷却 By 喵呜喵5
===============================================================================

【说明】

  在特定技能的备注中插入一行：

    <冷却时间 3>

  则该技能使用一次后需要等待三回合后才能重新使用

  在事件指令的脚本中输入：

    M5ST20160127.recover          # 重置全体队友的技能冷却时间

    M5ST20160127.recover(2,3)     # 重置 2、3 号角色的技能冷却时间

    M5ST20160127.recover(1,2,3,4) # 重置 1、2、3、4 号角色的技能冷却时间

    M5ST20160127.recover_4        # 重置全体队友 4 号技能的冷却时间

    M5ST20160127.recover_4_6      # 重置全体队友 4、6 号技能的冷却时间

    M5ST20160127.recover_4_6(1)     # 重置 1 号角色 4、6 号技能的冷却时间

  以此类推（请注意事件脚本强制换行的问题）

=end
$m5script ||= {};raise("需要喵呜喵5基础脚本的支持") unless $m5script[:M5Base]
$m5script[:M5ST20160127] = 20160127;M5script.version(20160125)
module M5ST20160127
#==============================================================================
#  设定部分
#==============================================================================

  RECOVER = false

  # 设置为 true 时，战斗结束后自动重置技能冷却时间

  MAP_COUNT = false

  # 设置为 true 时，在地图上移动一定步数也能积累技能冷却时间

  RECOVER_COMMAND = false

  # 设置为 true 时，完全恢复时自动重置技能冷却时间

  VOCAB1 = "-冷却中，剩余%s回合"

  # 冷却中技能的在帮助窗口说明中的提示文字

  VOCAB2 = "%s回合"

  # 冷却中技能在技能列表中的提示文字

#==============================================================================
#  设定结束
#==============================================================================
class << self
  def list(*a)
    a.empty? ? $game_party.all_members : a.collect{|id| $game_actors[id]}
  end
  def recover(*actor); list(*actor).each{|a| a.m5_20160127_skill.clear}; end
  def method_missing(method_name, *actor, &block)
    return super unless method_name =~ /^recover(_(\d+))+$/
    actors = list(*actor)
    method_name.to_s.scan(/_(\d+)/) do |s|
      actors.each{|a| a.m5_20160127_skill.delete(s[0].to_i)}
    end
  end
end
end
class Game_BattlerBase
  attr_reader   :m5_20160127_skill
  alias m5_20160127_initialize initialize
  def initialize
    m5_20160127_initialize
    m5_20160127_reset_time
  end
  def m5_20160127_reset_time; @m5_20160127_skill = {}; end
  alias m5_20160127_payable? skill_cost_payable?
  def skill_cost_payable?(skill)
    m5_20160127_payable?(skill) && !@m5_20160127_skill[skill.id]
  end
  alias m5_20160127_pay_cost pay_skill_cost
  def pay_skill_cost(skill)
    m5_20160127_pay_cost(skill)
    return if M5ST20160127::RECOVER && !$game_party.in_battle
    return unless time_cost = skill.m5note('冷却时间',nil)
    @m5_20160127_skill[skill.id] = time_cost.to_i
    @m5_20160127_skill[skill.id] -= 1 unless $game_party.in_battle
  end
  alias m5_20160127_recover_all recover_all
  def recover_all
    m5_20160127_recover_all
    return unless M5ST20160127::RECOVER_COMMAND
    m5_20160127_reset_time
  end
end
class Game_Battler
  alias m5_20160127_on_turn_end on_turn_end
  def on_turn_end
    m5_20160127_on_turn_end
    return unless $game_party.in_battle || M5ST20160127::MAP_COUNT
    @m5_20160127_skill.keys.each do |s|
      time = (@m5_20160127_skill[s] -= 1)
      @m5_20160127_skill.delete(s) if time < 0
    end
  end
  alias m5_20160127_on_battle_end on_battle_end
  def on_battle_end
    m5_20160127_on_battle_end
    @m5_20160127_skill.keys.each do |s|
      time = (@m5_20160127_skill[s] -= 1)
      @m5_20160127_skill.delete(s) if time < 0
    end
    return unless M5ST20160127::RECOVER
    m5_20160127_reset_time
  end
end
class Window_SkillList
  alias m5_20160124_make_item_list make_item_list
  def make_item_list
    m5_20160124_make_item_list
    return unless @actor
    return if M5ST20160127::RECOVER && !$game_party.in_battle
    @data.each_with_index do |s, i|
      next unless s && (time = @actor.m5_20160127_skill[s.id])
      (skill = s.clone).description = s.description +
        sprintf(M5ST20160127::VOCAB1, time + 1)
      @data[i] = skill
    end
  end
  alias m5_20160127_draw_skill_cost draw_skill_cost
  def draw_skill_cost(rect, skill)
    if (time = @actor.m5_20160127_skill[skill.id])
      draw_text(rect, sprintf(M5ST20160127::VOCAB2, time + 1), 2)
      return
    end
    m5_20160127_draw_skill_cost(rect, skill)
  end
end