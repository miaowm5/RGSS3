=begin
===============================================================================
  边框 By喵呜喵5
===============================================================================

  【说明】

  在游戏画面中显示一个平时不会被消除的边框
  边框文件放在“Graphics/system/”文件夹下，命名为Frame

  如果只是需要在地图画面上显示边框的话……请删掉这个脚本，直接用显示图片指令

=end
$m5script ||= {}; raise("需要喵呜喵5基础脚本的支持") unless $m5script[:M5Base]
$m5script[:M5Fog20150519] = 20150519; M5script.version(20150224)
module M5Fog20150519
#==============================================================================
#  设定部分
#==============================================================================

  SCENE = [Scene_Battle,Scene_Debug]

  #在上面设置不需要显示边框的场景
  #默认的设置是战斗画面以及调试窗口不会显示边框

  SWI = 1

  #当这个开关打开的时候，不显示边框

  Z = 500

  #修改这个数值调整边框的高度，数值越大边框能遮住的东西越多

#==============================================================================
#  设定结束
#==============================================================================
class Plane_Fog < Plane
end
class Spriteset_Fog < Spriteset_M5
  def initialize
    @fog = Plane_Fog.new
    @fog.bitmap = Cache.system("Frame")
    @fog.z = Z
    update
  end
  def update
    super
    @fog.visible = !$game_switches[SWI]
  end
  def dispose
    super
    @fog.dispose
  end
end
end
class Scene_Base
  alias m5_20131205_start start
  def start
    m5_20131205_start
    if !M5Fog20150519::SCENE.include?(self.class)
      @m5_20150519_fog = M5Fog20150519::Spriteset_Fog.new
    end
  end
end