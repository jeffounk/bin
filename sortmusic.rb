types = ['flac', 'ogg', 'mp3']

require 'fileutils'
dir = ARGV[0]
abort "No directory given" unless dir
abort "#{dir} is not a directory" unless Dir::exist?(dir)
dir = dir.chomp("/")

def create_links(type, types, dir, path)
  Dir.new(dir).each do |entry|
    unless entry == "." or entry == ".."
      if entry == type
        Dir.new(dir + "/" + entry).each do |sub_entry|
          unless sub_entry == "." and sub_entry == ".."
            FileUtils::mkdir_p(path) unless Dir::exist?(path)
            src = dir + "/" + entry + "/" + sub_entry
            dest = path + "/" + sub_entry
            File.link(src, dest) unless File::exist?(dest)
          end
        end
      elsif File::directory?(dir + "/" + entry)
        create_links(type, types, dir + "/" + entry, path + "/" + entry)
      else
        ext = File::extname(entry).sub(/^\./, '')
        if ext == type
          FileUtils::mkdir_p(path) unless Dir::exist?(path)
          src = dir + "/" + entry
          dest = path + "/" + entry
          File.link(src, dest) unless File::exist?(dest)
        end
      end
    end
  end
end

types.each do |type|
  path = dir + "/../" + type
  FileUtils::remove_dir(path, true) if File::exist?(path)
  create_links(type, types, dir, path)
end

