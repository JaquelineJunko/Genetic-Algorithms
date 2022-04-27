function [results] =  exercicio_01(PC, pm, n)
%{
FUNÇÃO:
        Algoritmo Genético para reconhecer o número 0, representado pela
        bitstring [1 1 1 1 0 1 1 0 1 1 1 1]
ENTRADA:
        PC: número real, tal q 0,6 < PC < 1.0. -> Indica a taxa de crossover
        pm: número real, tal q pm < PC         -> Indica a probabilidade de mutação
        n: número inteiroc                     -> Indica o número de indivíduos da população
SAÍDA:
        P: população final
        results: matriz com resultado de cada experimento
%}
    if (mod(n,2) ~= 0)
        error("Informe o número de indivíduos par!!");
    end
    
    tic;
    P = rand(n,12) >= 0.5; % Gera aleatoriamente uma matriz nx12 de 0's e 1's
        
    % Avaliar Aptidão da população
    [f, aptidaoMedia] = avaliar(P);
    
    geracao = 1;
    k = find(f == max(f)); %% indivíduo com melhor aptidão da geração
    fmax = f(1,k(1,1)); % valor da aptidão
    
    while(f ~= 12) % Enquanto nenhum indivíduo possuir aptidão f = 12
        
        % Buscar melhor indivíduo da população
        k1 = find(f == max(f)); 
        if (fmax < f(1,k1(1,1)))
            k = k1;
            fmax = f(1,k(1,1));
        end
        
        % Seleção por Roleta
        P = selecaoRoleta (P,f);
        
        % Reprodução
        P = crossover(P, PC);
        
        % Variação
        P = mutacao(P, pm);
        
        % Avaliação
        [f, aptidaoMedia] = avaliar(P);
        
        grafico(geracao,1) = aptidaoMedia;
        grafico(geracao,2) = fmax;
        
        geracao = geracao + 1; 
    end
    toc;
    
    % Matriz com dados do experimento
    % | Geração | Aptidao Média | PC | pm | Tempo de Execução
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
FUNÇÃO:
        Seleciona os indivíduos pelo método de Roleta. A parcela de cada
        indivíduo na roleta é proporcional a sua aptidão ( quanto maior a
        aptidão, maior será essa parcela)
ENTRADA:
        P: matriz(n,12)   -> população antes da seleção;
        f: vetor(1,n)     -> valor de aptidão do indivíduo;        
SAIDA:
        novaPopulacao: matriz(n,12) -> população com os indivíduos selecionados;
%}
    n = size(P,1); % quantidade de indivíduos na população
    % Definir intervalo da roleta para cada um dos n indivíduos
    roleta = zeros(1,n); % roleta(i) armazena o limite superior do indivíduo xi em seu intervalo na roleta
    limite = 0;   
    for i = 1: n
            porcaoRoleta = ( f(i)*360 ) / sum(f); % porção do indivíduo i na roleta
            pInteira = fix(porcaoRoleta); % parte inteira do número
            pFracionaria = porcaoRoleta - pInteira; % parte fracionária do número
            % Arredondamento do número real para um inteiro
            if(pFracionaria < 0.5)
                limite = limite + pInteira; % arredondar para baixo
            else
                limite = limite + pInteira + 1; % arredondar para cima
            end    
            roleta(i) = limite;
    end
    
    % Escolher aleatoriamente n números no intervalo (0,360]
    s = (randi(roleta(n),n,1))'; % individuos selecionados na roleta.
    
    % Selecionar o indivíduo que possui o número sorteado em seu intervalo
    for i = 1 : n
        cont = 1; % corresponde a posição do vetor roleta, consequentemente, indica o indivíduo que foi escolhido
        while( s(i) > roleta(cont) ) % significa que s(i) ainda não pertence ao intervalo atual (roleta(cont))
            cont = cont + 1;
        end
        s(i) = cont; % cada posição de s armazena o numero do individuo selecionado. O número do individuo selecionado é associado as linhas da matriz de população
    end
    
    % Compor a nova população com os indivíduos selecionados
    novaPopulacao = zeros(n, 12);
    for i = 1 : n
        novaPopulacao(i,:) = P(s(i),:); 
    end 
end

function[novaPopulacao] = crossover(P, PC)
%{

ENTRADA:
        P: matriz(n,12) -> população após seleção
        PC: número real -> taxa de crossover
SAÍDA:
        novaPopulação   -> população após reprodução
%}
    n = size(P,1); % numero de indivíduos da população
    pares = n/2; % quantidade de pares de invidívudos
    r = rand(1,pares); % gera um vetor (de tamanho 1 x pares) de numeros aleatorios entre 0 e 1;
    j = 1; % contador para percorrer o vetor r
    novaPopulacao = zeros(n,12);
    
    % Verificar se haverá crossover ou não
    for i = 1 : 2 : n % o indice i auxiliará a encontrar a posição dos individuos no par
        
        pai1 = P(i,:);
        pai2 = P(i+1,:);
        
        if(r(j) <= PC) % há crossover
            % sortear um número inteiro aleatório no intervalo [2,10] para ser o ponto de crossover (cp)
            cp = randi([2,10],1);
            % filho 1
            filho1(1, 1:cp) = pai1(1, 1:cp);
            filho1(1, cp+1:12) = pai2(1, cp+1:12);
            
            % filho 2
            filho2(1, 1:cp) = pai2(1, 1:cp);
            filho2(1, cp+1:12) = pai1(1, cp+1:12);
            
            novaPopulacao(i,:) = filho1;
            novaPopulacao(i+1,:) = filho2;    
            
        else % não há crossover, repetir os pais
            novaPopulacao(i,:) = pai1;
            novaPopulacao(i+1,:) = pai2;            
        end        
        j = j + 1;
    end           
end

function [P] = mutacao(P, pm)
%{
ENTRADA:
        P: matriz(n,12) -> população atual
        pm: número real -> probabilidade de mutação
SAÍDA:

%}    
    % Comparar r aleatorio e pm em  todas as posições da matriz de população
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
        P: matriz(n,12) -> população após seleção

SAÍDA:

%}
    n = size(P,1); % qtd de indivíduos da população
    x1 = [1 1 1 1 0 1 1 0 1 1 1 1]; 
    h = zeros(1, n); % 'h' armazena a distância de Hamming dos indivíduos
    
    for i = 1 : n
        h(i) = sum( abs( P(i,1:12) - x1(1,1:12) ) ); % Cálculo da distância de Hamming para cada indivíduo
    end
    
    f = 12 - h; % 'f' é a função de aptidão da população
    
    aptidaoMedia = sum(f)/n;
end

