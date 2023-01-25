-- gam_data
    -- fields to update: 
        --  filename, year, quarter, pattern (replace where there is an 'X')

        copy into gam_data (
        advertiser,
        ad_unit,
        month_year,
        advertiser_id,
        ad_unit_id,
        total_code_served,
        total_impressions,
        ad_exchange_revenue,
        quarter, 
        year, 
        filename
        )
        from (select t.$1, t.$2, t.$3, t.$4, t.$5, to_number(REPLACE(t.$6,  ','), 15, 0), to_number(REPLACE(t.$7,  ','), 15, 0), to_number(REPLACE(t.$8,  ','), 15, 2), 'q3', 2022,  'gam_q3_2022.csv'
        from @oo_ad_data t) pattern='.*gam_q3_2022.*' file_format = nosey_viewership 
        ON_ERROR=SKIP_FILE FORCE=TRUE;


-- spotx
    -- fields to update: 
        --  filename, year, quarter, pattern (replace where there is an 'X')
        copy into spotx (
        timestamp,
        channel_name,
        deal_demand_source,
        deal_name,
        placements,
        gross_revenue,
        impressions,
        quarter,
        year,
        filename
        )
        from (select t.$1, t.$2, t.$3, t.$4, to_number(REPLACE(t.$5, ','), 10, 0), to_number(REPLACE(t.$6, ','), 10,5), to_number(REPLACE(t.$7, ','), 12, 0),  'q3', 2022,  'spotx_revenue_q3_2022.csv'
        from @oo_revenue t) pattern='.*spotx_revenue_q3_2022.*' file_format = nosey_viewership 
        ON_ERROR=SKIP_FILE FORCE=TRUE;
        
-- powr
    -- copy into from register POWR     
       copy into powr_viewership(
        title, 
        type, 
        channel, 
        views, 
        watch_time_seconds, 
        average_watch_time_seconds, 
        platform, 
        geo, 
        year_month_day,
        ref_id,
        content_provider,
        series,
        quarter,
        year,
        filename
        )   
        from (select t.$1, t.$2, t.$3, to_number(REPLACE(t.$4, ','), 12, 2), to_decimal(REPLACE(t.$5,  ','), 12, 2), to_number(REPLACE(REPLACE(t.$6, '-', ''), ','), 16, 6), t.$7, t.$8, t.$9, t.$10, t.$11, t.$12, 'q3', 2022,  'powr_viewership_register_q3_2022.csv'
        from @oo_viewership t) pattern='.*powr_viewership_register_q3_2022.*' file_format = nosey_viewership 
        ON_ERROR=SKIP_FILE FORCE=TRUE;
    
    -- powr_viewership - update device and department
    update powr_viewership p
        -- set device id column to val in query, set dept id to val in query
        set p.device_id = q.devid, p.department_id = q.depid
        from 
        (
            -- query to match viewership record to the device
            select p.id as qid, d.device_id as devid, d.department_id as depid from powr_viewership p
            join dictionary.public.devices d on (d.entry = p.platform)
            where year = 2022 and quarter = 'q3'
        ) q
        -- update where the record id matches the record id in query
        where p.id = q.qid

        
-- AdX with Description - To Paste Into CSV for Revenue Upload (or to manually insert)
insert into revenue(year_month_day, amount, pay_partner, title, description, impressions, department_id, month, quarter, year, filename)
select year_month_day, sum(ad_exchange_revenue) as revenue, 'adx' as pay_partner, advertiser as title, ad_unit as description, sum(total_impressions) as impressions, department_id, month, quarter, year, 'Manual Insert' as filename
from gam_data where year = 2022 and quarter = 'q3' and advertiser = 'AdX'
group by ad_unit, year_month_day, month, quarter, year, department_id, advertiser
order by ad_unit

--GAM DATA Check
select * from gam_data where year = 2022 and quarter = 'q3'

-- GAM UPDATE
update gam_data
set year_month_day = 20220901, month = 9, viewership_type = 'VOD'
where month_year = 'Sep-22' and year = 2022 and quarter = 'q3'

-- gam_data 
    update gam_data g
    -- set device id column to val in query, set dept id to val in query
    set g.device_id = q.devid, g.department_id = q.depid
    from 
    (
        -- query to match viewership record to the device
        select g.id as qid, d.id as devid, d.department_id as depid from gam_data g
        join dictionary.public.devices d on (d.entry = g.ad_unit)
        where year = 2022 and quarter = 'q3'
    ) q
    -- update where the record id matches the record id in query
    where g.id = q.qid


select * from monthly_revenue where year = 2022 and quarter = 'q2' and pay_partner = '47 samurai'


