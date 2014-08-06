=begin
===============================================================================
  死亡时行走图改变 By喵呜喵5
===============================================================================

【说明】

  （※ 这个脚本需要同时插入 喵呜喵5基础脚本 后才能使用）

  角色死亡的时候行走图发生改变。
  
  默认情况下领队即使死亡行走图也不会变。（否则一具棺材拖着一群人到处走www）
  
  在角色的备注中加入：
  
    <领队尸体 行走图的文件名>
  
    <领队尸体编号 行走图的编号>
  
  可以设置角色作为领队死亡时改变的行走图。
  
  在角色的备注中加入：
  
    <跟随尸体 行走图的文件名>
  
    <跟随尸体编号 行走图的编号>
  
  可以设置角色作为跟随角色死亡时改变的行走图。
  
=end
$m5script ||= {};raise("需要喵呜喵5基础脚本的支持") unless $m5script["M5Base"]
$m5script["M5DC20140731"] = 20140731;M5script.version(20140731)
module M5DC20140731
#==============================================================================
# 设定部分
#==============================================================================
  
  CHARACTER = "$Coffin"
  
  # 跟随角色死亡时默认的行走图文件名
  
  CHARACTER_ID = 0
  
  # 跟随角色死亡时默认的行走图编号

#==============================================================================
# 设定部分
#==============================================================================
end
class RPG::BaseItem
  def m5le_dead;    return m5note("领队尸体").to_s; end
  def m5le_dead_id; return m5note("领队尸体编号",0).to_i; end
  def m5fo_dead;    return m5note("跟随尸体").to_s; end
  def m5fo_dead_id; return m5note("跟随尸体编号",0).to_i; end
end
class Game_Player
  alias m5_20140721_update update
  def update
    m5_20140721_update
    return unless actor
    refresh if @m5_dead != actor.dead?
  end
  alias m5_20140721_refresh refresh
  def refresh    
    if actor && actor.dead?
      if $data_actors[actor.id].m5le_dead
        @character_name = $data_actors[actor.id].m5le_dead
        @character_index = $data_actors[actor.id].m5le_dead_id
        @followers.refresh
      else
        m5_20140721_refresh
      end
    else
      m5_20140721_refresh
    end
    @m5_dead = actor.dead? if actor
  end
end
class Game_Follower
  alias m5_20140721_update update
  def update
    m5_20140721_update
    return unless actor
    refresh if @m5_dead != actor.dead?
  end
  alias m5_20140721_refresh refresh
  def refresh
    if actor && actor.dead?
      if $data_actors[actor.id].m5fo_dead
        @character_name = visible? ? $data_actors[actor.id].m5fo_dead : ""
        @character_index = visible? ? $data_actors[actor.id].m5fo_dead_id : 0
      else
        @character_name = visible? ? M5DC20140731::CHARACTER : ""
        @character_index = visible? ? M5DC20140731::CHARACTER_ID : 0
      end
    else
      m5_20140721_refresh      
    end
    @m5_dead = actor.dead? if actor
  end
end
