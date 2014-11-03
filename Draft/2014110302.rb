def hash_name(string)
  name_list.each {|match| return match[0] if match.include? string}  
  string
end
def name_list;[  
  %w[1 2 3],
  %w[4 5 6],  
];end
p hash_name("a")
p hash_name("4")
p hash_name("3")
