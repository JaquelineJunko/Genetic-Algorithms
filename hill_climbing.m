function [results] = hill_climbing(max_it)
%{

FUN��O:
    Algoritmo Gen�tico para maximizar a fun��o g(x) =
    2^(-2^(((x-0.1)/0.9)^2))*(sen(5*pi*x))^6 , com x no intervalo [0,1]

ENTRADA:
    max_it: n�mero inteiro -> n�mero m�ximo de itera��es do algoritmo

SA�DA:
    results: matrix -> % | N�mero de Itera��es | x | g(x) | Tempo de execu��o |
%}
    sigma = 0.3;
    
    tic
    % Inicializar x
    x = rand;
    
    % Avaliar x
    y = avaliar(x);
    
    t = 1;
    k = 1; % auxiliar para controlar se a solu��o melhora ou n�o
    % Enquanto n�o atingir o crit�rio de parada: n�mero m�ximo de itera��es
    % ou se n�o houver melhoras em g(x)
    while(t < max_it && k < 50)           
        % Perturbar x
        %perturbacao = rand; % distribui��o uniforme para o ru�do (-1,1)
        perturbacao = normrnd(0, sigma);
        x1 = x + perturbacao;
        
        % Descartar x fora do intervalo [0,1]
        %if(x1 >= 0 && x1 <= 1)            
            % Avaliar novo x
            y1 = avaliar(x1);
            
            % Se x' for melhor que x
            if (y1 > y)
                x = x1;
                k = 1;
            end
            k = k + 1;
            t = t + 1;                     
        %else % x' ultrapassa o intervalo [0,1]
        %    x1 = x1 - perturbacao;
        % end
    end 
    toc
    
    results = zeros(1,2);
    % | N�mero de Itera��es | x | g(x) | Tempo de execu��o |
    results(1,1) = t;
    results(1,2) = x;
    results(1,3) = avaliar(x);
    results(1,4) = toc;
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