%Principal


load('matriz_mistura.txt');
fontes_sinteticas=fontes(1000);
%save fontes_sinteticas.txt fontes_sinteticas -ascii
%load('fontes_sinteticas.txt');

sinais_sinteticos=matriz_mistura*fontes_sinteticas;
%save sinais_sinteticos.txt sinais_sinteticos -ascii

%sinais unicos%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
serie_unica=sum(fontes_sinteticas);

%Outlier simulados + Séries simulada única
load('serie_unica.txt');
conj_trval=500;
vetor_pos=[51 103 219 333 432 (conj_trval+51+9) (conj_trval+103-3) (conj_trval+219+1) (conj_trval+333-3) (conj_trval+432-2)];
vetor_out=[3 -5 4 10 -2 2 -3 -4 5 -10];
[serie_out] = outlier_simulado(serie_unica,vetor_pos,vetor_out);
figure;plot(serie_out,'r:');hold on;plot(serie_unica);
save serie_unica_out.txt serie_out -ascii
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Outlier simulados + Séries simuladas múltiplas
serie=load('sinais_sinteticos.txt');
conj_trval=500;
vetor_pos(1,:)=conj_trval+[51 103 219 333 432];
vetor_pos(2,:)=conj_trval+[48 99 200 301 450];
vetor_pos(3,:)=conj_trval+[59 110 237 315 401];
vetor_pos(4,:)=conj_trval+[44 108 198 321 417];
vetor_pos(5,:)=conj_trval+[69 125 241 307 473];
vetor_pos(6,:)=conj_trval+[60 113 212 326 499];

%outliers no conjunto de trval
vetor_pos2(1,:)=[49 102 250 341 409 vetor_pos(1,:)];
vetor_pos2(2,:)=[69 171 211 330 457 vetor_pos(2,:)];
vetor_pos2(3,:)=[91 169 281 319 433 vetor_pos(3,:)];
vetor_pos2(4,:)=[88 155 222 312 417 vetor_pos(4,:)];
vetor_pos2(5,:)=[55 123 234 344 400 vetor_pos(5,:)];
vetor_pos2(6,:)=[98 177 260 300 489 vetor_pos(6,:)];

vetor_out(1,:)=[2 -3 4 5 -10];
vetor_out(2,:)=[3 -2 5 4 -10];
vetor_out(3,:)=[2 -3 5 4 -10];
vetor_out(4,:)=[2 -4 3 10 -5];
vetor_out(5,:)=[4 -5 10 3 -2];
vetor_out(6,:)=[2 -3 4 5 -10];

%outliers no conjunto de trval
vetor_out2(1,:)=[4 -2 5 3 -10 vetor_out(1,:)];
vetor_out2(2,:)=[10 -2 5 4 -2 vetor_out(2,:)];
vetor_out2(3,:)=[2 -4 5 3 -10 vetor_out(3,:)];
vetor_out2(4,:)=[5 -4 3 10 -2 vetor_out(4,:)];
vetor_out2(5,:)=[4 -5 10 3 -2 vetor_out(5,:)];
vetor_out2(6,:)=[2 -10 4 5 -3 vetor_out(6,:)];

for i=1:6
[serie_out(i,:)] = outlier_simulado(serie(i,:),vetor_pos2(i,:),vetor_out2(i,:));
end
figure;plot(serie_out(1,:),'r:');hold on;plot(serie(1,:));
%save sinais_sinteticos_out_trval_teste.txt serie_out -ascii
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Outlier simulados + Séries reais AMD
[serie_trval, serie_teste] = financeiras_amd(4);% Se tdica_lag=0, não usa TDICA, se >0 usa tdica_lag atrasos
serie=[serie_trval serie_teste];
conj_trval=252;
vetor_pos=conj_trval+[19 28 94 122 155];
vetor_out=[2 -3 4 5 -10];
for i=1:4
[serie_out(i,:)] = outlier_simulado(serie(i,:),vetor_pos,vetor_out);
end
figure;plot(serie_out(1,:),'r:');hold on;plot(serie(1,:));
save serie_amd2000_out.txt serie_out -ascii
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Substituir as posicoes dos outliers por amostras estimadas%%%%%%%%%%%%%%%%
s=load('sinais_sinteticos_estimados.txt');
x=load('sinais_sinteticos_outeste.txt');x=x(:,501:end);

x(1, [51 103 219 333 432])=s(1, [51 103 219 333 432]);
x(2,[48 99 200 301 450])=s(2,[48 99 200 301 450]);
x(3,[59 110 237 315 401])=s(3,[59 110 237 315 401]);
x(4,[44 108 198 321 417])=s(4,[44 108 198 321 417]);
x(5,[69 125 241 307 473])=s(5,[69 125 241 307 473]);
x(6,[60 113 212 326 499])=s(6,[60 113 212 326 499]);
serie_teste=x;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Substituir as posicoes dos outliers detectados por SCICA e RN por amostras estimadas%%%%%%%%%%%%%%%%
s=load('sinais_sinteticos_estimados.txt');
x=load('sinais_sinteticos_outeste.txt');x=x(:,501:end);

