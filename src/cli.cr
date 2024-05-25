require "option_parser"
require "./tsnc_parser"

folder : String? = nil
file : String? = nil

OptionParser.parse do |parser|
  parser.banner = "Usage: tsnc [arguments]"
  parser.on("-f FILE", "--file=FILE", "fike of a scene to parse") { |file_path| file = file_path }
  parser.on("--folder=Folder", "Specifies the folder where scenes to parse") do |folder_path|
    raise ArgumentError.new("Folder does not exist") unless Dir.exists?(folder_path)
    raise ArgumentError.new("You can't specify both a file and a folder") if file
    folder = folder_path
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

test = TsncParser.new

if temp_folder = folder
  test.parse_folder(Path.new(temp_folder))
end

if temp_file = file
  test.parse_file(Path.new(temp_file))
end

test.output_result!
