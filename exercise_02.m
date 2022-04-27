function [results] = exercise_02 (PC, pm, n, max_it)
    %{
    FUNÇÃO:
        Algoritmo Genético para maximizar a função (2^(-2*(((x-0.1)/0.9)^2)))*((sin(5*pi*x))^6).
    ENTRADA:
        n: inteiro -> tamanho da população
    SAÍDA:
        results: matriz com os resultados do experimento.
        | x | g(x) | Geração | Aptidao Média | PC | pm | Tempo de Execução |
    %}  
        if (mod(n,2) ~= 0)
            error("Informe o número de indivíduos par!!");
        end
        
        tic;
        aptidaoMedia = 0;
        %% Inicializar P(n,32)
        P = zeros(n,32);
        for i = 1 : n
            x = rand; % gerar cada indivíduo aleatoriamente no intervalo (0,1)
            P(i,:) = real2bin(x); % converter o valor real aleatório para bitstring
        end
            
        %% Avaliação
        f = zeros(1,n);
        for i = 1 : n
            x = bin2real( P(i,:) ); % converte o valor do bitstring para um valor real
            f(1,i) = avaliar(x); % cada posição de f corresponde a g(x_i)
        end
        t = 1;
        k = 1;
        best = bin2real(P(find(max(f)),:));
        %% Enquanto não atender o critéiro de parada (número x de iterações, resultado não melhorar ou atingir o resultado esperado???)
        while (t < max_it && k < 50)         
            % Seleção
            P = selecaoRoleta (P,f);
            % Reprodução
            P = crossover(P, PC, 32);
            % Mutação
            P = mutacao(P, pm);
            % Avaliação e calcular Aptidao Média
            for i = 1 : n
                x = bin2real( P(i,:) ); % converte o valor do bitstring para um valor real
                f(1,i) = avaliar(x); % cada posição de f corresponde a g(x_i)
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
        % | x | g(x) | Geração | Aptidao Média | PC | pm | Tempo de Execução |
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
    FUNÇÃO:
        Converter um número real para binário
    ENTRADA:
        real: número real -> valor real a ser convertido em binário
    SAÍDA:
        r2b: vetor binário (1x32) -> número real convertido em binário. Bitstring
    %}
        n = 1; % number bits for integer part of your number
        m = 31; % number bits for fraction part of your number
        % binary number
        r2b = fix( rem( real*pow2( -(n-1):m ),2) );
    end
    
    function [b2r] = bin2real(binario)
    %{
    FUNÇÃO:
        Converte um número binário para real
    ENTRADA:
        binario: vetor binário (1x32) -> número em binário. Bitstring
    SAÍDA:
        b2r: número real -> número real convertido.
    %}
        n = 1;         % number bits for integer part of your number
        m = 31;         % number bits for fraction part of your number
        % real number
        b2r = binario*pow2(n-1:-1:-m).';
    end
    
    
    function [y] = avaliar(x)
    %{
    FUNÇÃO:
        Calcular o valor g(x) da função
    ENTRADA:
        x: número real
    SAÍDA: 
        y: número real -> g(x)
    %}
        y = (2^(-2*(((x-0.1)/0.9)^2 )))*((sin(5*pi*x))^6);
    
    end
    
    function [novaPopulacao] =  selecaoRoleta (P,f)
    %{
    FUNÇÃO:
            Seleciona os indivíduos pelo método de Roleta. A parcela de cada
            indivíduo na roleta é proporcional a sua aptidão ( quanto maior a
            aptidão, maior será essa parcela)
    ENTRADA:
            P: matriz(n,tamBitstring)   -> população antes da seleção;
            f: vetor(1,n)     -> valor de aptidão do indivíduo;        
    SAIDA:
            novaPopulacao: matriz(n,tamBitstring) -> população com os indivíduos selecionados;
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
        novaPopulacao = zeros(n, 32);
        for i = 1 : n
            novaPopulacao(i,:) = P(s(i),:); 
        end 
    end
    
    function[novaPopulacao] = crossover(P, PC, tamBitstring)
    %{
    FUNÇÃO:
        Reprodução dos indivíduos
    ENTRADA:
        P: matriz(n,tamBitstring) -> população após seleção
        PC: número real -> taxa de crossover
    SAÍDA:
        novaPopulação   -> população após reprodução
    %}
        n = size(P,1); % numero de indivíduos da população
        pares = n/2; % quantidade de pares de invidívudos
        r = rand(1,pares); % gera um vetor (de tamanho 1 x pares) de numeros aleatorios entre 0 e 1;
        j = 1; % contador para percorrer o vetor r
        novaPopulacao = zeros(n,tamBitstring);
        
        % Verificar se haverá crossover ou não
        for i = 1 : 2 : n % o indice i auxiliará a encontrar a posição dos individuos no par
            
            pai1 = P(i,:);
            pai2 = P(i+1,:);
            
            if(r(j) <= PC) % há crossover
                % sortear um número inteiro aleatório no intervalo [2,10] para ser o ponto de crossover (cp)
                cp = randi([2,tamBitstring-2],1);
                % filho 1
                filho1(1, 1:cp) = pai1(1, 1:cp);
                filho1(1, cp+1:tamBitstring) = pai2(1, cp+1:tamBitstring);
                
                % filho 2
                filho2(1, 1:cp) = pai2(1, 1:cp);
                filho2(1, cp+1:tamBitstring) = pai1(1, cp+1:tamBitstring);
                
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