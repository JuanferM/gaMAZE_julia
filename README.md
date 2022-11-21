# GAmaze_julia
Genetic Algorithms heuristic to generate and solve Maze in Julia

## TODO
Améliorer masquage :
 * introduire un quantificateur pour déterminer si l'on a
   un chemin plus ou moins rectiligne se rapprochant de la sortie
   (soit **n** la dimension du quadrillage, **v** le nombre de voisins total c-à-d
   que pour chaque case occupées on compte son nombre de voisins et on additionne
   le nombre de voisins de chaque cases, et **r** le nombre de cases occupées,
   on note **q**=(**v**+**n**)/2(**r**+**n**) un ratio qui permet de comparer deux individus (plus
   le ratio est petit plus le chemin décrit par la population est rectiligne)

 * lors des crossovers, quantifié l'allure des deux individus _i1_ et _i2_, on note
   **q_i1** et **q_i2**, soit **d(q_i1, q_i2)** la distance absolue entre les ratios et **s** un
   seuil donné, si **d(q_i1, q_i2) > s** et **q_i1 > q_i2** alors on créera un masque avec
   plus de 1 que de 0 (c'est-à-dire que l'on gardera un peu plus des
   caractéristiques de _i1_ que de _i2_), si **d(q_i1, q_i2) > s** et **q_i1 < q_i2** alors
   on créera un masque avec plus de 0 que de 1, enfin, si **d(q_i1, q_i2) < s** on
   créera un masque totalement aléatoire
