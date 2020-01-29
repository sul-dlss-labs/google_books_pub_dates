## Initialize the Project
```apple js
bundle install
```
## Run the Script
E.g. using the full record set:
```apple js
ruby analyze_marc.rb marc/grin_all_barcodes.mrc
```

## On Dates
This script currently only captures dates from the 008, therefore some dates are skipped
because they are not parsable as an integer year. The running total of these dates are reported
as 'Unusable dates'.

## Viewing the Data
Open the `output.csv` file using Excel or similar spreadsheet editor

Optionally create a histogram using the spreadsheet tool's built-in graphing function.

## How the MARC Data Was Collected
On the Symphony server this is the command used to dump the catalog records:
```apple js
cat grin_all_barcodes.txt | selitem -iB -oK 2>/dev/null |\
catalogdump -j -n junktags_pubdate_pages -om 2>/dev/null > grin_all_barcodes.mrc
```

#### Notes on the command: 
`grin_all_barcodes.txt` is a flat file of just the barcodes. This file is piped to `selitem`.

`selitem` takes the barcode as an input and outputs the catalog key of the item. The catalog key is then 
piped to `catalogdump`.
 
`junktags_pubdate_pages` is a file on the Symphony server `sirsi@bodoni /s/sirsi/Unicorn/Custom` that
contains all of the unused MARC tags so that the catalog records used here only include the 008 and 300 fields. 

`catalogdump` outputs a MARC binary file of all the selected records. 
