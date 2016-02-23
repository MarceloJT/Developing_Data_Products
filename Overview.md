# Minor Stoppages Analysis  

This app was built up as the final project of Coursera's Developing Data Products course.  

It's main goal is to be used as a tool to analyse Minor Stoppages of automated packaging equipment, using the data that can be obtained directly from their PLC (or "machine computer"), adjusting the statistical distributions and their related parameters as input for further simulations on productivity and efficiency improvement of those production lines.  
<br>

## Definition
A **Minor Stoppage** is an operational stoppage of the machine / line that :
* is shorter than 10min (600 seconds) - this values may change from company to company;
* to restore the machine's proper operation, theres is no need for a maintenance technician intervention;
* no spare parts are exchanged to restore the machine functioning;
* have direct impact on machine's **OEE** (Overall Equipment Effectiveness) and reduces significantly the line throughput.  

A deep understanding on the behavior of such stoppages can drive more effective action plans to either reduce them or eliminate them from the process.  In the same way, it allows *process simulation* processes through specific software, that demands good understanding on the statistical distribution parameters of those minor stoppages events.
<BR>

## Premises
1. For this app, we assume that all minor stoppages have an upper threshold at 600 seconds;
2. The database was created based on real data, but has been adapted to comply with the development of the project specific needs;
3. Usually, the *Time Between Minor Stoppages* or **Time Between Failures (TBF)** follows an exponential or Weibull distribution and is measured in **minutes**. Only the Weibull will be analysed here;
4. The **Minor Stoppage Duration** or *Time To Restore* follows a Lognormal distribution and is measured in **seconds**;
5. Only 3 months of data were generated in the database, but there would be no limits for such analysis;
6. There are 3 operating shifts (and their 3 respective operators) that can be analysed separately;
7. Machines run from Monday to Friday, 24 hours a day, with 3 hours for lunch time (1 hour per shift).
<BR>

## Procedures
To get the minor stoppages analysed, in the main panel of the app you just have to:
* define the dates interval you want to get analysed;
* define the packging line to be studied;
* define the operation shift of interest.  
As the input data changes, the graphs and parameters automatically change too.
* x axis range can be changed as well.
<BR>

## Results
As direct results of the analysis, you will obtain :  

1. In the "Time Between Minor Stoppages" tab :
     + A time series graph of the selected data;
     + An histogram of the data, with the Mean Time Between Stoppages plotted;
     + A graph with the real and the theoretical the Weibull plots;
     + The Weibull distribution parameters and the regression data in their specific tables;
     + The Weibull distribution plots.  


2. In the "Minor Stoppages Duration" tab :
     + A time series graph of the selected data;
     + An histogram of the data, with the Mean Stoppage Time plotted;
     + A graph with the real and the theoretical Lognormal plots;
     + The Lognormal distribution parameters and the regression data in their specific tables;
     + The Lognormal distribution plots.










