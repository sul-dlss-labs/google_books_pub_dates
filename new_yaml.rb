# frozen_string_literal: true

require 'yaml'

report = {
  years: {
    2020 => { items: 0, pages: 0 },
    2021 => { items: 0, pages: 0 },
    2022 => { items: 0, pages: 0 },
    2023 => { items: 0, pages: 0 },
    2024 => { items: 0, pages: 0 }
  }
}
File.open('yaml/report.yml', 'w').write(report.to_yaml)

unusable_dates = { unusable_dates: 0 }
File.open('yaml/unusable_dates.yml', 'w').write(unusable_dates.to_yaml)

unusable_pages = { unusable_pages: 0 }
File.open('yaml/unusable_pages.yml', 'w').write(unusable_pages.to_yaml)

counter = { count: 0 }
File.open('yaml/counter.yml', 'w').write(counter.to_yaml)
