# Genetic-Algorithms
Subject: Computação Inspirada pela Natureza. Algorithms developed for behavior studies.

## Description 
The solutions presented here were developed for study purposes, in the postgraduate course "Computação Inspirada Pela Natureza"

# Exercise 01
**Objetivo:** Implementar um algoritmo genético que reconheça o número 0, representado pela bitstring [1 1 1 1 0 1 1 0 1 1 1 1].

**Parâmetros para execução do algoritmo:**
- PC (número real): taxa de crossover;
- pm (número real): probabilidade de mutação;
- n (número inteiro par): número de indivíduos da população;

**Funcionamento do Algoritmo:** Inicialmente cria-se a população. Ela consiste em uma matriz de n linhas e 12 colunas. Cada indivíduo é criado sorteando-se 0’s e 1’s sob uma distribuição uniforme.

A função de avaliação considerada foi a Distância de Hamming. Dessa forma, extraiu-se a aptidão da população tomando o tamanho da bitstring, 12, e subtraindo das distâncias de Hamming obtidas de cada indivíduo. Um indivíduo com aptidão ideal possui o valor f = 12. Portanto, o critério de parada do algoritmo é o de que ao menos um indivíduo tenha essa aptidão.

O método de seleção proposto foi a seleção por roleta, no qual cada indivíduo possui uma parcela na roleta proporcional à sua aptidão. Assim, são sorteados n números inteiros, que posteriormente retornará a qual indivíduo ele pertence. Formando então uma nova população com os indivíduos.

Para a fase de cruzamento, a população é dividida em pares, de modo que cada par corresponde aos dois indivíduos que possivelmente gerarão outros dois descendentes que os substituirão na população. A taxa de crossover utilizada no experimento pertence ao intervalo (0.6, 1). Dessa forma, um número real r é sortido no intervalo (0,1), seguindo uma distribuição uniforme. O cruzamento só ocorre caso r <= PC. Caso isso não ocorra, os pais serão repetidos na próxima geração. Havendo o cruzamento, um ponto de crossover, cp, é sorteado no intervalo [2, 10], com distribuição uniforme, formando os dois descendentes que substituirão seus pais na população.

Em relação a mutação, cada posição da matriz da população é percorrida e gerado um respectivo valor aleatório real r, seguindo uma distribuição uniforme no intervalo (0,1). Caso r <= pm, o bit correspondente tem seu valor invertido.

## Exemplo de como rodar o projeto
``` 
PC = 0.6 + (1 - 0.6) * rand; % 0,6 < PC < 1.0
pm = 0.01;
n = 16; % num de indivíduos
results(1,:) =  exercicio_01(PC, pm,n);
```
