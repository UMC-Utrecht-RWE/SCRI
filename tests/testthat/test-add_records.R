test_that("select dates from window returns the corrects outptut", {
        records_table <- data.table::data.table(
          id = c(1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5),
          date = as.Date(c('2023-01-01', '2023-01-05', '2023-01-15', '2023-01-25',
                           '2023-02-01', '2023-02-10', '2023-02-25', '2023-03-01',
                           '2023-03-01', '2023-03-05', '2023-03-15', '2023-03-25',
                           '2023-03-26', '2023-03-30', '2023-04-01', '2023-04-10',
                           '2023-01-01', '2023-01-15', '2023-02-01', '2023-02-15')),
          value = c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200),
          outcome = c('event1','event1','event1','event1','event1','event1','event1','event1','event1','event1','event1','event2','event1','event1','event2','event2','event1','event1','event2','event2')
        )
        
        window_data <- data.table::data.table(
          id = c(1, 1, 2, 2, 3, 4, 1, 1, 2, 2, 3, 4),
          outcome = c('event1','event1','event1','event1','event1','event1','event1','event2','event1','event1','event1','event1'),
          reference_date_name = c("FIRST_TARGET", "FIRST_TARGET","FIRST_TARGET", "SECOND_TARGET", "SECOND_TARGET", "SECOND_TARGET",
                                  "FIRST_TARGET", "FIRST_TARGET","FIRST_TARGET", "SECOND_TARGET", "SECOND_TARGET", "SECOND_TARGET"),
          window_name = c('control', 'risk', 'control', 'risk', 'control', 'risk','control', 'risk', 'control', 'risk', 'control', 'risk'),
          start_date = as.Date(c('2023-01-01', '2023-01-11', '2023-02-01', '2023-02-21', '2023-03-01', '2023-03-25',
                                 '2023-01-11', '2023-01-21', '2023-02-11', '2023-02-31', '2023-03-11', '2023-03-25')),
          end_date = as.Date(c('2023-01-10', '2023-01-21', '2023-02-20', '2023-03-01', '2023-03-10', '2023-04-05',
                               '2023-01-21', '2023-01-31', '2023-02-20', '2023-03-26', '2023-03-20', '2023-04-05'))
        )
        
        
        result_test <- add_records(window_data = window_data,
                                                       records = records_table, # record table of interest, minimum expected columns are: person_id, date, value
                                                       start_column_prefix = 'start_date', # column name
                                                       end_column_prefix =  'end_date', # column name
                                                       only_first_record = FALSE,
                                                       is_wide_format = FALSE)
          
          
          
        
})
