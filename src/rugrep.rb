#!/usr/bin/env ruby
args = ARGF.argv
# args = ARGV
def parseArgs(args)
  optv = false; optc = false; optl = false; optL = false; opto = false; optF = false
  optA = 0; optB = 0; optC = 0
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
        Regexp.new(reg)
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
        optC = arg.sub('-C_','').to_i
      elsif arg.start_with?('--context=') then
        optC = arg.sub('--context=','').to_i
      end
     # else #Invalid opt, error 
    else #Filepath or error
      puts 'Other Read'
      if startPats then endPats = true end
      unless not (File.directory?(arg)) then files.append(arg) end
    end
  end
  if patterns.length == 0 then puts 'USAGE: ruby rugrep.rb'; return end
  files.each do |path| 
    begin
      Dir.children(path) do 
        #Do stuff
      end
    rescue puts "Error: could not read file #{path}" end
  end
end

puts parseArgs(args)
