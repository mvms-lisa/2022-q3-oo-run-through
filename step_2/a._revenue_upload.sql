--Revenue Upload
    copy into revenue(year_month_day, amount, pay_partner, title, type, description, impressions, department, department_id, cpm, quarter, year, month, label, filename)
    from (select t.$1, to_number(REPLACE(REPLACE(t.$2, '$', ''), ','), 12, 2), t.$3, t.$4, t.$5, t.$6, to_number(REPLACE(t.$7, ','),12, 0), t.$8, t.$9, to_number(REPLACE(t.$10, ','),6, 2), t.$11, t.$12, t.$13,'Revenue', 'revenue_q3_2022'
    from @oo_revenue t) pattern='.*revenue_q3_2022.*' file_format = nosey_viewership 
    ON_ERROR=SKIP_FILE FORCE=TRUE;

    -- SpotX with Description - To Paste Into CSV for Revenue Upload (or to manually insert)
    insert into revenue(year_month_day, amount, pay_partner, title, description, impressions, department_id, month, quarter, year, filename)
    select year_month_day, sum(gross_revenue) as revenue, 'spotx' as pay_partner, 'SpotX' as title, channel_name as description, sum(impressions) as impressions, department_id, month, quarter, year, 'Manual Insert' as filename
    from spotx where year = 2022 and quarter = 'q3' and channel_name not like '%Tegna%' and gross_revenue != 0
    group by channel_name, year_month_day, quarter, year, department_id, month
    order by channel_name
    
    -- AdX with Description - To Paste Into CSV for Revenue Upload (or to manually insert)
    insert into revenue(year_month_day, amount, pay_partner, title, description, impressions, department_id, month, quarter, year, filename)
    select year_month_day, sum(ad_exchange_revenue) as revenue, 'adx' as pay_partner, advertiser as title, ad_unit as description, sum(total_impressions) as impressions, department_id, month, quarter, year, 'Manual Insert' as filename
    from gam_data where year = 2022 and quarter = 'q3' and advertiser = 'AdX'
    group by ad_unit, year_month_day, quarter, year, department_id, advertiser, month
    order by ad_unit
    
    --9 Media Online
    insert into revenue(year_month_day, amount, pay_partner, title, description, impressions, department_id, month, quarter, year, filename, label)
    select year_month_day, sum(gross_revenue) as revenue, '9mediaonline' as pay_partner, '9MediaOnline' as title, channel_name as description, 
    sum(impressions) as impressions, department_id, month, quarter, year, 'Manual Insert' as filename, 'Revenue' as label
    from spotx where year = 2022 and quarter = 'q3' and deal_name like '%9 Media%'
    group by channel_name, year_month_day, quarter, year, department_id, month
    order by channel_name

    -- Ampliffy
    insert into revenue(amount, month, quarter, year, filename, pay_partner, year_month_day, department, title, type, description, label, viewership_type )
    values
    (115.98, 9, 'q3', 2022, 'Manual Insert', 'ampliffy', 20220901, 'Roku', 'Ampliffy', 'Roku Revenue', 'Nosey: September 2022 Invoice', 'Revenue', 'VOD')

    -- Vizio
    insert into revenue(amount, month, quarter, year, filename, pay_partner, year_month_day, department, title, type, description, label, viewership_type )
    values
    (4161.10, 7, 'q3', 2022, 'Manual Insert', 'vizio', 20220701, 'Vizio', 'Vizio', 'Vizio Revenue', 'Standalone App', 'Revenue', 'VOD'),
    (3950.96, 8, 'q3', 2022, 'Manual Insert', 'vizio', 20220801, 'Vizio', 'Vizio', 'Vizio Revenue', 'Standalone App', 'Revenue', 'VOD'),
    (3981.31, 9, 'q3', 2022, 'Manual Insert', 'vizio', 20220901, 'Vizio', 'Vizio', 'Vizio Revenue', 'Standalone App', 'Revenue', 'VOD')