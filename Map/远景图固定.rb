=begin
===============================================================================
  远景图固定 By喵呜喵5
===============================================================================

【说明】

  将远景图固定在地图上，不论玩家如何移动都不会与其他图块之间产生错位

=end
$m5script ||= {};$m5script[:M5FP20141221] = 20141221
module M5FP20141221
#==============================================================================
#  设定部分
#==============================================================================

  SWI = 1

  # 当对应ID的开关打开时，使用默认的方式显示远景图

#==============================================================================
#  设定结束
#==============================================================================
end
class Spriteset_Map
  alias m5_20141221_update_parallax update_parallax
  def update_parallax
    m5_20141221_update_parallax
    return if $game_switches[M5FP20141221::SWI]
    @parallax.ox = @tilemap.ox
    @parallax.oy = @tilemap.oy
  end
end