require 'webdrivers'
require 'watir'
require 'pry'
require 'yaml'
require 'open-uri.rb'
require 'mechanize'
@run = false
@download_directory = "/home/dinesh/RubymineProjects/OpenMW_AutoMod"

#Watir.default_timeout = 60000

class NexusMods

  def login
    browser = open_browser("nexusmods.com")
    puts "Press Enter when logged in"
    gets
    return browser
  end

  def find_download_button (browser)
    browser.li.wait_until_present
    urls = browser.lis.to_a
    urls.each do |url|
      if url.id.include?'action-manual'
        download_button = url.children[0].children[0]
        return download_button
      end
    end
  end

  def download(links, link_numbers)
    browser = NexusMods.login
    combined_links = links.zip(link_numbers)
    combined_links.each do |link, link_number|
      browser.goto(link)
      download_button = NexusMods.find_download_button(browser)
      begin
        download_button.click
      rescue
        puts "Make browser fullscreen"
        gets
        retry
      end
      sleep(5)
      puts link_number
      append_file(link_number)
    end
  end

end

class ModFlig

  def download(links, link_numbers)
    combined_links = links.zip(link_numbers)
    combined_links.each do |link, link_number|
      file_link = ModFlig.convert_link(link)
      download_file = ModFlig.mechanize_download(file_link, link_number)
      Dir.chdir(@download_directory)
      download_file.save
    end
  end

  def convert_link(link)
    link_parts = link.split(/(\/+)|(-)/)
    file_link = "http://" + link_parts[2] + "/file.php?id=" + link_parts[8]
    return file_link
  end

  def mechanize_download(file_link, link_number)
    agent = Mechanize.new
    download_file = agent.get(file_link)
    download_file.filename = link_number.to_s + download_file.filename
    return download_file
  end

end

class ModdingOpenMW

  def find_links(link)
    url = link.children[0].children[0].href
    if url.start_with? 'https://modding-openmw.com/mods/steps/?step='
      return link.children[1].children[0].href
    end
  end

  def convert_elements(mod_type)
    browser = open_browser(mod_type)
    browser.tr.wait_until_present
    all_links = browser_link.trs
    links_arr = all_links.to_a
    links_arr.shift
    return links_arr
  end

  def scrape (mod_type)
    download_links = []
    links_arr = convert_elements(mod_type)
    puts "Scraping links from:" + mod_type + "..."
    links_arr.each do |link|
      download_link = find_links(link)
      download_links.push download_link
      puts download_link
    end
    puts "#{download_links.length} links collected"
    browser_link.close
    return download_links
  end

end

def open_browser(link)
  unless @run
    @download_directory = get_download_directory
    @run = true
  end
  prefs = {
      download: {
          prompt_for_download: false,
          default_directory: @download_directory
      }
  }
  browser = Watir::Browser.new :chrome, options: {prefs: prefs}
  browser.goto(link)
  return browser
end

def append_file(number)
  Dir.chdir(@download_directory)
  file_directory = Dir.glob(@download_directory + "/*.*").max_by {|f| File.mtime(f)}
  directory_parts = file_directory.split('/')
  filename = number.to_s + directory_parts.last
  binding.pry
  File.rename(file_name, file_directory - directory_parts + filename)
end

def get_download_directory
  puts "Enter path to download files to"
  @download_directory = gets
  @download_directory = @download_directory.chomp
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
puts  "The following links have to be manually downloaded and renamed, please append the number shown in front of
the link to the downloaded file (Note: this only applies to mods that involve extraction of data files for mods like
soundtracks or tools to fix leveled lists please refer to the instructions posted at modding-openmw.com): "
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

  NexusMods.download(nexus_links, nexus_link_numbers)
  ModFlig.download(mod_flig_links, mod_flig_link_numbers)
end

############# END OF FUNCTION DEFINITIONS #############

#down_links = ModdingOpenMW.scrape("https://modding-openmw.com/mods/")
#write_yaml("download_links.yml", down_links)

link_gateway(read_yaml("download_links.yml"))

