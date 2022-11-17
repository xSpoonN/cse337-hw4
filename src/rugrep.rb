#!/usr/bin/env ruby
args = ARGF.argv
# args = ARGV=
def parseArgs(args)
  optv = false; optc = false; optl = false; optL = false; opto = false; optF = false
  optA = 0; optB = 0
  files = []; patterns = []
  startPats = false; endPats = false
  if args.length < 2 then puts 'USAGE: ruby rugrep.rb'; return end
  puts args
  args.each do |arg|
    if arg.start_with?('\\') then # Regex
      puts 'Regex Read'
      if not startPats then startPats = true end
      if endPats then puts 'USAGE: ruby rugrep.rb'; return end
      reg = arg[1..arg.length-2]
      begin
        regex = Regexp.new(reg)
        patterns.append(reg)
      rescue puts('Error: cannot parse regex') end
    elsif arg.start_with?('-') then #Option
      puts 'Option Read'
      if startPats then endPats = true end
      if arg == '-v' or arg == '--invert-match' then optv = true
      elsif arg == '-c' or arg == '--count' then optc = true
      elsif arg == '-l' or arg == '--files-with-matches' then optl = true
      elsif arg == '-L' or arg == '--files-without-match' then optL = true
      elsif arg == '-o' or arg == '--only-matching' then opto = true
      elsif arg == '-F' or arg == '--fixed-strings' then optF = true
      elsif arg.start_with?('-A_') == '-' then 
        optA = arg.sub('-A_','').to_i
      elsif arg.start_with?('--after-context=') then
        optA = arg.sub('--after-context=','').to_i
      elsif arg.start_with?('-B_') == '-' then 
        optB = arg.sub('-B_','').to_i
      elsif arg.start_with?('--before-context=') then
        optB = arg.sub('--before-context=','').to_i
      elsif arg.start_with?('-C_') == '-' then 
        optA = arg.sub('-C_','').to_i
        optB = arg.sub('-C_','').to_i
      elsif arg.start_with?('--context=') then
        optA = arg.sub('--context=','').to_i
        optB = arg.sub('--context=','').to_i
      else then 
        puts 'USAGE: ruby rugrep.rb' 
        return
      end
    else #Filepath or error
      puts 'Other Read'
      if startPats then endPats = true end
      unless not (File.directory?(arg)) then files.append(arg) end
    end
  end
  #Check for invalid opt combinations
  if patterns.length == 0 then puts 'USAGE: ruby rugrep.rb'; return end
  fposmatch = []; fnegmatch = []#; fcnts = Hash.new(0)
  bline = []
  files.each do |path| 
    begin
      Dir.each_child(path) do |fn|
        matched = false
        lposmatch = []; lnegmatch = []; lcount = 0
        iter = 0
        IO.foreach("#{path}#{fn}", "r") do |line|
          if optF then #Fixed string match
            patterns.each do |pat|
              if line.include?(pat) then 
                if opto then 
                  lposmatch.concat(line.scan(pat))
                else then 
                  lposmatch.append(line) 
                end
              else then 
                lnegmatch.append(line) 
              end 
            end 
          elsif optA != 0 or optB != 0 then
            patterns.each do |pat|
              patreg = Regexp.new(pat)
              if line =~ patreg then lposmatch.append(iter)
              else then lnegmatch.append(iter) end
            end
          else then
            patterns.each do |pat|
              patreg = Regexp.new(pat)
              if line.include?(patreg) then 
                lcount += 1
                lposmatch.concat(line.scan(patreg))
            end
          end 
          iter += 1
        end
        if lposmatch != 0 then fposmatch.append("#{path}#{fn}")
        else fnegmatch.append("#{path}#{fn}")
        if optF then #-F
          if optc then #-c -v or -c
            if optv then puts lnegmatch.length
            else then puts lposmatch.length end
          elsif optv then #-v
            puts lnegmatach
          elsif opto then #-o
            puts lposmatch
          else then #no args
            puts lposmatch
          end  
        
        elsif optA != 0 or optB != 0 then
          a = IO.readlines("#{path}#{fn}")
          if optv then
            fnegmatch.each do |index|
              puts a[index-optB...index+optA]
              if fnegmatch.length > 1 then puts '--'
            end
          else then
            fposmatch.each do |index|
              pre = index-optB
              if pre < 0 then pre = 0 end
              puts a[pre...index+optA]
              if fposmatch.length > 1 then puts '--'
            end
          end
        elsif opto then
          if optc then puts lcount
          else then puts lposmatch end
        elsif optc then
          if optv then puts "#{path}#{fn}: #{iter-lcount}"
          else then puts "#{path}#{fn}: #{lcount}" end
        end 



      end
    rescue puts "Error: could not read file #{path}" end
  end
  if opl then puts fposmatch # -l
  elsif optL then puts fnegmatch end # -L
end

puts parseArgs(args)
