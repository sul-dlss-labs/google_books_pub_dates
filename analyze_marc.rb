# frozen_string_literal: true

require 'marc'
require 'yaml'
require 'csv'
require 'yaml'

def add_unused_date(curr_count)
  curr_count.to_i + 1
end

def add_unused_pages(curr_count)
  curr_count.to_i + 1
end

def add_pages(curr_count, addition)
  curr_count.to_i + addition.to_i
end

def add_items(curr_count)
  curr_count.to_i + 1
end

def add(curr_count)
  curr_count.to_i + 1
end

def embargo_year(pub_date)
  year = pub_date.to_i

  return 0 if year < 1000

  return 2020 if year.between?(1000, 1925)

  case year
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

ARGV.each do |arg|
  puts "Processing #{arg}"
  report = YAML.load_file('yaml/report.yml')
  unusable_dates = YAML.load_file('yaml/unusable_dates.yml')
  unusable_pages = YAML.load_file('yaml/unusable_pages.yml')
  counter = YAML.load_file('yaml/counter.yml')

  MARC::Reader.new(arg, external_encoding: 'UTF-8').each do |record|
    counter[:count] = add(counter[:count])

    pub_record = record['300']
    pub = pub_record && record['300']['a'].to_s

    pages_or_leaves = /\d+ (p\.|leaves)/.match(pub)
    if pages_or_leaves.nil?
      unusable_pages[:unusable_pages] = add_unused_pages(unusable_pages[:unusable_pages])
    end

    pages = pages_or_leaves.to_s
    number_of_pages = /\d+/.match(pages).to_s

    year = embargo_year(pub_date(record))

    if year&.zero?
      unusable_dates[:unusable_dates] = add_unused_date(unusable_dates[:unusable_dates])
    elsif year # exclude anything published later than 1929..
      report[:years][year][:items] = add_items(report[:years][year][:items])
      report[:years][year][:pages] = add_pages(report[:years][year][:pages], number_of_pages)
    end
  end

  File.open('yaml/report.yml', 'w') { |f| f.write(report.to_yaml) }
  File.open('yaml/unusable_dates.yml', 'w') { |f| f.write(unusable_dates.to_yaml) }
  File.open('yaml/unusable_pages.yml', 'w') { |f| f.write(unusable_pages.to_yaml) }
  File.open('yaml/counter.yml', 'w') { |f| f.write(counter.to_yaml) }

  puts "Processed: #{counter[:count]}"
  puts "Unused dates: #{unusable_dates[:unusable_dates]}"
  puts "Unused pages: #{unusable_pages[:unusable_pages]}"
  puts report
end

CSV.open('report/output.csv', 'w') do |csv|
  report = YAML.load_file('yaml/report.yml')

  header = []
  header << ''
  report[:years].keys.each do |report_year|
    header << report_year
  end
  csv << header

  printable_values = []
  printable_values << 'Items'
  report[:years].each do |year, v|
    printable_values << report[:years][year][:items]
  end

  csv << printable_values

  printable_values = []
  printable_values << 'Pages'
  report[:years].each do |year, v|
    printable_values << report[:years][year][:pages]
  end

  csv << printable_values
end

CSV.open('report/not_parsed.csv', 'w') do |csv|
  unusable_dates = YAML.load_file('yaml/unusable_dates.yml')
  unusable_pages = YAML.load_file('yaml/unusable_pages.yml')
  counter = YAML.load_file('yaml/counter.yml')

  csv << ['Items processed', counter[:count]]
  csv << ['Dates not parsed', unusable_dates[:unusable_dates]]
  csv << ['Pages not parsed', unusable_pages[:unusable_pages]]
end

system('ruby new_yaml.rb')
