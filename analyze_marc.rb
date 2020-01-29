# frozen_string_literal: true

require 'marc'
require 'json'
require 'csv'

reader = MARC::Reader.new(ARGV[0], external_encoding: 'UTF-8')

report = {
  '2020' => { 'items' => 0, 'pages' => 0 },
  '2021' => { 'items' => 0, 'pages' => 0 },
  '2022' => { 'items' => 0, 'pages' => 0 },
  '2023' => { 'items' => 0, 'pages' => 0 },
  '2024' => { 'items' => 0, 'pages' => 0 }
}

unusable_dates = {
  'unusable_dates' => 0
}

def add_unused_date(curr_count)
  curr_count.to_i + 1
end

def add_pages(curr_count, addition)
  curr_count.to_i + addition.to_i
end

def add_items(curr_count)
  curr_count.to_i + 1
end

def embargo_year(pub_date)
  year = pub_date.to_i

  case year
  when year < 1000
    0
  when (1000..1925) == year
    2020
  when 1926
    2021
  when 1927
    2022
  when 1928
    2023
  when 1929
    2024
  end
end

def pub_date(record)
  pub_type = record['008'].to_s[10]

  case pub_type
  when 'r'
    record['008'].to_s[15..18]
  when 't'
    record['008'].to_s[15..18]
  else
    record['008'].to_s[11..14]
  end
end

reader.each do |record|
  pub_record = record['300']
  pub = pub_record && record['300']['a'].to_s

  pages_or_leaves = /\d+ (p\.|leaves)/.match(pub).to_s
  number_of_pages = /\d+/.match(pages_or_leaves)

  year = embargo_year(pub_date(record))

  # puts "#{pub_date(record)} #{pub_record} #{pages_or_leaves} #{number_of_pages}"

  if year&.zero?
    unusable_dates['unusable_dates'] = add_unused_date(unusable_dates['unusable_dates'])
  elsif year # exclude anything published later than 1929..
    report[year.to_s]['items'] = add_items(report[year.to_s]['items'])
    report[year.to_s]['pages'] = add_pages(report[year.to_s]['pages'], number_of_pages.to_s)
  end
end

puts report

CSV.open('./output.csv', 'w') do |csv|
  header = []
  header << ''
  report.keys.each do |report_year|
    header << report_year
  end
  csv << header

  printable_values = []
  printable_values << 'Items'
  report.keys.each do |report_year|
    printable_values << report[report_year.to_s]['items']
  end

  csv << printable_values

  printable_values = []
  printable_values << 'Pages'
  report.keys.each do |report_year|
    printable_values << report[report_year.to_s]['pages']
  end

  csv << printable_values

  csv << []
  csv << ['Unusable dates', unusable_dates['unusable_dates']]
end
