## FLP LOG Prolog- Rubikova kostka
#### Filip Šťastný (xstast24)

###Build###:
swipl -q -g start -o flp18-log -c proj2.pl

###Run:###
####Linux/unix:#### ./flp18-log < in_1step.txt
####Windows:#### type in_1step.txt | flp18-log

###Program:###
Využívá algoritmus IDS - pomocí DFS algoritmu zkouší všechny možné rotace, dokud
nedosáhne výsledku.
Jelikož prolog každou novou iteraci řešení počítá celou znovu, 7 kroků počítá do 10 sekund,
ale běh programu pro 8 a více kroků trvá déle než minutu a extrémně se navyšuje.
Možná optimalizace by byla implementací mezikroků algoritmu, který by vedl k výsledku díky
postupnému hledání mezivýsledků, které by byly dosažitelné vždy maximálně 7 kroky (např. složení
středové čáry jedné strany, poté kříže jedné strany, poté celé strany, atd.).
