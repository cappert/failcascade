class EveApi
  include HTTParty
  base_uri 'http://api.eveonline.com'

  def self.alliances
    get('/eve/AllianceList.xml.aspx')['eveapi']
  end

  def self.sovereignty
    get('/map/Sovereignty.xml.aspx')['eveapi']
  end
end
