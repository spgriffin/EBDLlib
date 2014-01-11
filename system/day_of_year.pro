function day_of_year, month, day, year
first_day_of_year=julday(1,1,year)
current_day_of_year=julday(month,day,year)
day_of_year=current_day_of_year-first_day_of_year + 1
return, day_of_year
end
