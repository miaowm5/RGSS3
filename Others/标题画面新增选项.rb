=begin
===============================================================================
  标题画面新增选项 By喵呜喵5
===============================================================================

  【说明】

  在标题画面增加新的选项

  玩家选择了这个选项后可以从另外一张地图开始新游戏
  在这张新地图上可以用事件指令之类的东西做出类似CG欣赏之类的功能

=end
$m5script ||= {};$m5script[:M5NTC20140811] = 20150319
module M5NTC20140811
  COMMAND = [
#==============================================================================
#  设定部分
#==============================================================================

  {
    :text  => "末尾的选项",
    :map   => 1,
    :x     => 0,
    :y     => 0,
    :opt   => true,
  },
  {
    :text  => "开头的选项",
    :x     => 10,
    :ext   => 1,
    :pos   => 0,
  },
  {
    :text  => "中间的选项",
    :x     => 20,
    :ext   => 2,
    :show  => true,
    :pos   => 2,
  },

  # 在这上方追加新的选项，一条设置对应一个显示在标题画面的选项
  # 设置格式为 :
  #   {
  #     要设置的属性 => 设置的内容,
  #   },
  #
  #（不要忘记前后的中括号以及中间和结尾的英文冒号、英文逗号）
  #
  # 可以设置的属性如下（未设置的属性将使用 F9 数据库中默认的设置）：
  #
  # :text  设置选项在菜单中的名称（前后加上英文引号）
  # :pos   设置这个选项出现在选项窗口中的位置
  #
  # :map   设置选择这个选项后移动到的地图ID
  # :x     设置选择这个选项后移到到对应地图的X坐标
  # :y     设置选择这个选项后移到到对应地图的Y坐标
  # :opt   设置选择这个选项后移到到对应地图时是否透明，true 为透明，false 为不透明
  #
  # :ext   设置选项是否显示的标志，请参考下方的详细说明
  # :show  填写 true 时，显示无法选择的选项，搭配上方的 ext 共同使用
  #
  # ===========================================================================
  #
  # 【关于选项是否显示标志的详细说明】
  #
  # 这个功能需要搭配我的全局变量脚本共同使用，可以实现类似通关后出现新选项的效果
  #
  # 下面以通关后出现 “观看CG” 选项为例：
  # 首先插入我的全局变量脚本，脚本的位置应该放在本脚本之上
  # 在设定部分新增一个跳转到执行“观看CG”地图的选项
  # 设置观看CG选项里 ext 的值，例如：
  #   ext : 233,
  #
  # 当游戏通关的时候在事件的脚本中执行下面的代码
  #   m5_20140811_ntc(233)
  # 之后，再次打开游戏时标题画面中就会出现“观看CG”的选项了
  #
  # 如果希望删除已经出现的“观看CG”这个选项的话，在事件的脚本中执行下面的代码
  #   m5_20140811_ntc(233,false)
  # 观看CG的选项便再次被消除了
  #
  # 如果观看CG这个选项还增加了下面的设置
  #   show : true,
  # 在游戏通关前标题画面也会显示这个选项，但是玩家无法选择

#==============================================================================
#  设定结束
#==============================================================================
  ]
end
class Window_TitleCommand
  alias m5_20140206_make_command_list make_command_list
  def make_command_list
    m5_20140206_make_command_list
    base = $m5script[:M5GV20140811]
    ext = (base && base >= 20140811) ? M5GV20140811.get_ext : {}
    ext = ext[:M5NTC20140811] || {}
    M5NTC20140811::COMMAND.each do |c|
      if c[:ext]
        enable = ext[ c[:ext] ]
        ( next unless c[:show] ) if !enable
      else
        enable = true
      end
      @list.insert( c[:pos] || -1 ,
      {
        :name => c[:text], :symbol => :m520140811ntc,
        :ext => c, :enabled => enable
      })
    end
    @list.compact!
  end
end
class Scene_Title
  alias m5_20140206_create_command_window create_command_window
  def create_command_window
    temp_data = load_data("Data/System.rvdata2")
    $data_system.start_map_id = temp_data.start_map_id
    $data_system.start_x = temp_data.start_x
    $data_system.start_y = temp_data.start_y
    $data_system.opt_transparent = temp_data.opt_transparent
    m5_20140206_create_command_window
    proc = Proc.new do
      command = @command_window.current_ext
      $data_system.start_map_id = command[:map] if command[:map]
      $data_system.start_x = command[:x] if command[:x]
      $data_system.start_y = command[:y] if command[:y]
      $data_system.opt_transparent = command[:opt] if command[:opt]
      command_new_game
    end
    @command_window.set_handler(:m520140811ntc, proc)
  end
end
class Game_Interpreter
  def m5_20140811_ntc(flag, value = true)
    base = $m5script[:M5GV20140811]
    raise "本功能需要新版喵呜喵5全局变量脚本的支持" if !base || base < 20150319
    ext = M5GV20140811.get_ext
    ext[:M5NTC20140811] ||= {}
    ext[:M5NTC20140811][flag] = value
    M5GV20140811.save_ext
  end
end