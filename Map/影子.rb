=begin
===============================================================================
  影子 By喵呜喵5
===============================================================================

【说明】

  在人物、事件的脚底显示影子
  
  影子的素材直接使用了飞行船的素材
  
  如果不希望某个角色显示影子的话，在行走图文件名里写上(shadow)即可
  
=end
$m5script ||= {};$m5script[:M5Shadow20141206] = 20141206
module M5Shadow20141206
#==============================================================================
#  设定部分
#==============================================================================
  
  X = 0
  
  # 影子的X位置（相对角色）  

  Y = 5
  
  # 影子的Y位置（相对角色）
  
  OPACITY = -20
  
  # 影子的透明度（相对角色）

#==============================================================================
#  设定结束
#==============================================================================
class Sprite_Shadow < Sprite
  def initialize(viewport, character = nil)
    super(viewport)
    @character = character
    set_character_bitmap
    update
  end
  def set_character_bitmap
    self.bitmap = Cache.system("Shadow")
    self.ox = self.bitmap.width / 2
    self.oy = self.bitmap.height    
  end
  def update
    super
    update_visible
    return unless self.visible
    update_position
    update_other
  end
  def update_visible
    self.visible = judge_name
    self.visible = !@character.transparent if self.visible
  end
  def judge_name
    return false if @character.character_name == "" 
    return false if @character.character_name =~ /(shadow)/
    true
  end
  def update_position
    self.x = @character.screen_x + X
    self.y = @character.screen_y + Y
    self.z = @character.screen_z - 1
  end
  def update_other
    self.opacity = @character.opacity + OPACITY
    self.blend_type = @character.blend_type
    self.bush_depth = @character.bush_depth
  end
end
end # module M5Shadow20141206
class Spriteset_Map
  alias m5_20141206_create_characters create_characters
  def create_characters
    m5_20141206_create_characters
    @m5_20141206_character_shadow_sprites = []
    array = @m5_20141206_character_shadow_sprites    
    $game_map.events.values.each do |event|
      array.push M5Shadow20141206::Sprite_Shadow.new(@viewport1, event)
    end    
    $game_player.followers.reverse_each do |follower|
      array.push M5Shadow20141206::Sprite_Shadow.new(@viewport1, follower)
    end    
    array.push M5Shadow20141206::Sprite_Shadow.new(@viewport1, $game_player)
  end
  alias m5_20141206_update_characters update_characters
  def update_characters
    m5_20141206_update_characters
    @m5_20141206_character_shadow_sprites.each {|sprite| sprite.update }
  end
  alias m5_20141206_dispose_characters dispose_characters
  def dispose_characters
    m5_20141206_dispose_characters
    @m5_20141206_character_shadow_sprites.each {|sprite| sprite.dispose }
  end  
end
