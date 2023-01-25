-- spotx
    -- in order to calculate spotx share, we need to  
        --  m =  monthly gross_revenue 
        --  divide record level gross_revenue by m.revenue
        --  then we can sum share by department_id
        
        -- (Update 10/25/22 - It's possible that we may not even need steps 1-3 anymore. Will evaluate later.)
         
        -- 1a. get monthly gross revenue
            -- update the year and quarter
         select sum(gross_revenue), year_month_day, month, 'spotx', year, quarter, 'SpotX Gross Revenue' as name, 'VOD' as viewership_type from spotx
         where year = 2022 and quarter = 'q3'
         group by year_month_day, month, year, quarter   
        
         -- 1b. insert into table
            -- update the year and quarter
         insert into monthly_gross_revenue(revenue, year_month_day, month, partner, year, quarter, name, viewership_type)
         select sum(gross_revenue), year_month_day, month, 'spotx', year, quarter, 'SpotX Gross Revenue' as name, 'VOD' as viewership_type from spotx
         where year = 2022 and quarter = 'q3'
         group by year_month_day, month, year, quarter          
         
         --monthly gross revenue
         select * from monthly_gross_revenue where year = 2022 
            

        -- 2a. update the spotx_share by dividing gross_rev by monthly_gross_rev  
            -- update year and quarter
        update spotx s
        set s.spotx_share = q.sx_share
        from(
          select s.id as id, gross_revenue, gross_revenue / m.revenue as sx_share, s.year_month_Day from spotx s
          join monthly_gross_revenue m on (m.year_month_day = s.year_month_day )
          where s.year = 2022 and s.quarter = 'q3'
        ) q
        where s.id = q.id
        
        
        -- 3a. REVENUE NEEDS TO BE IN BEFORE THIS STEP update the spotx_rev by multiplying revenue by spotx_share
            -- update the year and quarter
        update spotx s
        set s.spotx_revenue = q.sx_rev
        from(
          select s.id as id, gross_revenue, spotx_share, spotx_share * r.amount as sx_rev from spotx s
          join revenue r on (r.year_month_day = s.year_month_day)
          where pay_partner = 'spotx' and s.year = 2022 and s.quarter = 'q3'
        ) q
        where s.id = q.id 
        
        
        -- 4a. NEW ADDITION (8/30/22) - We need to calculate the net_revenue, then use that to calculate the share_exp %, and then use that percentage to calculate the final_net_revenue
              -- What is the difference in share % when using net vs gross? 
              -- Why would using net be more accurate? 
              -- How is the resulting share used for calculating the final_net_revenue? 
              -- So the only place the net-rev share is used is exp_share, which splits the expense cost at the record level.
              -- Does that make sense to do it that way? 
                  -- Is it more accurate? 
                  -- Are any records excluded? 

              --  The final_net_revenue will later be inserted into the monthly_revenue table. Any negative values will then be excluded or deleted. 
              
              -- Run the following statement to update the net_revenue column (and update the quarter and year:
              
              call spotx_update_net_revenue('q3', 2022::DOUBLE);
              
            -- 4b. Insert the sum of net_revenue by month:
                -- update the year and quarter
                 insert into monthly_gross_revenue(revenue, year_month_day, month, quarter, year, partner, name, viewership_type)
                 select sum(net_revenue), year_month_day, month, quarter, year, 'spotx' as partner, 'SpotX Net Revenue' as name, 'VOD' as viewership_type  from spotx
                 where year = 2022 and quarter = 'q3'
                 group by year_month_day, year, month, quarter  
              
            -- 4c. Need to calculate the exp_share, which takes the net_revenue per record divided by the sum of net_revenue per month.
                -- Before running this step, the sum of the net_revenue should be inserted into the monthly_gross_revenue table.
            
                    update spotx s
                    set s.share_exp = q.exp_share
                    from (
                        select s.id as sid, (net_revenue/m.revenue) as exp_share, s.year_month_day from spotx s
                        join monthly_gross_revenue m on (m.year_month_day = s.year_month_day)
                        where s.year = 2022 and s.quarter = 'q3' and m.name = 'SpotX Net Revenue'
                        and m.partner = 'spotx'
                    )q
                    where s.id = q.sid
       
                -- Expenses: SpotX Seat Fee Insert
                    insert into expenses(amount, year, quarter, pay_partner, filename, title, description, label, viewership_type)
                    values(-2500, 2022, 'q3', 'spotx', 'Manual Insert', 'SpotX', 'SpotX Seat Fee', 'Expense', 'VOD')

                -- Check: Seat Fee
                    select * from expenses where year = 2022 and quarter = 'q3' and description = 'SpotX Seat Fee'
                    
            -- 4d. Below will update the final_net_revenue values, which will later be inserted into the monthly_revenue table.
            
                -- Updates the final_net_revenue:
                    update spotx s
                    set s.final_net_revenue = q.final_rev
                    from (
                      select s.id as qid, net_revenue, share_exp, (e.amount*share_exp) + net_revenue as final_rev,  s.year_month_day, s.channel_name from spotx s
                      join expenses e 
                      where s.year = 2022 and s.quarter = 'q3' and e.pay_partner = 'spotx' and e.description = 'SpotX Seat Fee' and e.year = 2022 and e.quarter = 'q3'
                    ) q
                    where q.qid = s.id

