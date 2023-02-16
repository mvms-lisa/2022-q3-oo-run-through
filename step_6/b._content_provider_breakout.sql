--Expenses
select * from expenses where year = 2022 and quarter = 'q3' and pay_partner = 'powr'

select sum(amount) from expenses where year = 2022 and quarter = 'q3' and pay_partner = 'oao' and type != 'roku'

--Revenue
select * from revenue where year = 2022 and quarter = 'q3' and pay_partner = 'vizio'

select concat(department, 'Revenue') from revenue where year = 2022 and quarter = 'q3' and type is null and department_id != 0

select * from revenue where year = 2022 and quarter = 'q3' and type is null and department_id != 0


-- GAM Data
select * from gam_data where year = 2022 and quarter = 'q3' a

-- SpotX
select * from spotx where year = 2022 and quarter = 'q3' 

-- Monthly Expenses
select * from monthly_expenses where year = 2022 and quarter = 'q3'

-- Monthly Revenue
select * from monthly_revenue where year = 2022 and quarter = 'q3'

select sum(tot_revenue) from monthly_revenue where year = 2022 and quarter = 'q3'

-- Monthly Impressions
select * from monthly_impressions where year = 2022 and quarter = 'q3' and partner = 'gam'



-- monthly viewership - sum viewership minutes, grouped by department and year_month_day
-- content provider viewership - sum viewership minutes grouped by content_provider,  year_month_day and department
-- content provider share is determined by content provider viewership / monthly_viewership 


select p.department_id, p.year_month_day,sum(watch_time_seconds) from powr_viewership p
join nosey_staging.public.departments d on (d.id = p.department_id)
group by  p.department_id, p.year_month_day
order by p.year_month_Day, p.department_id


-- content provider share is determined by total viewership 
insert into content_provider_share (content_provider, department_id, year_month_day, total_viewership, year, quarter, month)
select content_provider, department_id, year_month_day, sum(watch_time_seconds), year, quarter, month from powr_viewership 
where year = 2022 and quarter = 'q3' and content_provider is not null and department_id is not null
group by content_provider, department_id, year_month_day, year, quarter, month
order by year_month_day, department_id

-- Content Provider Share
select * from content_provider_share where year = 2022 and quarter = 'q3'

-- insert viewership by dept and month (used for 1,3,4 departments...)
  -- Reminder: There is also a grouped record mobile/web of departments 1, 3, and 4 in MONTHLY_VIEWERSHIP as department = 6 (used to calc powr_share)
insert into  monthly_viewership(tot_viewership, department_id, department_name, year_month_day, usage, quarter, month, year)
select sum(watch_time_seconds), d.id, d.name, year_month_day, 'powr viewership share' as usage, quarter, month, year from powr_viewership p
join dictionary.public.temp_departments d on (d.id = p.department_id)
where quarter = 'q3' and year = 2022 and p.department_id not in (2, 5)
group by d.name, p.year_month_day, d.id, p.month, p.year, p.quarter


-- set the share of the content provider so that we can multiply by revenue to get rev_share 
  -- This share calculation uses the monthly_viewership records where departments 1, 3, and 4 and broken out instead of grouped together as mobile/web department 6
update content_provider_share c
set c.cp_share = q.cp_share
from (
  select c.id as id, c.year_month_day,c.department_id,c.content_provider, c.total_viewership / mv.tot_viewership as cp_share  from content_provider_share c
  join monthly_viewership mv on (mv.department_id = c.department_id and mv.year_month_day = c.year_month_day)
  where mv.usage = 'powr viewership share' and mv.department_id is not null and c.year = 2022 and c.quarter = 'q3' 
) q
where c.id = q.id

-- CHECK: should roughly equal 1 (ALL departments)
select sum(cp_share), year_month_day, department_id from content_provider_share
where year = 2022 and quarter = 'q3'
group by year_month_day, department_id

--CONTENT_PROVIDER_SHARE table
select * from content_provider_share where year = 2022 and quarter = 'q3'

-- overview of cp share by month and dept
select sum(cp_share), content_provider, year_month_day, department_id from content_provider_share
group by year_month_day, department_id, content_provider

-- share query
select c.id as id, c.year_month_day,c.department_id,c.content_provider, c.total_viewership / mv.tot_viewership as cp_share  from content_provider_share c
join monthly_viewership mv on (mv.department_id = c.department_id and mv.year_month_day = c.year_month_day)
where mv.usage = 'powr viewership share' and mv.department_id is not null 

-- revenue query
select c.id as id, c.year_month_day,c.department_id,c.content_provider, c.cp_share * mr.tot_revenue as rev_share, cp_share, partner from content_provider_share c
join monthly_revenue mr on (mr.department_id = c.department_id and mr.year_month_day = c.year_month_day)
where  mr.department_id is not null 


-- REGISTER INSERT - Revenue
insert into register (
    year_month_day,
    department_id, 
    content_provider, 
    amount, 
    description,
    title,
    year,
    month,
    quarter,
    label,
    type,
    viewership_type
)
select c.year_month_day, c.department_id, c.content_provider, c.cp_share * mr.tot_revenue as amount, 
mr.description, title, c.year, c.month, c.quarter, 'Revenue' as label, mr.type, c.viewership_type from content_provider_share c
join monthly_revenue mr on (mr.department_id = c.department_id and mr.year_month_day = c.year_month_day)
where  mr.department_id is not null and c.year = 2022 and c.quarter = 'q3' 


-- register query
select year_month_day, nd.name, partner as title,  content_provider, cp_share as content_provider_share, rev_share as revenue from register r
join nosey_staging.public.departments nd on (nd.id = r.department_id)


-- EXPENSES --

-- ** NOTES: 11/16/2022 Could be possible to use one table (content_provider_share, instead of having an additional cp_share_expense table? Would need to add columns.)
  -- Would need to test and think about it more. Writing down so I don't forget.

-- Content Provider Share Expense Table Insert (To be used for Expenses INSERT for REGISTER)
insert into cp_share_expense (content_provider, year_month_day, quarter, year, month, powr_share)
select content_provider, year_month_day, quarter, year, month, sum(powr_share) from powr_viewership
where year = 2022 and quarter = 'q3' and ref_id is not null and department_id is not null
group by content_provider, year_month_day, quarter, year, month

-- CHECK: cp_share_expense table
select * from cp_share_expense where year = 2022 and quarter = 'q3'

-- REGISTER INSERT - Expenses
insert into register (year_month_day, year, quarter, month, content_provider, amount, title, department_id, label, type)
select c.year_month_day, c.year, c.quarter, c.month, c.content_provider, c.powr_share * -me.amount, me.title, me.department_id, 'Expense' as Label, type from cp_share_expense c
join monthly_expenses me on (me.year_month_day = c.year_month_day)
where c.year = 2022 and c.quarter = 'q3' 


-- Check REV_SHARE (Topline Total)
select sum(rev_share) from powr_viewership where year = 2022 and quarter = 'q3'

select * from powr_viewership where year = 2022 and quarter = 'q3' and platform in ('undefined', 'generic')

-- Check MONTHLY_REVENUE Topline Total
select sum(tot_revenue) from monthly_revenue where year = 2022 and quarter = 'q3' and partner != 'vizio'

