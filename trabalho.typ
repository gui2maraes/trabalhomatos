
#let authors = (
  "Guilherme Guimarães",
  "Eduardo Altmann de Bem",
  "Leonardo Greco Fin",
)
#set document(
  title: [Trabalho Linguagens Formais e Autômatos - Parte 2],
  author: authors,
)
#set text(size: 12pt)

#align(center, title())

#align(center, authors.join("\n"))

= Introdução
Foi desenvolvido na primeira etapa do trabalho um sistema de cadastro que reconhece senhas
consideradas "fortes", usando os estados de um autômato finito para guardar os requisitos
alcançados. Agora, iremos expandir esse sistema para que este seja necessariamente modelado por uma
linguagem livre de contexto (GLC), provando que o novo cenário não pode ser descrito por uma
linguagem regular.

= O Sistema
O objetivo do novo sistema é reconhecer entradas em que a senha de login é a mesma da senha de
cadastro, fazendo o papel de um autenticador. Infelizmente, linguagens livres de contexto não são
poderosas o suficiente para descrever palavras do tipo $w w$ (uma palavra repetida duas vezes),
então será preciso a formulação de uma técnica para simular/aproximar essa classe de linguagens sem
alterarmos a entrada do sistema.

== Outras Tentativas
Para contornar esse problema, seria possível definir o sistema de forma que a entrada contenha a
primeira ou segunda ocorrência da senha ao contrário, formando a palavra $w^r w$ / $w w^r$. Essas
entradas são reconhecidas por mecanismos livres de contexto. Entretanto, isso afetaria a usabilidade
do sistema, dado que o usuário precisará manualmente escrever uma das senhas inversas. Dessa forma,
decidimos pela estratégia a seguir.

== A Estratégia
Como visto, GLCs são incapazes de gerar palavras do tipo $w w$, mas conseguem gerar palavras do tipo
$a^n b^n$. Então, se conseguirmos achar um modo de interpretar a entrada como uma palavra
balanceada, será possível modelar o sistema usando uma GLC.

A ideia básica dessa estratégia é a transformação $w -> a^n$. Ou seja, é preciso criar um mapeamento
de todas as possíveis senhas para sequências de um único símbolo. Se interpretarmos a palavra $a^n$
como o número $n$ em base unária, vemos que essa transformação é um _hash_ de $w$, onde mapeamos uma
_string_ arbitrária para um número. Assim, é preciso designar um algoritmo de _hashing_ que seja
implementável por um autômato de pilha.

== O Algoritmo
O nosso algoritmo de _hashing_ possui alguns requisitos que precisam ser cumpridos para poder ser
usado pelo nosso sistema:
+ palavras iguais devem resultar no mesmo número (_hash_)
+ colisões de _hash_ devem ser mínimas (palavras diferentes com mesmo _hash_)
+ o algoritmo precisa fazer um único passe pela palavra

Com esses requisitos em mente, iremos começar com um algoritmo básico e o aprimorar aos poucos, até
chegarmos em uma solução aceitável.

=== Primeira Iteração
O algoritmo mais básico implementável por um autômato de pilha é um que associa um número distinto a
cada símbolo e faz a soma dos números correpondentes aos símbolos da palavra de entrada. Expressando
em termos matemáticos, com uma palavra sendo uma sequência $w = x_1 x_2 x_3...x_n$, $h(w)$ sendo a
função de hash, e $p(x)$ sendo o mapeamento de um símbolo para um número:

$ h(w) = sum_(k=1)^n p(x_k) $

Esse algoritmo é simples de implementar e garante que palavras iguais resultam no mesmo _hash_.
Entretanto, o número de colisões é muito alto, considerando que permutações (anagramas) da mesma
palavra criam _hashes_ iguais, devido à natureza comutativa da adição.

=== Segunda Iteração
Para resolvermos o problema das colisões, precisamos que a posição do símbolo na palavra influencie
o seu valor na soma do _hash_. Um bom método seria multiplicar o $p(x)$ pela posição do símbolo
antes de adicionar à soma:

$ h(w) = sum_(k=1)^n k * p(x_k) $
Como a pilha já está sendo utilizada, precisamos codificar a informação da posição do símbolo nos
estados. Isso traz outro problema: os estados são finitos, enquanto as palavras têm tamanho
arbitrário.

