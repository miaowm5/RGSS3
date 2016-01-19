=begin
===============================================================================
  死亡时行走图改变 By喵呜喵5
===============================================================================

【说明】

  （※ 这个脚本需要同时插入 喵呜喵5基础脚本 后才能使用）

  角色死亡的时候行走图发生改变。

  默认情况下领队即使死亡行走图也不会变。（否则一具棺材拖着一群人到处走……）

  在角色的备注中加入：

    <领队尸体 行走图的文件名>

    <领队尸体编号 行走图的编号>

  可以设置角色作为领队死亡时改变的行走图。

  在角色的备注中加入：

    <跟随尸体 行走图的文件名>

    <跟随尸体编号 行走图的编号>

  可以设置角色作为跟随角色死亡时改变的行走图。

=end
$m5script ||= {}; raise("需要喵呜喵5基础脚本的支持") unless $m5script[:M5Base]
$m5script[:M5DC20140731] = 20160119; M5script.version(20151221)
module M5DC20140731
#==============================================================================
# 设定部分
#==============================================================================

  CHARACTER = "$Coffin"

  # 跟随角色死亡时默认的行走图文件名，设置为 nil 则默认不显示死亡行走图

  CHARACTER_ID = 0

  # 跟随角色死亡时默认的行走图编号

#==============================================================================
# 设定部分
#==============================================================================
  def self.data(player, actor)
    player ? actor.m5_20160119_leader : actor.m5_20160119_follower
  end
end
class RPG::Actor
  def m5_20160119_leader
    [m5note("领队尸体"), m5note("领队尸体编号",0).to_i]
  end
  def m5_20160119_follower
    [m5note("跟随尸体", M5DC20140731::CHARACTER),
      m5note("跟随尸体编号",M5DC20140731::CHARACTER_ID).to_i]
  end
end
class Game_Character
  def m5_20160119_refresh_character
    @m5_20160119_dead = actor.dead?
    return unless actor.dead?
    data = M5DC20140731.data(self.is_a?(Game_Player), actor.actor)
    return unless data[0]
    @character_name, @character_index = *data
  end
end
class Game_Player
  alias m5_20140721_update update
  def update
    m5_20140721_update
    return unless actor && @m5_20160119_dead != actor.dead?
    refresh
  end
  alias m5_20140721_refresh refresh
  def refresh
    m5_20140721_refresh
    return unless actor
    m5_20160119_refresh_character
  end
end
class Game_Follower
  alias m5_20140721_update update
  def update
    m5_20140721_update
    return unless visible? && @m5_20160119_dead != actor.dead?
    refresh
  end
  alias m5_20140721_refresh refresh
  def refresh
    m5_20140721_refresh
    return unless visible?
    m5_20160119_refresh_character
  end
end