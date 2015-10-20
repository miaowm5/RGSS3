=begin
===============================================================================
  物理伤害反弹 By喵呜喵5
===============================================================================

【说明】

  当满足条件时，角色原本应该发动的物理反击效果会变成物理反弹

  物理反弹效果和魔法反射效果相同，
  是指敌人攻击自己时，不仅无法攻击自己同时还会受到来自自己的攻击
  与物理反击效果下的主角攻击敌人不同，物理反弹效果是敌人自己攻击自己
  （即：用敌人的能力来攻击敌人自己，数据库伤害公式中的b全部被替换成a）

=end
$m5script ||= {}
$m5script[:M5Reflect20151020] = 20151020
module M5Reflect20151020
#==============================================================================
#  设定部分
#==============================================================================

  HINT = '%s反弹了物理伤害！'

  # 这里设置物理反弹时的提示文字
  # %s 表示对象的名字

  STATE = [10, 11, 12, 13]

  # 当角色处于上面数字对应ID的状态时，物理反击的效果变成物理反弹的效果

  WEAPON = [6, 12, 18, 24]

  # 当角色装备上面数字对应ID的武器时，物理反击的效果变成物理反弹的效果

  ARMOR = [15, 50]

  # 当角色装备面数字对应ID的防具时，物理反击的效果变成物理反弹的效果

  FORMULA = 'a.atk - a.def + (%s)'

  # 如果希望物理伤害反弹时伤害公式也发生改变的话，可以在这里设置新的公式
  # 公式的设置格式和数据库中的伤害公式相同，不过a、b指的都是受到攻击者
  # %s 表示原本的伤害公式
  # 不需要改变伤害公式的话，这里直接设置成 '%s' 即可

#==============================================================================
#  设定结束
#==============================================================================
  def self.check(actor)
    armor = actor.armors.collect {|armors| armors.id }
    return true unless (armor | ARMOR).size == armor.size + ARMOR.size
    state = actor.states.collect {|state| state.id }
    return true unless (state | STATE).size == state.size + STATE.size
    weapon = actor.weapons.collect {|weapons| weapons.id }
    return true unless (weapon | WEAPON).size == weapon.size + WEAPON.size
    false
  end
end
class Scene_Battle
  alias m5_20131123_invoke_counter_attack invoke_counter_attack
  def invoke_counter_attack(target, item)
    if M5Reflect20151020.check(target)
      m5 = M5Reflect20151020
      item = item.clone
      item.damage.formula = sprintf(m5::FORMULA, item.damage.formula)
      Sound.play_evasion
      @log_window.add_text sprintf(m5::HINT, target.name)
      @log_window.wait
      @log_window.back_one
      apply_item_effects(@subject, item)
    else
      m5_20131123_invoke_counter_attack(target, item)
    end
  end
end