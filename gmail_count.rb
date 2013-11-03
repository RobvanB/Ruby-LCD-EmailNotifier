class GmailCount
  require 'nokogiri'
  require 'net/https'
  require_relative('ruby-lcd.rb')

  @lcd = RubyLcd.new()
  @countHash = Hash.new()

  def self.getCount(username, password)
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
      #puts "Authentication Error for account " + username
      @lcd.lcdPrint("Authentication Error for account " + username)
    else
      node      = htmlDoc.xpath("//fullcount")
      mailCount = node[0].content
      #puts username + " : " + node[0].content
      shortName = username.split("@")[0]
      puts shortName + " : " + mailCount
      #@lcd.lcdPrint(shortName + " : " + mailCount)
      @countHash[shortName] = mailCount
    end
  end

  def self.getCountLoop()
    @countHash.clear
    @doc.xpath("//account").each { |acc|
      #puts acc.to_s
      username = acc.xpath("uname")[0].content
      password = acc.xpath("pw")[0].content
      getCount(username, password)
    }
  end



  # Open the config file with the account info
  cfg = File.open("gmail_count_config.xml")
  @doc = Nokogiri::XML(cfg)
  cfg.close
  checkCount = 300

  while true
    # Keep updating the display, but only check for email once every 5 mins
    if (checkCount == 300)
        checkCount = 0
        getCountLoop()
    end

    @countHash.each() { |uname, mailcount|
      #puts 'lcd'
      #limit the length of the email acct name to 10
      uname = uname.sub[0,9]
      @lcd.lcdPrint(uname + " : " + mailcount)
      sleep 2
    }

      checkCount += 2
  end
end