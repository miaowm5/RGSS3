=begin
===============================================================================
  菜单子界面不隐藏选项窗口 By喵呜喵5
===============================================================================

【说明】

  状态/装备/技能这些菜单中的子界面不隐藏菜单中的选项窗口
  
  具体来说的话，这个脚本是为了应对下面这种情况所以才写的：
  http://rm.66rpg.com/thread-374019-1-1.html
  
=end
$m5script ||= {};$m5script[:M5MCS20141125] = 20141125
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
end
module SceneManager
  @m5_20141125_background_bitmap = nil
  class << self
    attr_reader :m5_20141125_background_bitmap
    def m5_20141125_snapshot_for_background
      @m5_20141125_background_bitmap.dispose if @m5_20141125_background_bitmap
      @m5_20141125_background_bitmap = Graphics.snap_to_bitmap
    end
  end
end
class Scene_MenuBase
  alias m5_20141125_create_background create_background
  def create_background
    m5_20141125_create_background    
    return unless m5_20141125_check_scene
    @m5_20141125_background = SceneManager.m5_20141125_background_bitmap.clone
    @background_sprite.bitmap = @m5_20141125_background
  end
  def m5_20141125_check_scene
    M5MCS20141125::SCENE.each do |scene|
      return true if SceneManager.scene_is?(scene)
    end
    false
  end
  alias m5_20141125_terminate terminate
  def terminate
    SceneManager.m5_20141125_snapshot_for_background    
    m5_20141125_terminate
    @m5_20141125_background.dispose if @m5_20141125_background
  end
end
