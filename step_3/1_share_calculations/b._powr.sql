-- powr viewership
    -- powr viewership by dept and month (each department split out individually)
    select sum(watch_time_seconds), d.id, d.name, year_month_day, 'powr viewership share' as usage from powr_viewership p
    join dictionary.public.temp_departments d on (d.id = p.department_id)
    where quarter = 'q3' and year = 2022
    group by d.name, p.year_month_day, d.id
    
    
    -- DEPT_SHARE CALCULATION: We first need to group the monthly viewership from the powr_viewership table. 
    -- These will be grouped by FireTV, Roku CTV App, and Web/Mobile (which includes the following platforms: android_app, android_tv, appletv_app, ios_app, web, webMobile - any department in 1,3,4).
    -- The monthly viewrship will then be used to calculate the dept_share. It is the record's watch_time_seconds divided by the sum of watch_time_seconds(viewership) for that department. 
       
    
     -- insert viewership by dept and month (firetv & roku) - update the QUARTER and YEAR
    insert into  monthly_viewership(tot_viewership, department_id, department_name, year_month_day, usage, quarter, month, year)
    select sum(watch_time_seconds), d.id, d.name, year_month_day, 'powr viewership share' as usage, quarter, month, year from powr_viewership p
    join dictionary.public.temp_departments d on (d.id = p.department_id)
    where quarter = 'q3' and year = 2022 and p.department_id in (2,5)
    group by d.name, p.year_month_day, d.id, p.month, p.year, p.quarter


    -- insert viewership by dept and month (mobile/web dept 1,3,4 together) - update the quarter and YEAR 
    insert into  monthly_viewership(tot_viewership, department_id, department_name, year_month_day, usage, quarter, month, year)
    select sum(watch_time_seconds), 6, 'mobile/web', year_month_day, 'powr viewership share' as usage, quarter, month, year from powr_viewership p
    where quarter = 'q3' and year = 2022 and department_id in (1,3,4) 
    group by year_month_day, month, year, quarter
    


    -- update dept_share on records (roku & firetv) - update QUARTER and YEAR
    update powr_viewership p
    set p.dept_share = q.dept_share
    from
    (
    select p.id as id, ref_id, WATCH_TIME_SECONDS / mv.TOT_VIEWERSHIP as dept_share, p.year_month_day, d.name from powr_viewership p
    join monthly_viewership mv on (mv.year_month_day = p.year_month_day and mv.department_id  = p.department_id)
    join dictionary.public.temp_departments d on (d.id = p.department_id)
    where mv.usage = 'powr viewership share' and p.year = 2022 and p.quarter = 'q3' and p.department_id in (2, 5)
    ) q
    where p.id = q.id
    
    -- update dept share on records (mobile/web) - update QUARTER and YEAR
    update powr_viewership p
    set p.dept_share = q.dept_share
    from
    (
    select p.id as id, ref_id, WATCH_TIME_SECONDS / mv.TOT_VIEWERSHIP as dept_share, p.year_month_day from powr_viewership p
    join monthly_viewership mv on (mv.year_month_day = p.year_month_day)
    where mv.usage = 'powr viewership share' and p.year = 2022 and p.quarter = 'q3' and p.department_id in (1,3,4) and mv.department_id = 6
    ) q
    where p.id = q.id


-- POWR SHARE Calculations - Used Later on for Content Provider Breakout

-- Insert - Grouped Viewership
insert into grouped_viewership (tot_viewership, year_month_day, year, month, quarter, partner, viewership_type)
select sum(tot_viewership), year_month_day, year, month, quarter, 'powr' as partner, 'VOD' as viewership_type from monthly_viewership
where year = 2022 and quarter = 'q3'
group by year_month_day, year, month, quarter

-- CHECK: Grouped Viewership
select * from grouped_viewership where year = 2022 and quarter = 'q3'

-- Update POWR_SHARE on powr_viewership
    update powr_viewership p
    set p.powr_share = q.powr_share
    from
    (
    select p.id as id, ref_id, p.WATCH_TIME_SECONDS / gv.tot_viewership as powr_share, p.year_month_day from powr_viewership p
    join grouped_viewership gv on (gv.year_month_day = p.year_month_day)
    where p.year = 2022 and p.quarter = 'q3' and ref_id is not null
    ) q
    where p.id = q.id
