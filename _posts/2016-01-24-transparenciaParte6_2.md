---
title: "Transparência (6): Quem são os 1% do funcionalismo público?"
author: "Sillas Teixeira Gonzaga"
date: "Sunday, January 24, 2016"
layout: post
output:
  md_document:
    variant: markdown_phpextra+backtick_code_blocks
---

# Transparência (6): Quem são os 1% mais ricos do funcionalismo público?

[Para quem não entendeu a referência.](https://en.wikipedia.org/wiki/We_are_the_99%25)

{% highlight r %}
library(ggplot2)
library(dplyr)
library(reshape2)
library(lubridate)
library(htmlTable)
df <- read.csv2("/home/sillas/R/data/transparenciaComSalarios.csv", stringsAsFactors = FALSE, fileEncoding = "ISO-8859-15")
{% endhighlight %}

Você já teve curiosidade em saber quem são os funcionários públicos mais ricos do Brasil? O sexto post da série de artigos sobre dados do Portal da Transparência será dedicado a eles.

Primeiramente, quantos servidores compõem o 1%?


{% highlight r %}
paste0("O número total de servidores é: ", nrow(df))
{% endhighlight %}



{% highlight text %}
## [1] "O número total de servidores é: 518270"
{% endhighlight %}



{% highlight r %}
print("\n")
{% endhighlight %}



{% highlight text %}
## [1] "\n"
{% endhighlight %}



{% highlight r %}
paste0("A quantidade de servidores do 1% é: ", round(nrow(df)*0.01))
{% endhighlight %}



{% highlight text %}
## [1] "A quantidade de servidores do 1% é: 5183"
{% endhighlight %}

Temos, então, que classificar os servidores em ordem decrescente de salário e criar um data frame separado para os servidores do 1% selecionando as primeiras 5183 linhas.


{% highlight r %}
umPorCento <- df[order(-df$SALARIO),]
umPorCento <- umPorCento[1:5183,]
{% endhighlight %}

Todo o movimento do Occupy Wall Street começou baseado no fato que 1% da população americana detem cerca de 25% da massa salarial dos Estados Unidos. Quanto deve ser esse valor tomando no contexto do funcionalismo federal?


{% highlight r %}
# Salário dos 1%
sum(umPorCento$SALARIO)
{% endhighlight %}



{% highlight text %}
## [1] 146524625
{% endhighlight %}



{% highlight r %}
# Salário total
sum(df$SALARIO)
{% endhighlight %}



{% highlight text %}
## [1] 4377796333
{% endhighlight %}



{% highlight r %}
# Porcentagem
round(100*(sum(umPorCento$SALARIO)/sum(df$SALARIO)),2)
{% endhighlight %}



{% highlight text %}
## [1] 3.35
{% endhighlight %}

Os 1% dos servidores mais ricos detem 3,35% dos salários somados de todos os servidores federais. Comparado com a população americana, estamos mais distribuídos.

Estados Unidos a parte, quem são os 1%? Para traçar o perfil médio dos servidores do grupo, vamos analisar:

## 1. Onde eles estão?


{% highlight r %}
temp <- umPorCento %>%
  group_by(UF_EXERCICIO, REGIAO) %>%
  summarise(quantidade = n())

ggplot(temp, aes(x = reorder(UF_EXERCICIO, -quantidade), y = quantidade, fill = REGIAO)) +
    geom_bar(stat = "identity") +
    labs(title = "Quantidade de\n servidores por estado", x = "", y = "") +
   theme(legend.position = "bottom", legend.title = element_blank())
{% endhighlight %}

![center](/figs/transparenciaParte6/unnamed-chunk-5-1.png) 

Melhor do que apresentar esses resultados isolados é comparar com os resultados apresentados no [primeiro post](http://sillasgonzaga.github.io/blog/transparencia1/) desta série. Para isso, ao invés de trabalhar com quantidade, veremos o porcentual de servidores que está alocado em cada UF.


{% highlight r %}
temp2 <- df %>%
  group_by(UF_EXERCICIO, REGIAO) %>%
  summarise(quantidadeNormal = n())

# transformar quantidade em porcentagem do total
temp$quantidade <- 100*temp$quantidade/sum(temp$quantidade)
temp2$quantidadeNormal <- 100*temp2$quantidadeNormal/sum(temp2$quantidadeNormal)


comparacao <- merge(temp, temp2, by = "UF_EXERCICIO")


temp3 <- select(comparacao, UF_EXERCICIO, REGIAO = REGIAO.x, quantidade1 = quantidade, quantidadeNormal)

temp3 <- melt(temp3, id.vars = c("UF_EXERCICIO", "REGIAO"))

#mudar nome do fator para aparecer bonito no gráfico
levels(temp3$variable) <- c("Grupo dos 1%", "Total geral")

ggplot(temp3, aes(x = UF_EXERCICIO, y = value, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Porcentual da quantidade de\n servidores por estado", x = "", y = "%") +
  theme(legend.position = "bottom", legend.title = element_blank())
{% endhighlight %}

![center](/figs/transparenciaParte6/unnamed-chunk-6-1.png) 

Mais uma vez o DF desponta como anomalia, onde mais de 35% dos servidores mais ricos estão alocados.

## 2. Em quais cargos trabalham?


{% highlight r %}
temp <- umPorCento %>%
  group_by(ORG_LOTACAO) %>%
  summarise(quantidade = n())


temp2 <- df %>%
  group_by(ORG_LOTACAO) %>%
  summarise(quantidadeNormal = n())
  


# transformar quantidade em porcentagem do total
temp$quantidade <- 100*temp$quantidade/sum(temp$quantidade)
temp2$quantidadeNormal <- 100*temp2$quantidadeNormal/sum(temp2$quantidadeNormal)

# filtrar 20 maiores de cada
temp <- temp %>%
  top_n(20)

temp2 <- temp2 %>%
  top_n(20)

comparacao <- merge(temp, temp2, by = "ORG_LOTACAO")
temp3 <- select(comparacao, ORG_LOTACAO, quantidade1 = quantidade, quantidadeNormal)

temp3 <- melt(temp3, id.vars = "ORG_LOTACAO")

#mudar nome do fator para aparecer bonito no gráfico
levels(temp3$variable) <- c("Grupo dos 1%", "Total geral")

ggplot(temp3, aes(x = ORG_LOTACAO, y = value, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Porcentual da quantidade de\n servidores por órgão", x = "", y = "%") +
  coord_flip() +
  theme(legend.position = "bottom", legend.title = element_blank())
{% endhighlight %}

![center](/figs/transparenciaParte6/unnamed-chunk-7-1.png) 

Também há uma discrepância notável aqui: Enquanto que apenas 1,5% dos servidores federais trabalha na AGU, no grupo dos 1% esse percentual sobe para 9%.

## 3. Qual cargo desempenham?


{% highlight r %}
umPorCento %>%
  group_by(DESCRICAO_CARGO) %>%
  summarise(quantidade = n()) %>%
  mutate(percentual = 100*quantidade/sum(quantidade)) %>%
  na.omit() %>%
  top_n(20) %>%
  ggplot(aes(x = reorder(DESCRICAO_CARGO, percentual), y = percentual)) +
    labs(title = "Porcentual da quantidade de\n servidores por cargo", x = "", y = "%") +
    coord_flip() +
    geom_bar(stat = "identity")
{% endhighlight %}

![center](/figs/transparenciaParte6/unnamed-chunk-8-1.png) 

Curiosamente, a maioria dos 1% são professores de universidades federais. Pelo visto não é todo professor que ganha pouco...


## 4. A quanto tempo estão no cargo?


{% highlight r %}
CalcAnos <- function(t0, t=today()) {
    x <- interval(t0, t)
    x <- as.period(x)
    x <- ceiling(year(x) + month(x)/12)
    return(x)
}


umPorCento$anos <- umPorCento$DATA_DIPLOMA_INGRESSO_SERVICOPUBLICO %>% dmy() %>% CalcAnos
df$anos <- df$DATA_DIPLOMA_INGRESSO_SERVICOPUBLICO %>% dmy() %>% CalcAnos

par(mfrow=c(2,2))
hist(umPorCento$anos, main = "Tempo trabalhando para o Estado\n(Grupo dos 1%)", xlab = "Anos")
hist(df$anos, main = "Tempo trabalhando para o Estado\n(Geral)", xlab = "Anos")
boxplot(umPorCento$anos, main = "Tempo trabalhando para o Estado\n(Grupo dos 1%)", ylab = "Anos")
boxplot(df$anos, main = "Tempo trabalhando para o Estado\n(Geral)", ylab = "Anos")
{% endhighlight %}

![center](/figs/transparenciaParte6/unnamed-chunk-9-1.png) 

Aqui temos o esperado: O tempo médio e mediano no funcionalismo público é maior para os 1% do que para o geral.

## 5. Qual a natureza de seus vínculos com o Estado?


{% highlight r %}
temp <- umPorCento %>%
  group_by(SITUACAO_VINCULO) %>%
  summarise(quantidade = n()) 


temp2 <- df %>%
  group_by(SITUACAO_VINCULO) %>%
  summarise(quantidadeNormal = n())
  


# transformar quantidade em porcentagem do total
temp$quantidade <- 100*temp$quantidade/sum(temp$quantidade)
temp2$quantidadeNormal <- 100*temp2$quantidadeNormal/sum(temp2$quantidadeNormal)

# filtrar 20 maiores de cada
temp <- temp %>%
  top_n(20)

temp2 <- temp2 %>%
  top_n(20)

comparacao <- merge(temp, temp2, by = "SITUACAO_VINCULO")
temp3 <- select(comparacao, SITUACAO_VINCULO, quantidade1 = quantidade, quantidadeNormal)

temp3 <- melt(temp3, id.vars = "SITUACAO_VINCULO")

#mudar nome do fator para aparecer bonito no gráfico
levels(temp3$variable) <- c("Grupo dos 1%", "Total geral")

ggplot(temp3, aes(x = SITUACAO_VINCULO, y = value, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Porcentual da quantidade de\n servidores por situação do vínculo", x = "", y = "%") +
  coord_flip() +
  theme(legend.position = "bottom", legend.title = element_blank())
{% endhighlight %}

![center](/figs/transparenciaParte6/unnamed-chunk-10-1.png) 

**Mais uma grande descoberta**: O porcentual de servidores das categorias *"APOSENTADO"*, *"EXERC DESCENT CARREI"* (que são servidores das carreiras típicas de Estado vinculadas aos Ministérios do Planejamento, Orçamento e Gestão e Ministério da Fazenda que exercem as suas atividades na UJ mediante exercício descentralizado de atividade) e *"REQUISITADO"* (servidores que exercem atividades na UJ em razão de haverem sido requisitados conforme previsão do art. 93, inciso II, da Lei n.º 8.112/90) é muito maior no grupo dos 1% do que no geral.

É só ver o resultado acima para o grupo dos aposentados para saber o que tem de errado com nossa previdência.


## 6. Afinal de contas, quem é o que ganha mais?


{% highlight r %}
umPorCento %>% select(-ID_SERVIDOR_PORTAL, -V1, -x) %>% top_n(1, SALARIO) %>% t %>% htmlTable()
{% endhighlight %}

<table class='gmisc_table' style='border-collapse: collapse; margin-top: 1em; margin-bottom: 1em;' >
<tbody>
<tr style='border-top: 2px solid grey;'>
<td style='border-top: 2px solid grey; text-align: left;'>UF_EXERCICIO</td>
<td style='border-top: 2px solid grey; text-align: center;'>DF</td>
</tr>
<tr>
<td style='text-align: left;'>NOME</td>
<td style='text-align: center;'>MANOEL DIAS</td>
</tr>
<tr>
<td style='text-align: left;'>DESCRICAO_CARGO</td>
<td style='text-align: center;'>MINISTRO DE ESTADO</td>
</tr>
<tr>
<td style='text-align: left;'>ATIVIDADE</td>
<td style='text-align: center;'></td>
</tr>
<tr>
<td style='text-align: left;'>UORG_LOTACAO</td>
<td style='text-align: center;'>MINISTERIO DO TRABALHO E EMPREGO</td>
</tr>
<tr>
<td style='text-align: left;'>ORG_LOTACAO</td>
<td style='text-align: center;'>MINISTERIO DO TRABALHO E EMPREGO</td>
</tr>
<tr>
<td style='text-align: left;'>ORGSUP_LOTACAO</td>
<td style='text-align: center;'>MINISTERIO DO TRABALHO E EMPREGO</td>
</tr>
<tr>
<td style='text-align: left;'>UORG_EXERCICIO</td>
<td style='text-align: center;'>MINISTERIO DO TRABALHO E EMPREGO</td>
</tr>
<tr>
<td style='text-align: left;'>ORG_EXERCICIO</td>
<td style='text-align: center;'>MINISTERIO DO TRABALHO E EMPREGO</td>
</tr>
<tr>
<td style='text-align: left;'>ORGSUP_EXERCICIO</td>
<td style='text-align: center;'>MINISTERIO DO TRABALHO E EMPREGO</td>
</tr>
<tr>
<td style='text-align: left;'>SITUACAO_VINCULO</td>
<td style='text-align: center;'>NATUREZA ESPECIAL</td>
</tr>
<tr>
<td style='text-align: left;'>REGIME_JURIDICO</td>
<td style='text-align: center;'>NATUREZA ESPECIAL</td>
</tr>
<tr>
<td style='text-align: left;'>JORNADA_DE_TRABALHO</td>
<td style='text-align: center;'>40 HORAS SEMANAIS</td>
</tr>
<tr>
<td style='text-align: left;'>DATA_INGRESSO_CARGOFUNCAO</td>
<td style='text-align: center;'>16/03/2013</td>
</tr>
<tr>
<td style='text-align: left;'>DATA_INGRESSO_ORGAO</td>
<td style='text-align: center;'>15/03/2013</td>
</tr>
<tr>
<td style='text-align: left;'>DATA_DIPLOMA_INGRESSO_SERVICOPUBLICO</td>
<td style='text-align: center;'>15/03/2013</td>
</tr>
<tr>
<td style='text-align: left;'>REGIAO</td>
<td style='text-align: center;'>Centro-Oeste</td>
</tr>
<tr>
<td style='text-align: left;'>SALARIO</td>
<td style='text-align: center;'>52808.24</td>
</tr>
<tr>
<td style='border-bottom: 2px solid grey; text-align: left;'>anos</td>
<td style='border-bottom: 2px solid grey; text-align: center;'>3</td>
</tr>
</tbody>
</table>

**Por hoje, é só!**

