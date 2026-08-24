function [T_lida] = ler_dados_csv(filename)
% ==== LER DADOS DA PLANILHA ====
T_lida = readtable(filename);

disp('Primeiras linhas dos dados lidos:');
disp(head(T_lida));


end