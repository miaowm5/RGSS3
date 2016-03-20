=begin
===============================================================================
  能够遗忘技能的物品、技能 By喵呜喵5
===============================================================================

【说明】

  在物品/道具的备注中加入：

    <遗忘技能 1>

  使用时使用者就会遗忘1号技能

  加上

    <遗忘技能 1>
    <遗忘技能 2>

  使用时使用者就会遗忘1号和2号技能

  请注意，能够被遗忘的仅有学习到的技能，职业、角色、装备附加的技能无法遗忘

=end
$m5script ||= {};raise("需要喵呜喵5基础脚本的支持") unless $m5script[:M5Base]
$m5script[:M5FS20160320] = 20160320;M5script.version(20160320)
module M5FS20160320
#==============================================================================
# 设定部分
#==============================================================================

  VALID_LIMIT = false  # true / false

  # 设置为 true 的情况下，只有使用者掌握有需要遗忘的技能的时候才能使用该物品/道具
  # 否则如果该物品/技能没有其他效果（恢复HP、执行公共事件……）时将无法使用

#==============================================================================
# 脚本部分
#==============================================================================
end
class Game_Actor
  instance_methods(false).include?(:item_has_any_valid_effects?) ||
    (def item_has_any_valid_effects? *args; super; end)
  instance_methods(false).include?(:item_user_effect) ||
    (def item_user_effect *args; super; end)

  alias m5_20160320_valid? item_has_any_valid_effects?
  def item_has_any_valid_effects?(user, item)
    m5_20160320_valid?(user, item) && (return true)
    item.m5note('遗忘技能',{list: true}) do |id|
      return true unless M5FS20160320::VALID_LIMIT
      return true if skill_learn?($data_skills[id.to_i])
    end
    false
  end
  alias m5_20140329_item_user_effect item_user_effect
  def item_user_effect(user, item)
    v = item.m5note('遗忘技能',{list: true}){|id| forget_skill(id.to_i)}
    @result.success = !v.empty?
    m5_20140329_item_user_effect(user, item)
  end

end