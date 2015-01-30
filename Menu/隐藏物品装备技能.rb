=begin
===============================================================================
  隐藏物品/装备/技能 By 喵呜喵5
===============================================================================

【说明】

  在物品/装备/技能的数据库备注栏中输入“<hide>”（不包括双引号）

  实际游戏时即使玩家获得了这个物品/装备/技能玩家也无法在游戏中看到

=end
#==============================================================================
#  脚本部分
#==============================================================================
$m5script ||= {};raise("需要喵呜喵5基础脚本的支持") unless $m5script[:M5Base]
$m5script[:M5HI20150131] = 20150131;M5script.version(20150129)
class Window_ItemList
  alias m5_20150131_include? include?
  def include?(item)
    return false if item && item.m5note("hide",false,false)
    return m5_20150131_include?(item)
  end
end
class Window_SkillList
  alias m5_20150131_include? include?
  def include?(item)
    return false if item && item.m5note("hide",false,false)
    return m5_20150131_include?(item)
  end
end
class Window_EquipItem
  alias m5_20150131_include? include?
  def include?(item)
    return false if item && item.m5note("hide",false,false)
    return m5_20150131_include?(item)
  end
end
class Window_BattleItem
  alias m5_20150131_include? include?
  def include?(item)
    return false if item && item.m5note("hide",false,false)
    return m5_20150131_include?(item)
  end
end