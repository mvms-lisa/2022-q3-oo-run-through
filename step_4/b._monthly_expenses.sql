-- AWS
insert into monthly_expenses (amount, year_month_day, department_id, title, year, quarter, month, description, type, partner, department, viewership_type)
select amount, year_month_day, department_id, title, year, quarter, month, description, type, pay_partner, department, 'VOD' as viewership_type from expenses
where year = 2022 and quarter = 'q3' and pay_partner = 'aws'

-- POWR
insert into monthly_expenses (amount, year_month_day, department_id, title, year, quarter, month, description, type, partner, department, viewership_type)
select amount, year_month_day, department_id, title, year, quarter, month, description, type, pay_partner, department, 'VOD' as viewership_type from expenses
where year = 2022 and quarter = 'q3' and pay_partner = 'powr'

-- OAO - This was manually inserted and taken from the Register for Q3
    -- For Q4, we need to figure out how the split was done by department
    -- Previously was done by inserting non-FireTV temporary expenses in monthly_expenses into one lump sum to be joined with oao_expense_share


-- insert non-FireTV expenses (TEMPORARY - to delete after gam_data oao_expense_share is updated)
insert into monthly_expenses(
    amount, 
    year_month_day,
    department_id,
    title,
    year, 
    quarter,
    month,
    type,
    partner,
    department
  
)
select sum(e.amount), e.year_month_day, 3, title, year, quarter, month, 'Temporary' as type, pay_partner, department  from expenses e
where  e.department_id != 5 and e.quarter = 'q3' and e.year = 2022 and pay_partner = 'oao'
group by e.year_month_day, title, year, quarter, month, type, pay_partner, department

-- Update OAO Expense Share in gam_data table - must have temp mobile monthly share in monthly_expenses before this
update gam_data g
set g.oao_expense_share = q.expense_sh
from (
  select g.id as gid, oao_share * e.amount as expense_sh from gam_data g
  join monthly_expenses e on (e.year_month_day = g.year_month_day)
  where g.department_id != 5 and g.quarter = 'q3' and g.year = 2022 and e.department_id = 3
) q
where q.gid = g.id


--SELECT non-FireTV Temporary Expenses
select * from monthly_expenses where year = 2022 and quarter = 'q3' and department_id = 3 and type = 'Temporary'

--DELETE non-FireTV Temporary Expenses
delete from monthly_expenses where year = 2022 and quarter = 'q3' and department_id = 3 and type = 'Temporary'

-- OAO Mobile/Web
insert into monthly_expenses (amount, year_month_day, year, quarter, month, department_id, title, type, description )
select sum(oao_expense_share), year_month_day, year, quarter, month, 6 as department_id, 'OAO Adserving' as title, 'adserving' as type, 'OAO Mobile/Web Expenses' as description from gam_data
where year = 2022 and quarter = 'q3' and department_id !=2 --and advertiser != 'Tremor'
group by year_month_day, year, quarter, month

-- OAO FireTV
insert into monthly_expenses (amount, year_month_day, year, quarter, month, department_id, title, type, description )
select sum(oao_expense_share), year_month_day, year, quarter, month, 2 as department_id, 'OAO Adserving' as title, 'adserving' as type, 'OAO FireTV Expenses' as description from gam_data
where year = 2022 and quarter = 'q3' and department_id = 2 --and advertiser != 'Tremor'
group by year_month_day, year, quarter, month

----- Share CALCULATIONS
    -- 1. oao impression share (Updated 10/26/22 - Now removing Advertiser 'Tremor')
        -- Update where statement for quarter and year; replace 'X'
        insert into monthly_impressions(tot_impressions, year_month_day, partner, year, quarter, month, viewership_type)
        select sum(TOTAL_IMPRESSIONS), year_month_day, 'gam', year, quarter, month, 'VOD' as viewership_type from gam_data
        where quarter = 'q3' and year = 2022 and advertiser not in ('Spotx', 'Telaria')
        group by year_month_day, year, quarter, month
        

        -- update oao share
            -- Update where statement for quarter and year; replace 'X'
        update gam_data g
        set g.oao_share = q.oao
        from (
        select g.id as gid, total_impressions / m.tot_impressions as oao ,g.year_month_day, ad_unit from gam_data g
        join monthly_impressions m on (m.year_month_day = g.year_month_day)
        where  m.partner = 'gam' and g.quarter = 'q3' and g.year = 2022
        ) q
        where q.gid = g.id

        -- check (should == 1)
            -- Update where statement for quarter and year; replace 'X'
        select sum(oao_share), g.year_month_day from gam_data g
        join monthly_impressions m on (m.year_month_day = g.year_month_day)
        where  m.partner = 'gam' and g.quarter = 'q3' and g.year = 2022
        group by g.year_month_day
        