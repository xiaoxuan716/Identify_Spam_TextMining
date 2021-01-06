library(NLP)
library(tm)
library(ggplot2)
library(wordcloud)
library(dplyr)
library(stringr)
library(SparseM) #SVM
library(pROC) #ROC
library(magrittr)
library(caret)
library(class) #KNN
library(e1071)# Bayes


setwd("C:\\Users\\xiaoxuan\\Desktop\\xiaoxuan\\Hiver 2020\\text mining\\project")
spam = read.csv("spam.csv", sep=",")
spam = spam[,c(1,2)]
names(spam)=c("type","message")

str(spam$message)
#message est factor donc on va le changer en charchacter
spam$message=as.character(spam$message)
spam$message = as.vector(spam$message)
#regarder la distribution du type de messages
# ham 4825 spam 747
table(spam$type)


#    --------------------------------------------------------------------------
#                  PAATIE I FICHER APPRENTISSAGE & TEST
#diviser dans 2 parties un ficher de train (60%) et un ficher de test (40%)
train=spam[1:3343,]
test=spam[3344:5572,]

#regarder la distribution du type de messages dans le ficher apprentissage
table(train$type)
# ham 2897 spam 446
# histogramme de la distribution dans le ficher apprentissage
ggplot(aes(x=type),data=train) + geom_bar(fill="grey",width=0.5)

#Speparer deux type SPAM et HAM
train_spam=train[train$type =="spam",]
train_ham=train[train$type =="ham",]

#Creer corpus 
corpus = VCorpus(VectorSource(spam$message)) 
corpus_spam = VCorpus(VectorSource(train_spam$message)) 
content(corpus_spam[[15]])  # test : exemple de read un message 

corpus_ham = VCorpus(VectorSource(train_ham$message)) 
content(corpus_ham[[15]])  # test : exemple de read un message 



#     -----------------------------------------------------------------------
#                        PARTIE II TRAITEMENT DU TEXTE
#         Presentater du texte (worldcloud--les frequents mots de chaque type)
#Pretraitement du texte
dtm_spam = corpus_spam  %>% 
  tm_map(tolower) %>% #miniscule
  tm_map(stripWhitespace)%>% #standardiser espace
  tm_map(removePunctuation) %>%
  tm_map(removeNumbers) %>%
  tm_map(removeWords, stopwords("English")) %>%  # stopwords
  tm_map(stemDocument)  %>%   #stemming 
  tm_map(PlainTextDocument) %>% #transformer en text
  DocumentTermMatrix(control = list(weighting = weightTf)) #transformer en DTM + TFIDF
#creer matrix 
dtmMat <- as.matrix(dtm_spam)
term_frequency = colSums(dtmMat)



#les 30 plus frequents mots utilises dans spam (sans selectionner les termes : sans utiliser chi-deux)
term_frequency=sort(term_frequency, decreasing =T)
barplot(term_frequency[1:30],col="tan",las=2)

wordcloud(names(term_frequency), term_frequency, 
          max.words = 50, color = c("orange","pink","blue","grey"))

#Pretraitement du texte
dtm_ham = corpus_ham  %>% 
  tm_map(tolower) %>% #miniscule
  tm_map(stripWhitespace)%>% #standardiser espace
  tm_map(removePunctuation) %>%
  tm_map(removeNumbers) %>%
  tm_map(removeWords, stopwords("English")) %>%  # stopwords
  tm_map(stemDocument)  %>%   #stemming 
  tm_map(PlainTextDocument) %>% #transformer en text
  DocumentTermMatrix(control = list(weighting = weightTf)) #transformer en DTM + TF
#creer matrix 
dtmMat2 <- as.matrix(dtm_ham)
term_frequency2 = colSums(dtmMat2)

#les 30 frequents mots utilises dans ham (sans selectionner les termes : sans utiliser chi-deux)
term_frequency2=sort(term_frequency2, decreasing =T)
barplot(term_frequency2[1:30],col="tan",las=2)

wordcloud(names(term_frequency2), term_frequency2, 
          max.words = 50, color = "black")




#       ------------------------------------------------------------------
#               PARTIE III SELECTIONNER LES TERMES 
#Selection des 30 termes les plus fréquents:

