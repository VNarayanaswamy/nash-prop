# Explore Nashville Property Data

## Organization

scraper/prop_scraper.R functions for scrapping http://padctn.org/  
scraper/json_to_db.R functions for munging records and writing to sql database tables  
utils/sql_wrappers.R fucntions for getting database settings and connecting  
shiny-app/ code for shiny app for querying database and visualizing results  


## Example scraped record
```
{
    "Property": [
        {
            "Map & Parcel": "161 10 0B 187.00",
            "Location": "4700 CHEPSTOW DR",
            "Mailing Address": " 4825 ENOCH DR, NASHVILLE, TN 37211",
            "Legal Description": "LOT 33 VILLAGES OF BRENTWOOD PHASE 11 FINAL PLAT",
            "Tax District": "USD  View Tax Record",
            "Assessment Classification*": "RES",
            "Legal Reference": "20160503-0043205 View Deed",
            "Sale Date": "04/29/2016",
            "Sale Price": "$264,000",
            "Assessment Year": "2017",
            "Last Reappraisal Year": "2017",
            "Improvement Value": "$242,600",
            "Land Value": "$45,000",
            "Total Appraisal Value": "$287,600",
            "Assessed Value": "$71,900",
            "Property Use": "SINGLE FAMILY",
            "Zone": "1",
            "Neighborhood": "4038",
            "Land Area": "0.22 Acres",
            "Property Type": "SINGLE FAM",
            "Year Built": "2000",
            "Square Footage": "2,706",
            "Exterior Wall": "BRICK/FRAME",
            "Story Height": "TWO STY",
            "Building Condition": "Average",
            "Foundation Type": "CRAWL",
            "Number of Rooms": "9",
            "Number of Beds": "4",
            "Number of Baths": "2",
            "Number of Half Bath": "1",
            "Number of Fixtures": "12",
            "lat": "36.04430000",
            "lng": "-86.73020000"
        }
    ],
    "Building": [
        {
            "Property Type": "SINGLE FAM",
            "Year Built": "2000",
            "Story Height": "TWO STY",
            "Living Units": "1",
            "Exterior Wall": "BRICK/FRAME",
            "Building Condition": "Average",
            "Foundation Type": "CRAWL",
            "Roof Cover": "ASPHALT",
            "Number of Rooms": "9",
            "Number of Beds": "4",
            "Number of Baths": "2",
            "Number of Half Bath": "1",
            "Number of Fixtures": "12"
        }
    ],
    "Sales": [
        {
            "Sale Date": "04/29/2016",
            "Sale Price": "$264,000",
            "Deed Type": "WARRANTY DEED",
            "Deed Book & Page": "20160503-0043205"
        },
        {
            "Sale Date": "03/16/2010",
            "Sale Price": "$226,000",
            "Deed Type": "WARRANTY DEED",
            "Deed Book & Page": "20100318-0020329"
        },
        {
            "Sale Date": "04/26/2007",
            "Sale Price": "$235,000",
            "Deed Type": "WARRANTY DEED",
            "Deed Book & Page": "20070502-0052273"
        },
        {
            "Sale Date": "03/30/2007",
            "Sale Price": "$0",
            "Deed Type": "QUIT CLAIM",
            "Deed Book & Page": "20070502-0052272"
        },
        {
            "Sale Date": "11/27/2000",
            "Sale Price": "$178,737",
            "Deed Type": "WARRANTY DEED",
            "Deed Book & Page": "20001206-0120256"
        },
        {
            "Sale Date": "08/08/2000",
            "Sale Price": "$65,000",
            "Deed Type": "WARRANTY DEED",
            "Deed Book & Page": "20000817-0081457"
        },
        {
            "Sale Date": "08/20/1998",
            "Sale Price": "$0",
            "Deed Type": "WARRANTY DEED",
            "Deed Book & Page": "0000661-00011076"
        }
    ],
    "Appraisals": [
        {
            "Year": "2017",
            "Land Use Code": "R11 - RES",
            "Building": "$242,600",
            "Yard Items": "$0",
            "Land Value": "$45,000",
            "Category": "ROLL",
            "Total": "$287,600"
        },
        {
            "Year": "2013",
            "Land Use Code": "R11 - RES",
            "Building": "$213,800",
            "Yard Items": "$0",
            "Land Value": "$36,000",
            "Category": "ROLL",
            "Total": "$249,800"
        },
        {
            "Year": "2009",
            "Land Use Code": "R11 - RES",
            "Building": "$215,700",
            "Yard Items": "$0",
            "Land Value": "$36,000",
            "Category": "ROLL",
            "Total": "$251,700"
        },
        {
            "Year": "2005",
            "Land Use Code": "R11 - RES",
            "Building": "$195,400",
            "Yard Items": "$0",
            "Land Value": "$36,000",
            "Category": "ROLL",
            "Total": "$231,400"
        },
        {
            "Year": "2001",
            "Land Use Code": "R11 - RES",
            "Building": "$167,400",
            "Yard Items": "$0",
            "Land Value": "$36,000",
            "Category": "ROLL",
            "Total": "$203,400"
        },
        {
            "Year": "2000",
            "Land Use Code": "R10 - RES",
            "Building": "$0",
            "Yard Items": "$0",
            "Land Value": "$20,000",
            "Category": "RLL",
            "Total": "$20,000"
        }
    ]
}
```
