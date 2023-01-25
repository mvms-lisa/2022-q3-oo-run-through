--Expenses Upload
copy into expenses(year_month_day, month, amount, pay_partner, type, description, department, department_id, quarter, year, label, filename)
from (select t.$1, t.$2, to_number(REPLACE(REPLACE(t.$3, '$', ''), ','), 12, 2), t.$4, t.$5, t.$6, t.$7, t.$8, t.$9, t.$10, t.$11, 'expenses_q3_2022.csv'
from @oo_expenses t) pattern='.*expenses_q3_2022.*' file_format = nosey_viewership 
ON_ERROR=SKIP_FILE FORCE=TRUE; 
