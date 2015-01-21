=begin
===============================================================================
  行走图帧数增加 By喵呜喵5
===============================================================================

【说明】

  RMVA自带的行走图只支持三个动作（立正、迈左脚、迈右脚）

  插入这个脚本可以使用包括RMXP四个动作行走图在内的多帧行走图

  在需要使用的特殊行走图文件名中写上 [frame动作数] 即可

  例如，在RMVA中使用RMXP行走图时，在行走图文件名开头加上 $[frame4]

  请注意：

    行走图仅在实际游戏中变更，编辑器中的行走图无法正常显示

    行走图的默认动作固定为每一行的正中间那个动作，在事件页中设置的默认动作将失效

=end
$m5script ||= {};$m5script[:M5CP20150121] = 20150121
class Game_CharacterBase
  attr_accessor :m5_20150121_pattern
  alias m5_20150121_update_anime_pattern update_anime_pattern
  def update_anime_pattern
    return m5_20150121_update_anime_pattern unless @m5_20150121_pattern
    if !@step_anime && @stop_count > 0
      @m5_20150121_pattern[1] = @m5_20150121_pattern[0] / 2
    else
      @m5_20150121_pattern[1] += 1
      @m5_20150121_pattern[1] %= @m5_20150121_pattern[0]
    end
  end
  alias m5_20150121_update_stop update_stop
  def update_stop
    m5_20150121_update_stop
    return if @step_anime || !@m5_20150121_pattern
    @m5_20150121_pattern[1] = @m5_20150121_pattern[0] / 2
  end
  alias m5_20150121_straighten straighten
  def straighten
    m5_20150121_straighten
    return unless @m5_20150121_pattern
    @m5_20150121_pattern[1] = @m5_20150121_pattern[0] / 2
  end
end
class Sprite_Character
  alias m5_20150121_update_src_rect update_src_rect
  def update_src_rect
    return m5_20150121_update_src_rect unless @tile_id == 0
    return m5_20150121_update_src_rect unless @character.m5_20150121_pattern
    index = @character.character_index
    frame = @character.m5_20150121_pattern[0]
    pattern = @character.m5_20150121_pattern[1]
    sx = (index % 4 * frame + pattern) * @cw
    sy = (index / 4 * 4 + (@character.direction - 2) / 2) * @ch
    self.src_rect.set(sx, sy, @cw, @ch)
  end
  alias m5_20150121_set_character_bitmap set_character_bitmap
  def set_character_bitmap
    @character.m5_20150121_pattern = nil
    m5_20150121_set_character_bitmap
    frame = /^.*\[frame(\S+)\].*$/ =~ @character_name ? $1.to_i : nil
    return unless frame
    @character.m5_20150121_pattern = [frame , frame/2]
    @cw = bitmap.width / frame
    sign = @character_name[/^[\!\$]./]
    @cw /= 4 unless sign && sign.include?('$')
    self.ox = @cw / 2
  end
end
