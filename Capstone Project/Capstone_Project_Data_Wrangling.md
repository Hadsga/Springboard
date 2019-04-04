#### Packages

    library(purrrlyr)
    library(plyr)
    library(tidyverse)
    library(knitr)
    library(MASS)

1 Reading in of the data
========================

The dataset is a JSON file with multiple JSON values inside the file.
Each JSON value is considered as an independent object. In this case,
each information makes up one single JSON value. Therefore, there are
many JSON values inside of the JSON file. In this case, there is a need
to use the "stream\_in()" function instead of the "fromJSON()" function.
Moreover, some columns are data frames which in turn contain different
data frames. Flaten makes the nested hierarchical data structure of
these columns into a flatten manner by assigning each of the nested
variables as its own column as much as possible.

    yelp = stream_in(file("yelp_academic_dataset_business.json"))
    yelp_flat = flatten(yelp)
    yelp_tbl = tbl_df(yelp_flat)

2 Discovering the data
======================

    glimpse(yelp_tbl)

    ## Observations: 144,072
    ## Variables: 16
    ## $ business_id  <chr> "0DI8Dt2PJp07XkVvIElIcQ", "LTlCaCGZE14GuaUXUGbamg...
    ## $ name         <chr> "Innovative Vapors", "Cut and Taste", "Pizza Pizz...
    ## $ neighborhood <chr> "", "", "Dufferin Grove", "", "Downtown Core", ""...
    ## $ address      <chr> "227 E Baseline Rd, Ste J2", "495 S Grand Central...
    ## $ city         <chr> "Tempe", "Las Vegas", "Toronto", "Oakdale", "Toro...
    ## $ state        <chr> "AZ", "NV", "ON", "PA", "ON", "ON", "AZ", "AZ", "...
    ## $ postal_code  <chr> "85283", "89106", "M6H 1L5", "15071", "M5B 2C2", ...
    ## $ latitude     <dbl> 33.37821, 36.19228, 43.66105, 40.44454, 43.65983,...
    ## $ longitude    <dbl> -111.93610, -115.15927, -79.42909, -80.17454, -79...
    ## $ stars        <dbl> 4.5, 5.0, 2.5, 4.0, 3.0, 2.5, 3.5, 2.5, 4.5, 3.5,...
    ## $ review_count <int> 17, 9, 7, 4, 8, 3, 8, 9, 11, 3, 7, 38, 4, 4, 3, 3...
    ## $ is_open      <int> 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1...
    ## $ attributes   <list> [<"BikeParking: True", "BusinessAcceptsBitcoin: ...
    ## $ categories   <list> [<"Tobacco Shops", "Nightlife", "Vape Shops", "S...
    ## $ hours        <list> [<"Monday 11:0-21:0", "Tuesday 11:0-21:0", "Wedn...
    ## $ type         <chr> "business", "business", "business", "business", "...

3 Subsetting the data frame
===========================

Since the goal of this analyses is to perform a market-analyses for
Asian restaurants the data set will be subsetted.

3.1 Filtering for Restaurants and Fast Food
-------------------------------------------

Let´s take a look at the most common categories in the data set. As you
can see, the restaurant category is most frequent.

    yelp_tbl %>%
      dplyr::select(categories) %>%
      filter(categories != "NULL") %>%
      unnest(categories) %>% 
      dplyr::count(categories) %>%
      arrange(-n) %>%
      head(10)

    ## # A tibble: 10 x 2
    ##    categories           n
    ##    <chr>            <int>
    ##  1 Restaurants      48485
    ##  2 Shopping         22466
    ##  3 Food             21189
    ##  4 Beauty & Spas    13711
    ##  5 Home Services    11241
    ##  6 Nightlife        10524
    ##  7 Health & Medical 10476
    ##  8 Bars              9087
    ##  9 Automotive        8554
    ## 10 Local Services    8133

Now, all businesses will be filtered which belong to the category
"Restaurants".

    yelp_tbl_restaurants = yelp_tbl %>%
      filter(grepl("Restaurants", categories))

2.2 Filtering for asian food categories
---------------------------------------

Next, let´s take a look at the restaurant categories.

    yelp_tbl_restaurants %>%
      dplyr::select(categories) %>%
      filter(categories != "NULL") %>%
      unnest(categories) %>%
      distinct() %>%
      head(10)

    ## # A tibble: 10 x 1
    ##    categories   
    ##    <chr>        
    ##  1 Restaurants  
    ##  2 Pizza        
    ##  3 Chicken Wings
    ##  4 Italian      
    ##  5 Tex-Mex      
    ##  6 Mexican      
    ##  7 Fast Food    
    ##  8 Hawaiian     
    ##  9 Barbeque     
    ## 10 Cafes

Because the analysis is dealing with Asian restaurants only those
restaurants will be kept which are offer Asian food.

    asian_food_categories = c("Chinese", "Japanese", "Sushi Bars", "Indian", "Asian Fusion", "Thai", "Vietnamese", "Korean", "Dim Sum", "Filipino", "Taiwanese", "Hot Pot", "Szechuan", "Cantonese", "Malaysian", "Mongolian", "Myanmar", "Pan Asian", "Indonesian", "Teppanyaki", "Singaporean", "Laotian", "Shanghainese", "Izakaya", "Japanese Curry", "Wok", "Tempura", "Tonkatsu")

    yelp_tbl_aisan_restaurants = yelp_tbl_restaurants %>%
      unnest(categories) %>%
      filter(categories %in% asian_food_categories) %>%
      dplyr::select(business_id) %>% 
      distinct() %>% 
      left_join(yelp_tbl_restaurants, by = "business_id")

2.3 Removing non asian food categories
--------------------------------------

