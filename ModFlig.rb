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
