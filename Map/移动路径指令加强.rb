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
      wait_random(等待的最长时间,等待的最短时间)
    可以让事件移动过程中随机等待指定的帧数

  3.滚个球
    在移动路线中输入脚本：
      rolling_up
      rolling_left
      rolling_right
      rolling_down
    事件将会分别向对应的方向（上、左、右、下）移动999步，移动过程中碰到障碍物会停止移动
    用这个功能可以实现类似踢足球的效果

  4.淡入淡出
    在移动路线中输入脚本：
      fade_out(淡出时间)
      fade_in(淡入时间)
    角色将会依照指定的时间执行淡入、淡出的效果

=end
#==============================================================================
#  脚本部分
#==============================================================================
class Game_Character < Game_CharacterBase
  def wait_random(time = 250,min = 0)
    @wait_count = [rand(time),min].max
  end
  alias m5_20140611_move_random move_random
  def move_random
    list = [
    "turn_random","m5_20140611_move_random","wait_random(120,30)"
    ]
    eval(list.sample)
  end
  def rolling_up
    m5_rolling(4)
  end
  def rolling_left
    m5_rolling(2)
  end
  def rolling_right
    m5_rolling(3)
  end
  def rolling_down
    m5_rolling(1)
  end
  def m5_rolling(direction)
    save_route_command
    push_route_command(999,RPG::MoveCommand.new(direction))
    @rolling = true
  end
  def push_route_command(t,*command)
    command.reverse!
    t.times {|i|
      command.each {|c| @move_route.list.insert(@move_route_index+1,c)}
    }
  end
  def save_route_command
    @m5_temp_route = @move_route.list.clone
    @special_route = true
  end
  def fade_out(terminate = 10)
    save_route_command
    push_route_command(1,RPG::MoveCommand.new(42,[0]))
    terminate.times { |i|
      opacity = ((i+1) * @opacity / terminate.to_f).to_i
      push_route_command(1,
        RPG::MoveCommand.new(42,[opacity]),
        RPG::MoveCommand.new(15,[5]))
      }
  end
  def fade_in(terminate = 10)
    save_route_command
    push_route_command(1,RPG::MoveCommand.new(42,[255]))
    terminate.times { |i|
      opacity = (255 - (i+1) * (255 - @opacity) / terminate.to_f).to_i
      push_route_command(1,
        RPG::MoveCommand.new(42,[opacity]),
        RPG::MoveCommand.new(15,[5]))
      }
  end
  alias m5_20140610_force_move_route force_move_route
  def force_move_route(move_route)
    process_route_end if @special_route
    m5_20140610_force_move_route(move_route)
  end
  alias m5_20140607_advance_move_route_index advance_move_route_index
  def advance_move_route_index
    m5_20140607_advance_move_route_index
    process_route_end if (!@move_succeed && @rolling)
  end
  alias m5_20140607_process_route_end process_route_end
  def process_route_end
    @rolling = false
    if @special_route
      @move_route.list = @m5_temp_route.clone
      @special_route = false
    end
    m5_20140607_process_route_end
  end
end
#==============================================================================
#  脚本结束
#==============================================================================