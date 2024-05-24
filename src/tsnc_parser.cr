class TsncParser
  class Node
    getter name : String, type : String?, id : String?, properties : Hash(String, String), children : Array(Node)

    def initialize(@name = "", @type : String? = "", @id : String? = "", @properties = {} of String => String, @children = [] of Node)
    end
  end

  getter nodes : Array(Node), missing_files : Array(String), missing_resources : Array(String)

  @missing_files = [] of String
  @missing_resources = [] of String

  def parse_folder(folder : Path)
    raise "Can't find #{folder}" unless Dir.exists?(folder)

    Dir.new(folder).children.sort.each do |file|
      if file.ends_with?(".tscn")
        parse_file(folder / file)
      elsif File.directory?(folder / file)
        parse_folder(folder / file)
      end
    end
  end

  def output_result!
    if test.missing_files.size > 0
      puts "Missing files:"
      test.missing_files.each do |file|
        puts "- #{file}"
      end
    end

    if test.missing_resources.size > 0
      puts "Missing resources:"
      test.missing_resources.each do |resource|
        puts "- #{resource}"
      end
    end

    if test.missing_files.size > 0 || test.missing_resources.size > 0
      exit 1
    end
  end

  def parse_file(file : Path)
    raise "Can't find #{file}" unless File.exists?(file)

    content = File.read(file)
    parse(content)
  end

  def parse(content : String)
    file_content_lines = content.split("\n")
    i = 0
    while i != file_content_lines.size
      line = file_content_lines[i]
      if line.starts_with?("[")
        line = line[1..-2]
        line_content = parse_node_line(line)
        id : String? = nil
        type : String? = nil
        path : String? = nil
        properties = {} of String => String
        line_content[1..].each do |content|
          if content.starts_with?("id=")
            id = content[4..-2]
          elsif content.starts_with?("type=")
            type = content[5..-1]
          elsif content.starts_with?("path=")
            path = content[5...-1]
            verify_file(path[7..])
            properties["path"] = path[7..]
          else
            property = content.split("=")
            properties[property[0]] = property[1]
          end
        end

        @nodes << Node.new(line_content[0], type, id, properties)
      elsif !line.blank?
        property = line.gsub(" ", "").split("=")
        if property[1].starts_with?("ExtResource")
          verify_resource(property[1])
        elsif property[1] == "{"
          i += 1
          while file_content_lines[i] != "}"
            property = file_content_lines[i].split(":")
            if property[1].starts_with?("ExtResource") || property[1].starts_with?("SubResource")
              verify_resource(property[1])
            end
            i += 1
          end
        end
        @nodes.last.properties[property[0]] = property[1]
      end
      i += 1
    end
  end

  private def parse_node_line(line)
    result = [""]
    inside_paranthesis = false
    line.each_char do |char|
      if char == '('
        inside_paranthesis = true
      elsif char == ')'
        inside_paranthesis = false
      elsif char == ' ' && !inside_paranthesis
        result << ""
      else
        result[-1] += char
      end
    end
    result
  end

  private def verify_resource(resource)
    resource_id = resource[13..-3]
    if !@nodes.any? { |x| x.id == resource_id } && !@missing_resources.includes?(resource_id)
      @missing_resources << resource_id
    end
  end

  private def verify_file(file)
    if !File.exists?(file) && !@missing_files.includes?(file)
      @missing_files << file
    end
  end
end