x(1, [103 219 333 432 475])=s(1, [103 219 333 432 475]);
x(2,[48 187 301 450])=s(2,[48 187 301 450]);
x(3,[60 110 237 401])=s(3,[60 110 237 401]);
x(4,[108 321 418])=s(4,[108 321 418]);
x(5,[69 125 241 308])=s(5,[69 125 241 308]);
x(6,[113 187 326 499])=s(6,[113 187 326 499]);
serie_teste=x;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Substituir as posicoes dos outliers SCICA por amostras estimadas com RN%%%%%%%%%%%%%%%%
s=load('sinais_sinteticos_estimados.txt');
x=load('sinais_sinteticos_outeste.txt');x=x(:,501:end);

%Substituição dos outliers simulados pelas estimativas
%Outliers simulados
p1=[51 103 219 333 432];
p2=[48 99 200 301 450];
p3=[59 110 237 315 401];
p4=[44 108 198 321 417];
p5=[69 125 241 307 473];
p6=[60 113 212 326 499];

x(1,p1)=s(1, p1);
x(2,p2)=s(2,p2);
x(3,p3)=s(3,p3);
x(4,p4)=s(4,p4);
x(5,p5)=s(5,p5);
x(6,p6)=s(6,p6);
serie_teste=x;
%save serie_teste_corrigida.txt serie_teste -ascii
%%%%%%%%%%%%%%%%%

%Substituição dos outliers simulados pelas posições detectadas por SCICA
s=load('sinais_sinteticos_estimados.txt');
x=load('sinais_sinteticos_outeste.txt');x=x(:,501:end);

%Outliers detectados + falsos alarmes de SCICA
p1=[103 111 219 245 284 308 333 369 400 432 458 470 471 474];
p2=[31 48 186 200 287 288 301 313 323 334 428 450];
p3=[59 110 237 315 401 463 474 479];
p4=[31 44 53 108 186 198 226 273 321 325 339 370 376 381 420 417 452 498];
p5=[69 125 151 170 190 237 241 307 312 344 414 440 461 491];
p6=[31 60 113 212 310 326 334 370 428 494 499];

x(1,p1)=s(1, p1);
x(2,p2)=s(2,p2);
x(3,p3)=s(3,p3);
x(4,p4)=s(4,p4);
x(5,p5)=s(5,p5);
x(6,p6)=s(6,p6);
serie_teste=x;
%save serie_teste_corrigida.txt serie_teste -ascii
%%%%%%%%%%%%%%%%%

%Substituição dos outliers simulados pelas posições detectadas por SCICA
s=load('sinais_sinteticos_estimados.txt');
x=load('sinais_sinteticos_outeste.txt');x=x(:,501:end);

%Outliers detectados + falsos alarmes de MCICA
p1=[51 103 219 273 333 334 432 448 462 463];
p2=[27 48 65 187 200 214 289 301 321 324 327 331 404 420 421 437 450 453];
p3=[16 59 65 110 118 183 237 308 311 315 327 331 334 364 388 401 406 432 437 491];
p4=[32 44 65 84 114 118 119 168 186 198 213 218 227 232 286 289 313 317 321 326 328 329 331 332 371 406 427 437 481 492];
p5=[58 65 67 69 114 118 119 125 166 180 213 215 241 313 316 317 328 331 402 406 437 447 466];
p6=[60 65 113 118 187 212 288 326 327 331 437 463 467 474 482 499];

x(1,p1)=s(1, p1);
x(2,p2)=s(2,p2);
x(3,p3)=s(3,p3);
x(4,p4)=s(4,p4);
x(5,p5)=s(5,p5);
x(6,p6)=s(6,p6);
serie_teste=x;
%save serie_teste_corrigida.txt serie_teste -ascii
%%%%%%%%%%%%%%%%%

%Substituição dos outliers simulados pelas posições detectadas por SCICA
s=load('sinais_sinteticos_estimados.txt');
x=load('sinais_sinteticos_outeste.txt');x=x(:,501:end);

%Outliers detectados + falsos alarmes detectados SEM ICA
p1=[103 219 273 285 333 370 398 432 475];
%p2=[13 32 33 42 48 54 99 155 187 200 227 255 289 301 311 324 335 396 409 425 442 450 496];
p2=[32 33 42 48 54 99 155 187 200 227 255 289 301 311 324 335 396 409 425 442 450 496];
%p3=[16 40 59 71 88 91 100 110 146 147 166 167 176 177 182 185 186 190 195 216 226 236 237 242 243 246 271 272 275 285 301 302 306 307 308 311 315 319 321 331 335 351 371 381 391 401 402 410 411 426 431 436 455 460 461 466 471 472 475 476 480 481 500];
p3=[40 59 71 88 91 100 110 146 147 166 167 176 177 182 185 186 190 195 216 226 236 237 242 243 246 271 272 275 285 301 302 306 307 308 311 315 319 321 331 335 351 371 381 391 401 402 410 411 426 431 436 455 460 461 466 471 472 475 476 480 481 500];
p4=[44 62 108 176 198 227 263 273 313 316 321 326 340 371 377 387 417 421 453 461 492 499];
p5=[69 86 125 152 180 191 238 241 307 337 345 365 375 387 393 400 415 420 432 441 442 447 453 462 492];
p6=[32 38 113 155 212 326 499];

x(1,p1)=s(1, p1);
x(2,p2)=s(2,p2);
x(3,p3)=s(3,p3);
x(4,p4)=s(4,p4);
x(5,p5)=s(5,p5);
x(6,p6)=s(6,p6);
serie_teste=x;
%save serie_teste_corrigida.txt serie_teste -ascii
%%%%%%%%%%%%%%%%%




