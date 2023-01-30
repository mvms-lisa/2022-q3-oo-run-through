-- POWR
select * from powr_viewership where year = 2022 and quarter = 'q3'

-- The first big goal to hit with revenue data is to break it out monthly and by department
-- Some of the revenue is already broken out this way coincidentally, for example: 
    -- 47 Samurai is only in the Roku department, and is broken out monthly, so there is no further breakout needed 
-- Other revenue payments are not broken out this way and need to be broken out by running queries, for ex:
    -- Roku Reps is paid in a quarterly sum, but is also only on Roku, so no need to break out by department
    -- the monthly revenue is calculated by the gam_impression share  

-- Reminder: Be sure to update the quarter and year in each statement's where clause

--monthly revenue
select * from monthly_revenue where year = 2022 and quarter = 'q3'

-- spotx revenue (Updated 8/23/22 - now using the final_net_revenue)
insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, quarter, month, description, title)
select sum(final_net_revenue) as revenue, year_month_day, department_id, 'spotx', year, quarter, month, channel_name as description, 'SpotX' as title from spotx
where department_id is not null and channel_name not like '%Tegna%' and year = 2022 and quarter = 'q3' and final_net_revenue != 0
group by year_month_day, channel_name, department_id, year, quarter, month

-- pubmatic revenue (NEED TO FIX) - Need to add in unallocated revenue0
insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, quarter, year, month, description, title)
select sum(pub_revenue), year_month_day, s.department_id, 'pubmatic', quarter, year, month, channel_name as description, 'Pubmatic' as title from spotx s
where pub_share is not null and year = 2022 and quarter = 'q3'
group by YEAR_MONTH_DAY, s.department_id, quarter, year, month, channel_name

insert into revenue(amount, month, quarter, year, filename, pay_partner, year_month_day, department, department_id, title, type, description, label, viewership_type )
values
(8218.30, 7, 'q3', 2022, 'Manual Insert', 'pubmatic', 20220701, 'Unassigned', 0, 'Pubmatic', 'Adjustment', 'Adjustment - Revenue from Q1 2022', 'Revenue', 'VOD')


--adx is summed on record level
insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, quarter, year, month, description, title)
select sum(ad_exchange_revenue),YEAR_MONTH_DAY, department_id, 'adx', quarter, year, month, ad_unit as description, 'AdX' as title from gam_data 
where advertiser = 'AdX' and year = 2022 and quarter = 'q3'
group by YEAR_MONTH_DAY, department_id, quarter, year, month, ad_unit


-- amazon publisher services
insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, quarter, month, description, title, type)
select amount, year_month_day, 2, 'amazon publisher services', year, quarter, month, description, title, type from revenue 
where pay_partner like '%amazon%' and year = 2022 and quarter = 'q3'


-- 47 samurai
insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, quarter, month, description, title, type)
select amount, year_month_day, 5, '47 samurai', year, quarter, month, description, title, type from revenue 
where pay_partner like '%47%' and year = 2022 and quarter = 'q3'


-- glewedTv
insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, quarter, month, description, title, type)
select amount, year_month_day, 5, 'glewedtv', year, quarter, month, description, title, type from revenue
where pay_partner = 'glewedtv' and year = 2022 and quarter = 'q3'

-- 9MediaOnline
insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, quarter, month, description, title, type)
select sum(amount), year_month_day, department_id, pay_partner, year, quarter, month, description, title, type from revenue
where pay_partner = '9mediaonline' and year = 2022 and quarter = 'q3'
group by year_month_day, year, quarter, month, department_id, pay_partner, description, title, type
            
--SpringServe
insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, quarter, month, description, title, type)
select sum(amount), year_month_day, department_id, pay_partner, year, quarter, month, description, title, type from revenue
where pay_partner = 'springserve' and year = 2022 and quarter = 'q2'
group by year_month_day, year, quarter, month, department_id, pay_partner, description, title, type

-- Magnite
insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, quarter, month, description, title, type)
select amount, year_month_day, 5, 'magnite', year, quarter, month, description, title, type from revenue 
where pay_partner = 'magnite' and year = 2022 and quarter = 'q3'


-- video bridge (NEED TO FIGURE OUT SPLIT)
    -- I ended up manually entering this for q3. Need to figure out split for q4.
    -- roku
    insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, quarter, month, description, title, type)
    select amount, year_month_day, 5, 'videobridge', year, quarter, month, description, title, type  from revenue
    where pay_partner like '%videobridge - roku%' and year = 2022 and quarter = 'q3'

    -- firetv
    insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, quarter, month, description, title, type)
    select amount, year_month_day, 2, 'videobridge', year, quarter, month, description, title, type from revenue
    where pay_partner like '%videobridge - firetv%' and year = 2022 and quarter = 'q3'