Furthermore, all categories will be removed which are not an Asian food
category.

    yelp_tbl_aisan_restaurants$categories = lapply(yelp_tbl_aisan_restaurants$categories, 
    function(x) x[x %in%  asian_food_categories])

3 Data Cleaning
===============

3.1 NA values
-------------

Now, in all empty cells, a "NA" value will be imputed, which is a
missing value indicator.

    yelp_tbl_aisan_restaurants[yelp_tbl_aisan_restaurants == ""] = NA 

3.2 City
--------

Let´s take a look at the column city regarding misspellings (all other
columns were checked as well but only the column city had some issues).

    yelp_tbl_aisan_restaurants %>%
      dplyr::select(city) %>%
      dplyr::count(city) %>%
      arrange(-n)

    ## # A tibble: 337 x 2
    ##    city              n
    ##    <chr>         <int>
    ##  1 Toronto        1919
    ##  2 Las Vegas      1188
    ##  3 Montréal        685
    ##  4 Phoenix         458
    ##  5 Markham         416
    ##  6 Mississauga     367
    ##  7 Charlotte       352
    ##  8 Pittsburgh      290
    ##  9 Edinburgh       267
    ## 10 Richmond Hill   216
    ## # ... with 327 more rows

As you can see, there are five different spellings.

    yelp_tbl_aisan_restaurants %>%
      dplyr::select(city) %>%
      filter(grepl("vega|las ", ignore.case = T, city)) %>%
      distinct()

    ## # A tibble: 5 x 1
    ##   city           
    ##   <chr>          
    ## 1 Las Vegas      
    ## 2 North Las Vegas
    ## 3 Las  Vegas     
    ## 4 South Las Vegas
    ## 5 N Las Vegas

So all values will be replaced with "Las Vegas".

    yelp_tbl_aisan_restaurants = yelp_tbl_aisan_restaurants %>%
      mutate(city = ifelse(grepl("vega|las ", ignore.case = T, city), 
                           "Las Vegas", city))

4 Data Enriching
================

4.1 attributes
--------------

In order to create the mashine learning model, all values of the column
attributes will be transfered into their own column.

    yelp_tbl_attributes = yelp_tbl_aisan_restaurants %>%
      dplyr::select(business_id, attributes) %>%
      mutate(Num_attributes = length(attributes))

    yelp_tbl_attributes = yelp_tbl_attributes %>% 
      mutate(num_atts = map_int(attributes, length)) %>%
      filter(num_atts > 0) %>% 
      unnest(attributes) %>%
      separate(attributes, into = c("key", "value"), extra = "merge") %>% 
      spread(key, value) %>%
      dplyr::select(-num_atts, -Num_attributes)

### 4.1.1 Ambiance, BestNights, BusinessParking, DietaryRestrictions, Music and GoodForMeal

Since the variables of Ambiance, BestNights, BusinessParking,
DietaryRestrictions and GoodForMeal are nested (i.e. they variable
values are variables itself) the precedure has to be repeated.

    yelp_tbl_attributes = yelp_tbl_attributes %>% 
      mutate(Ambience = strsplit(str_remove_all(Ambience, '[\'|}]'), ",")) %>%
      unnest() %>%
      mutate_at(vars(Ambience), str_trim) %>%
      separate(Ambience, into = c("key", "value"), extra = "merge", sep = ":") %>%
      spread(key, value)

    yelp_tbl_attributes = yelp_tbl_attributes %>%
      mutate(Music = strsplit(str_remove_all(Music, '[\'|}]'), ",")) %>%
      unnest() %>%
      mutate_at(vars(Music), str_trim) %>%
      separate(Music, into = c("key", "value"), extra = "merge", sep = ":") %>%
      spread(key, value)

     yelp_tbl_attributes = yelp_tbl_attributes %>% 
      mutate(BusinessParking = strsplit(str_remove_all(BusinessParking, '[\'|}]'), ",")) %>%
      unnest() %>%
      mutate_at(vars(BusinessParking), str_trim) %>%
      separate(BusinessParking, into = c("key", "value"), extra = "merge", sep = ":") %>%
      spread(key, value)
     
    yelp_tbl_attributes = yelp_tbl_attributes %>% 
      mutate(BestNights = strsplit(str_remove_all(BestNights, '[\'|}]'), ",")) %>%
      unnest() %>%
      mutate_at(vars(BestNights), str_trim) %>%
      separate(BestNights, into = c("key", "value"), extra = "merge", sep = ":") %>%
      spread(key, value)

    yelp_tbl_attributes = yelp_tbl_attributes %>% 
      mutate(DietaryRestrictions = strsplit(str_remove_all(DietaryRestrictions, '[\'|}]'), ",")) %>%
      unnest() %>%
      mutate_at(vars(DietaryRestrictions), str_trim) %>%
      separate(DietaryRestrictions, into = c("key", "value"), extra = "merge", sep = ":") %>%
      spread(key, value)

    yelp_tbl_attributes = yelp_tbl_attributes %>% 
      mutate(GoodForMeal = strsplit(str_remove_all(GoodForMeal, '[\'|}]'), ",")) %>%
      unnest() %>%
      mutate_at(vars(GoodForMeal), str_trim) %>%
      separate(GoodForMeal, into = c("key", "value"), extra = "merge", sep = ":") %>%
      spread(key, value) %>%
      dplyr::select(-`<NA>`)

    yelp = left_join(yelp_tbl_aisan_restaurants, yelp_tbl_attributes, by = "business_id")

5 Saving the data frame
=======================

As the last step, the dataset will be saved as a "Rda" file.

    colnames(yelp) = make.names(colnames(yelp), unique = T) 

    save(yelp, file="yelp.Rda")
