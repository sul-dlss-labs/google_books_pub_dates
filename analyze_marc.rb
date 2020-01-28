# frozen_string_literal: true

require 'marc'
require 'json'
require 'csv'

reader = MARC::Reader.new(ARGV[0], external_encoding: 'MARC-8')

report = {
  '2020' => { 'items' => 0, 'pages' => 0 },
  '2021' => { 'items' => 0, 'pages' => 0 },
  '2022' => { 'items' => 0, 'pages' => 0 },
  '2023' => { 'items' => 0, 'pages' => 0 },
  '2024' => { 'items' => 0, 'pages' => 0 }
}

def add_pages(curr_count, addition)
  curr_count.to_i + addition.to_i
end

def add_items(curr_count)
  curr_count.to_i + 1
end

def embargo_year(pub_date)
  case pub_date.to_i
  when pub_date.to_i < 1925
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
  pub_type = record['008'].to_s[6]
  case pub_type
  when 's'
    record['008'].to_s[7..10]
  else
    record['008'].to_s[11..14]
  end
end

reader.each do |record|
  pub = record['300']['a'].to_s

  pages_or_leaves = /\d+ (p\.|leaves)/.match(pub).to_s
  number_of_pages = /\d+/.match(pages_or_leaves)

  year = embargo_year(pub_date(record))

  if year # exclude anything published later than 1929..
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
end