=== Terceira Iteração
Um modo de diminuir mais ainda a taxa das colisões seria ao invés de multiplicar o $p(x)$ pela
posição do símbolo, fazer uma mudança de base da palavra para um número unário.

Primeiro é preciso definir qual a base da palavra de entrada. Sabendo que a base de qualquer sistema
numérico é o tamanho do conjunto de dígitos (ex: a base decimal contém {0, 1, 2, 3, 4, 5, 6, 7, 8,
9} = 10 dígitos), podemos definir a base da nossa palavra como o tamanho do alfabeto de entrada
$Sigma$.

Com a base definida, podemos fazer a operação de mudança de bases calculando a soma de todos os
valores numéricos dos caracteres da palavra multiplicados pela base elevada à posição do caracter.
Definindo a base do alfabeto de entrada como $b$, temos:

$ h(w) = sum_(k=0)^(n-1) b^k * p(x_k) $

Interpretando a palavra como um número de base $b$, se nota que os dígitos do número estão
invertidos, com o digíto menos significativo mais à esquerda. Entretanto, isso se torna irrelevante
visto que o valor em si do número não importa, mas apenas que palavras iguais gerem o mesmo número.

Também vemos que o valor do número cresce de forma exponencial em relação ao tamanho da palavra.
Esse problema também é irrelevante dado que o modelo teórico de um autômato de pilha possui memória
infinita.

=== O Problema
O problema principal desse algorítmo é que autômatos com pilha não conseguem calcular exponenciais
nem multiplicações por números arbitrários. Então é nesse momento que é preciso introduzir uma
aproximação do comportamento ideal.

O caminho encontrado foi dividir a palavra em blocos de tamanho $m$, e calcular os exponenciais
módulo $m$. Como $m$ é finito, podemos precalcular o valor dos exponenciais, e transformar as
operações do algorítmo em uma multiplicação por uma constante (o que sabemos que é possível fazer).
Assim, o algorítmo final seria:

$ h(w) = sum_(k=0)^(n-1) b^(k mod m) * p(x_k) $

Um exemplo desse algorítmo usando um alfabeto $Sigma = {a, b, c, d, e, f}$ e base $6$:

Primeiro definimos o mapeamento $p(x) = {(a, 1), (b, 2), (c, 3), (d, 4), (e, 5), (f, 6)}$, a palavra
$w = op("abcd")$, e o tamanho de bloco $m = 4:$

$
  h(w) & = p(a) * 6^(0 mod 4) + p(b) * 6^(1 mod 4) + p(c) * 6^(2 mod 4) + p(d) * 6^(3 mod 4) \
       & = 1 * 6^0 + 2 * 6^1 + 3 * 6^2 + 4 * 6^3 \
       & = 1 * 1 + 2 * 6 + 3 * 36 + 4 * 216 \
       & = 985
$

Outro exemplo com $w = op("bcefaa")$ e $m = 3$:

$
  h(w) & = p(b) * 6^(0 mod 3) + p(c) * 6^(1 mod 3) + p(e) * 6^(2 mod 3) + p(f) * 6^(3 mod 3) +
         p(a) * 6^(4 mod 3) + p(a) * 6^(5 mod 3) \
       & = 2 * 6^0 + 3 * 6^1 + 5 * 6^2 + 6 * 6^0 + 1 * 6^1 + 1 * 6^2 \
       & = 2 * 1 + 3 * 6 + 5 * 36 + 6 * 1 + 1 * 6 + 1 * 36 \
       & = 248
$

Uma implicação importante dessa aproximação por blocos, é que o número de estados do autômato cresce
rapidamente com valores maiores de $n$, enquanto valores menores de $n$ aumentam a taxa de colisões.
Então é preciso escolher um valor apropriado de $n$ que balanceie a complexidade do autômato e
segurança do algorítmo.

Um resultado interessante desse sistema é que GLCs não conseguem gerar palavras do tipo $w w$, mas
estamos aproximando esse comportamento usando esse algoritmo. A precisão dessa linguagem se aproxima
da ideal na medida que $n -> inf$.
