=begin
===============================================================================
  移动路径指令加强 By喵呜喵5
===============================================================================

【说明】

  修改了默认事件移动路径指令中的一些指令增加了一些新的功能

  1.随机移动增强
    移动路径设置为随机移动的角色将会执行下面几个操作中的一个：
      随机移动一步、随机停止移动一段时间、随机转换方向
    角色的随机移动看起来将变得更加随机

  2.随机等待时间
    在移动路线中输入脚本：
      @m5_20160114_control.wait(等待的最长时间,等待的最短时间)
    可以让事件移动过程中随机等待指定的帧数

  ※ 以下功能请通过事件指令的设置移动路径指令设置，
     不要设置到角色的移动路径 - 自定义中：

  3.滚个球
    在移动路线中输入脚本：
      @m5_20160114_control.rolling_up
      @m5_20160114_control.rolling_left
      @m5_20160114_control.rolling_right
      @m5_20160114_control.rolling_down
    事件将会分别向对应的方向（上、左、右、下）移动999步，
    移动过程中碰到障碍物会停止移动
    用这个功能可以实现类似踢足球的效果

  4.淡入淡出
    在移动路线中输入脚本：
      @m5_20160114_control.fade_out(淡出时间)
      @m5_20160114_control.fade_in(淡入时间)
    角色将会依照指定的时间执行淡入、淡出的效果

=end
#==============================================================================
#  脚本部分
#==============================================================================
$m5script ||= {}; $m5script[:M5MC20160114] = 20160114
module M5MC20160114; class Control
  attr_accessor :move_route
  attr_accessor :move_route_index
  def initialize(character)
    @character = character
    @current_command = nil
    @move_route = nil
    @move_route_index = 0
  end

  def wait(time = 250,min = 0)
    time = [rand(time), min].max
    command = RPG::MoveCommand.new(Game_Character::ROUTE_WAIT, [time + 1])
    @character.process_move_command(command)
  end

  def rolling_up;    rolling(Game_Character::ROUTE_MOVE_UP); end
  def rolling_left;  rolling(Game_Character::ROUTE_MOVE_LEFT); end
  def rolling_right; rolling(Game_Character::ROUTE_MOVE_RIGHT); end
  def rolling_down;  rolling(Game_Character::ROUTE_MOVE_DOWN); end
  def rolling(command_code)
    list = Array.new(999) {|i| RPG::MoveCommand.new(command_code)}
    set_move_command(:rolling, list)
  end

  def fade_in(time)
    opacity = @character.opacity
    code = Game_Character::ROUTE_CHANGE_OPACITY
    amount = (255.0 - opacity) / time
    list = Array.new(time) do |i|
      value = opacity + amount * (i + 1)
      RPG::MoveCommand.new(code, [value.to_i])
    end
    set_move_command(:fade_in, list)
  end
  def fade_out(time)
    opacity = @character.opacity
    code = Game_Character::ROUTE_CHANGE_OPACITY
    amount = (opacity) / time
    list = Array.new(time) do |i|
      value = opacity - amount * (i + 1)
      RPG::MoveCommand.new(code, [value.to_i])
    end
    set_move_command(:fade_out, list)
  end

  def set_move_command(name, list)
    @move_route || @character.m5_20160114_memorize_move_route
    @current_command = name
    route = RPG::MoveRoute.new
    route.repeat = false
    route.list = list
    route.list.push RPG::MoveCommand.new(Game_Character::ROUTE_END)
    @character.m5_20160114_set_move_route(route)
  end
  def process_route_end
    @move_route || return
    @character.m5_20160114_restore_move_route
    @current_command = nil
  end
  def move_route_fail(index)
    case @current_command
    when :rolling then process_route_end
    end
  end
end; end
class Game_Character
  alias m5_20160114_init_private_members init_private_members
  def init_private_members
    m5_20160114_init_private_members
    @m5_20160114_control = M5MC20160114::Control.new(self)
  end
  def m5_20160114_memorize_move_route
    @m5_20160114_control.move_route = @move_route
    @m5_20160114_control.move_route_index = @move_route_index
  end
  def m5_20160114_restore_move_route
    @move_route = @m5_20160114_control.move_route
    @move_route_index = @m5_20160114_control.move_route_index
    @move_route_index += 1
    @m5_20160114_control.move_route = nil
  end
  def m5_20160114_set_move_route(route)
    @move_route = route
    @move_route_index = 0
  end

  alias m5_20140607_process_route_end process_route_end
  def process_route_end
    @m5_20160114_control.process_route_end
    m5_20140607_process_route_end
  end
  alias m5_20140610_force_move_route force_move_route
  def force_move_route(move_route)
    @m5_20160114_control.process_route_end
    m5_20140610_force_move_route(move_route)
  end
  alias m5_20140607_advance_move_route_index advance_move_route_index
  def advance_move_route_index
    @move_succeed || @m5_20160114_control.move_route_fail(@move_route_index)
    m5_20140607_advance_move_route_index
  end

  alias m5_20140611_move_random move_random
  def move_random
    command = rand(3)
    case command
    when 0 then turn_random
    when 1 then m5_20140611_move_random
    when 2 then @m5_20160114_control.wait(120,30)
    end
  end

end