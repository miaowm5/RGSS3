=begin
===============================================================================
  怪物死亡音效 By喵呜喵5
===============================================================================

【说明】

  在Audio文件夹下新建一个Enemy文件夹，里面放上怪物死亡时的音效，以 怪物的ID 命名
  怪物死亡的时候便会播放对应的音效
  
  如果文件不存在，则会播放默认音效
  
=end
$m5script ||= {};$m5script["M5ECS20140821"] = 20140821;
$m5script["ScriptData"] ||= {}
module M5ECS20140821
#==============================================================================
# 设定部分
#==============================================================================

  SWI = 1
  
  # 对应ID的开关打开时，脚本失效


#==============================================================================
#  脚本部分
#==============================================================================
end
class Game_Enemy
  alias m5_20140821_perform_collapse_effect perform_collapse_effect
  def perform_collapse_effect
    m5_20140821_judge_enemy_se unless $game_switches[M5ECS20140821::SWI]
    m5_20140821_perform_collapse_effect
  end
  def m5_20140821_judge_enemy_se
    sename = "Audio/Enemy/#{@enemy_id}"
    $m5script["ScriptData"]["M5ECS20140821"] = sename unless \
      Dir.glob(sename+ ".*").empty?
  end
end
class << Sound
  alias m5_20140821_play_enemy_collapse play_enemy_collapse
  alias m5_20140821_play_boss_collapse1 play_boss_collapse1
  def play_enemy_collapse
    m5_20140821_play_collapse(method(:m5_20140821_play_enemy_collapse))
  end  
  def play_boss_collapse1
    m5_20140821_play_collapse(method(:m5_20140821_play_boss_collapse1))    
  end  
  def m5_20140821_play_collapse(method)
    if $m5script["ScriptData"]["M5ECS20140821"]
      Audio.se_play($m5script["ScriptData"]["M5ECS20140821"],80,100)
      $m5script["ScriptData"]["M5ECS20140821"] = nil
    else
      method.call
    end
  end
end
