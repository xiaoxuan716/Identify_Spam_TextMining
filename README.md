# Identify_Spam_TextMining
Introduction
L’avancement technologique qu’a connu le monde durant ces dernières années a contribué à la démocratisation des interactions de types électronique comme les E-mails. Néanmoins, l’utilisation de ces derniers comporte son lot d’inconvénients dont, probablement la plus importante, est la publicité. En effet, les entreprises qui ont dans leur base de données l’information relative aux courriels de leurs clients utilisent ce moyen pour envoyer des publicités et c’est ce qui constitue les courriels indésirables ou plus communément connus sous le nom de « spam ».  
Plusieurs approches existent pour l'identification et le tri automatique des spams, mais l’efficacité des méthodes reste toujours à tester: les résultats ne sont pas précis à 100% dans l'identification et le filtrage des spams.  Dans ce contexte-là, l’objectif de ce travail d’analyse est de pouvoir classifier automatiquement les courriels dans les deux catégories « Spam » et « Ham » et ce en utilisant un modèle de classification supervisée codé à l’aide du langage R.  
Ainsi, dans un premier temps un prétraitement de la base de données a été effectué, à l’issue duquel la sélection des mots les plus pertinents a été faite. Dans un deuxième temps, différents algorithmes de classification ont été appliqués sur l’échantillon d’apprentissage et validé à l’aide de l’échantillon test.  Dans un dernier temps, l’identification du meilleur modèle en fonction du taux de bonne classification, de la sensibilité et de la spécificité a été réalisée. Le modèle proposé est donc utilisé pour identifier les courriers indésirables des courriels principaux avec une meilleure précision et exactitude. 

Ce project a uitlisé trois méthodes, SVM, KNN et Naive bayes.

Conclusion 
Les trois modèles nous ont permis d’obtenir des taux de bonne classification supérieurs à 90%. La différence entre les trois réside principalement dans la sensibilité et la spécificité. En effet, les modèles KNN et SVM ont obtenus des taux de spécificité assez élevés (supérieur à 99%), mais c’est le modèle SVM qui obtient la première place avec un taux de sensibilité de 82%.  Notons par ailleurs que la sensibilité des trois modèles est moins importante que la spécificité, chose que l’on peut expliquer par le fait que dans nos échantillons d’apprentissage et de validation la proportion des messages Ham est plus importante que celle des spam. 
Malgré ce détail, les résultats obtenus dans leur ensemble restent assez satisfaisants. 
On tient aussi à ajouter qu’on a réussi à obtenir des taux élevés car notre base de données peut être qualifiée d’homogène (petits textes à caractère personnel et dont 
les sujets ne sont pas trop divers). 

