=begin
===============================================================================
  足音 By喵呜喵5
===============================================================================

【说明】

  事件或者主角行走时播放脚步声

  脚步声的音效文件名为角色行走图的文件名，放在 Audio/SE 目录下

  由于 RM 自身的限制，脚步声音效建议使用 ogg 格式

=end
$m5script ||= {};$m5script["M5SS20140821"] = 20241021
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

  DIR = 'Audio/SE/'

  # 脚步声文件所在的目录

#==============================================================================
# 设定结束
#==============================================================================
  class Cache
    def initialize; init_data; end
    def init_data
      @se = ''
      @character_name = ''
      @ignore = nil
    end
    def get(character, name)
      if @ignore.nil?
        @ignore = !M5SS20140821::ACTOR if character.is_a?(Game_Player)
        @ignore = !M5SS20140821::FOLLOWER if character.is_a?(Game_Follower)
        @ignore = !M5SS20140821::EVENT if character.is_a?(Game_Event)
      end
      return nil if @ignore
      if @character_name != name
        se = !Dir.glob("#{M5SS20140821::DIR}#{name}.*").empty? ? name : M5SS20140821::DEFAULT
        se = nil if !se || se == ""
        @character_name = name
        @se = se
      end
      return @se
    end
    def marshal_dump; nil; end
    def marshal_load(obj); init_data; end
  end
end
class Game_CharacterBase
  alias m5_20140821_increase_steps increase_steps
  def increase_steps
    m5_20140821_increase_steps
    return if $game_switches[M5SS20140821::SWI]
    return if @character_name == ""
    @m5_20241021_sound_cache ||= M5SS20140821::Cache.new
    se = @m5_20241021_sound_cache.get(self, @character_name)
    Audio.se_play("#{M5SS20140821::DIR}#{se}",80,100) if se
  end
end
