function [saida, model] = ppsazon(serie)
%Permite a avaliação da presença de sazonalidades (visual) e o pre-processamento(diferenciação sazonal) da série
%Sazonalidades%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[n1,n2]=size(serie);
for i=1:n1
    [serie_sem_NaN nans]=removeNaN(serie(i,:));%Remove os NaNs da série analisada e armazena o numero de nans encontrados
    testsaz(serie_sem_NaN,n2-2,3 );
    ps(i)=input('Entre com o período da sazonalidade: ');%Teste visual
    residuoNaN=[];%aloca espaço a memória para a variável
    if ps(i)>0
    residuoNaN(1:ps(i))=NaN;%criar um vetor com NaN para ser concatenado e manter o tamanho original do vetor
    [residuo{i},seriesazon0] = difsaz(serie_sem_NaN,ps(i));%Faz a difereciacao sazonal, resultando um vetor com um numero reduzido de amostras
    else
    residuo{i}=serie_sem_NaN;  %Se não for detectada sazonalidade, não se faz nada
    end
    if nans==0
    serie(i,:)=[residuoNaN residuo{i}];%Se nao foram encontrado nans pela funcao removeNaN, não há que se desfazer esta operacao. Apenas os NaNs para equilibrar a diferenciação sazonal
    else %Se foram removidos nans por removeNaN, então estes deverão ser readicionados para voltar ao tamanho origial do vetor
    [serie_com_nans] = adicionaNaN(residuo{i},nans);%Adiciona os nans extraídos por removeNaN
    serie(i,:)=[residuoNaN serie_com_nans];%Adiciona os nans que surgiram pela diferenciacao sazonal
    end
    clear residuoNaN;%apaga a variável para evitar incompatibilidade no loop
end
saida=serie;
model=ps;%Modelo pp sazonalidades

end

