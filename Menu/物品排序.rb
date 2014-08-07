=begin
===============================================================================
  物品排序 By喵呜喵5
===============================================================================

【说明】

  修改对应变量的值时，在菜单中查看物品可以按照某种顺序排序
  
  唯一的问题是，除了数据库ID外……物品还真没啥好排序的 = =
  
  有时间的话加一个按照指定备注排序算了 = =
    
=end
$m5script ||= {};$m5script["M5IS20140807"] = 20140807
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
  
#==============================================================================
# 设定结束
#==============================================================================
end
class Game_Party
  alias m5_20140807_items items
  alias m5_20140807_weapons weapons
  alias m5_20140807_armors armors  
  def m5_20140807_list_reverse(list,type)
    list.reverse! if type < 0
    return list
  end
  def items
    type = $game_variables[M5IS20140807::VAR1]
    case type
    when 1,-1
      m5_20140807_items
      list = @items.keys.collect {|id| $data_items[id] }
      return m5_20140807_list_reverse(list,type)
    when 2,-2      
      list = m5_20140807_items.sort_by {|item| [item.price, item.id] }
      return m5_20140807_list_reverse(list,type)
    else return m5_20140807_list_reverse(m5_20140807_items,type)
    end
  end
  def m5_20140807_sort_equip(type,list,list_sort,data,armors = false)
    case type
    when 1 
      list = list.keys.collect {|id| data[id] }
      return m5_20140807_list_reverse(list,type)
    when 2
      list = list_sort.sort_by {|euqip| [euqip.price, euqip.id] }
      return m5_20140807_list_reverse(list,type)
    when 3
      list = list_sort.sort_by {|euqip| [euqip.etype_id, euqip.id] }
      return m5_20140807_list_reverse(list,type)
    when 4
      list = list_sort.sort_by {|euqip| 
        [armors ? euqip.atype_id : euqip.wtype_id, euqip.id] }
      return m5_20140807_list_reverse(list,type)
    when 5
      list = list_sort.sort_by {|euqip| [euqip.performance, euqip.id]}
      return m5_20140807_list_reverse(list,type)
    when 6,7,8,9,10,11,12,13
      list = list_sort.sort_by {|euqip| [euqip.params[type - 6], euqip.id]}      
      return m5_20140807_list_reverse(list,type)
    else
      return m5_20140807_list_reverse(list_sort,type)
    end
  end
  def weapons
    case $game_variables[M5IS20140807::VAR2]
    when 0
      return m5_20140807_weapons
    else
      m5_20140807_sort_equip($game_variables[M5IS20140807::VAR2],
        @weapons,m5_20140807_weapons,$data_weapons)
    end
  end  
  def armors
    case $game_variables[M5IS20140807::VAR3]
    when 0
      return m5_20140807_armors
    else
      m5_20140807_sort_equip($game_variables[M5IS20140807::VAR3],
        @armors,m5_20140807_armors,$data_armors,true)
    end
  end
end
