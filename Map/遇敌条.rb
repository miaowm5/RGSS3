=begin
===============================================================================
  遇敌条 By喵呜喵5
===============================================================================

【说明】

  在地图上显示一个遇敌条

=end
$m5script ||= {};$m5script[:M5EW20150129] = 20150129
module M5EW20150129
#==============================================================================
# 设定部分
#==============================================================================

  X = 0

  Y = 0

  WIDTH = 120

  HEIGHT = 50

  # 设置遇敌条的X坐标、Y坐标、宽、高

  BACK = false

  # 设置为true时，遇敌条不显示窗口

  REVERSE = false

  # 设置为true时，遇敌条的显示方式变为随步数下降

  HIDE = false

  # 设置为true时，当开启禁用遇敌时隐藏遇敌条

  SWI = 0

  # 对应ID的开关打开时，隐藏遇敌条

#==============================================================================
# 设定结束
#==============================================================================
end
class Game_Player; attr_accessor :encounter_count; end
class Scene_Map
  alias m5_20150129_create_all_windows create_all_windows
  def create_all_windows
    m5_20150129_create_all_windows
    @m5_20150129_ew = Window_Base.new(M5EW20150129::X,M5EW20150129::Y,
      M5EW20150129::WIDTH,M5EW20150129::HEIGHT)
    @m5_20150129_ew.opacity = 0 if M5EW20150129::BACK
    class << @m5_20150129_ew
      include M5EW20150129
      def can_encounter?
        return false if $game_system.encounter_disabled
        $game_map.encounter_list.each do |encounter|
          next unless $game_player.encounter_ok?(encounter)
          return true
        end
        false
      end
      def update
        super
        self.visible = !$game_switches[SWI]
        self.visible = self.visible && can_encounter? if HIDE
        return unless self.visible
        rate = $game_player.encounter_count
        rate /= ($game_map.encounter_step * 2 + 1).to_f
        rate = 1.0 unless can_encounter?
        return if @rate && @rate == rate
        @rate = rate
        refresh
      end
      def refresh
        contents.clear
        draw_gauge(0, -5, contents.width,
          REVERSE ? @rate : 1.0 - @rate, hp_gauge_color1, hp_gauge_color2)
      end
    end
  end
end