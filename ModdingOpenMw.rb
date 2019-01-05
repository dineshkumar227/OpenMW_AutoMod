
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

