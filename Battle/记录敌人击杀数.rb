=begin
===============================================================================
  记录敌人击杀数 By喵呜喵5
===============================================================================

【说明】

  记录游戏开始后总共在战斗中击倒敌人多少次

  在变量操作的脚本中输入

    M5EC20151114[敌人的ID]

  该变量就会被赋值为敌人的击杀次数

  在事件的脚本中输入：

    M5EC20151114.clear(敌人的ID)

  重置指定敌人的击杀次数

    M5EC20151114.clear

  重置全部敌人的击杀次数

=end
#==============================================================================
#  脚本部分
#==============================================================================
$m5script ||= {}; $m5script[:M5EC20151114] = 20151114
module M5EC20151114; class << self
  def data; $game_system.m5_20151114_enemy_count; end
  def [](id);         data[id] || 0;    end
  def []=(id, value); data[id] = value; end
  def clear(id = nil)
    if id then data[id] = 0
    else       data = []
    end
  end
end; end
class Game_System
  attr_accessor :m5_20151114_enemy_count
  alias m5_20151114_initialize initialize
  def initialize
    m5_20151114_initialize
    @m5_20151114_enemy_count = []
  end
end
class Game_Troop
  alias m5_20151114_on_battle_end on_battle_end
  def on_battle_end
    m5_20151114_on_battle_end
    dead_members.each {|e| M5EC20151114[e.enemy_id] += 1 }
  end
end