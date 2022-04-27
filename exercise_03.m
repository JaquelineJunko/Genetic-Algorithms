function [results] = exercise_03(PC, pm, n, max_it)
%{
FUN��O:
    Algoritmo Gen�tico para minimizar a fun��o F(x,y) = (1-x)^2 +
    100(y-x^2)^2
ENTRADA:
    PC: taxa de crossover
    pm: probabilidade de muta��o
    n: n�mero de indiv�duos
    max_it: n�mero maximo de itera��es
SA�DA:
    resultados do experimento
    | x | y | F(x,y) | Gera��o | k | PC | pm | Tempo de Execu��o |
%}
    if( mod(n,2) ~= 0 )
         error("Informe em n�mero de popula��o par!");
    end
    
    bitString = 64; % indiv�duo ser� reprentado por 32 bits: { 1� bit: 1 = positivo | 0 = negativo } {31 bits seguintes para numero}.
    
    tic;
    
    P = zeros(n, bitString);
    
    % Inicializar P
    for i = 1 : n        
        x = (rand() * 10 - 5); % gera n�meros aleatorios num intervalo de [-5,5]
        if(x >= 0) % numero negativo
            P(i,1) = 1;
        else
            P(i,1) = 0;
        end
        
        P(i,1:32) = real2bin(x);
        
        y = (rand() * 10 - 5);
        if(y >= 0) % numero positivo
            P(i,1) = 1;
        else
            P(i,1) = 0;
        end
        P(i,33:64) = real2bin(y);
    end
    
    % f <- Avaliar P
    f = avaliar(P);
    
    best = P(find(f == min(f)), :);
    t = 1;
    k = 1;
    
    while(t < max_it && k < 50)
        
        % Selecionar
        P = selecaoRoleta (P,f);
        
        % Reproduzir
        P = crossover(P, PC, bitString);
        
        % Variar
        P = mutacao(P, pm);
        
        % Avaliar
        f1 = avaliar(P);        
        if( min(f) > min(f1))
            f = f1;
            k = 1;
            % Melhor indiv�duo
            best = P(find(f == min(f)), :);
        end      
        
        k = k + 1;
        t = t + 1;
    end
    
    toc;
    
    x = bin2real(best(1, 1:32));
    y = bin2real(best(1, 33:64));
    
    % Matriz com dados do experimento
    % | x | y | F(x,y) | Gera��o | k | PC | pm | Tempo de Execu��o |
    results = zeros(1,8);
    results(1,1) = x; %x
    results(1,2) = y; %y
    results(1,3) = ( 1-x )^2 + 100 *( y-x^2 )^2;
    results(1,4) = t; 
    results(1,5) = k;
    results(1,6) = PC;
    results(1,7) = pm;    
    results(1,8) = toc;
end

function [f] = avaliar(P)
%{
FUN��O:
    Transformar o valor bin�rio x em um n�mero inteiro e avali�-lo na
    primeira parte da fun��o que depende apenas de x. f(x) = (1-x)^2
ENTRADA:
    P: matriz binaria (n,bitString) -> Popula��o
SA�DA:
    f: matriz de inteiros (n,m) -> cada linha de 1,..,n da matriz f
    corresponde a sua respectiva linha na matriz da popula��o, assim como
    cada m-�sima coluna de f corresponde a qual linha na popula��o ele
    corresponde. Por exemplo, f(3,6) � o valor da fun��o em que x � o 3�
    indiv�duo (3� linha) da popula��o e y � o 6� indiv�duo (6� linha) da
    popula��o.
%}     
    n = size(P,1);
    f = zeros(1,n);
        
    for i = 1 : n
        x = bin2real( P(i,1:32) ); % converte o valor do bitstring para um valor real  
        y = bin2real( P(i,33:64) );
        f(1,i) = ( 1-x )^2 + 100 *( y-x^2 )^2; % cada posi��o de f corresponde a g(x_i)
    end
end

function [b2r] = bin2real(binario)
%{
FUN��O:
    Converte um n�mero bin�rio para real, no qual o primeiro bit indica o
    sinal do n�mero: 1 = positivo, 0 = negativo.
ENTRADA:
    binario: vetor bin�rio (1x32) -> n�mero em bin�rio. Bitstring
SA�DA:
    b2r: n�mero real -> n�mero real convertido.
%}
    n = 3;         % number bits for integer part of your number
    m = 28;         % number bits for fraction part of your number

    % real number
    b2r = binario(1,2:32)*pow2(n-1:-1:-m).';
    
    if( binario(1,1) == 0 ) % n�mero negativo
        b2r = -1 * b2r; 
    end
end


function [r2b] = real2bin(real)
%{
FUN��O:
    Converter um n�mero real para bin�rio
ENTRADA:
    real: n�mero real -> valor real a ser convertido em bin�rio
SA�DA:
    r2b: vetor bin�rio (1x32) -> n�mero real convertido em bin�rio. Bitstring
%}
    n = 3; % number bits for integer part of your number
    m = 28; % number bits for fraction part of your number
    % binary number
           
    if(real < 0) % n�mero negativo
        r2b(1,1) = 0;
        real = -1 * real; 
    else
        r2b(1,1) = 1;
    end
    
    r2b(1,2:32) = fix(rem(real*pow2(-(n-1):m),2));
