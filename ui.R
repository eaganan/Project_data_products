library(shiny)

shinyUI(fluidPage(
  titlePanel("Diamond Price Prediction"),
  includeMarkdown("Information.Rmd"),
  fluidRow(
    column(3,
           wellPanel(
             h4("Choose a model"),
             selectInput("model", "Prediction Model",
                         c("Tree" = "tree",
                           "Random Forest" = "randomForest",
                           "bgm" = "bgm")),
             conditionalPanel(condition="input.model=='tree'",
                              sliderInput(inputId="cp", label="Define complexity of the tree model",
                                          min=0.01, max=0.5, value=0.01, step=0.01) ),
             conditionalPanel(condition="input.model=='randomForest'",
                              radioButtons(inputId="ntreeF", label="Define number of trees",
                                           choices=c(50,100,150), selected=50) ),
             conditionalPanel(condition="input.model=='bgm'",
                              radioButtons(inputId="ntreeG", label="Define number of trees",
                                           choices=c(50,100,150), selected=50) ),
             actionButton("goModel","Fit model!")
           )
    ),
    column(9,
           tabsetPanel(type="pills",#pills tabs
                       #tabPanel("Information",includeMarkdown("Information.Rmd")),
                       #br(),
                       tabPanel("Exploratory",
                                fluidRow(column(4,plotOutput(outputId="plotCut",width="350px",height="250px")),
                                         column(4,plotOutput(outputId="plotColor",width="350px",height="250px")),
                                         column(4,plotOutput(outputId="plotClarity",width="350px",height="250px"))
                                ),
                                fluidRow(column(4,plotOutput(outputId="plotCaratCut",width="350px",height="250px")),
                                         column(4,plotOutput(outputId="plotCaratColor",width="350px",height="250px")),
                                         column(4,plotOutput(outputId="plotCaratClarity",width="350px",height="250px"))
                                )
                       ),
                       tabPanel("Fitted Model",
                                verbatimTextOutput("summaryModel"),
                                h4("Estimation of prediction error for the selected model based on the test set"),
                                h3(textOutput("rmse"),style="color:#428BCA"),
                                p("Comparison between prediction and real values"),
                                plotOutput(outputId="plotModel",width="600px",height="400px")
                       ),
                       tabPanel("Prediction",
                                h4("Make a prediction"),
                                p("Now, define the new values for the fitted model and make your prediction"),
                                wellPanel(
                                  fluidRow(
                                    column(5,sliderInput(inputId="carat", label="Carat value",
                                                         min=0.2, max=5.01, value=0.01, step=0.01)),
                                    column(2,selectInput("cut", "Cut value",
                                                         choices=c("Fair","Good","Very Good","Premium","Ideal"))),
                                    column(2,selectInput("color", "Color value",
                                                         choices=c("D","E","F","G","H","I","J"))),
                                    column(2,selectInput("clarity", "Clarity value",
                                                         choices=c("I1","SI2","SI1","VS2","VS1","VVS2","VVS1","IF")))
                                  ),
                                  fluidRow(actionButton("goPrediction","Make prediction!"))
                                ),
                                h4("This is the predicted price for the specified diamond"),
                                h2(textOutput("predUser"),style="color:#428BCA")
                       )
           )#tabsetPanel
    )#Column
  )#fluidRow
)
)
