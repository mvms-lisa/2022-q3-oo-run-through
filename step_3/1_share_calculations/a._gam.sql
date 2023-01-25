----- Share CALCULATIONS
    -- 1. oao impression share (Updated 10/26/22 - Now removing Advertiser 'Tremor')
        -- Update where statement for quarter and year; replace 'X'
        insert into monthly_impressions(tot_impressions, year_month_day, partner, year, quarter, month, viewership_type)
        select sum(TOTAL_IMPRESSIONS), year_month_day, 'gam', year, quarter, month, 'VOD' as viewership_type from gam_data
        where quarter = 'q3' and year = 2022 and advertiser != 'Tremor'
        group by year_month_day, year, quarter, month
        
     -- Monthly Impressions
     select * from monthly_impressions where year = 2022 and quarter = 'q3'
     
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