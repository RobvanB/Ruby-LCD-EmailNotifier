class GmailCount
  require 'nokogiri'
  require 'net/https'

  username = ""
  password = ""

  begin
    http = Net::HTTP.new("mail.google.com", 443)
    http.use_ssl = true
    http.start do |http|
      req = Net::HTTP::Get.new("/mail/feed/atom", {"User-Agent" =>
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2)"})
      req.basic_auth(username, password)
      @response = http.request(req)
    end

    htmlDoc  = Nokogiri::HTML(@response.body)
    #puts htmlDoc.to_s

    node = htmlDoc.xpath("//title")
    if (node[0].content == 'Unauthorized')
      puts "Authentication Error"
    else
      node =  htmlDoc.xpath("//fullcount")
      puts " The Node "
      puts node[0].content
    end
  end
end