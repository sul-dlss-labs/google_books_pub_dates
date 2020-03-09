# frozen_string_literal: true

require 'marc'

def pub_type(record)
  record['008'].to_s[10]
end

def public_domain_year(pub_date)
  year = pub_date.to_i
  return 'Out or copyright' if year.between?(1000, 1925)
  return 'Out of copyright in 5 years' if year.between?(1926, 1929)
  return 'In copyright' if year > 1929
end

ARGV.each do |arg|
  MARC::Reader.new(arg, external_encoding: 'UTF-8').each do |record|
    next unless %w[d t u].include? pub_type(record)

    ckey = record['001'].to_s[5]
    copyright = public_domain_year(record['008'].to_s[15..18])
    barcodes = `echo #{ckey} | /s/sirsi/Unicorn/Bin/selitem -iC -oB 2>/dev/null`.split('|')
    barcodes = barcodes.collect{|b| b.strip || b }

    barcodes.each do |bc|
      puts "#{copyright}, #{bc}"
    end
  end
end
