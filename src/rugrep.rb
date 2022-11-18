#!/usr/bin/env ruby
args = ARGF.argv
# args = ARGV=
def error()
  puts 'USAGE: ruby rugrep.rb'
end
def parseArgs(args)
  optv = false; optc = false; optl = false; optL = false; opto = false; optF = false
  optA = 0; optB = 0
  files = []; patterns = []
  startPats = false; endPats = false
  if args.length < 2 then return error() end
  print 'Args: ', args.join(", "), "\n"
  # Parse arguments given to populate options/patterns/files
  args.each do |arg|
    if arg.start_with?("\"") then # Regex
      if not startPats then startPats = true end
      if endPats then return error() end
      reg = arg[1..arg.length-2]
      begin
        regex = Regexp.new(reg)
        patterns.append(reg)
      rescue => e 
        puts('Error: cannot parse regex'); end
    elsif arg.start_with?('-') then #Option
      if startPats then endPats = true end
      if arg == '-v' or arg == '--invert-match' then 
        if optv then return error() end
        optv = true
      elsif arg == '-c' or arg == '--count' then 
        if optc then return error() end
        optc = true
      elsif arg == '-l' or arg == '--files-with-matches' then 
        if optl then return error() end
        optl = true
      elsif arg == '-L' or arg == '--files-without-match' then 
        if optL then return error() end
        optL = true
      elsif arg == '-o' or arg == '--only-matching' then 
        if opto then return error() end
        opto = true
      elsif arg == '-F' or arg == '--fixed-strings' then 
        if optF then return error() end
        optF = true
      elsif arg.start_with?('-A_') then 
        if optA != 0 then return error() end
        optA = arg.sub('-A_','').to_i
      elsif arg.start_with?('--after-context=') then
        if optA != 0  then return error() end
        optA = arg.sub('--after-context=','').to_i
      elsif arg.start_with?('-B_') then 
        if optB != 0  then return error() end
        optB = arg.sub('-B_','').to_i
      elsif arg.start_with?('--before-context=') then
        if optB != 0  then return error() end
        optB = arg.sub('--before-context=','').to_i
      elsif arg.start_with?('-C_') then 
        if optA != 0  or optB != 0  then return error() end
        optA = arg.sub('-C_','').to_i
        optB = arg.sub('-C_','').to_i
      elsif arg.start_with?('--context=') then
        if optA != 0  or optB != 0  then return error() end
        optA = arg.sub('--context=','').to_i
        optB = arg.sub('--context=','').to_i
      else return error() end
    else #Filepath or error
      if startPats then endPats = true end
      unless not (File.directory?(arg)) then files.append(arg) end
    end
  end
  print 'Opts: v>', optv,' c>', optc,' l>', optl,' L>', optL,' o>', opto,' F>', optF,' A>', optA,' B>', optB, "\n"
  # Checks for illegal option combinations
  if not ((optv and not (optc or optl or optL or opto or optF or optA != 0 or optB != 0)) or #-v
    (optc and not (optl or optL or opto or optF or optA != 0 or optB != 0)) or #-c [-v]
    (optl and not (optc or optv or optL or opto or optF or optA != 0 or optB != 0)) or #-l
    (optL and not (optc or optv or optl or opto or optF or optA != 0 or optB != 0)) or #-L
    (opto and not (optv or optl or optL or optF or optA != 0 or optB != 0)) or #-o [-c]
    (optF and not (optl or optL or opto or optA != 0 or optB != 0)) or #-F [-v/-c/-c -v]
    (optF and opto and not (optc or optv or optl or optL or optA != 0 or optB != 0)) or #-F -o
    ((optA != 0 or optB != 0) and not (optc or optl or optL or opto or optF)) or
    (not (optv or optc or optl or optL or opto or optF or optA != 0 or optB != 0))) then #-A/B/C [-v] 
    return error() end
  print 'Patterns: ', patterns, "\n"
  if patterns.length == 0 then return error() end
  fposmatch = []; fnegmatch = []#; findices = Hash.new([])
  bline = []
  # Scan through every file
  files.each do |path| 
    begin
      Dir.each_child(path) do |fn|
        matched = false
        lposmatch = []; lnegmatch = []; lcount = 0
        iter = 0
        IO.foreach("#{path}#{fn}") do |line|
          if optF then #Fixed string match
            patterns.each do |pat|
              if line.include?("#{pat}") then 
                if opto then 
                  lposmatch.concat(line.scan(pat))
                else 
                  lposmatch.append(line) 
                end
              else 
                lnegmatch.append(line) 
              end 
            end 
          elsif optA != 0 or optB != 0 then #Contexts
            patterns.each do |pat|
              patreg = Regexp.new(pat)
              if line =~ patreg then lposmatch.append(iter)
              else lnegmatch.append(iter) end
            end
          elsif opto then
            patterns.each do |pat|
              patreg = Regexp.new(pat)
              if line =~ patreg then 
                lcount += 1
                lposmatch.concat(line.scan(patreg))
              end
            end
          else #Everything else
            patterns.each do |pat|
              patreg = Regexp.new(pat)
              if line =~ patreg then 
                lcount += 1
                lposmatch.concat(line)
              end
            end
          end 
          iter += 1
        end
        lposmatch = lposmatch.uniq #Deletes duplicates
        lnegmatch = lnegmatch.uniq
        if lposmatch.length != 0 then fposmatch.append("#{path}#{fn}") #Saves matched filenames
        else fnegmatch.append("#{path}#{fn}") end
        #findices["#{path}#{fn}"] = optv ? lnegmatch : lposmatch
        if optF then #-F
          if optc then #-c -v or -c
            if optv then puts lnegmatch.length
            else puts lposmatch.length end
          elsif optv then puts lnegmatch #-v
          elsif opto then puts lposmatch #-o
          else puts lposmatch #no args
          end  
        elsif optA != 0 or optB != 0 then
          a = IO.readlines("#{path}#{fn}")
          if optv then
            lnegmatch.each do |index|
              pre = index.to_i()-optB
              if pre < 0 then pre = 0 end
              puts a[pre...index.to_i()+optA+1]
              if lnegmatch.length > 1 then puts '--' end
            end
          else
            lposmatch.each do |index|
              pre = index.to_i()-optB
              if pre < 0 then pre = 0 end
              puts a[pre...index.to_i()+optA+1]
              if lposmatch.length > 1 then puts '--' end
            end
          end
        elsif opto then
          if optc then puts lcount
          else puts lposmatch
          end
        elsif optc then
          if files.length > 1 then 
            if optv then puts "#{path}#{fn}: #{iter-lcount}"
            else puts "#{path}#{fn}: #{lcount}" end
          else
            if optv then puts "#{iter-lcount}"
            else puts "#{lcount}" end
          end 
        elsif not optl and not optL 
          puts lposmatch
        end 
      end
    rescue => e 
      puts("Error: could not read file #{path}"); end
  end
  if optl then puts fposmatch # -l
  elsif optL then puts fnegmatch end # -L
end

puts parseArgs(args)
