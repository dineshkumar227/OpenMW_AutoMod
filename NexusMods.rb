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

