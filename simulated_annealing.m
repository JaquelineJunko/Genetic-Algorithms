function [results] = simulated_annealing(max_it)
%{
FUN��O:
    Algoritmo Recozimento Simulado/Simulated Annealing
ENTRADA:
    max_it: inteiro -> número máximo de iterações
SA�DA:
    results: matrix -> % | N�mero de Itera��es | x | g(x) |
%}
    beta = 0.1; % gradiente de decaimento da temperatura
    k = 10; % quantidade de perturba��es em x na mesma temperatura
    Tmin = 50;
    sigma = 0.3;
    % intervalo para gerar temperatura aleatoria para iniciar o sistema
    Tmin = 200;
    Tmax = 300;  
    
    
    T = randi([Tmin,Tmax]);
    x = rand;
    y = avaliar(x);   
    t = 1;
    
    while(t < max_it || Tmin < T)        
        perturbacao = normrnd(0, sigma);
        x1 = x + perturbacao;
        %if (x1 >= 0 && x1 <= 0)
            y = avaliar(x); 
            y1 = avaliar(x1);
            if(y1 > y)
                x = x1;
            else if (rand < exp((y1 - y)/T) )
                    x = x1;
                end
            end
            T = beta * T;            
        %else
        %    x1 = x1 - perturbacao;
        %end
        t = t + 1;
    end
      
    results = zeros(1,2);
    % | N�mero de Itera��es | x | g(x) |
    results(1,1) = t;
    results(1,2) = x;
    results(1,3) = y;
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