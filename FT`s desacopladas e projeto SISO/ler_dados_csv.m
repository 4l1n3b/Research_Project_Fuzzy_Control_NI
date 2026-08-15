function [Tempo, r_f, y_f, u_f, erro_f] = ler_dados_csv(filename, var)
    data = readtable(filename);
    if var == 1
    % Use nomes que existem na planilha (ex: 'Tempo' com T maiúsculo)
    Tempo = data.Tempo; 
    r_f   = data.Referencia_Temperatura;
    y_f   = data.Saida_Temperatura;
    u_f   = data.Sinal_Controle_Temperatura;
    erro_f = data.Erro_Temperatura;
    elseif var == 2
    Tempo = data.Tempo; 
    r_f   = data.Referencia_Umidade;
    y_f   = data.Saida_Umidade;
    u_f   = data.Sinal_Controle_Umidade;
    erro_f = data.Erro_Umidade;    
    end
end