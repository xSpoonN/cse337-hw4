#  gem install simplecov for coverage
# uncomment the following two lines to generate coverage report
require 'simplecov'
SimpleCov.start
require_relative File.join("..", "src", "rugrep")

# write rspec tests
Dir.mkdir("testfiles") unless File.exist?("testfiles")
Dir.mkdir("testfiles2") unless File.exist?("testfiles2")
File.delete("testfiles/asdf") if File.exist?("testfiles/asdf")
File.delete("testfiles/cook") if File.exist?("testfiles/cook")
File.delete("testfiles/michael") if File.exist?("testfiles/michael")
File.delete("testfiles2/asdf") if File.exist?("testfiles2/asdf")
File.open("testfiles/asdf", "w") do |f|
    f.write("21345678\napple\napplication\n[0-9]\n")
end
File.open("testfiles/cook", "w") do |f|
    f.write("happy\njesus?\n551512\nappropriate\nsomething\nsomething else\nbooo\napplications\nappear\nhappen\nblahblah\ni hate ruby\nooooooooooooooo\nargh\n^app\n")
end
File.open("testfiles/michael","w") {}
File.open("testfiles2/asdf", "w") do |f|
    f.write("21345678\napple\napplication\n[0-9]\n")
end

describe "parseArgs" do
    example "no args given" do
        expect { parseArgs(["\"app\"","testfiles/"]) }.to output(
            "testfiles/asdf: apple\ntestfiles/asdf: application\ntestfiles/cook: happy\ntestfiles/cook: appropriate\n"\
            "testfiles/cook: applications\ntestfiles/cook: appear\ntestfiles/cook: happen\ntestfiles/cook: ^app\n").to_stdout
    end
    example "no args given one file" do
        expect { parseArgs(["\"app\"","testfiles2/"]) }.to output(
            "apple\napplication\n").to_stdout
    end
    example "-v" do
        expect { parseArgs(["\"app\"","testfiles/","-v"]) }.to output(
            "testfiles/asdf: 21345678\ntestfiles/asdf: [0-9]\ntestfiles/cook: jesus?\ntestfiles/cook: 551512\ntestfiles/cook: something\ntestfiles/cook: something else\n"\
            "testfiles/cook: booo\ntestfiles/cook: blahblah\ntestfiles/cook: i hate ruby\ntestfiles/cook: ooooooooooooooo\ntestfiles/cook: argh\n").to_stdout
    end
    example "--invert-match" do
        expect { parseArgs(["\"app\"","testfiles/","--invert-match"]) }.to output(
            "testfiles/asdf: 21345678\ntestfiles/asdf: [0-9]\ntestfiles/cook: jesus?\ntestfiles/cook: 551512\ntestfiles/cook: something\ntestfiles/cook: something else\n"\
            "testfiles/cook: booo\ntestfiles/cook: blahblah\ntestfiles/cook: i hate ruby\ntestfiles/cook: ooooooooooooooo\ntestfiles/cook: argh\n").to_stdout
    end
    example "-c" do
        expect { parseArgs(["\"app\"","testfiles/","-c"]) }.to output(
            "testfiles/asdf: 2\ntestfiles/cook: 6\ntestfiles/michael: 0\n").to_stdout
    end
    example "-c one file" do
        expect { parseArgs(["\"app\"","testfiles2/","-c"]) }.to output(
            "2\n").to_stdout
    end
    example "--count" do
        expect { parseArgs(["\"app\"","testfiles/","--count"]) }.to output(
            "testfiles/asdf: 2\ntestfiles/cook: 6\ntestfiles/michael: 0\n").to_stdout
    end
    example "-c -v" do
        expect { parseArgs(["\"app\"","testfiles/","-c","-v"]) }.to output(
            "testfiles/asdf: 2\ntestfiles/cook: 9\ntestfiles/michael: 0\n").to_stdout
    end
    example "-c -v one file" do
        expect { parseArgs(["\"app\"","testfiles2/","-c","-v"]) }.to output(
            "2\n").to_stdout
    end
    example "-l" do
        expect { parseArgs(["\"app\"","testfiles/","-l"]) }.to output(
            "testfiles/asdf\ntestfiles/cook\n").to_stdout
    end
    example "-L" do
        expect { parseArgs(["\"app\"","testfiles/","-L"]) }.to output(
            "testfiles/michael\n").to_stdout
    end
    example "-o" do
        expect { parseArgs(["\"app\"","testfiles/","-o"]) }.to output(
            "testfiles/asdf: app\n"*2 + "testfiles/cook: app\n"*6).to_stdout
    end
    example "-o one file" do
        expect { parseArgs(["\"app\"","testfiles2/","-o"]) }.to output(
            "app\napp\n").to_stdout
    end
    example "-o ^app" do
        expect { parseArgs(["\"^app\"","testfiles/","-o"]) }.to output(
           "testfiles/asdf: app\n"*2 + "testfiles/cook: app\n"*3).to_stdout
    end
    example "-o -c" do
        expect { parseArgs(["\"app\"","testfiles/","-o","-c"]) }.to output(
            "testfiles/asdf: 2\ntestfiles/cook: 6\ntestfiles/michael: 0\n").to_stdout
    end
    example "-F" do
        expect { parseArgs(["\"app\"","testfiles/","-F"]) }.to output(
            "testfiles/asdf: apple\ntestfiles/asdf: application\ntestfiles/cook: happy\ntestfiles/cook: appropriate\ntestfiles/cook: applications\n"\
            "testfiles/cook: appear\ntestfiles/cook: happen\ntestfiles/cook: ^app\n").to_stdout
    end
    example "-F -o" do
        expect { parseArgs(["\"app\"","testfiles/","-o", "-F"]) }.to output(
            "testfiles/asdf: app\n"*2 + "testfiles/cook: app\n"*6).to_stdout
    end
    example "-F -o ^app" do
        expect { parseArgs(["\"^app\"","testfiles/","-o", "-F"]) }.to output(
            "testfiles/cook: ^app\n").to_stdout
    end
    example "-F ^app" do
        expect { parseArgs(["\"^app\"","testfiles/","-F"]) }.to output(
            "testfiles/cook: ^app\n").to_stdout
    end
    example "-F -c ^app" do
        expect { parseArgs(["\"^app\"","testfiles/","-F","-c"]) }.to output(
            "testfiles/asdf: 0\ntestfiles/cook: 1\ntestfiles/michael: 0\n").to_stdout
    end
    example "-F one file" do
        expect { parseArgs(["\"app\"","testfiles2/","-F"]) }.to output(
            "apple\napplication\n").to_stdout
    end
    example "-F -c one file" do
        expect { parseArgs(["\"app\"","testfiles2/","-F","-c"]) }.to output(
            "2\n").to_stdout
    end
    example "-F -c -v one file" do
        expect { parseArgs(["\"app\"","testfiles2/","-F","-c","-v"]) }.to output(
            "2\n").to_stdout
    end
    example "-F -v one file" do
        expect { parseArgs(["\"app\"","testfiles2/","-F","-v"]) }.to output(
            "21345678\n[0-9]\n").to_stdout
    end
    example "-F -o one file" do
        expect { parseArgs(["\"app\"","testfiles2/","-F","-o"]) }.to output(
            "app\napp\n").to_stdout
    end
    example "-F -v ^app" do
        expect { parseArgs(["\"^app\"","testfiles/","-F","-v"]) }.to output(
            "testfiles/asdf: 21345678\ntestfiles/asdf: apple\ntestfiles/asdf: application\ntestfiles/asdf: [0-9]\ntestfiles/cook: happy\n"\
            "testfiles/cook: jesus?\ntestfiles/cook: 551512\ntestfiles/cook: appropriate\ntestfiles/cook: something\ntestfiles/cook: something else\n"\
            "testfiles/cook: booo\ntestfiles/cook: applications\ntestfiles/cook: appear\ntestfiles/cook: happen\ntestfiles/cook: blahblah\n"\
            "testfiles/cook: i hate ruby\ntestfiles/cook: ooooooooooooooo\ntestfiles/cook: argh\n").to_stdout
    end
    example "-F -c -v ^app" do
        expect { parseArgs(["\"^app\"","testfiles/","-F","-c","-v"]) }.to output(
            "testfiles/asdf: 4\ntestfiles/cook: 14\ntestfiles/michael: 0\n").to_stdout
    end
    example "-A_2 ^app" do
        expect { parseArgs(["\"^app\"","testfiles/","-A_2"]) }.to output(
            "testfiles/asdf: apple\ntestfiles/asdf: application\ntestfiles/asdf: [0-9]\n--\n"\
            "testfiles/asdf: application\ntestfiles/asdf: [0-9]\n--\n"\
            "testfiles/cook: appropriate\ntestfiles/cook: something\ntestfiles/cook: something else\n--\n"\
            "testfiles/cook: applications\ntestfiles/cook: appear\ntestfiles/cook: happen\n--\n"\
            "testfiles/cook: appear\ntestfiles/cook: happen\ntestfiles/cook: blahblah\n").to_stdout
    end
    example "--after_context=2 ^app" do
        expect { parseArgs(["\"^app\"","testfiles/","--after-context=2"]) }.to output(
            "testfiles/asdf: apple\ntestfiles/asdf: application\ntestfiles/asdf: [0-9]\n--\n"\
            "testfiles/asdf: application\ntestfiles/asdf: [0-9]\n--\n"\
            "testfiles/cook: appropriate\ntestfiles/cook: something\ntestfiles/cook: something else\n--\n"\
            "testfiles/cook: applications\ntestfiles/cook: appear\ntestfiles/cook: happen\n--\n"\
            "testfiles/cook: appear\ntestfiles/cook: happen\ntestfiles/cook: blahblah\n").to_stdout
    end
    example "-A_1 one file" do
        expect { parseArgs(["\"app\"","testfiles2/","-A_1"]) }.to output(
            "apple\napplication\n--\napplication\n[0-9]\n").to_stdout
    end
    example "-A_1 -v one file" do
        expect { parseArgs(["\"app\"","testfiles2/","-A_1","-v"]) }.to output(
            "21345678\napple\n--\n[0-9]\n").to_stdout
    end
    example "-B_2 ^app" do
        expect { parseArgs(["\"^app\"","testfiles/","-B_2"]) }.to output(
            "testfiles/asdf: 21345678\ntestfiles/asdf: apple\n--\n"\
            "testfiles/asdf: 21345678\ntestfiles/asdf: apple\ntestfiles/asdf: application\n--\n"\
            "testfiles/cook: jesus?\ntestfiles/cook: 551512\ntestfiles/cook: appropriate\n--\n"\
            "testfiles/cook: something else\ntestfiles/cook: booo\ntestfiles/cook: applications\n--\n"\
            "testfiles/cook: booo\ntestfiles/cook: applications\ntestfiles/cook: appear\n").to_stdout
    end
    example "--before-context=2 ^app" do
        expect { parseArgs(["\"^app\"","testfiles/","--before-context=2"]) }.to output(
            "testfiles/asdf: 21345678\ntestfiles/asdf: apple\n--\n"\
            "testfiles/asdf: 21345678\ntestfiles/asdf: apple\ntestfiles/asdf: application\n--\n"\
            "testfiles/cook: jesus?\ntestfiles/cook: 551512\ntestfiles/cook: appropriate\n--\n"\
            "testfiles/cook: something else\ntestfiles/cook: booo\ntestfiles/cook: applications\n--\n"\
            "testfiles/cook: booo\ntestfiles/cook: applications\ntestfiles/cook: appear\n").to_stdout
    end
    example "-B_1 one file" do
        expect { parseArgs(["\"app\"","testfiles2/","-B_1"]) }.to output(
            "21345678\napple\n--\napple\napplication\n").to_stdout
    end
    example "-C_2 ^app" do
        expect { parseArgs(["\"^app\"","testfiles/","-C_2"]) }.to output(
            "testfiles/asdf: 21345678\ntestfiles/asdf: apple\ntestfiles/asdf: application\ntestfiles/asdf: [0-9]\n--\n"\
            "testfiles/asdf: 21345678\ntestfiles/asdf: apple\ntestfiles/asdf: application\ntestfiles/asdf: [0-9]\n--\n"\
            "testfiles/cook: jesus?\ntestfiles/cook: 551512\ntestfiles/cook: appropriate\ntestfiles/cook: something\ntestfiles/cook: something else\n--\n"\
            "testfiles/cook: something else\ntestfiles/cook: booo\ntestfiles/cook: applications\ntestfiles/cook: appear\ntestfiles/cook: happen\n--\n"\
            "testfiles/cook: booo\ntestfiles/cook: applications\ntestfiles/cook: appear\ntestfiles/cook: happen\ntestfiles/cook: blahblah\n").to_stdout
    end
    example "--context=2 ^app" do
        expect { parseArgs(["\"^app\"","testfiles/","--context=2"]) }.to output(
            "testfiles/asdf: 21345678\ntestfiles/asdf: apple\ntestfiles/asdf: application\ntestfiles/asdf: [0-9]\n--\n"\
            "testfiles/asdf: 21345678\ntestfiles/asdf: apple\ntestfiles/asdf: application\ntestfiles/asdf: [0-9]\n--\n"\
            "testfiles/cook: jesus?\ntestfiles/cook: 551512\ntestfiles/cook: appropriate\ntestfiles/cook: something\ntestfiles/cook: something else\n--\n"\
            "testfiles/cook: something else\ntestfiles/cook: booo\ntestfiles/cook: applications\ntestfiles/cook: appear\ntestfiles/cook: happen\n--\n"\
            "testfiles/cook: booo\ntestfiles/cook: applications\ntestfiles/cook: appear\ntestfiles/cook: happen\ntestfiles/cook: blahblah\n").to_stdout
    end
    example "-C_2 -v ^app" do
        expect { parseArgs(["\"^app\"","testfiles/","-C_2","-v"]) }.to output(
            "testfiles/asdf: 21345678\ntestfiles/asdf: apple\ntestfiles/asdf: application\n--\n"\
            "testfiles/asdf: apple\ntestfiles/asdf: application\ntestfiles/asdf: [0-9]\n--\n"\
            "testfiles/cook: happy\ntestfiles/cook: jesus?\ntestfiles/cook: 551512\n--\n"\
            "testfiles/cook: happy\ntestfiles/cook: jesus?\ntestfiles/cook: 551512\ntestfiles/cook: appropriate\n--\n"\
            "testfiles/cook: happy\ntestfiles/cook: jesus?\ntestfiles/cook: 551512\ntestfiles/cook: appropriate\ntestfiles/cook: something\n--\n"\
            "testfiles/cook: 551512\ntestfiles/cook: appropriate\ntestfiles/cook: something\ntestfiles/cook: something else\ntestfiles/cook: booo\n--\n"\
            "testfiles/cook: appropriate\ntestfiles/cook: something\ntestfiles/cook: something else\ntestfiles/cook: booo\ntestfiles/cook: applications\n--\n"\
            "testfiles/cook: something\ntestfiles/cook: something else\ntestfiles/cook: booo\ntestfiles/cook: applications\ntestfiles/cook: appear\n--\n"\
            "testfiles/cook: applications\ntestfiles/cook: appear\ntestfiles/cook: happen\ntestfiles/cook: blahblah\ntestfiles/cook: i hate ruby\n--\n"\
            "testfiles/cook: appear\ntestfiles/cook: happen\ntestfiles/cook: blahblah\ntestfiles/cook: i hate ruby\ntestfiles/cook: ooooooooooooooo\n--\n"\
            "testfiles/cook: happen\ntestfiles/cook: blahblah\ntestfiles/cook: i hate ruby\ntestfiles/cook: ooooooooooooooo\ntestfiles/cook: argh\n--\n"\
            "testfiles/cook: blahblah\ntestfiles/cook: i hate ruby\ntestfiles/cook: ooooooooooooooo\ntestfiles/cook: argh\ntestfiles/cook: ^app\n--\n"\
            "testfiles/cook: i hate ruby\ntestfiles/cook: ooooooooooooooo\ntestfiles/cook: argh\ntestfiles/cook: ^app\n--\n"\
            "testfiles/cook: ooooooooooooooo\ntestfiles/cook: argh\ntestfiles/cook: ^app\n").to_stdout
    end
    context "Expected errors"
    example "not enough args" do expect { parseArgs(["\"^app\""]) }.to output("USAGE: ruby rugrep.rb\n").to_stdout end
    example "invalid regex" do expect { parseArgs(['"[0-9a"', "testfiles/"]) }.to output("Error: cannot parse regex [0-9a\nUSAGE: ruby rugrep.rb\n").to_stdout end
    example "noncontiguous patterns" do expect { parseArgs(["\"^app\"","testfiles/","\"[0-9]\""]) }.to output("USAGE: ruby rugrep.rb\n").to_stdout end
    example "no files given" do expect { parseArgs(["\"^app\"","\"[0-9]\"","-o"]) }.to output("Error: could not read file\n").to_stdout end
    example "bad file" do expect { parseArgs(["\"^app\"","testfiles3/","-o"]) }.to output("Error: could not read file testfiles3/\n").to_stdout end
    example "no patterns given" do expect { parseArgs(["testfiles/","testfiles2/","-o"]) }.to output("USAGE: ruby rugrep.rb\n").to_stdout end
    example "invalid option type" do expect { parseArgs(["\"^app\"","testfiles/","-u"]) }.to output("USAGE: ruby rugrep.rb\n").to_stdout end
    example "bad option combo 1" do expect { parseArgs(["\"^app\"","testfiles/","-v","-l"]) }.to output("USAGE: ruby rugrep.rb\n").to_stdout end
    example "bad option combo 2" do expect { parseArgs(["\"^app\"","testfiles/","-c","-L"]) }.to output("USAGE: ruby rugrep.rb\n").to_stdout end
    example "bad option combo 3" do expect { parseArgs(["\"^app\"","testfiles/","-F","-A_2"]) }.to output("USAGE: ruby rugrep.rb\n").to_stdout end
    example "bad option combo 4" do expect { parseArgs(["\"^app\"","testfiles/","-o","-v"]) }.to output("USAGE: ruby rugrep.rb\n").to_stdout end
    example "bad option combo 5" do expect { parseArgs(["\"^app\"","testfiles/","-B_2","-c"]) }.to output("USAGE: ruby rugrep.rb\n").to_stdout end
    
end
