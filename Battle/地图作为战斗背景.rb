=begin
===============================================================================
  地图作为战斗背景 By喵呜喵5
===============================================================================

  【说明】

  使用地图作为战斗背景

=end
$m5script ||= {}; $m5script[:M5BB20150211] = 20151221
module M5BB20150211
#==============================================================================
#  设定部分
#==============================================================================

  ID = 1

  # 对应ID的开关打开时，使用原本的战斗背景

  AUTO = true

  # 设置为 true 时，
  # 若已经设置了战斗背景且战斗背景文件名不为“无”，则使用设置的战斗背景

  # 设置为 false 时，始终使用地图作为战斗背景

  BLUR = true

  # 战斗背景是否模糊，true：模糊，false：不模糊

  TONE = [0,0,0,0]

  # 战斗背景的色调，四个数字分别代表R、G、B、灰度

  COLOR = [0,0,0,70]

  # 战斗背景的颜色，四个数字分别代表R、G、B、Alpha

  ZOOM = 1

  # 战斗背景的放大倍数

#==============================================================================
#  设定结束
#==============================================================================
  def self.snapshot
    @background_bitmap.dispose if @background_bitmap
    @background_bitmap = Graphics.snap_to_bitmap
  end
  def self.background; @background_bitmap; end
end
class Scene_Map
  alias m5_20151221_pre_battle_scene pre_battle_scene
  def pre_battle_scene
    m5_20151221_pre_battle_scene
    M5BB20150211.snapshot
  end
end
class Spriteset_Battle
  alias m5_20150211_create_battleback1 create_battleback1
  def create_battleback1
    m5_20150211_create_battleback1
    return if $game_switches[M5BB20150211::ID]
    if M5BB20150211::AUTO
      return if battleback1_name && battleback1_name != ""
      return if battleback2_name && battleback2_name != ""
    end
    source = M5BB20150211::BLUR ? SceneManager.background_bitmap :
      M5BB20150211.background
    @back1_sprite.bitmap.dispose
    bitmap = Bitmap.new(Graphics.width, Graphics.height)
    bitmap.stretch_blt(bitmap.rect, source, source.rect)
    @back1_sprite.bitmap = bitmap
    @back1_sprite.zoom_x = M5BB20150211::ZOOM
    @back1_sprite.zoom_y = M5BB20150211::ZOOM
    @back1_sprite.tone.set(Tone.new *M5BB20150211::TONE)
    @back1_sprite.color.set(Color.new *M5BB20150211::COLOR)
    center_sprite(@back1_sprite)
  end
end