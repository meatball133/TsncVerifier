require "option_parser"

folder : String? = nil
file : String? = nil

OptionParser.parse do |parser|
  parser.banner = "Usage: tsnc [arguments]"
  parser.on("-f FILE", "--file=FILE", "fike of a scene to parse") { |file| file = file }
  parser.on("--folder=Folder", "Specifies the folder where scenes to parse") do |folder|
    raise ArgumentError, "Folder does not exist" unless Dir.directory?(folder)
    raise ArgumentError, "You can't specify both a file and a folder" if file
    folder = folder
  end
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end

  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end
