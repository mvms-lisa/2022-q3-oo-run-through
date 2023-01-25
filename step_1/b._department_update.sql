-- spotx 
    update spotx s
    -- set channel id column to val in query, set dept id to val in query
    set s.channel_id = q.chid, s.department_id = q.depid
    from
    (
        -- query to match viewership record to the channel
        select s.id as qid,  c.id as chid, c.department_id as depid from spotx s
        join dictionary.public.spotx_channels c on (c.name = s.channel_name)
        where year = 2022 and quarter = 'q3' 
    ) q
    -- update where the record id matches the record id in query
    where s.id = q.qid
    
    
    
    update spotx s
    -- set channel id column to val in query, set dept id to val in query
    set s.device_id = q.did, s.department_id = q.depid
    from
    (
        -- query to match viewership record to the channel
        select s.id as qid,  d.device_id as did, d.department_id as depid from spotx s
        join dictionary.public.devices d on (d.entry = s.channel_name)
        where year = 2022 and quarter = 'q3' 
    ) q
    -- update where the record id matches the record id in query
    where s.id = q.qid


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
    
    
-- powr_viewership - update series id
update powr_viewership p
    -- set device id column to val in query, set dept id to val in query
    set p.series_id = q.seriesid
    from 
    (
        -- query to match viewership record to the device
        select p.id as qid, d.series_id as seriesid from powr_viewership p
        join dictionary.public.series d on (d.entry = p.series)
        where year = 2022 and quarter = 'q3'
    ) q
    -- update where the record id matches the record id in query
    where p.id = q.qid