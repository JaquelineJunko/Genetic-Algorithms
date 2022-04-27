function [results] = exercise_02 (PC, pm, n, max_it)
%{
FUN��O:
    Algoritmo Gen�tico para maximizar a fun��o (2^(-2*(((x-0.1)/0.9)^2
    )))*((sin(5*pi*x))^6).

ENTRADA:
    n: inteiro -> tamanho da popula��o
SA�DA:
    results: matriz com os resultados do experimento.
    | x | g(x) | Gera��o | Aptidao M�dia | PC | pm | Tempo de Execu��o |
%}  
    if (mod(n,2) ~= 0)
        error("Informe o n�mero de indiv�duos par!!");
    end
    
    tic;
    aptidaoMedia = 0;
    %% Inicializar P(n,32)
    P = zeros(n,32);
    for i = 1 : n
        x = rand; % gerar cada indiv�duo aleatoriamente no intervalo (0,1)
        P(i,:) = real2bin(x); % converter o valor real aleat�rio para bitstring
    end
        
    %% Avalia��o
    f = zeros(1,n);
    for i = 1 : n
        x = bin2real( P(i,:) ); % converte o valor do bitstring para um valor real
        f(1,i) = avaliar(x); % cada posi��o de f corresponde a g(x_i)
    end
    t = 1;
    k = 1;
    best = bin2real(P(find(max(f)),:));
    %% Enquanto n�o atender o crit�iro de parada (n�mero x de itera��es, resultado n�o melhorar ou atingir o resultado esperado???)
    while (t < max_it && k < 50)         
        % Sele��o
        P = selecaoRoleta (P,f);
        % Reprodu��o
        P = crossover(P, PC, 32);
        % Muta��o
        P = mutacao(P, pm);
        % Avalia��o e calcular Aptidao M�dia
        for i = 1 : n
            x = bin2real( P(i,:) ); % converte o valor do bitstring para um valor real
            f(1,i) = avaliar(x); % cada posi��o de f corresponde a g(x_i)
            aptidaoMedia = aptidaoMedia + x;
        end
        aptidaoMedia = aptidaoMedia/n;
        
       
        best1 = bin2real(P(find(max(f)),:));
        % encontrar melhor x 
        if (best < best1)
           best = best1;
           k = 1;
        end
        
         t = t + 1;
         k = k+1;
    end
    
    toc;
    % Matriz com dados do experimento
    % | x | g(x) | Gera��o | Aptidao M�dia | PC | pm | Tempo de Execu��o |
    results = zeros(1,7);
    results(1,1) = x;
    results(1,2) = avaliar(x);
    results(1,3) = t; 
    results(1,4) = aptidaoMedia;
    results(1,5) = PC;
    results(1,6) = pm;    
    results(1,7) = toc;
    results(1,8) = k;
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
    n = 1; % number bits for integer part of your number
    m = 31; % number bits for fraction part of your number
    % binary number
    r2b = fix( rem( real*pow2( -(n-1):m ),2) );
end

function [b2r] = bin2real(binario)
%{
FUN��O:
    Converte um n�mero bin�rio para real
ENTRADA:
    binario: vetor bin�rio (1x32) -> n�mero em bin�rio. Bitstring
SA�DA:
    b2r: n�mero real -> n�mero real convertido.
%}
    n = 1;         % number bits for integer part of your number
    m = 31;         % number bits for fraction part of your number
    % real number
    b2r = binario*pow2(n-1:-1:-m).';
end


function [y] = avaliar(x)
%{
FUN��O:
    Calcular o valor g(x) da fun��o
ENTRADA:
    x: n�mero real
SA�DA: 
    y: n�mero real -> g(x)
%}
    y = (2^(-2*(((x-0.1)/0.9)^2 )))*((sin(5*pi*x))^6);

end

function [novaPopulacao] =  selecaoRoleta (P,f)
%{
FUN��O:
        Seleciona os indiv�duos pelo m�todo de Roleta. A parcela de cada
        indiv�duo na roleta � proporcional a sua aptid�o ( quanto maior a
        aptid�o, maior ser� essa parcela)
ENTRADA:
        P: matriz(n,tamBitstring)   -> popula��o antes da sele��o;
        f: vetor(1,n)     -> valor de aptid�o do indiv�duo;        
SAIDA:
        novaPopulacao: matriz(n,tamBitstring) -> popula��o com os indiv�duos selecionados;
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
    novaPopulacao = zeros(n, 32);
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

