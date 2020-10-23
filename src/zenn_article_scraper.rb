require 'nokogiri'
require 'open-uri'
require 'csv'

class ZennArticleScraper
  ZENN_URL = 'https://zenn.dev'
  RESULT_FILE = 'result.csv'

  def initialize(command:, topic: nil, option: nil)
    @command = command
    @url = "#{ZENN_URL}/topics/#{topic}"
    @option = option
    @result = {}
    @path_hash = {
      title_link: '//a[@class="acu-link"]',
      date_link: '//time[@class="acu-date"]',
      good_link: '//span[@class="act-liked-count inline-flex-central"]',
      error_link: '//div[@class="error-status font-bold"]'
    }
    @dates = []
    @good_counts = []
  end

  def execute
    case @command
    when '-h', '--help'
      show_help
    when '-s', '--scrape'
      manage_writed_method
    end
  end

  private

  def setup_document
    charset = 'utf-8'
    html = open(@url, &:read)
    @document = Nokogiri::HTML.parse(html, nil, charset)
    @document.search('br').each { |n| n.replace("\n") }
  end

  def scrape
    @document.xpath("#{@path_hash[:title_link]}").each do |node|
      title = node.text
      url = node.attribute('href').value
      @result.store(title, "#{ZENN_URL}" + "#{url}")
    end
  end

  def scrape_date
    @document.xpath("#{@path_hash[:date_link]}").each do |node|
      @dates << node.text
    end
    scrape
  end

  def scrape_good
    @document.xpath("#{@path_hash[:good_link]}").each do |node|
      @good_counts << node.text
    end
    scrape
  end

  def manage_writed_method
    setup_document
    if @document.xpath("#{@path_hash[:error_link]}").text == '404'
      raise '404 Not Found.'
    end
    begin
      CSV.open(RESULT_FILE, 'w') do |csv|
        case @option
        when nil
          write_csv(csv)
        when 'new'
          write_csv_date(csv)
        when 'good'
          write_csv_good(csv)
        end
      end
      puts 'Succesfully scraping!'
    rescue StandardError
      puts 'Error scraping!'
    end
  end

  def write_csv(csv)
    csv << %w[ページタイトル URL]
    scrape
    @result.each { |key, value| csv << [key, value] }
  end

  def write_csv_date(csv)
    csv << %w[ページタイトル URL 何日前]
    scrape_date
    @result.each.with_index { |(key, value), i| csv << [key, value, @dates[i]] }
  end

  def write_csv_good(csv)
    csv << %w[ページタイトル URL いいね数]
    scrape_good
    @result.each.with_index do |(key, value), i|
      csv << [key, value, @good_counts[i]]
    end
  end

  def show_help
    puts <<~'EOS'
      Scraping Zenn Topics!
      Usage: %ruby scraper.rb [-options]
      -h --help     , show help       / %ruby scraper.rb -h
      -s --scrape   , scrape web site / %ruby scraper.rb -s topic (option -> new, good)
    EOS
  end
end

if __FILE__ == $0
  zenn_article_scraper =
    case ARGV[0]
    when '-h', '--help'
      ZennArticleScraper.new(command: ARGV[0])
    when '-s', '--scrape'
      ZennArticleScraper.new(command: ARGV[0], topic: ARGV[1], option: ARGV[2])
    end
  zenn_article_scraper.execute
end
