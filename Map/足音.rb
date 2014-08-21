=begin
===============================================================================
  足音 By喵呜喵5
===============================================================================

【说明】

  事件或者主角行走时播放脚步声
  
  脚步声的音效文件名为角色行走图的文件名，放在 Audio/SE 目录下
  
  由于RM自身的限制，脚步声音效建议使用 ogg 格式
  
=end
$m5script ||= {};$m5script["M5SS20140821"] = 20140821
module M5SS20140821
#==============================================================================
# 设定部分
#==============================================================================
  
  SWI = 1
  
  # 对应ID的开关打开时，不播放脚步声音效
  
  ACTOR = true
  
  # 设置为 false 时，不播放主角的脚步声
  
  FOLLOWER = true
  
  # 设置为 false 时，不播放跟随角色的脚步声
  
  EVENT = true
  
  # 设置为 false 时，不播放事件的脚步声
  
  DEFAULT  = nil
  
  # 当对应的脚步声文件不存在时播放的脚步声，需要用英文双引号括起来
  # 不需要的话，填写 nil
  
#==============================================================================
# 设定结束
#==============================================================================
end
class Game_CharacterBase
  alias m5_20140821_increase_steps increase_steps
  def increase_steps
    m5_20140821_increase_steps
    return if $game_switches[M5SS20140821::SWI]
    return if !M5SS20140821::ACTOR && self.is_a?(Game_Player)
    return if !M5SS20140821::FOLLOWER && self.is_a?(Game_Follower)
    return if !M5SS20140821::EVENT && self.is_a?(Game_Event)
    return if @character_name == ""
    se = @character_name    
    se = !Dir.glob("Audio/SE/#{se}.*").empty? ? se : M5SS20140821::DEFAULT
    return if !se || se == ""
    Audio.se_play("Audio/SE/#{se}",80,100)
  end
end
