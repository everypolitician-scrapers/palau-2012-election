#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.xpath('//p[strong[text()="FOR HOUSE OF DELEGATES"]]/following-sibling::table').each do |table|
    area = table.css('tr').first.text.tidy
    candidates = table.css('tr').drop(2).reject { |tr| tr.css('td').first.text.tidy.empty? }.map { |tr|
      tds = tr.css('td')
      {
        name: tds[0].text.tidy,
        area: area,
        votes: tds[3].text.tidy,
        party: "Independent",
        won: 'no',
        term: 2012,
      }
    }.sort_by { |c| c[:votes].to_i }.reverse
    candidates.first[:won] = 'yes'
    # puts candidates
    ScraperWiki.save_sqlite([:name, :area], candidates)
  end
end

scrape_list('http://www.oceaniatv.net/republic-of-palau-2012-elections-candidates/')
