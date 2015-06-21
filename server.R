library(shiny)
library(ggplot2)
library(caret)
library(rpart)
library(randomForest)
library(gbm)
library(scales)

shinyServer(function(input, output) {
  
  #set.seed(12356)
  iTrain<-createDataPartition(diamonds$price,p=0.6,list=F)
  training<-diamonds[iTrain,]
  testing<-diamonds[-iTrain,]
  
  ## Tab Exploratory
  output$plotCut<-renderPlot ({
    p<-qplot(cut, price, data=training, geom="boxplot",fill=cut)
    p<-p+ theme_bw()
    p
  })
  output$plotColor<-renderPlot ({
    p<-qplot(color, price, data=training, geom="boxplot",fill=color)
    p<-p+ theme_bw()
    p
  })
  output$plotClarity<-renderPlot ({
    p<-qplot(clarity, price, data=training, geom="boxplot",fill=clarity)
    p<-p+ theme_bw()
    p
  })
  output$plotCaratCut<-renderPlot ({
    p<-qplot(carat, price, data=training, geom="point",color=cut)
    p<-p+ theme_bw()
    p
  })
  output$plotCaratColor<-renderPlot ({
    p<-qplot(carat, price, data=training, geom="point",color=color)
    p<-p+ theme_bw()
    p
  })
  output$plotCaratClarity<-renderPlot ({
    p<-qplot(carat, price, data=training, geom="point",color=clarity)
    p<-p+ theme_bw()
    p
  })
  
  ##Model fit
  
  modelFit<-reactive({
    input$goModel
    isolate(
      switch(input$model,
             tree=rpart(price~carat+cut+color+clarity,data=training,cp=input$cp),
             randomForest=randomForest(price~carat+cut+color+clarity,data=training,
                                       ntree=as.numeric(input$ntreeF),mtry=2),
             bgm =gbm(price~carat+cut+color+clarity,data=training,
                      n.trees=as.numeric(input$ntreeG),
                      distribution="gaussian",interaction.depth=2,shrinkage=0.05)
      )
    )
  })
  
  output$summaryModel<-renderPrint({
    modelFit()
  })
  
  PredictionTest<-reactive({
    Prediction<-predict(modelFit(),newdata=testing,n.trees=as.numeric(input$ntreeG))
    Prediction
  })
  
  output$rmse<-renderText({
    residuals.pred<- testing$price-PredictionTest()
    RMSE<-sqrt(mean(residuals.pred^2))
    paste0("RMSE=",round(RMSE,4))
  })
  output$plotModel<-renderPlot({
    residuals.pred<- testing$price-PredictionTest()
    p<-qplot(PredictionTest(), testing$price, geom="point",color=residuals.pred)
    p<-p + theme_bw() +scale_colour_gradient2(mid="green", high="red", low="red")
    p
  })
  
  ##Prediction
  output$predUser<-renderText({
    input$goPrediction
    isolate({
      newdata<-data.frame(carat=input$carat,cut=input$cut,
                          color=input$color,clarity=input$clarity)
      newdata$cut<-factor(newdata$cut, levels=levels(training$cut),ordered=T)
      newdata$color<-factor(newdata$color, levels=levels(training$color),ordered=T)
      newdata$clarity<-factor(newdata$clarity, levels=levels(training$clarity),ordered=T)
      
      Prediction<-predict(modelFit(),newdata=newdata,n.trees=as.numeric(input$ntreeG))
      dollar(Prediction)
    })
  })
  
})
