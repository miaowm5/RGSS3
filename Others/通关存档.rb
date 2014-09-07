=begin
=============================================================================== 
  通关存档 By喵呜喵5
===============================================================================

【说明】

  在存档界面查看存档时，已经通关的存档会在名字后面会显示特殊效果

=end
$m5script ||= {};$m5script["M5Save20140907"] = 20140907
module M5Save20140907
#==============================================================================
#  设定部分
#==============================================================================
  

  SWI = 1 # 这里设置通关后打开的开关，通关以后请打开这个开关
  
  ICO = 104 # 这里设置已经通关的存档在存档名之后显示的图标，不需要的话设置成 0
  
  X_OFF = 8 # 图标在X方向的偏移
  
  Y_OFF = -1 # 图标在Y方向的偏移
  
  WORD = " 已通关！" # 这里设置已经通关的存档在存档名之后显示的文字

  
#==============================================================================
#  设定结束
#==============================================================================
end
class << DataManager
  alias m5_20140907_make_save_header make_save_header
  def make_save_header
    header = m5_20140907_make_save_header    
    header[:m5_clear] = $game_switches[M5Save20140907::SWI]
    header
  end
end
class Window_SaveFile  
  alias m5_20140907_refresh refresh
  def refresh
    m5_20140907_refresh
    header = DataManager.load_header(@file_index)
    if header != nil and header[:m5_clear]
      draw_icon(M5Save20140907::ICO, M5Save20140907::X_OFF + @name_width,\
        M5Save20140907::Y_OFF)
      draw_text(@name_width + \
        (M5Save20140907::ICO == 0 ? 0 : 24 + M5Save20140907::X_OFF),0,\
        Graphics.width, line_height, M5Save20140907::WORD)
    end
  end
end

if $imported && $imported["YEA-SaveEngine"]
  
class Window_FileList  
  alias m5_20140907_draw_item draw_item
  def draw_item(index)
    m5_20140907_draw_item(index)    
    header = DataManager.load_header(index)    
    if header != nil and header[:m5_clear]
      rect = item_rect(index)
      rect.width -= 4
      width = text_size(sprintf(YEA::SAVE::SLOT_NAME, (index + 1).group)).width
      draw_icon(M5Save20140907::ICO, rect.x + width + 24 + \
        M5Save20140907::X_OFF, rect.y + M5Save20140907::Y_OFF)
    end
  end
end
class Window_FileStatus
  alias m5_20140907_draw_save_slot draw_save_slot
  def draw_save_slot(dx, dy, dw)
    m5_20140907_draw_save_slot(dx, dy, dw)
    header = DataManager.load_header(@file_window.index)    
    if header != nil and header[:m5_clear]
      text = sprintf(YEA::SAVE::SLOT_NAME, (@file_window.index+1).group)
      width = text_size(text).width
      draw_icon(M5Save20140907::ICO, dx + width + M5Save20140907::X_OFF,\
        M5Save20140907::Y_OFF + dy)
      draw_text(dx + width + \
        (M5Save20140907::ICO == 0 ? 0 : 24 + M5Save20140907::X_OFF),dy,\
        Graphics.width, line_height, M5Save20140907::WORD)
    end    
  end 
end

end # if $imported && $imported["YEA-SaveEngine"]
