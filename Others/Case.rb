=begin
===============================================================================
  Case By喵呜喵5
===============================================================================

【说明】

  “判断变量的值为1时执行XX事件，值为2时执行XX事件，值为3时执行XX事件...”
  像是这样的内容用默认的事件指令来写时要写好多个分支条件，看着极其不舒服
  
  这个脚本将类似case这样的Ruby语法移植到了事件中，
  使在事件中实现上面的过程变得清晰起来
  
=end
#==============================================================================
# 脚本部分
#==============================================================================
$m5script ||= {};$m5script["M5Case20140617"] = 20140807
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 初始化
  #--------------------------------------------------------------------------  
  alias m5_20140617_clear clear
  def clear
    m5_20140617_clear
    @m5case = [0]
  end
  #--------------------------------------------------------------------------
  # ● 执行事件
  #--------------------------------------------------------------------------
  alias m5_20140617_execute_command execute_command
  def execute_command
    return m5_20140617_execute_command if @m5case[0] == 0
    if @m5case[0] != 0
      flag = false
      @m5case[0].times {|indent| flag = true unless @m5case[indent+1][1]}
      return m5_20140617_execute_command unless flag
      command = @list[@index]
      m5_20140617_execute_command if command.code == 108
    end
  end
  #--------------------------------------------------------------------------
  # ● case
  #--------------------------------------------------------------------------
  alias m5_20140617_command_1081 command_108
  def command_108
    m5_20140617_command_1081
    return unless @comments[0] =~ (/^\s*case\s*.*?/)
    if @comments[0] =~ (/^\s*case\s*$/)
      comment = "true"
    else
      comment = @comments[0].clone
      comment.slice!(/^\s*case\s+.*?/) rescue ""
    end
    变量 = $game_variables
    @m5case[0] += 1
    @m5case[@m5case[0]] = [eval(comment),false,false]
  end
  #--------------------------------------------------------------------------
  # ● when
  #--------------------------------------------------------------------------
  alias m5_20140617_command_1082 command_108
  def command_108
    m5_20140617_command_1082    
    return unless (@m5case[0] != 0 && @comments[0] =~ (/^\s*when\s+.*?/))    
    comment = @comments[0].clone
    comment.slice!(/^\s*when\s+.*?/) rescue ""    
    return if comment == ""
    变量 = $game_variables
    comment = eval("[#{comment}]")
    comment.each do |c|
      @m5case[@m5case[0]][1] = ( c == @m5case[@m5case[0]][0])
      if @m5case[@m5case[0]][1]
        @m5case[@m5case[0]][2] = true
        break
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● else
  #--------------------------------------------------------------------------
  alias m5_20140617_command_1084 command_108
  def command_108
    m5_20140617_command_1084
    return unless (@m5case[0] != 0 && @comments[0] =~ (/^\s*else\s*?/))
    return (@m5case[@m5case[0]][1] = false) if @m5case[@m5case[0]][2]    
    @m5case[@m5case[0]][1] = true
  end
  #--------------------------------------------------------------------------
  # ● end
  #--------------------------------------------------------------------------
  alias m5_20140617_command_1083 command_108
  def command_108
    m5_20140617_command_1083
    return unless (@m5case[0] != 0 && @comments[0] =~ (/^\s*end\s*?/))    
    @m5case[0] -= 1
  end
end
