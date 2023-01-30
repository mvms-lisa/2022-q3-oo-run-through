--- Please be sure to update quarter and year
-- create revenue pool and insert
  -- fire tv and roku
  insert into rev_pool(revenue, department_id, year_month_day, quarter, year, month, viewership_type)
  select sum(tot_revenue), department_id, year_month_day, quarter, year, month, 'VOD'
  from monthly_revenue 
  where department_id in (2, 5) and year = 2022 and quarter = 'q3'
  group by department_id, year_month_day, quarter, year, month
  
  -- non fire tv and roku (updated 9/6/22 - Mobile/Web)
  insert into rev_pool(revenue, department_id, year_month_day, quarter, year, month, viewership_type)
  select sum(tot_revenue), 6, year_month_day, quarter, year, month, 'VOD'
  from monthly_revenue 
  where department_id not in (2, 5) and year = 2022 and quarter = 'q3'
  group by year_month_day, quarter, year, month
  
  
-- Check the rev_pool table for this quarter and year
select * from rev_pool where year = 2022 and quarter = 'q3'
  
-- Check the sum of the topline revenue amount in the rev_pool table. 
select sum(revenue) from rev_pool where year = 2022 and quarter = 'q3'


-- FireTV and Roku CTV App Revenue Share Update
update powr_viewership  p
set p.rev_share = q.rev_share
from(
    select p.id as id, p.year_month_day, p.dept_share * r.revenue as rev_share, p.content_provider from powr_viewership p
    join rev_pool r on (p.year_month_day = r.year_month_day and p.department_id = r.department_id) 
    where r.department_id != 6 and p.year = 2022 and p.quarter = 'q3' and p.platform not in ('undefined', 'generic')
) q 
where p.id = q.id 


-- Mobile/Web Revenue Share Update
update powr_viewership  p
set p.rev_share = q.rev_share
from(
    select p.id as id, p.year_month_day, p.dept_share * r.revenue as rev_share, p.content_provider from powr_viewership p
    join rev_pool r on (p.year_month_day = r.year_month_day and p.department_id in (1,3,4)) 
    where r.department_id = 6 and p.year = 2022 and p.quarter = 'q3'
) q 
where p.id = q.id


select * from powr_viewership where year = 2022 and quarter = 'q3' and rev_share is null

-- Check REV_SHARE (Topline Total)
select sum(rev_share) from powr_viewership where year = 2022 and quarter = 'q3'

-- Check MONTHLY_REVENUE Topline Total
select sum(tot_revenue) from monthly_revenue where year = 2022 and quarter = 'q3' and partner != 'vizio'