-- pubmatic - share
    -- in order to calculate pubmatic share, we need   
        --  m =  monthly impressions 
        --  divide record level impressions by monthly impressions (m)
        --  then we can sum share by department_id
        
        -- (Prerequisite: Make sure that the year_month_day column is filled out. To update it, please use the update statement below. Set the year_month_day in YYYYMMDD format. Make sure the timestamp date is relevant. Do this for each month in the quarter.)
        -- Update Statement YEAR_MONTH_DAY:
            UPDATE spotx
            SET year_month_day = ENTER YYYYMMDD
            WHERE timestamp like '%XX%'
         
      -- monthly_impressions
        --update year and month
      select sum(impressions), year_month_day from spotx s
      where DEAL_NAME like '%Pubmatic%' and year = 2022 and quarter = 'q3'
      group by year_month_day
      
      -- insert into  monthly_impressions table
      insert into monthly_impressions(tot_impressions, year_month_day, month, quarter, year, partner, viewership_type)
      select sum(impressions), year_month_day, month, quarter, year, 'pubmatic' as partner, 'VOD' as viewership_type from spotx s
      where DEAL_NAME like '%Pubmatic%' and year = 2022 and quarter = 'q3'
      group by year_month_day, month, quarter, year
      
      -- Check Monthly Impressions
      select * from monthly_impressions where year = 2022 and quarter = 'q3'
      
       
      -- calculate the pubmatic share 
      select (impressions / tot_impressions) as pub_share, s.year_month_day from spotx s
      join monthly_impressions m on (m.year_month_day = s.year_month_day)
      where DEAL_NAME like '%Pubmatic%' and s.year = 2022 and s.quarter = 'q3'
      and m.partner = 'pubmatic'
      
      
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


    -- Update pubmatic rev share
    update spotx s
    set s.pub_revenue = q.pub_rev
    from ( 
      select s.id as qid, pub_share, s.impressions, pub_share * r.amount as pub_rev,  s.year_month_day, s.channel_name from spotx s
      join revenue r on (r.year_month_day = s.year_month_day)
      where DEAL_NAME like '%Pubmatic%' and s.year = 2022 and s.quarter = 'q3'
      and r.pay_partner = 'pubmatic'
    ) q
    where q.qid = s.id


