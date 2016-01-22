# 固定在地图特定坐标上的图片
# 用于在踩砖块事件中表示出已经踩过的砖块
# M5FS20160122.add(x, y, bitmap)

class Game_Map
  attr_accessor :m5_20160122_fix_sprite
  alias m5_20160122_setup setup
  def setup *args
    m5_20160122_setup *args
    @m5_20160122_fix_sprite = {queue: []}
  end
end
module M5FS20160122
  def self.add(x, y, bitmap, option = {})
    hash = { x: x, y: y, bitmap: bitmap, option: option }
    hash[:id] = hash.object_id
    $game_map.m5_20160122_fix_sprite[hash.object_id] = hash
    $game_map.m5_20160122_fix_sprite[:queue] << hash
    hash.object_id
  end
class S < Sprite
  def initialize(data, viewport = nil)
    @x, @y, @id, @option = data[:x], data[:y], data[:id], data[:option]
    super(viewport)
    self.z = 50
    case @option[:type]
    when 1, 2
      self.bitmap = Cache.character(data[:bitmap])
      index, direction = @option[:index], @option[:direction] - 2
      cw, ch = self.bitmap.width / 3, self.bitmap.height / 4
      if @option[:type] == 1
        cw /= 4; ch /= 2
      end
      pattern = 1
      sx = (index % 4 * 3 + pattern) * cw
      sy = (index / 4 * 4 + direction / 2) * ch
      self.src_rect.set(sx, sy, cw, ch)
    when 3
      self.bitmap = data[:bitmap]
      self.src_rect.set *@option[:rect] if @option[:rect]
    else
      self.bitmap = Bitmap.new(data[:bitmap])
      @option[:dispose] = true
    end
    update
  end
  def update
    super
    self.x = $game_map.adjust_x(@x) * 32
    self.y = $game_map.adjust_y(@y) * 32
    if !$game_map.m5_20160122_fix_sprite[@id]
      self.bitmap.dispose if self.bitmap && @option[:dispose]
      self.dispose
    end
  end
end
end # module M5FS20160122
class Spriteset_Map
  alias m5_20160122_update_characters update_characters
  def update_characters
    m5_20160122_update_characters
    $game_map.m5_20160122_fix_sprite[:queue].each do |data|
      s = M5FS20160122::S.new(data, @viewport1)
      @m5_20160122_fix_sprites << s
    end
    $game_map.m5_20160122_fix_sprite[:queue] = []
    @m5_20160122_fix_sprites.reject! do |s|
      s.update
      s.disposed?
    end
  end
  alias m5_20160122_create_characters create_characters
  def create_characters
    m5_20160122_create_characters
    @m5_20160122_fix_sprites = []
    $game_map.m5_20160122_fix_sprite.values.each do |data|
      next if data.is_a? Array # ignore :queue
      s = M5FS20160122::S.new(data, @viewport1)
      @m5_20160122_fix_sprites << s
    end
  end
  alias m5_20160122_dispose_characters dispose_characters
  def dispose_characters
    m5_20160122_dispose_characters
    @m5_20160122_fix_sprites.each {|sprite| sprite.dispose }
  end
end