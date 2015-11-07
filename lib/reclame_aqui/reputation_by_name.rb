require 'capybara'
require 'capybara/poltergeist'

# Configure Poltergeist to not blow up on websites with js errors aka every website with js
# See more options at https://github.com/teampoltergeist/poltergeist#customization
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
    js_errors: false,
    phantomjs_options: ["--load-images=no"],
    debug: false)
end

Capybara.default_driver = :poltergeist

class ReputationByName

  STATUS_MAP = {
    "reputacao-ra1000.png" => 1,
    "reputacao-otimo.png" => 2,
    "reputacao-bom.png" => 3,
    "reputacao-regular.png" => 4,
    "reputacao-ruim.png" => 5,
    "reputacao-nao-recomendado.png" => 6
  }

  def initialize(name)
    @name = name
  end

  def get_reputation
    begin
      do_scrap
    rescue => error
      { error: true, message: error.message, reputation: {} }
    end
  end

  private
  def do_scrap
    browser = Capybara.current_session

    safe_name = URI.encode(@name)
    browser.visit "http://www.reclameaqui.com.br/busca/?q=#{safe_name}"

    company_name = browser.find(".titulo-resumo-resultado-empresa h3").text
    reputation_img = browser.find(".img-reputacao-reputacao img")['src'].match(/reputacao-.+/)[0]
    id = browser.find(".acao-resultado-empresa a:first-child")['href'].match(/([0-9]+)/)[0]
    nota_consumidor = browser.find(".numeros-indices:not(.second-line) li:first-child span").text.strip
    response_time = browser.find(".numeros-indices:not(.second-line) li:nth-child(2) span").text.strip
    complaints = browser.find(".numeros-indices.second-line li:last-child span").text.strip
    answered = browser.find(".numeros-indices.second-line li:nth-child(3) span").text.strip
    not_answered = browser.find(".numeros-indices.second-line li:nth-child(2) span").text.strip
    measured = browser.find(".numeros-indices.second-line li:first-child span").text.strip
    solution_index = browser.find(".graficos-indices li:nth-child(2) h3").text.strip.match(/\d+\.\d+/)[0]
    would_return = browser.find(".graficos-indices li:last-child h3").text.strip.match(/\d+\.\d+/)[0]

    { error: false,
      reputation: {
        id: id.to_i,
        name: company_name,
        period: 1,
        status: STATUS_MAP[reputation_img],
        complaints: complaints.to_i,
        answered: answered.to_i,
        not_answered: not_answered.to_i,
        measured: measured.to_i,
        solution_index: solution_index.to_i,
        would_return: would_return.to_i,
        grade: nota_consumidor.to_i,
        time_to_response: response_time,
        chat: nil,
        fone: nil,
        show_selo: nil
      }
    }
  end
end
