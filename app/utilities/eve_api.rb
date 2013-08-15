class EveApi
  include HTTParty
  base_uri 'http://api.eveonline.com'

  def self.alliances
    result = get '/eve/AllianceList.xml.aspx'
    result['eveapi']['result']['rowset']['row']
  end
end
