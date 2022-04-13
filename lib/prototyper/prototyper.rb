require 'logger'
require 'fileutils'

class Prototyper
  def self.call(args)
    Prototyper.new(args).run
  end

  def initialize(args)
    @args = args
    @logger = Logger.new($stdout)
  end

  def run
    @origin_folder = @args[0]
    @destination_folder = @args[1]
    prototype_recursively(@origin_folder)
  end

  private

  def prototype_recursively(folder)
    prototype_folder(folder)

    Dir.new(folder).each_child do |child|
      path = "#{folder}/#{child}"
      prototype_recursively(path) if File.directory?(path)
    end
  end

  def prototype_folder(origin_folder)
    Dir.glob("#{origin_folder}/*.rb") do |file|
      @logger.info "Processing file -> #{File.basename(file)}"
      if File.exist?(file)
        prototype_file(file)
      else
        @logger.warn "File not found! -> #{file}"
      end
    end
  end

  def prototype_file(file)
    full_destination_path = "#{mount_destination_folder(file)}/#{determine_file_name(file)}"
    system("rbs prototype rb #{file} > #{full_destination_path}")
  end

  def mount_destination_folder(folder)
    destination_folder = File.dirname(@destination_folder + folder.gsub(@origin_folder, ''))
    FileUtils.mkdir_p(destination_folder) unless Dir.exist?(destination_folder)
    destination_folder
  end

  def determine_file_name(file)
    File.basename(file, '.rb').concat('.rbs')
  end
end
