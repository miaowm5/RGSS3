=begin
===============================================================================
  公共事件转换为特殊界面 By喵呜喵5
===============================================================================

【说明】

  可以将按照指定格式设置的公共事件转换为类似音乐盒、书籍系统这样的特殊界面
  
  初版的功能并不多，之后将为脚本添加更多的功能
  
  ● 公共事件的设置格式
  
    使用显示选项功能为界面增加新的指令
    
    显示不同选项的分支指令将转换为界面中选择对应选项时执行的内容
    
    目前支持以下选项：
    
    播放音乐：设置的音乐将在选择了对应选项后播放
    
    显示滚动文字：滚动文字的内容将在选择了对应选项后显示在界面右侧
    
  ● 打开对应公共事件转换的界面
  
    在事件指令中的脚本里输入
  
      M5CES20141001.call(公共事件的ID)
      
    或者，在设置部分设置将转换的界面添加进菜单后从菜单中打开
  
=end
$m5script ||= {};$m5script[:M5CES20141001] = 20141001
module M5CES20141001
#==============================================================================
#  设定部分
#==============================================================================
  
  COMMAND_X = 0
  
  # 界面中指令窗口的X坐标
  
  COMMAND_Y = 0
  
  # 界面中指令窗口的Y坐标
  
  COMMAND_WIDTH = 160
  
  # 界面中指令窗口的宽度
  
  COMMAND_HEIGHT = 0
  
  # 界面中指令窗口的高度，填写为0时，高度将随着选项个数自动计算
  
  STATUE_X = 160
  
  # 界面中状态窗口的X坐标
  
  STATUE_Y = 0
  
  # 界面中状态窗口的Y坐标
  
  STATUE_WIDTH = 544 - 160
  
  # 界面中状态窗口的宽度
  
  STATUE_HEIGHT = 416
  
  # 界面中状态窗口的高度
  
  MENU = [ # 请不要删除本行
  
  ["公共事件1",1],["公共事件2",2],
  
  # 将转换后的界面加入菜单
  # 设置格式为
  
  #    ["菜单指令名称",对应的公共事件ID],
  
  # 菜单指令的名称前后需要加上英文双引号，结尾需要加上英文逗号
  # 每条设置前后需要加上英文中括号，结尾需要加上英文逗号
  
  ] # 请不要删除本行    


#==============================================================================
#  设定结束
#==============================================================================
  def self.call(id)
    SceneManager.call(Scene_M5CES20141001)
    SceneManager.scene.prepare(id)
  end
#--------------------------------------------------------------------------
# ● Window_Command
#--------------------------------------------------------------------------
class Window_Command < Window_Command  
  def initialize(command, window)
    @command = command
    @window = window
    super(window_x, window_y)
    unselect
  end
  def window_x;COMMAND_X;end
  def window_y;COMMAND_Y;end
  def window_width;COMMAND_WIDTH;end
  def window_height
    COMMAND_HEIGHT == 0 ? [super,Graphics.height].min : COMMAND_HEIGHT
  end  
  def make_command_list
    @command.each do |command|
      add_command(command[0], :nil, true, command[1])
    end
  end
  def process_ok
    if current_item_enabled?
      play_ok_sound
      music = @command[@index][1][0]
      string = @command[@index][1][1]
      @window.refresh(string)
      music.play if music
      activate      
    else
      play_buzzer_sound
    end
  end
  def play_ok_sound;Sound.play_ok;end
  def play_buzzer_sound;Sound.play_buzzer;end
  def cancel_enabled?;true;end  
  def call_cancel_handler;SceneManager.return;end  
end
#--------------------------------------------------------------------------
# ● Window_Status
#--------------------------------------------------------------------------
class Window_Status < Window_Base
  def initialize(data)
    @data = data
    super(window_x, window_y, window_width, window_height)
  end
  def window_x;STATUE_X;end
  def window_y;STATUE_Y;end
  def window_width;STATUE_WIDTH;end
  def window_height;STATUE_HEIGHT;end  
  def refresh(text)
    contents.clear
    draw_text_ex(4, 0, text)
  end
end
  
end # module M5CES20141001

#--------------------------------------------------------------------------
# ● Scene_M5CES20141001
#--------------------------------------------------------------------------
class Scene_M5CES20141001 < Scene_MenuBase
  def prepare(id)
    @ev = id
  end
  def start
    super
    @status = M5CES20141001::Window_Status.new(nil)
    @command = M5CES20141001::Window_Command.new(load_events(@ev),@status)
  end
  def load_events(id = 1)
    ev_list = $data_common_events[id]
    raise "公共事件读取失败！" unless ev_list
    ev_list = ev_list.clone
    command_list = []
    ev_list.list.each_with_index do |command,index|
      next unless command.indent == 0 && command.code == 402      
      name = command.parameters[1]
      content = [nil,""]
      pos = index + 1
      while ev_list.list[pos].indent == 1
        case ev_list.list[pos].code
        when 241
          content[0] = ev_list.list[pos].parameters[0]
        when 405
          content[1] += "#{ev_list.list[pos].parameters[0]}\n"
        end
        pos += 1
      end
      command_list.push [name,content]      
    end
    return command_list
  end  
end
#--------------------------------------------------------------------------
# ● Window_MenuCommand
#--------------------------------------------------------------------------
class Window_MenuCommand
  alias m5_20141001_add_formation_command add_formation_command
  def add_formation_command
    m5_20141001_add_formation_command
    M5CES20141001::MENU.each_with_index do |set|      
      add_command(set[0],"m5_ces20141001_#{set[1]}".to_sym)
    end
  end
  alias m5_20141001_handle? handle?
  def handle?(symbol)
    if /m5_ces20141001_\S+/ =~ symbol.to_s
      return true
    else
      return m5_20141001_handle?(symbol)
    end
  end
  alias m5_20141001_call_handler call_handler
  def call_handler(symbol)    
    id = /m5_ces20141001_(\S+)/ =~ symbol.to_s ? $1.to_i : nil
    return m5_20141001_call_handler(symbol) unless id    
    M5CES20141001.call(id)
  end
end
