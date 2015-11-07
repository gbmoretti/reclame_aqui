require "net/http"
require "reclame_aqui/version"
require "reclame_aqui/reputation_by_website"
require "reclame_aqui/reputation_by_name"

module ReclameAqui
  def self.reputation(term)
    ReputationByWebsite.new(term).get_reputation
  end

  def self.reputation_by_name(term)
    ReputationByName.new(term).get_reputation
  end
end
