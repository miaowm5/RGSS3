code = ''
@index += 1
while next_event_code == 405
  @index += 1
  code += @list[@index].parameters[0]
  code += "\n"
end
eval(code)