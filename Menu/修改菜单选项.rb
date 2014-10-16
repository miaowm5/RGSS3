=begin
===============================================================================
  修改菜单选项 By喵呜喵5
===============================================================================

【说明】

  可以删除默认菜单中不需要的选项
  
  也可以设置当某个开关打开的时候指定的选项才出现在菜单中  
  
=end
$m5script ||= {};$m5script[:M5MC20140822] = 20140822
module M5MC20140822
#==============================================================================
#  设定部分
#==============================================================================
  
  SWI = [-1,0,1,0,-1]
  
  # 请按照[物品，技能，装备，状态，游戏结束]的顺序依次填写每个选项对应的出现条件
  # 小于零：出现
  # 等于零：不出现
  # 大于零：对应数字ID的开关打开时才出现  
  # （存档和整队功能可以使用事件页中的【允许存档】和【允许整队】控制是否出现）
  
  SAVE = true
  
  # 游戏开始时默认禁止存档，不需要的话设置为false  
  
  FORMATION = true
  
  # 游戏开始时默认禁止整队，不需要的话设置为false
  
#==============================================================================
#  设定结束
#==============================================================================
end
class Window_MenuCommand
  alias m5_20140822_make_command_list make_command_list
  def make_command_list
    m5_20140822_make_command_list    
    @list.delete_if do |command|
      !m5_20140822_judge_command(command[:symbol])
    end
  end
  def m5_20140822_judge_command(symbol)
    case symbol
    when :save      then return save_enabled
    when :formation then return formation_enabled
    end
    swi = M5MC20140822::SWI
    swi_id = case symbol
             when :item     then 0
             when :skill    then 1
             when :equip    then 2
             when :status   then 3
             when :game_end then 4
             else return true
             end
    return (swi[swi_id] < 0 || $game_switches[swi[swi_id]])
  end
end
class Game_System
  alias m5_20131108_initialize initialize
  def initialize
    m5_20131108_initialize
    @save_disabled = M5MC20140822::SAVE
    @formation_disabled = M5MC20140822::FORMATION
  end
end
