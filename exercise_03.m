function [results] = exercise_03(PC, pm, n, max_it)
    %{
    FUNÇÃO:
        Algoritmo Genético para minimizar a função F(x,y) = (1-x)^2 +100(y-x^2)^2
    ENTRADA:
        PC: taxa de crossover
        pm: probabilidade de mutação
        n: número de indivíduos
        max_it: número maximo de iterações
    SAÍDA:
        resultados do experimento
        | x | y | F(x,y) | Geração | k | PC | pm | Tempo de Execução |
    %}
        if( mod(n,2) ~= 0 )
             error("Informe em número de população par!");
        end
        
        bitString = 64; % indivíduo será reprentado por 32 bits: { 1º bit: 1 = positivo | 0 = negativo } {31 bits seguintes para numero}.
        
        tic;
        
        P = zeros(n, bitString);
        
        % Inicializar P
        for i = 1 : n        
            x = (rand() * 10 - 5); % gera números aleatorios num intervalo de [-5,5]
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
                % Melhor indivíduo
                best = P(find(f == min(f)), :);
            end      
            
            k = k + 1;
            t = t + 1;
        end
        
        toc;
        
        x = bin2real(best(1, 1:32));
        y = bin2real(best(1, 33:64));
        
        % Matriz com dados do experimento
        % | x | y | F(x,y) | Geração | k | PC | pm | Tempo de Execução |
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
    FUNÇÃO:
        Transformar o valor binário x em um número inteiro e avaliá-lo na
        primeira parte da função que depende apenas de x. f(x) = (1-x)^2
    ENTRADA:
        P: matriz binaria (n,bitString) -> População
    SAÍDA:
        f: matriz de inteiros (n,m) -> cada linha de 1,..,n da matriz f
        corresponde a sua respectiva linha na matriz da população, assim como
        cada m-ésima coluna de f corresponde a qual linha na população ele
        corresponde. Por exemplo, f(3,6) é o valor da função em que x é o 3º
        indivíduo (3ª linha) da população e y é o 6º indivíduo (6ª linha) da
        população.
    %}     
        n = size(P,1);
        f = zeros(1,n);
            
        for i = 1 : n
            x = bin2real( P(i,1:32) ); % converte o valor do bitstring para um valor real  
            y = bin2real( P(i,33:64) );
            f(1,i) = ( 1-x )^2 + 100 *( y-x^2 )^2; % cada posição de f corresponde a g(x_i)
        end
    end
    
    function [b2r] = bin2real(binario)
    %{
    FUNÇÃO:
        Converte um número binário para real, no qual o primeiro bit indica o
        sinal do número: 1 = positivo, 0 = negativo.
    ENTRADA:
        binario: vetor binário (1x32) -> número em binário. Bitstring
    SAÍDA:
        b2r: número real -> número real convertido.
    %}
        n = 3;         % number bits for integer part of your number
        m = 28;         % number bits for fraction part of your number
    
        % real number
        b2r = binario(1,2:32)*pow2(n-1:-1:-m).';
        
        if( binario(1,1) == 0 ) % número negativo
            b2r = -1 * b2r; 
        end
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
        n = 3; % number bits for integer part of your number
        m = 28; % number bits for fraction part of your number
        % binary number
               
        if(real < 0) % número negativo
            r2b(1,1) = 0;
            real = -1 * real; 
        else
            r2b(1,1) = 1;
        end
        
        r2b(1,2:32) = fix(rem(real*pow2(-(n-1):m),2));
    end
    
    function [novaPopulacao] =  selecaoRoleta (P,f)
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
        novaPopulacao = zeros(n, size(P,2));
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