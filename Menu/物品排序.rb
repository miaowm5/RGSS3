=begin
===============================================================================
  物品排序 By喵呜喵5
===============================================================================

【说明】

  修改对应变量的值时，在菜单中查看物品可以按照某种顺序排序

  唯一的问题是，除了数据库ID外……物品还真没啥好排序的 = =

  有时间的话加一个按照指定备注排序算了 = =

=end
$m5script ||= {};$m5script[:M5IS20140807] = 20161012
module M5IS20140807
#==============================================================================
# 设定部分
#==============================================================================

  VAR1 = 1

  # 决定物品、贵重物品排序的变量ID，不需要的话，填0就好了

  # 值为正数时：
  # 值为 1 时：按照 入手顺序 排序
  # 值为 2 时：按照 价格 排序
  # 其他值 时：按照 数据库ID 排序
  # 值为负数时，先按照其相反数进行排序，之后倒序排列

  VAR2 = 2

  # 决定武器排序的变量ID，不需要的话，填0就好了

  VAR3 = 3

  # 决定防具排序的变量ID，不需要的话，填0就好了

  # 对于武器与防具
  # 值为正数时：
  # 值为 1    时：按照 入手顺序 排序
  # 值为 2    时：按照 价格 排序
  # 值为 3    时：按照 装备类型 排序
  # 值为 4    时：按照 武器、防具类型 排序
  # 值为 5    时：按照 武器评价 排序
  # 值为 6~13 时：按照 体力上限/魔力上限/物理攻击/物理防御/魔法攻击
  #                    /魔法防御/敏捷值/幸运值 排序
  # 其他值    时：按照 数据库ID 排序
  # 值为负数时，先按照其相反数进行排序，之后倒序排列

  COMPATIBLE = false

  # 入手顺序排序可能与其他装备相关的脚本之间存在不兼容问题，
  # 将此选项设置为 true 后，按入手顺序排序的功能将会关闭

#==============================================================================
# 设定结束
#==============================================================================
  module_function
  def [](id)
    case id
    when :item then $game_variables[VAR1]
    when :weapon then $game_variables[VAR2]
    when :armor then $game_variables[VAR3]
    else 0
    end
  end
  def sort_reverse(list, type)
    type < 0 ? list.reverse : list
  end
  def sort_item(list, type)
    case type.abs
    when 2 then list = list.sort_by {|item| [item.price, item.id] }
    end
    sort_reverse(list, type)
  end
  def sort_equip(list, type, armor=false)
    case type.abs
    when 2
      list = list.sort_by {|euqip| [euqip.price, euqip.id] }
    when 3
      list = list.sort_by {|euqip| [euqip.etype_id, euqip.id] }
    when 4
      list = list.sort_by do |euqip|
        [armors ? euqip.atype_id : euqip.wtype_id, euqip.id]
      end
    when 5
      list = list.sort_by {|euqip| [euqip.performance, euqip.id]}
    when 6,7,8,9,10,11,12,13
      list = list.sort_by {|euqip| [euqip.params[type - 6], euqip.id]}
    end
    sort_reverse(list, type)
  end
end
class Game_Party
  alias m5_20140807_items items
  alias m5_20140807_weapons weapons
  alias m5_20140807_armors armors
  def items
    type = M5IS20140807[:item]
    if (type == 1 || type == -1) && (!M5IS20140807::COMPATIBLE)
      list = @items.keys.collect {|id| $data_items[id] }
    else list = m5_20140807_items
    end
    M5IS20140807.sort_item(list, type)
  end
  def weapons
    type = M5IS20140807[:weapon]
    if (type == 1 || type == -1) && (!M5IS20140807::COMPATIBLE)
      list = @weapons.keys.collect {|id| $data_weapons[id] }
    else list = m5_20140807_weapons
    end
    M5IS20140807.sort_equip(list, type)
  end
  def armors
    type = M5IS20140807[:armor]
    if (type == 1 || type == -1) && (!M5IS20140807::COMPATIBLE)
      list = @armors.keys.collect {|id| $data_armors[id] }
    else list = m5_20140807_armors
    end
    M5IS20140807.sort_equip(list, type, true)
  end
end
