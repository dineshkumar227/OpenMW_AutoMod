class NexusMods
  @profile = Selenium::WebDriver::Firefox::Profile.new
  class << self

    def open_browser(link, download_directory)
      init_browser(download_directory)
      browser = Watir::Browser.new :firefox, profile: @profile
      browser.goto(link)
      return browser
    end

    def init_browser(download_directory)
      @profile['browser.download.dir'] = download_directory
      @profile['browser.download.folderList'] = 2
      @profile['browser.download.manager.showWhenStarting'] = false
      @profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/x-rar-compressed, application/x-7z-compressed, application/zip'
    end

    def login(download_directory)
      browser = open_browser("nexusmods.com", download_directory)
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

    def get_latest_file(download_directory)
      Dir.chdir(download_directory)
      while !Dir.glob(download_directory + "/*.part").empty?
        sleep(5)
      end
      file_directory = Dir.glob(download_directory + "/*.*").max_by {|f| File.mtime(f)}
      return file_directory
    end

    def append_file(number, download_directory)
      file_directory = get_latest_file(download_directory) 
      directory_parts = file_directory.split('/')
      filename = number.to_s + "_" + directory_parts.last
      begin
        File.rename(directory_parts.last, filename)
      rescue
        binding.pry
      end
    end

    def download(links, link_numbers, download_directory)
      browser = login(download_directory)
      combined_links = links.zip(link_numbers)
      combined_links.each do |link, link_number|
        begin
          browser.goto(link)
        rescue Net::ReadTimeout
          puts "page taking too long to load, please check and press enter to continue"
          gets
        end

        download_button = find_download_button(browser)
        begin
          download_button.click
        rescue
          puts "Cant click/find the download button. Usually making your browser fullscreen resolves this. Press enter to retry and s to skip"
          tmp = gets
          tmp.chomp
          if tmp != 's'
            retry
          else
            next #fucking hipster ruby with no continue keyword
          end
        end
        sleep(5)
        puts link_number
        append_file(link_number, download_directory)
      end
    end
  end
end
