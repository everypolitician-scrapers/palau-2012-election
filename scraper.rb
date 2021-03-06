#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'scraperwiki'
require 'nokogiri'
require 'pry'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.xpath('//p[strong[text()="FOR HOUSE OF DELEGATES"]]/following-sibling::table').each do |table|
    area = table.css('tr').first.text.tidy
    candidates = table.css('tr').drop(2).reject { |tr| tr.css('td').first.text.tidy.empty? }.map do |tr|
      tds = tr.css('td')
      {
        name:  tds[0].text.tidy,
        area:  area,
        votes: tds[3].text.tidy,
        party: 'Independent',
        won:   'no',
        term:  2012,
      }
    end.sort_by { |c| c[:votes].to_i }.reverse
    candidates.first[:won] = 'yes'
    # puts candidates
    ScraperWiki.save_sqlite(%i(name area), candidates)
  end
end

scrape_list('http://www.oceaniatv.net/republic-of-palau-2012-elections-candidates/')
