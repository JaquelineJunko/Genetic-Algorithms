# Genetic-Algorithms
Subject: Computação Inspirada pela Natureza. Algorithms developed for behavior studies.

## Description 
The solutions presented here were developed for study purposes, in the postgraduate course "Computação Inspirada Pela Natureza"

# Exercise 01
**Goal:** Implement a genetic algorithm that recognizes the number 0, represented by the bitstring [1 1 1 1 1 0 1 1 0 1 1 1 1 1]. 

**Parameters for algorithm execution:**
- PC (real number): crossover rate;
- pm (real number): mutation probability;
- n (even integer): number of individuals in the population;

**Algorithm Operation:** First the population is created. It consists of a matrix of n rows and 12 columns. Each individual is created by drawing 0's and 1's under a uniform distribution.

The evaluation function considered was the Hamming Distance. This way, the fitness of the population was extracted taking the size of the bitstring, 12, and subtracting the Hamming distances obtained from each individual. An individual with ideal fitness has the value f = 12. Therefore, the stopping criterion of the algorithm is that at least one individual has this fitness.

The selection method proposed was roulette wheel selection, in which each individual has a share in the roulette proportional to its aptitude. Thus, n numbers are drawn, which will later return to which individual it belongs. Forming then a new population with the individuals.

For the crossover phase, the population is divided into pairs, so that each pair corresponds to the two individuals that will possibly generate another two descendant, that will replace them in the population. The crossover rate used in the experiment belongs to the interval (0.6, 1). Thus, a real number r is sorted in the interval (0, 1), following a uniform distribution. The crossover occurs only if r <= PC. If this does not occur, the parents will be repeated in the next generation. When the crossover occurs, a crossover point, cp, is drawn on the interval [2, 10], with uniform distribution, forming the two descendants that will replace their parents in the population.

Regarding mutation, each position of the population matrix is run through and a respective real random value r is generated, following a uniform distribution in the interval (0,1). If r <= pm, the corresponding bit has its value reversed.

## Example of how to run the project
``` 
PC = 0.6 + (1 - 0.6) * rand;        % 0,6 < PC < 1.0
pm = 0.01;
n = 16;                             % number of individuals
results =  exercise_01(PC, pm,n);
```

# Exercise 02
**Goal:** Implement genetic algorithm to maximize the function ![equation](http://www.sciweavers.org/upload/Tex2Img_1651089086/render.png)

**Parameters for running the algorithm:**
- PC (real number): crossover rate;
- pm (real number): mutation probability;
- n (even integer): number of individuals in the population;
- max\_it: maximum number of iterations.

**Algorithm Operation:** The structure of the algorithm is similar to Exercise 01. One modification is to start the population with randomly chosen real numbers in the interval (0,1), following the uniform distribution. Each of these numbers is converted to a bitstring of fixed size 32, chosen empirically. The conversion process adopts 1 bit to store the integer part of the number and the other 31 bits are used to store the fractional part. Thus, the population consists of n individuals, and is represented by a matrix of n rows and 32 columns, where each row represents the n-th individual.

The evaluation function consists of g(x) itself. So, to calculate the fitness of the individuals, each of them is converted to its real value and applied to the function. The selection, crossover and mutation methods are the same as in the previous exercise. The stopping criterion consists of a limit number of runs and when there is no improvement in the fitness of the population.

## Example of how to run the project
``` 
n = 100;                      % num of individuals
max_it = 10;
PC = 0.6 + (1 - 0.6) * rand;  % 0,6 < PC < 1.0
pm = 0.01;                    % pm varies between 0.01 and 0.02
results = exercise_02(PC, pm, n, max_it);
```

## Bonus
We can solve exercise 2 by the methods: hill climbing and simulated annealing.

```
results = simulated_annealing(max_it)

input: maximum number of iterations (int)
output: number of iterations | x | g(x) | (matrix 1x3)
```
```
results = hill_climbing(max_it)

input: maximum number of iterations (int)
output: | number of iterations | x | g(x) | execution time | (matrix 1x4)
```

# Exercise 03
**Goal****: Implement a genetic algorithm to minimize the function ![equation2](http://www.sciweavers.org/upload/Tex2Img_1651089153/render.png) on the continuous interval ![intervalo](http://www.sciweavers.org/upload/Tex2Img_1651089172/render.png)

**Parameters for running the algorithm:**
- PC (real number): crossover rate;
- pm (real number): mutation probability;
- n (even integer): number of individuals in the population;

**Algorithm Operation:** In this algorithm it was taken into account that each of the individuals is formed by a bitstring of size 64, where the interval [0,32] represents the bitstring of variable x and the interval [32,64] represents variable y. Knowing this, it is considered that the first bit of each bitstring is used for the sign representation, being equal to 1 for positive numbers and 0 for negative numbers, that is, given a bitstring of size 64, positions 1 and 33 indicate the signs of variables x and y, respectively.

To make up the population of size n, two numbers in the interval (0,1) with uniform distribution are drawn. Then these numbers are multiplied by 10, giving the interval (0,10), and then 5 is subtracted, resulting in individuals within the interval -5 to +5. In the same way as in the previous exercise, the numbers are converted to binary values, considering 3 bits to store the integer part and 28 bits for the fractional part, resulting in 32 bits.

To evaluate the fitness of individuals, the function f (x, y) is used. In the evaluation, each bitstring is separated into its respective variable x and y, as explained earlier, and applied to the function, resulting in its fitness value. All fitness values are stored in a vector of size 1 x n, so that each column represents the n-th individual in the population.

The stopping criterion taken into account is a maximum value of iterations and when there is no improvement in the fitness function, k. The selection, crossover and mutation methods are the same as in the previous exercises.

## Example of how to run the project
``` 
n = 100;                      % num of individuals
max_it = 10;
PC = 0.6 + (1 - 0.6) * rand;  % 0,6 < PC < 1.0
pm = 0.01;                    % pm varies between 0.01 and 0.02
results = exercise_03(PC, pm, n, max_it);
```
