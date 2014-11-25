=begin
===============================================================================
  状态、装备、技能界面不隐藏选项菜单 By喵呜喵5
===============================================================================

【说明】

  状态/装备/技能界面不隐藏菜单中的指令窗口
  
  具体来说的话，这个脚本是为了应对下面这种情况所以才写的：
  http://rm.66rpg.com/thread-374019-1-1.html
  
=end
$m5script ||= {};$m5script[:M5MS20141125] = 20141125
#==============================================================================
# 脚本部分
#==============================================================================
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
class Scene_Menu
  alias m5_20141125_terminate terminate
  def terminate
    SceneManager.m5_20141125_snapshot_for_background
    m5_20141125_terminate
  end
end
class Scene_Skill
  alias m5_20141125_create_background create_background
  def create_background
    m5_20141125_create_background
    @background_sprite.bitmap = SceneManager.m5_20141125_background_bitmap
  end
end
class Scene_Equip
  alias m5_20141125_create_background create_background
  def create_background
    m5_20141125_create_background
    @background_sprite.bitmap = SceneManager.m5_20141125_background_bitmap
  end
end
class Scene_Status
  alias m5_20141125_create_background create_background
  def create_background
    m5_20141125_create_background    
    @background_sprite.bitmap = SceneManager.m5_20141125_background_bitmap
  end
end
