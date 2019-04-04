library(tidyr)
library(stringr)
library(dplyr)


# 0. Loading data 
setwd("../Basic Data Manipulation")
refine = read.csv("refine_original.csv", sep=";")

# Task 1: Clean up brand names
# Clean up the company column so all of the misspellings of the brand names are standardized. 
# Transform the values in the column into philips, akzo, van houten and unilever. 

refine = refine %>% 
  mutate(company = replace(company, str_detect(company, "ips|phi"), "philips"))

refine = refine %>% 
  mutate(company = replace(company, str_detect(company, "van|ou"), "van houten"))

refine = refine %>% 
  mutate(company = replace(company, str_detect(company, "ak|zo|AK"), "akzo"))

refine = refine %>% 
  mutate(company = replace(company, str_detect(company, "uni|ver"), "unilever"))


# Task 2: Separate product code and number
# Separate the product code and product number into separate columns i.e. add two new columns 
# called product_code and product_number, containing the product code and number respectively.

refine = refine %>% 
  separate(Product.code...number, into = c("product_code", "product_number"), sep="-")


# 3. Add product categories
# Add a column with the product category for each record: 
# p = Smartphone, v = TV, x = Laptop, q = Tablet.

refine$product_category = ifelse(refine$product_code == "v", "TV", 
                          ifelse(refine$product_code == "p", "Smartphone", 
                          ifelse(refine$product_code == "x", "Laptop", 
                          ifelse(refine$product_code == "q", "Tablet", 999))))


# 4. Add full address for geocoding
# Create a new column full_address that concatenates the three address 
# fields (address, city, country), separated by commas.

refine = unite(refine, "full_address", c("address", "city", "country"), sep = ",")


# 5. Create dummy variables for company and product category
# Add four binary (1 or 0) columns for company and  product category. 

refine["product_smartphone"] = ifelse(refine$product_code == "p", 1,0)
refine["product_tv"] = ifelse(refine$product_code == "v", 1,0)
refine["product_laptop"] = ifelse(refine$product_code == "x", 1,0)
refine["product_tablet"] = ifelse(refine$product_code == "q", 1,0)

refine["company_philips"] = ifelse(refine$company == "philips", 1,0)
refine["company_akzo"] = ifelse(refine$company == "akzo", 1,0)
refine["company_van_houten"] = ifelse(refine$company == "van houten", 1,0)
refine["company_unilever"] = ifelse(refine$company == "unilever", 1,0)

# 6. Save File

write.csv(refine, file = "refine_clean.csv")
