=begin
===============================================================================
  菜单子界面不隐藏选项窗口 By喵呜喵5
===============================================================================

【说明】

  状态/装备/技能这些菜单中的子界面不隐藏菜单中的选项窗口

  具体来说的话，这个脚本是为了应对下面这种情况所以才写的：
  http://rm.66rpg.com/thread-374019-1-1.html

  请注意，这个脚本只适用于菜单的子界面，
  若通过子界面打开的新的子界面也被设置为不隐藏选项窗口时画面将出现异常

=end
$m5script ||= {}; $m5script[:M5MCS20141125] = 20151221
module M5MCS20141125
#==============================================================================
# 设定部分
#==============================================================================

  SCENE = [
    Scene_Skill,  # 技能界面
    Scene_Equip,  # 装备界面
    Scene_Status, # 状态界面
    Scene_Item,   # 物品界面
    Scene_Save,   # 存档界面
    Scene_End,    # 结束界面
  ]

  # 设置不隐藏指令窗口的界面，
  # 如果某个界面不需要的话把对应的那一行删除就好了
  # 不知道意思的话，不建议随意修改

#==============================================================================
# 设定结束
#==============================================================================
  def self.snapshot
    @background_bitmap.dispose if @background_bitmap
    @background_bitmap = Graphics.snap_to_bitmap
  end
  def self.background; @background_bitmap; end
end
class Scene_MenuBase
  alias m5_20141125_create_background create_background
  def create_background
    m5_20141125_create_background
    M5MCS20141125::SCENE.each do |scene|
      next unless SceneManager.scene_is?(scene)
      @background_sprite.bitmap = M5MCS20141125.background
      break
    end
  end
end
class Scene_Menu
  alias m5_20141125_pre_terminate pre_terminate
  def pre_terminate
    M5MCS20141125.snapshot
    m5_20141125_pre_terminate
  end
end