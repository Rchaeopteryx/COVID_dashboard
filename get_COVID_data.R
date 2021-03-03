
rm(list = ls()) # Clear environment (for re-runs of the script) - Use carefully!!!

require(data.table)

filepath <- c("https://opendata.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0.csv")

# read only the second line of the csv file
csv_line2 <- readLines(filepath, encoding = "UTF-8", n = 2)[2]
# split the character string at the commas
csv_update_field_raw <- unlist(strsplit(csv_line2, ","))[11]
# get the substring needed
csv_update_field <- substr(csv_update_field_raw,2,nchar(csv_update_field_raw))
# transform to date
update_status <- as.Date(csv_update_field, format = "%d.%m.%Y")
#delete obsolete objects
rm(csv_line2,csv_update_field_raw,csv_update_field) 

# read file
auxvar <- fread("COVID_data_auxvar.txt")

# compare dates and store result in boolean 'new_data'
if (!update_status==auxvar$last_update_status) new_data <- TRUE else new_data <- FALSE

if (new_data) {
    covid <- as.data.frame(fread(filepath, encoding = "UTF-8", colClasses = c("integer","factor","factor","factor","factor","factor","integer","integer","character","factor","factor","integer","integer","character","integer","integer","integer","factor")))
    save(covid,file="COVID_data.Rda")
}

if (!new_data) {
    load("COVID_data.Rda")
}

# if there was no new data
if (!new_data) {
    auxvar$last_check_datetime <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")
    fwrite(auxvar,"COVID_data_auxvar.txt")
}

# if new data was downloaded
if (new_data) {
    auxvar$last_check_datetime <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")
    auxvar$last_downl_datetime <- format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")
    auxvar$last_update_status <- as.Date(update_status)
    fwrite(auxvar,"COVID_data_auxvar.txt")
}
