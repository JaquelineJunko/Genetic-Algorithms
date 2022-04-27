function [results] =  exercise_01(PC, pm, n)
%{
FUN��O:
        Algoritmo Gen�tico para reconhecer o n�mero 0, representado pela
        bitstring [1 1 1 1 0 1 1 0 1 1 1 1]
ENTRADA:
        PC: n�mero real, tal q 0,6 < PC < 1.0. -> Indica a taxa de crossover
        pm: n�mero real, tal q pm < PC         -> Indica a probabilidade de muta��o
        n: n�mero inteiroc                     -> Indica o n�mero de indiv�duos da popula��o
SA�DA:
        P: popula��o final
        results: matriz com resultado de cada experimento
%}
    if (mod(n,2) ~= 0)
        error("Informe o n�mero de indiv�duos par!!");
    end
    
    tic;
    P = rand(n,12) >= 0.5; % Gera aleatoriamente uma matriz nx12 de 0's e 1's
        
    % Avaliar Aptid�o da popula��o
    [f, aptidaoMedia] = avaliar(P);
    
    geracao = 1;
    k = find(f == max(f)); %% indiv�duo com melhor aptid�o da gera��o
    fmax = f(1,k(1,1)); % valor da aptid�o
    
    while(f ~= 12) % Enquanto nenhum indiv�duo possuir aptid�o f = 12
        
        % Buscar melhor indiv�duo da popula��o
        k1 = find(f == max(f)); 
        if (fmax < f(1,k1(1,1)))
            k = k1;
            fmax = f(1,k(1,1));
        end
        
        % Sele��o por Roleta
        P = selecaoRoleta (P,f);
        
        % Reprodu��o
        P = crossover(P, PC);
        
        % Varia��o
        P = mutacao(P, pm);
        
        % Avalia��o
        [f, aptidaoMedia] = avaliar(P);
        
        grafico(geracao,1) = aptidaoMedia;
        grafico(geracao,2) = fmax;
        
        geracao = geracao + 1; 
    end
    toc;
    
    % Matriz com dados do experimento
    % | Gera��o | Aptidao M�dia | PC | pm | Tempo de Execu��o
    results = zeros(1,5);
    results(1,1) = geracao; 
    results(1,2) = aptidaoMedia;
    results(1,3) = PC;
    results(1,4) = pm;    
    results(1,5) = toc;
    plot(grafico);
end

function [novaPopulacao] =  selecaoRoleta (P,f,n)
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
    novaPopulacao = zeros(n, 12);
    for i = 1 : n
        novaPopulacao(i,:) = P(s(i),:); 
    end 
end

function[novaPopulacao] = crossover(P, PC)
%{

ENTRADA:
        P: matriz(n,12) -> popula��o ap�s sele��o
        PC: n�mero real -> taxa de crossover
SA�DA:
        novaPopula��o   -> popula��o ap�s reprodu��o
%}
    n = size(P,1); % numero de indiv�duos da popula��o
    pares = n/2; % quantidade de pares de invid�vudos
    r = rand(1,pares); % gera um vetor (de tamanho 1 x pares) de numeros aleatorios entre 0 e 1;
    j = 1; % contador para percorrer o vetor r
    novaPopulacao = zeros(n,12);
    
    % Verificar se haver� crossover ou n�o
    for i = 1 : 2 : n % o indice i auxiliar� a encontrar a posi��o dos individuos no par
        
        pai1 = P(i,:);
        pai2 = P(i+1,:);
        
        if(r(j) <= PC) % h� crossover
            % sortear um n�mero inteiro aleat�rio no intervalo [2,10] para ser o ponto de crossover (cp)
            cp = randi([2,10],1);
            % filho 1
            filho1(1, 1:cp) = pai1(1, 1:cp);
            filho1(1, cp+1:12) = pai2(1, cp+1:12);
            
            % filho 2
            filho2(1, 1:cp) = pai2(1, 1:cp);
            filho2(1, cp+1:12) = pai1(1, cp+1:12);
            
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

function [f, aptidaoMedia] = avaliar(P)
%{
ENTRADA:
        P: matriz(n,12) -> popula��o ap�s sele��o

SA�DA:

%}
    n = size(P,1); % qtd de indiv�duos da popula��o
    x1 = [1 1 1 1 0 1 1 0 1 1 1 1]; 
    h = zeros(1, n); % 'h' armazena a dist�ncia de Hamming dos indiv�duos
    
    for i = 1 : n
        h(i) = sum( abs( P(i,1:12) - x1(1,1:12) ) ); % C�lculo da dist�ncia de Hamming para cada indiv�duo
    end
    
    f = 12 - h; % 'f' � a fun��o de aptid�o da popula��o
    
    aptidaoMedia = sum(f)/n;
end