-- Roku Reps
-- Since roku reps pays in a quarterly sum, we need to calculate a share to breakout the monthly revenue.
-- For this we use spotx impressions
        -- get total impressions for roku reps deals in spotx
        select sum(impressions) from spotx 
        where DEAL_NAME like '%Reps%' and year = 2022 and quarter = 'q3'


        -- use impressions of deals with roku reps to get share to break out revenue into months
        select (sum(s.impressions) / 109198), s.year_month_day from spotx s
        where DEAL_NAME like '%Reps%' and year = 2022 and quarter = 'q3'
        group by s.year_month_day 
        
        

        -- get revenue breakout by month
        with 
        monthly as
        (
                select (sum(s.impressions) / 109198) as share, s.year_month_day as ymd, 'roku reps' from spotx s
                where DEAL_NAME like '%Reps%' and year = 2022 and quarter = 'q3'
                group by s.year_month_day
            ) 
        select amount * monthly.share, monthly.ymd from revenue r, monthly where pay_partner = 'roku reps' and year = 2022 and quarter = 'q3'

        -- manually update the values in the insert statement and get each months revenue into monthly_revenue table
        insert into monthly_revenue(tot_revenue, year_month_day, partner, department_id, year, quarter, month, description, type, title)
        VALUES (4118.548551, 20220701, 'roku reps', 5, 2022, 'q3', 7, 'Roku CTV App Revenue', 'Roku CTV App Revenue', 'Roku Reps'),
               (4269.59992552, 20220801, 'roku reps', 5, 2022, 'q3', 8, 'Roku CTV App Revenue', 'Roku CTV App Revenue', 'Roku Reps'),
               (1101.79152394, 20220901, 'roku reps', 5, 2022, 'q3', 9, 'Roku CTV App Revenue', 'Roku CTV App Revenue', 'Roku Reps')


      --update pub_share column in spotx table
      update spotx s
      set s.pub_share = q.pubshare
      from (
        select s.id as sid, (impressions / tot_impressions) as pubshare, s.year_month_day from spotx s
        join monthly_impressions m on (m.year_month_day = s.year_month_day)
        where  DEAL_NAME like '%Pubmatic%' and s.year = 2022 and s.quarter = 'q3'
        and m.partner = 'pubmatic'
      )  q
      where s.id = q.sid


-- Where there is more than one line per month for Pubmatic
select pub_share * 20538.47 from spotx where DEAL_NAME like '%Pubmatic%' and year = 2022 and quarter = 'q3' and year_month_day = 20220701

-- Update Pubmatic Revenue with the combined July 2022 Revenue
update spotx
set pub_revenue = pub_share * 20538.47
where DEAL_NAME like '%Pubmatic%' and year = 2022 and quarter = 'q3' and year_month_day = 20220701


-- VideoBridge
    -- Gross revenue was not broken out by department (i.e., FireTV & Roku) on the invoice, so I had to sum up the monthly impressions.
    -- The goal is to get a percentage, but I'm not sure how we will go about that in the future. Making note for Q4.

select * from spotx where year = 2022 and quarter = 'q3' and deal_name like '%VideoBridge%'

      -- insert into  monthly_impressions table (VideoBridge - FireTV)
      insert into monthly_impressions(tot_impressions, year_month_day, month, quarter, year, partner, viewership_type)
      select sum(impressions), year_month_day, month, quarter, year, 'videobridge - firetv' as partner, 'VOD' as viewership_type from spotx s
      where DEAL_NAME like '%VideoBridge%' and year = 2022 and quarter = 'q3' and channel_name like '%FireTV%'
      group by year_month_day, month, quarter, year
      
      -- insert into  monthly_impressions table (VideoBridge - Roku)
      insert into monthly_impressions(tot_impressions, year_month_day, month, quarter, year, partner, viewership_type)
      select sum(impressions), year_month_day, month, quarter, year, 'videobridge - roku' as partner, 'VOD' as viewership_type from spotx s
      where DEAL_NAME like '%VideoBridge%' and year = 2022 and quarter = 'q3' and channel_name not like '%FireTV%'
      group by year_month_day, month, quarter, year

      --update pub_share column in spotx table
      update spotx s
      set s.gross_share = q.grossshare
      from (
        select s.id as sid, (impressions / tot_impressions) as grossshare, s.year_month_day from spotx s
        join monthly_impressions m on (m.year_month_day = s.year_month_day)
        where s.year = 2022 and s.quarter = 'q3'
      )  q
      where s.id = q.sid

-- Ampliffy
insert into monthly_revenue(tot_revenue, year_month_day, department_id, partner, year, quarter, month, description, title, type, viewership_type)
select amount, year_month_day, 5, 'ampliffy', year, quarter, month, description, title, type, 'VOD' as viewership_type from revenue 
where pay_partner = 'ampliffy' and year = 2022 and quarter = 'q3'

-- Vizio
insert into monthly_revenue(tot_revenue, year_month_day, partner, year, quarter, month, description, title, type, viewership_type)
select amount, year_month_day, 'vizio', year, quarter, month, description, title, type, 'VOD' as viewership_type from revenue 
where pay_partner = 'vizio' and year = 2022 and quarter = 'q3'