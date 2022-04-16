class Window_MenuCommand
  alias m5_20151102_add_save_command add_save_command
  def add_save_command
    m5_20151102_add_save_command
    add_command('读档', :m5_20151102_load)
    return unless @handler
    @handler[:m5_20151102_load] = ->{ SceneManager.call(Scene_Load) }
  end
end
