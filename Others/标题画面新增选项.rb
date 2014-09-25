=begin
===============================================================================
  标题画面新增选项 By喵呜喵5
===============================================================================

  【说明】
  
  在标题画面增加新的选项
  
  玩家选择了这个选项后可以从另外一张地图开始新游戏
  在这张新地图上可以用事件指令之类的东西做出类似CG欣赏之类的功能
  
=end
$m5script ||= {};$m5script[:M5NTC20140811] = 20140925
module M5NTC20140811
  COMMAND = [
#==============================================================================
#  设定部分
#==============================================================================  
  
  ["末尾的选项",1,0,0,true,-1,0],
  
  ["开头的选项",1,1,1,false,0,1],
  
  ["中间的选项",1,2,2,false,2,2],
  
  
  # 设置格式为 : [a,b,c,d,e,f,g],
  
  # a 为选项显示的文字，前后需要加上英文双引号  
  # b 为选择这个选项后移动到的地图ID  
  # c 为选择这个选项后移到到对应地图的X坐标
  # d 为选择这个选项后移到到对应地图的Y坐标
  # e 为选择这个选项后移到到对应地图时是否透明，true 为透明，false 为不透明
  # f 为这个选项在菜单中的位置，不需要的话填写 -1 就好了
  # g 为选项是否显示的标志，请参考下方的详细说明，不需要的话填写 0 
  # 请不要忘记结尾的逗号  
  
  
  # 【关于选项是否显示标志的详细说明】  
  # 这个功能需要搭配我的全局变量脚本共同使用，可以实现类似通关后出现新选项的效果  
  
  # 下面以通关后出现 “观看CG” 选项为例：  
  # 首先插入我的全局变量脚本，脚本的位置应该放在本脚本之上
  # 在设定部分“观看CG”选项的 g 的位置填上一个不为0的数字，例如 233
  # 接着，当游戏通关的时候在事件的脚本中执行下面的代码
  
  #   m5_20140811_ntc(233)
  
  # 之后，再次打开游戏时标题画面中就会出现“观看CG”的选项了
  # 如果希望删除已经出现的“观看CG”这个选项的话，在事件的脚本中执行下面的代码
  
  #   m5_20140811_ntc(233,false)
  
  # “观看CG”的选项便再次被消除了

#==============================================================================
#  设定结束
#==============================================================================
  ]
end
class Window_TitleCommand
  alias m5_20140206_make_command_list make_command_list
  def make_command_list
    m5_20140206_make_command_list
    m5_20140811_ntc
  end
  def m5_20140811_ntc
    base = $m5script["M5GV20140811"]
    ext = (base && base >= 20140811) ? M5GV20140811.load_ext : nil
    M5NTC20140811::COMMAND.each_with_index do |command,index|
      @list.insert(command[5],{:name=>command[0], :symbol=>:m5_20140811_ntc,\
        :enabled=>true, :ext=>index}) if m5_20140811_need_add(command[6],ext)
    end
    @list.compact!
  end
  def m5_20140811_need_add(flag,ext)
    return true if (!ext || flag == 0)    
    ext[:m5_20140811_ntc] ||= {}
    return ext[:m5_20140811_ntc][flag]
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
    @command_window.set_handler(:m5_20140811_ntc, method(:c_m5_20140811_ntc))
  end
  def c_m5_20140811_ntc
    command = M5NTC20140811::COMMAND[@command_window.current_ext]    
    $data_system.start_map_id = command[1]
    $data_system.start_x, $data_system.start_y = command[2], command[3]
    $data_system.opt_transparent = command[4]
    command_new_game
  end
end
class Game_Interpreter
  def m5_20140811_ntc(flag,value = true)
    base = $m5script["M5GV20140811"]
    ext = (base && base >= 20140811) ? M5GV20140811.load_ext : nil
    raise "本功能需要 喵呜喵5全局变量 脚本的支持" unless ext
    ext[:m5_20140811_ntc] ||= {}
    ext[:m5_20140811_ntc][flag] = value
    M5GV20140811.save_ext(ext)    
  end
end