term_ham=term_frequency2[1:30]
term_spam=term_frequency[1:30]
x=term_ham [- c(4, 5, 7)] # Enlever les termes qui apparaissent dans les deux catégories 'just', 'now', 'call'
y =term_spam [-c(1,3,10)] # Enlever les termes qui apparaissent dans les deux catégories 'just', 'now', 'call'
termes= c(x,y) 
termes= c(names(termes)) #vecteur incluant les termes les plus fréquents pour les deux catégories

wordcloud(names(y), y, color = c("orange","pink"))
wordcloud(names(x), x, color = c("blue","grey"))

#     ----------------------------------------------------------------------
#               PARTIE IV DEVELOPER MODELE ET TESTER 
dtm = corpus %>% 
  tm_map(tolower) %>% 
  tm_map(stripWhitespace)%>% 
  tm_map(removePunctuation) %>%
  tm_map(removeNumbers) %>%
  tm_map(removeWords, stopwords("English")) %>%  
  tm_map(stemDocument)  %>%  
  tm_map(PlainTextDocument) %>% 
  DocumentTermMatrix(control = list(weighting = weightTf)) 

# diviser le fichier 
trainData = dtm[1:3343,]
testData =  dtm[3344:5572,]

#Sélectionner la sous matrice qui contient les 60 mots (30 pour chaque catégorie préselectionnés)
#dans la partie précédente

trainDataMat= as.matrix (trainData)
head(trainDataMat)
trainDataMat= trainDataMat[,termes]
# termes 是在前面筛选好的！ 记住要帅选termes 才可以进行运算！
# 去掉 两者中重复 引起偏差的termes 
testDataMat= as.matrix(testData)
testDataMat= testDataMat[,termes]



#-------------------------------Naive Bayes 
set.seed(2020)
#séparer les labels pour chacun des fichiers train et test
# avant deja fait train ; test

#Entrainement du modèle naive bayes sur la base de la partie test
naive_classifier <- naiveBayes(trainDataMat, train$type)
summary(naive_classifier)
#Prédiction (Réalisée sur la partie test)
preds <- predict(naive_classifier, testDataMat)

prednum=ifelse(preds=="spam",1,2)
auc = roc(as.factor(test$type),prednum)
summary(auc)
plot(auc)
auc$auc
#Matrice de confusion: 
# confucion matrix de naive
cmatrix_naive = confusionMatrix(preds,test$type)  


#-------------------------------# model KNN --------------------------------------

require(class)
model_knn= knn(trainData,testData,train$type,k=1,prob=T)
#Il faut essaye de different K, jai roule k=1 et k=2 k=3, finalememnt cest k=1 
#qui donnera de bons resultats

summary(model_knn)
#ham     spam                 
#2014    215
cmatrix_knn= table(Preictions=model_knn,Actual=test$type)
# acccuracy 
acc_knn=mean(model_knn==test$type)*100
# bonne classification 
# 94.70614
auc = roc(as.factor(test$type),ordered(model_knn))
plot(auc)
auc$auc
#Area under the curve: 
# 0.8264
auc$sensitivities
auc$specificities
#> auc$sensitivities
#[1] 1.0000000 0.6611296 0.0000000
# auc$specificities
#[1] 0.0000000 0.9917012 1.0000000


#---------------------------    # model SVM  ------------------------------------

model_svm = svm(x = trainData, y = train$type ,kernel = 'linear')
#jai aussi esseye de differents kernel function, cest linear donne meilleur resultat
preds =  predict(model_svm, newdata = testData)

# confucion matrix de svm
cmatrix_svm = confusionMatrix(preds,test$type)  
# acccuracy 
acc_svm=mean(preds==test$type)*100
# acccuracy : 97,35307
prednum=ifelse(preds=="spam",1,2)
auc = roc(as.factor(test$type),prednum)
plot(auc)
auc$auc

# Area under the curve: 0.9118
auc$sensitivities
auc$specificities
#> auc$sensitivities
#1.0000000 0.8272425 0.0000000
# auc$specificities  
# 0.0000000 0.9963693 1.0000000



