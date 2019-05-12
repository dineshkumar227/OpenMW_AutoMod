require 'webdrivers'
require 'watir'
require 'pry'
require 'yaml'
require 'open-uri.rb'
require 'mechanize'
require 'tmpdir'
require 'fileutils'
require_relative 'ModFlig'
require_relative 'NexusMods'

@download_directory 
#Watir.default_timeout = 60000

def make_temp
  if Dir.exist?(File.join(Dir.tmpdir, "OpenMW_AutoMod"))
    FileUtils.remove_dir(File.join(Dir.tmpdir, "OpenMW_AutoMod"))
    Dir.mkdir(File.join(Dir.tmpdir, "OpenMW_AutoMod"))
  else
    Dir.mkdir(File.join(Dir.tmpdir, "OpenMW_AutoMod"))
  end
  @download_directory = File.join(Dir.tmpdir, "OpenMW_AutoMod")
end

def get_download_directory
  make_temp
  puts "Enter path to download files to (default: " + @download_directory.to_s + ")"
  temp = gets
  temp = temp.chomp
  if Dir.exists?(temp)
    @download_directory = temp
    @download_directory = @download_directory.chomp
  end
  return @download_directory
end




def write_yaml(file_name, data)
  File.open(file_name, "w") do |f|
    f.flush
    f.write(data.to_yaml)
  end
end

def read_yaml(file_name)
  parsed = begin
             data = YAML.load(File.open(file_name))
           rescue ArgumentError => e
             puts "Could not parse YAML: #{e.message}"
           end
  return data
end



def user_download(manual_links, link_numbers)
  puts  "The following links have to be manually downloaded and renamed, please append the number shown in front of the link to the downloaded file like <number>_file.name (Note: this only applies to mods that involve extraction of data files for mods like soundtracks or tools to fix leveled lists please refer to the instructions posted at modding-openmw.com): "
  i = 0
  while i < manual_links.length
    puts "#{link_numbers[i]}: #{manual_links[i]}"
    i += 1
  end
  puts "\nPress enter to continue once finished"
  gets
end

def link_gateway(links)
  #supported_domains = ["mw.modhistory.com", "nexusmods.com", "download.fliggerty.com"]
  manual_links = []
  nexus_links = []
  mod_flig_links = []
  mod_flig_link_numbers = []
  nexus_link_numbers = []
  manual_link_numbers = []
  i = 1

  links.each do |link|
    unless  (link.include?("nexusmods.com") && !link.include?("tab=files")) || link.include?("mw.modhistory.com") || link.include?("download.fliggerty.com")
      manual_link_numbers.push i
      manual_links.push link
    end
    if link.include?("mw.modhistory.com") || link.include?("download.fliggerty.com")
      mod_flig_links.push link
      mod_flig_link_numbers.push i
    elsif link.include?("nexusmods.com")  && !link.include?("tab=files")
      nexus_links.push link
      nexus_link_numbers.push i
    end
    i += 1
  end
  user_download(manual_links, manual_link_numbers)
  puts "All manual links have been taken care of, you may now leave and grab a cup of coffee\n"

  NexusMods.download(nexus_links, nexus_link_numbers, @download_directory)
  ModFlig.download(mod_flig_links, mod_flig_link_numbers, @download_directory)
end

############# END OF FUNCTION DEFINITIONS #############

@download_directory = get_download_directory
#down_links = ModdingOpenMW.scrape("https://modding-openmw.com/mods/")
#write_yaml("download_links.yml", down_links)
link_gateway(read_yaml("download_links.yml"))
