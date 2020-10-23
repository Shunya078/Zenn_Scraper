# ZennScraper
Zenn記事をスクレイピングして、Result.csvに書き出してくれるだけのシンプルなCLIツールです。

## ファイル構成
+ Zenn_Scraping
  + src
    + result.csv
    + zenn_article_scraper.rb
- .gitignore
- .ruby-version
- package-lock.json
- package.json
- README.md

## Usage
```
Scraping Zenn Topics!
      Usage: %ruby scraper.rb [-options]
      -h --help     , show help       / %ruby scraper.rb -h
      -s --scrape   , scrape web site / %ruby scraper.rb -s topic (option -> new, good)
```