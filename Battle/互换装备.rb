=begin
===============================================================================
  互换装备 By喵呜喵5
===============================================================================

【说明】

  在事件指令的脚本中输入

    m5_20150128_swap(角色1的ID,角色2的ID)

  即可让指定ID的两名角色身上的装备互相交换

  交换只是单纯的交换，并不会检测这名角色是否允许装备交换的装备，
  因此，交换后的角色可能会获得普通情况下无法装备到的装备
  （例如非二刀流角色装备两把武器）

=end
$m5script ||= {};$m5script[:M5SE20150128] = 20150128
class Game_Actor
  def m5_20150128_equips;@equips;end
  def m5_20150128_equips=(equips);@equips = equips;end
end
class Game_Interpreter
  def m5_20150128_swap(a1,a2)
    $game_actors[a1].m5_20150128_equips, $game_actors[a2].m5_20150128_equips =
      $game_actors[a2].m5_20150128_equips,$game_actors[a1].m5_20150128_equips
  end
end