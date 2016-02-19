library(shiny)
library(MASS)
library(ggplot2)
library(fitdistrplus)
library(truncdist)
library(EnvStats)
library(gridExtra)


# loading the data
dataMS <- read.csv("~/Data/tabMinorStoppages.csv", header = TRUE)
dataMS$fail_date <- as.POSIXct(dataMS$fail_date, origin = "1970-01-01", tz = "UTC")
dataMS <- subset(dataMS, stopDur <= 600)


shinyServer(  
        function(input, output) {   
                
                # prepares the dataset for multiple usage
                dataSubSet <- reactive({
                   dataA <- as.POSIXct(input$dateRange[1])
                   dateB <- as.POSIXct(input$dateRange[2])
                   lineSel <- input$lineSel
                   ShiftSel <- input$ShiftSel
                   minDur <- 5
                   maxDur <- 600
                   dataSubSet <- subset(dataMS, (fail_date >= dataA & fail_date <= dateB))
                   dataSubSet <- subset(dataSubSet, (line == lineSel & Shift == ShiftSel))
                })
                
### Weibull Distribution
                
                # prepares MTBF for multiple usage
                mean_tbf <- reactive({
                   mean_tbf   <- mean(dataSubSet()$tbf)
                })
                
                # prepares Weibull Fitting for multiple usage
                fitWeibull <- reactive({
                   fitWeibull <- fitdist(dataSubSet()$tbf, "weibull", start = c(shape=1, scale=mean_tbf()))
                })
                
                
                # prepares Weibull Test for multiple usage
                testWeib <- reactive({
                   testWeib <- ks.test(dataSubSet()$tbf, "pweibull",shape=fitWeibull()$estimate[1], scale=fitWeibull()$estimate[2])
                })
                
                # time series of MS TBF (tbf)
                output$lineGraphTBF <- renderPlot({
                        ggplot(data = dataSubSet(), aes(x=fail_date)) +
                        geom_line(aes(y=tbf)) +
                        geom_hline(yintercept = mean_tbf(), colour = "red", size = 1) +     
                        ggtitle(expression(atop("Time Between Minor Stoppages",
                                           atop(italic("in minutes"),"")))) +
                        xlab("Date") + ylab("TBF (in minutes)")  }) 
                
                # histogram of MS TBF (tbf)
                output$histWeibull <- renderPlot({
                           ggplot(data=dataSubSet(), aes(x=tbf)) +
                           geom_histogram(aes(y=..density..), binwidth = 5, 
                                          colour="#999999",fill="#000099") +
                           geom_vline(xintercept = fitWeibull()$estimate[2], colour = "red", size=1) +
                           ggtitle(expression(atop("Time Between Minor Stoppages",
                                              atop(italic("in minutes"),"")))) +
                           xlab("TBF (min)") + ylab("density") +
                           scale_x_continuous(limits = c(0, input$graphRangeA))  }) 
                
                
                # graph of Weibull Fitting of MS TBF (tbf)
                output$functWeibull <- renderPlot({
                           ggplot(data=dataSubSet(), aes(x=tbf)) +
                           geom_density(aes(y=..density..), size=.5, colour= "blue") +
                           geom_vline(xintercept = fitWeibull()$estimate[2], colour = "red", size=1) +
                           stat_function(fun=dweibull, geom="line", size=.5, colour="red",
                                         args = list(shape=fitWeibull()$estimate[1], 
                                                     scale=fitWeibull()$estimate[2])) +
                           ggtitle(expression(atop("Weibull Distribution Fitting",
                                              atop(italic("in minutes"),"")))) +
                           xlab("TBF (min)") + ylab("density") +
                           scale_x_continuous(limits = c(0, input$graphRangeB))  }) 
                
                
                # table with Weibull Outputs
                output$WeibullTable <- renderTable({
                        WeibullTable <- cbind(fitWeibull()$estimate,fitWeibull()$sd)
                        colnames(WeibullTable) <- c("Value","SE")
                        as.table(WeibullTable)  })
                        
                # table with Weibull Fitting Outputs
                output$WeibullFit <- renderTable({
                        WeibullFit <- rbind(testWeib()$statistic,testWeib()$p.value,testWeib()$alternative,testWeib()$method)
                        rownames(WeibullFit) <- c("statistic","p.value","alternative","method")
                        colnames(WeibullFit) <- "values"
                        as.table(WeibullFit)    })
                
                # probability plots
                output$WeibProb <- renderPlot({
                        par(mfrow=c(2,2))
                        denscomp(fitWeibull())
                        cdfcomp(fitWeibull())
                        qqcomp(fitWeibull())
                        ppcomp(fitWeibull())  })

### Lognormal Distribution                
                
                # prepares meanLogDur for multiple usage
                meanLogDur <- reactive({
                        meanLogDur <- mean(log(dataSubSet()$stopDur))
                })
                
                # prepares sdLogDur for multiple usage
                sdLogDur <- reactive({
                        sdLogDur   <- sd(log(dataSubSet()$stopDur))
                })
                
                # prepares Lognormal Fitting for multiple usage
                fitLogNorm <- reactive({
                        fitLogNorm <- fitdist(dataSubSet()$stopDur, "lnormTrunc", 
                                              start = c(meanlog = meanLogDur(), sdlog = sdLogDur()))
                })
                
                # prepares Lognormal Test for multiple usage
                testLogNorm <- reactive({
                        testLogNorm <- ks.test(dataSubSet()$stopDur, "plnormTrunc", 
                                               meanlog = fitLogNorm()$estimate[1], sdlog = fitLogNorm()$estimate[2])
                })
                
                # time series of MS Duration (stopDur)
                output$lineGraphMS <- renderPlot({
                        ggplot(data = dataSubSet(), aes(x=fail_date)) +
                                geom_line(aes(y=stopDur)) +
                                geom_hline(yintercept = exp(fitLogNorm()$estimate[1]), colour = "red", size = 1) +     
                                ggtitle(expression(atop("Minor Stoppages Duration",
                                                        atop(italic("in seconds"),"")))) +
                                xlab("Date") + ylab("duration (in seconds)")  })
                
                # histogram of MS Duration (stopDur)
                output$histLogNorm <- renderPlot({
                                ggplot(data=dataSubSet(), aes(x=stopDur)) +
                                geom_histogram(aes(y=..density..), binwidth = 5, 
                                               colour="#999999",fill="#000099") +
                                geom_vline(xintercept = exp(fitLogNorm()$estimate[1]), colour = "red", size=1) +
                                ggtitle(expression(atop("Minor Stoppages Duration",
                                                        atop(italic("in seconds"),"")))) +
                                xlab("duration (sec)") + ylab("density") +
                                scale_x_continuous(limits = c(0, input$graphRangeC))  }) 
                
                # graph of Lognormal Fitting of MS Duration (stopDur)
                output$functLogNorm <- renderPlot({
                        ggplot(data=dataSubSet(), aes(x=stopDur)) +
                                geom_density(aes(y=..density..), size=.5, colour= "blue") +
                                geom_vline(xintercept = exp(fitLogNorm()$estimate[1]), colour = "red", size=1) +
                                stat_function(fun=dlnormTrunc, geom="line", size=.5, colour="red",
                                              args = list(meanlog = fitLogNorm()$estimate[1], 
                                                          sdlog = fitLogNorm()$estimate[2])) +
                                ggtitle(expression(atop("Lognormal Distribution Fitting",
                                                        atop(italic("in seconds"),"")))) +
                                xlab("duration (sec)") + ylab("density") +
                                scale_x_continuous(limits = c(0, input$graphRangeD))  }) 
                
                
                # table with Lognormal Outputs
                output$LogNormTable <- renderTable({
                        valuesLog <- rbind(fitLogNorm()$estimate[1],fitLogNorm()$estimate[2])
                        nonLogValues <- rbind(exp(fitLogNorm()$estimate[1]),exp(fitLogNorm()$estimate[2]))
                        seLog <- rbind(fitLogNorm()$sd[1], fitLogNorm()$sd[2])
                        LogNormTable <- cbind(valuesLog,nonLogValues,seLog)
                        rownames(LogNormTable) <- c("meanlog","sdlog")
                        colnames(LogNormTable) <- c("value","exp(value)" ,"SE")
                        as.table(LogNormTable)  })
                
                # table with Weibull Fitting Outputs
                output$LogNormFit <- renderTable({
                        LogNormFit <- rbind(testLogNorm()$statistic,testLogNorm()$p.value,testLogNorm()$alternative,testLogNorm()$method)
                        rownames(LogNormFit) <- c("statistic","p.value","alternative","method")
                        colnames(LogNormFit) <- "values"
                        as.table(LogNormFit)    })
                
                # probability plots Lognormal
                output$LogNormProb <- renderPlot({
                        par(mfrow=c(2,2))
                        denscomp(fitLogNorm())
                        cdfcomp(fitLogNorm())
                        qqcomp(fitLogNorm())
                        ppcomp(fitLogNorm())  })
                
                
                
                }
)
