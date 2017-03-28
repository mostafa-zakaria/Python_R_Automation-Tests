# GOAL
The goal is to explore customer's order, order_item files according to the template specification. (There is an option for contact analisys too)
You can reveal the most common variable attributes and problems with these files.

#Output
The script output are several files containing informations about the most common issues, frequencies about the variables in the specific files (order, order_items or product, sales_iemts; contacts) or some kind of cross validation between files (eg. all of the contact references in order file present in the contact file, etc.. ).

The main output of the analisys is the profiling.txt.
If there was a warning or error, you are going to give a summary about those at the end of the output, written with red lines.
(If you see something red in the console, you should consider that as a warning or error)

#Frequencies output files (*_freq.csv)
*_freq.csv files contain informations about the value sets of the variables.
(the first two columns are just an Id sequence, depricated please ignore them)
From the 3th column there are column pairs – every column pair related to a variable from the original csv, and these column pairs are independent from each other.

Column pairs:

In the first column (the column name is the <varible name>) you will find the current variable values, in the second column (the column name is the <varible name>_freq) there is the frequency of the current value.
Further notes:
-          if a variable is unique or has got more than 10000 distinct values (this is a changeable parameter), than you can find just the top 1000 value – based on frequency.
-          if there was „wrong” or „missing” values in the current variable, for example „NULL” – which was replaced to NA, and R threats these as missing values -, than you will found a value NULL with 0 occurrence, and you will found all of the missing occurrences under the label NA. (It should be the last value in the list)
