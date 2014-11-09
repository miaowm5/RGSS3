=begin
===============================================================================
  选项指令合并 By喵呜喵5
===============================================================================

【说明】

  事件指令中相邻的显示选项指令将自动合并成同一个
  
  如果希望相邻的显示选项指令不合并时，在二者之间插入一个任意内容的注释即可
  
  使用这个脚本以后，显示选项指令的“取消的时候 - 分支”这一功能将失效
  
=end
$m5script ||= {};$m5script[:M5CE20140927] = 20141109
class Game_Interpreter  
  alias m5_20140927_setup setup
  def setup(list, event_id = 0)
    m5_20140927_setup(list, event_id)
    @list.each_with_index do |c,i|
      next unless c.code == 102
      c.parameters[1] = 0 if c.parameters[1] == 5
      indent,index,branch = c.indent,i,0
      loop do
        index += 1
        next if @list[index].indent != indent
        case @list[index].code
        when 102
          @list[i].parameters[0] += @list[index].parameters[0]
          @list.delete_at(index)
          index -= 1
        when 402
          @list[index].parameters[0] = branch
          branch += 1
        when 403
          @list.delete_at(index)
          loop do
            break if @list[index].indent == indent
            @list.delete_at(index)
          end
        when 404
          break if @list[index + 1].code != 102
          @list.delete_at(index)
          index -= 1
        else break
        end
      end      
    end    
  end
end
class Window_Message; attr_reader :position; end
class Window_ChoiceList
  alias m5_20141109_update_placement update_placement
  def update_placement
    m5_20141109_update_placement
    self.y = [0,self.y].max
  end
  alias m5_20141109_fitting_height fitting_height
  def fitting_height(line)
    old_height = m5_20141109_fitting_height(line)
    height = Graphics.height
    height -= @message_window.height if @message_window.open?
    height -= @message_window.y if @message_window.position == 1
    return [height, old_height].min
  end  
end