end

function [novaPopulacao] =  selecaoRoleta (P,f)
%{
FUN��O:
        Seleciona os indiv�duos pelo m�todo de Roleta. A parcela de cada
        indiv�duo na roleta � proporcional a sua aptid�o ( quanto maior a
        aptid�o, maior ser� essa parcela)
ENTRADA:
        P: matriz(n,12)   -> popula��o antes da sele��o;
        f: vetor(1,n)     -> valor de aptid�o do indiv�duo;        
SAIDA:
        novaPopulacao: matriz(n,12) -> popula��o com os indiv�duos selecionados;
%}
    n = size(P,1); % quantidade de indiv�duos na popula��o
    % Definir intervalo da roleta para cada um dos n indiv�duos
    roleta = zeros(1,n); % roleta(i) armazena o limite superior do indiv�duo xi em seu intervalo na roleta
    limite = 0;   
    for i = 1: n
            porcaoRoleta = ( f(i)*360 ) / sum(f); % por��o do indiv�duo i na roleta
            pInteira = fix(porcaoRoleta); % parte inteira do n�mero
            pFracionaria = porcaoRoleta - pInteira; % parte fracion�ria do n�mero
            % Arredondamento do n�mero real para um inteiro
            if(pFracionaria < 0.5)
                limite = limite + pInteira; % arredondar para baixo
            else
                limite = limite + pInteira + 1; % arredondar para cima
            end    
            roleta(i) = limite;
    end
    
    % Escolher aleatoriamente n n�meros no intervalo (0,360]
    s = (randi(roleta(n),n,1))'; % individuos selecionados na roleta.
    
    % Selecionar o indiv�duo que possui o n�mero sorteado em seu intervalo
    for i = 1 : n
        cont = 1; % corresponde a posi��o do vetor roleta, consequentemente, indica o indiv�duo que foi escolhido
        while( s(i) > roleta(cont) ) % significa que s(i) ainda n�o pertence ao intervalo atual (roleta(cont))
            cont = cont + 1;
        end
        s(i) = cont; % cada posi��o de s armazena o numero do individuo selecionado. O n�mero do individuo selecionado � associado as linhas da matriz de popula��o
    end
    
    % Compor a nova popula��o com os indiv�duos selecionados
    novaPopulacao = zeros(n, size(P,2));
    for i = 1 : n
        novaPopulacao(i,:) = P(s(i),:); 
    end 
end


function[novaPopulacao] = crossover(P, PC, tamBitstring)
%{
FUN��O:
    Reprodu��o dos indiv�duos
ENTRADA:
    P: matriz(n,tamBitstring) -> popula��o ap�s sele��o
    PC: n�mero real -> taxa de crossover
SA�DA:
    novaPopula��o   -> popula��o ap�s reprodu��o
%}
    n = size(P,1); % numero de indiv�duos da popula��o
    pares = n/2; % quantidade de pares de invid�vudos
    r = rand(1,pares); % gera um vetor (de tamanho 1 x pares) de numeros aleatorios entre 0 e 1;
    j = 1; % contador para percorrer o vetor r
    novaPopulacao = zeros(n,tamBitstring);
    
    % Verificar se haver� crossover ou n�o
    for i = 1 : 2 : n % o indice i auxiliar� a encontrar a posi��o dos individuos no par
        
        pai1 = P(i,:);
        pai2 = P(i+1,:);
        
        if(r(j) <= PC) % h� crossover
            % sortear um n�mero inteiro aleat�rio no intervalo [2,10] para ser o ponto de crossover (cp)
            cp = randi([2,tamBitstring-2],1);
            % filho 1
            filho1(1, 1:cp) = pai1(1, 1:cp);
            filho1(1, cp+1:tamBitstring) = pai2(1, cp+1:tamBitstring);
            
            % filho 2
            filho2(1, 1:cp) = pai2(1, 1:cp);
            filho2(1, cp+1:tamBitstring) = pai1(1, cp+1:tamBitstring);
            
            novaPopulacao(i,:) = filho1;
            novaPopulacao(i+1,:) = filho2;    
            
        else % n�o h� crossover, repetir os pais
            novaPopulacao(i,:) = pai1;
            novaPopulacao(i+1,:) = pai2;            
        end        
        j = j + 1;
    end           
end

function [P] = mutacao(P, pm)
%{
ENTRADA:
        P: matriz(n,12) -> popula��o atual
        pm: n�mero real -> probabilidade de muta��o
SA�DA:

%}    
    % Comparar r aleatorio e pm em  todas as posi��es da matriz de popula��o
    for i = 1 : size(P,1)
        for j = 1 : size(P,2)
            r = rand; % sorteia um numero aleatorio no intervalo (0,1)
            if (r <= pm)
                P(i,j) = ~P(i,j);
            end
        end
    end
end