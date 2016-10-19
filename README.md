# Importing Presentation log files into Matlab

import_pres_log.m imports data from Presentation log files as Matlab variables. 

The function returns the cell structure LOG (one cell per logfile) which contains the fields NAME (= the filename) as well as the vectors EVENT, CODE, and TIME which contain data from the corresponding columns in the log file. TIME values are converted into seconds.

Usage: import_pres_log(LOGFILES, START)

- where LOGFILES is a string and either the name of a single log file (e.g. 'exp1_s01.log') or the name of a directory containing one or more log files (e.g. '/Users/P/Documents/'),
- and START (optional) is a string that corresponds to the value of the "Event Type" column of the beginning line of the experiment (e.g. 'Start'). Preceding lines are discarded for EVENT, CODE, and TIME. The default is to start with the first line after the column names.



