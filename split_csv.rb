#!/usr/bin/env ruby
data = Array.new()
MAX_BYTES = 3500
MAX_LINES = 32
lineNum = 0
file_num = 0
bytes    = 0


filename = 'W:/IN/tangoZ.txt_100.TXT'
r = File.exist?(filename)
puts 'File exists =' + r.to_s + ' ' +  filename
file=File.open(filename,"r")
line_count = file.readlines.size
file_size = File.size(filename).to_f / 1024000
puts 'Total lines=' + line_count.to_s + '   size=' + file_size.to_s + ' Mb'
puts ' '


file = File.open(filename,"r")
#puts '1 File open read ' + filename
file.each{|line|
  bytes += line.length
  lineNum += 1
  data << line

  if bytes > MAX_BYTES  then
    # if lineNum > MAX_LINES  then
    bytes = 0
    file_num += 1
    #puts '_2 File open write ' + file_num.to_s + '  lines ' + lineNum.to_s
    File.open("#{file_num}.txt", 'w') {|f| f.write data.join}
    data.clear
    lineNum = 0
  end



}

## write leftovers
file_num += 1
#puts '__3 File open write FINAL' + file_num.to_s + '  lines ' + lineNum.to_s
File.open("#{file_num}.txt", 'w') {|f| f.write data.join}
