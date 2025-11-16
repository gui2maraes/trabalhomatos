
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
Entretanto, o número de colisões é muito alto, considerando que permutações da mesma palavra criam
_hashes_ iguais, devido à natureza comutativa da adição.

=== Segunda Iteração
Para resolvermos o problema das colisões, precisamos que a posição do símbolo na palavra influencie
o seu valor na soma do _hash_. Um método ideal seria multiplicar o $p(x)$ pela posição do símbolo
antes de adicionar à soma:

$ h(w) = sum_(k=1)^n k * p(x_k) $
Como a pilha já está sendo utilizada, precisamos codificar a informação da posição do símbolo nos
estados. Isso traz outro problema: os estados são finitos, enquanto as palavras têm tamanho
arbitrário.
