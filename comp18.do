*Limpando a area de trabalho
clear all
set more off

log using "C:\Users\WazX\Desktop\comp18", replace
*Abrindo a base de dado
 use "C:\Users\WazX\Desktop\base.dados18.dta", clear
 

	 *Linearizando variaveis
	 
 quietly gen ln_sau=ln(saude)
 quietly gen ln_edu=ln(educ)
 quietly gen ln_num=ln(num)
 quietly gen ln_nas=ln(nascidos)
 
 quietly gen ln_comp=comparecimento/(abstencao+comparecimento)
 *Correlação
pwcorr ln_comp analfabetos pobreza ln_sau ln_edu desemprego ln_nas pib ln_num conc, star(.05)
*******Usando o estimador Arellano-Bond *******
*Transformar o periodo de eleições(de quatro em quatro anos) em periodo continuo(1,2,3...)
 quietly gen ano2=1
 quietly replace ano2=2 if ano==1998
 quietly replace ano2=3 if ano==2002
 quietly replace ano2=4 if ano==2006
 quietly replace ano2=5 if ano==2010
 quietly replace ano2=6 if ano==2014
 quietly replace ano2=7 if ano==2018
 quietly xtset codigo ano2
****Estimador Arellano-Bond	****
quietly xtset codigo ano2
*COMPARECIMENTO* 
xtabond ln_comp analfabetos ln_sau desemprego ln_nas conc , lags(1) twostep artests(3) vce(robust)
*Teste de autocorrelação
estat abond, artests(3)
*No caso (?) não há presença de autocorrelação,não rejeitamos H0 a niveis de siginificancia de 1%,5% e 10%.
*Podemos usar o Método de Momentos Generalizados ótimo (GMM) 
*Teste de Sargan 
xtabond ln_comp analfabetos ln_sau desemprego ln_nas conc, lags(1) twostep artests(3)
estat sargan
****Teste de Brausch Pagan****
 xtset codigo ano
 *COMPARECIMENTO*
 xtreg ln_comp analfabetos theil ln_sau desemprego ln_nas conc, re vce(cluster codigo) theta
 xttest0
 *A rejeição da hipótese nula indica que OLS pooled não é modelo apropriado pois a estrutura de variabilidade dos erros compostos é R2.
 ****Teste de Chow*****
xtset codigo ano
 *COMPARECIMENTO*
xtreg ln_comp analfabetos ln_sau desemprego ln_nas conc, fe
*A rejeição da hipótese nula indica que parâmetros são diferentes entre indivíduos, desta forma FE é preferível à POLS.
****Teste de Hausmann*****
 *COMPARECIMENTO*
xtreg  ln_comp analfabetos ln_sau desemprego ln_nas conc, fe
estimates store fixed
xtreg  ln_comp analfabetos ln_sau desemprego ln_nas conc, re
hausman fixed
*A rejeição da hipótese nula indica que especificação correta é a de FE e não RE.
 *****Comparando regressões*****
	*COMPARECIMENTO*
	*Regressão OLS
 quietly regress  ln_comp analfabetos ln_sau desemprego ln_nas conc, vce(cluster codigo)
estimates store OLS 	
	*Regressão FE
 quietly xtreg  ln_comp analfabetos ln_sau desemprego ln_nas conc, fe vce(cluster codigo)
estimates store FE 
	*Regressão RE
 quietly xtreg  ln_comp analfabetos ln_sau desemprego ln_nas conc, re vce(cluster codigo)
estimates store RE 
	*Tabela de comparação
estimates table  OLS  FE  RE,  b  se  t  stats(N  r2  r2_o  r2_b  r2_w  sigma_usigma_e  rho theta)
    
save "C:\Users\WazX\Desktop\comp18", replace
translate @Results "C:\Users\WazX\Desktop\comp18.txt",replace
log close
