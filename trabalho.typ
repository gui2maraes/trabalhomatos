
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

Esse algoritmo é simples de implementar e garante que palavras iguais resultem no mesmo _hash_.
Entretanto, o número de colisões é muito alto, considerando que permutações (anagramas) da mesma
palavra criam _hashes_ iguais, devido à natureza comutativa da adição.

=== Segunda Iteração
Para melhorarmos o problema das colisões, precisamos que a posição do símbolo na palavra influencie
o seu valor na soma do _hash_. Um método fácil seria multiplicar o $p(x)$ pela posição do símbolo
antes de adicionar à soma:

$ h(w) = sum_(k=1)^n k * p(x_k) $

Infelizmente, a taxa de colisões ainda permanece alta. Considere o alfabeto de entrada
$Sigma = {a..z}$, $p(x) = {op("posição do símbolo no alfabeto latino")}$ e palavras
$w_1 = op("cba")$ e $w_2 = op("j")$:
$
  h(op("\"cba\"")) & = 1 * p(c) + 2 * p(b) + 3 * p(a) \
                   & = 1 * 3 + 2 * 2 + 3 * 1 = 10
$
$
  h(op("\"j\"")) = 1 * p(j) = 1 * 10 = 10
$


=== Terceira Iteração
Um modo de resolver completamente o problema das colisões seria ao invés de multiplicar o $p(x)$
pela posição do símbolo, tratar a palavra de entrada como um número e fazer uma mudança de base da
palavra para a base unária.

Se definirmos a base da palavra de maneira correta, a operação de conversão de bases se torna uma
função injetora, garantindo um mapeamento único de palavras para _hashes_.

Primeiro é preciso definir qual a base da palavra de entrada. Sabendo que a base de qualquer sistema
numérico é o tamanho do conjunto de dígitos (ex: a base decimal contém {0, 1, 2, 3, 4, 5, 6, 7, 8,
9} = 10 dígitos), poderiamos definir a base da nossa palavra como o tamanho do alfabeto de entrada
$Sigma$. Nesse caso, iremos definir como $|Sigma| + 1$, pois nenhum símbolo terá o valor $0$, para
evitar problemas como $1 = 01 = 001$.

Com a base definida, podemos fazer a operação de mudança de bases calculando a soma de todos os
valores numéricos dos caracteres da palavra multiplicados pela base elevada à posição do caracter.
Definindo a base do alfabeto de entrada como $b$, temos:

$ h(w) = sum_(k=1)^(n) b^(k-1) * p(x_k) $

Interpretando a palavra como um número de base $b$, se nota que os dígitos do número estão
invertidos, com o digíto menos significativo mais à esquerda. Entretanto, isso se torna irrelevante
visto que o valor em si do número não importa, mas apenas que as propriedades do _hash_ sejam
mantidas.

Também vemos que o valor do número cresce de forma exponencial em relação ao tamanho da palavra.
Isso não é um problema dado que o modelo teórico de um autômato de pilha possui memória infinita.

Para terminar a transformação, convertemos $h(w)$ para uma base unária que é processável pelo
autômato (usando um símbolo arbitrário $a$):
$ h(w) -> a^(h(w)) $

=== O Problema

Como a pilha já está sendo utilizada, precisamos codificar a informação da posição do símbolo nos
estados. Isso traz um problema: os estados são finitos, enquanto as palavras têm tamanho arbitrário.
Similarmente, autômatos com pilha não conseguem calcular exponenciais nem multiplicações por números
arbitrários. Então é nesse momento que é preciso introduzir uma aproximação do comportamento ideal.

=== Algorítmo Final

O caminho encontrado foi dividir a palavra em blocos de tamanho $m$, e calcular os exponenciais
módulo $m$. Como $m$ é finito, podemos precalcular esses valores, e transformar as operações do
algorítmo em uma multiplicação por uma constante (o que sabemos que é possível fazer). Assim, o
algorítmo final seria:

$ h(w) = sum_(k=1)^(n) b^((k-1) mod m) * p(x_k) $

Um exemplo desse algorítmo usando um alfabeto $Sigma = {a, b, c, d, e, f}$ e base $7$:

Primeiro definimos o mapeamento $p(x) = {(a, 1), (b, 2), (c, 3), (d, 4), (e, 5), (f, 6)}$, a palavra
$w = op("abcd")$, e o tamanho de bloco $m = 4:$

$
  h(w) & = p(a) * 7^(0 mod 4) + p(b) * 7^(1 mod 4) + p(c) * 7^(2 mod 4) + p(d) * 7^(3 mod 4) \
       & = 1 * 7^0 + 2 * 7^1 + 3 * 7^2 + 4 * 7^3 \
       & = 1 * 1 + 2 * 7 + 3 * 49 + 4 * 343 \
       & = 1534
$

Outro exemplo com $w = op("bcefaa")$ e $m = 3$:

$
  h(w) & = p(b) * 7^(0 mod 3) + p(c) * 7^(1 mod 3) + p(e) * 7^(2 mod 3) + p(f) * 7^(3 mod 3) +
         p(a) * 7^(4 mod 3) + p(a) * 7^(5 mod 3) \
       & = 2 * 7^0 + 3 * 7^1 + 5 * 7^2 + 6 * 7^0 + 1 * 7^1 + 1 * 7^2 \
       & = 2 * 1 + 3 * 7 + 5 * 49 + 6 * 1 + 1 * 7 + 1 * 49 \
       & = 330
$

=== Análise
Essa aproximação transforma a linguagem reconhecida de uma que reconhece palavras iguais para uma
que reconhece permutações de sequências de blocos com tamanho $m$. Por exemplo, para $m = 3$,
$op("abcdef") = op("defabc")$. Assim, quanto menor for $m$, maior será a taxa de colisões, com
$m = 1$ sendo equivalente à primeira iteração do algoritmo. Nesse mesmo sentido, na medida que
$m -> inf$, a linguagem se aproxima do comportamento ideal $w w^r$. Veremos que o valor de $m$
influencia diretamente na quantidade de estados do autômato.


== Implementação
Iremos modelar um sistema simples de reconhecimento de senha. O sistema possui apenas duas ações:
cadastrar uma senha e tentar acessar o sistema pela senha. Infelizmente não é possível reutilizar
uma senha cadastrada para tentar o acesso repetidamente, então o sistema possuirá uma autenticação
de senha de uso único.

Um alfabeto de entrada simples será utilizado por motivos de praticidade, mas é possível integrar
esse sistema à primeira etapa do trabalho para serem permitidas apenas senhas fortes. Também é
preciso escolher um valor de $m$, que definirá a complexidade e segurança do sistema. Será mostrado
um método de construção de um autômato para um $m$ arbitrário, mas a implementação usará um $m$
pequeno, também por motivos de simplicidade.

Será usado um subconjunto do alfabeto latino como alfabeto de entrada + um símbolo para denotar o
fim da palavra, ou a ação de registrar a senha (usaremos o símbolo '\#')
$Sigma = {a,b,c,d,e,f,g,h,i, \#}$, a base $b = 10$ e
$p(x) = {(a,1), (b,2), (c,3), (d,4), (e,5), (f,6), (g,7), (h,8), (i,9)}$. Os estados serão divididos
em duas fases: cadastro e autenticação. A primeira fase será responsável por ler os símbolos da
primeira palavra e empilhar seu valor correspondente, enquanto a segunda fase lerá os símbolos da
segunda palavra e desempilhar seus valores. A condição de aceite será ter uma pilha vazia ao fim da
entrada. Assim, a linguagem ideal que queremos aproximar é $L = {w\#w\#}$. O alfabeto da pilha será
apenas o símbolo para representar o número unário e um símbolo para o início da pilha:
$Gamma = {x, Z}$.

O número de estados será $2m + 1$, para guardar a posição atual do bloco em cada fase, mais um
estado final. Em ambas as fases, cada estado $q_i$ lerá o próximo símbolo da palavra,
empilhará/desempilhará o número de dígitos unários correspondentes, e passará para o estado
$q_((i+1) mod m)$. Caso encontrem o símbolo '\#', a primeira fase passará para a segunda, e a
segunda irá aceitar ou rejeitar a entrada, a depender do estado da pilha. Os números a serem
manipulados, após serem precalculados, podem ser modelados com a seguinte tabela:

#figure(
  table(
    columns: 10,
    table.header[*$q_i$*][*a*][*b*][*c*][*d*][*e*][*f*][*g*][*h*][*i*],
    [0],
    [$x^(1)$],
    [$x^(2)$],
    [$x^(3)$],
    [$x^(4)$],
    [$x^(5)$],
    [$x^(6)$],
    [$x^(7)$],
    [$x^(8)$],
    [$x^(9)$],

    [1],
    [$x^(10)$],
    [$x^(20)$],
    [$x^(30)$],
    [$x^(40)$],
    [$x^(50)$],
    [$x^(60)$],
    [$x^(70)$],
    [$x^(80)$],
    [$x^(90)$],

    [2],
    [$x^(100)$],
    [$x^(200)$],
    [$x^(300)$],
    [$x^(400)$],
    [$x^(500)$],
    [$x^(600)$],
    [$x^(700)$],
    [$x^(800)$],
    [$x^(900)$],

    [3],
    [$x^(1000)$],
    [$x^(2000)$],
    [$x^(3000)$],
    [$x^(4000)$],
    [$x^(5000)$],
    [$x^(6000)$],
    [$x^(7000)$],
    [$x^(8000)$],
    [$x^(9000)$],
  ),
  caption: [Exemplo de tabela de números precalculados para $m = 3$],
)

Segue a definição formal desse autômato para $m = 4$:

$ M = (Q, Sigma, Gamma, delta, q_0, Z, F) $, onde:
$
  & Q = {q_0, q_1, q_2, q_3, r_0, r_1, r_2, r_3, r_f} \
  & Sigma = {a, b, c, d, e, f, g, h, i, \#} \
  & Gamma = {x, Z} \
  & F = {r_f}
$

Segue a tabela de transições $delta$:
#table(
  columns: 7,
  table.header[*$q_0$*][*$q_1$*][*$q_2$*][*$q_3$*][*$q_0$*][*$q_0$*][*$q_0$*][*$q_0$*][*$r_f$*]
  [$delta(q_0, a, epsilon) -> (q_1, x^1)$],
  [$delta(q_0, b, epsilon) -> (q_1, x^2)$],
  [$delta(q_0, c, epsilon) -> (q_1, x^3)$],
  [$delta(q_0, d, epsilon) -> (q_1, x^4)$],
  [$delta(q_0, e, epsilon) -> (q_1, x^5)$],
  [$delta(q_0, f, epsilon) -> (q_1, x^6)$],
  [$delta(q_0, g, epsilon) -> (q_1, x^7)$],

  [$delta(q_0, h, epsilon) -> (q_1, x^8)$],
  [$delta(q_0, i, epsilon) -> (q_1, x^9)$],
  [$delta(q_0, \#, epsilon) -> (r_0, epsilon)$],

  [$delta(q_1, a, epsilon) -> (q_2, x^10)$],
  [$delta(q_1, b, epsilon) -> (q_2, x^20)$],
  [$delta(q_1, c, epsilon) -> (q_2, x^30)$],
  [$delta(q_1, d, epsilon) -> (q_2, x^40)$],
  [$delta(q_1, e, epsilon) -> (q_2, x^50)$],
  [$delta(q_1, f, epsilon) -> (q_2, x^60)$],
  [$delta(q_1, g, epsilon) -> (q_2, x^70)$],

  [$delta(q_1, h, epsilon) -> (q_2, x^80)$],
  [$delta(q_1, i, epsilon) -> (q_2, x^90)$],
  [$delta(q_1, \#, epsilon) -> (r_0, epsilon)$],

  [$delta(q_2, a, epsilon) -> (q_2, x^100)$],
  [$delta(q_2, b, epsilon) -> (q_2, x^200)$],
  [$delta(q_2, c, epsilon) -> (q_2, x^300)$],
  [$delta(q_2, d, epsilon) -> (q_2, x^400)$],
  [$delta(q_2, e, epsilon) -> (q_2, x^500)$],
  [$delta(q_2, f, epsilon) -> (q_2, x^600)$],
  [$delta(q_2, g, epsilon) -> (q_2, x^700)$],

  [$delta(q_2, h, epsilon) -> (q_2, x^800)$],
  [$delta(q_2, i, epsilon) -> (q_2, x^900)$],
  [$delta(q_2, \#, epsilon) -> (r_0, epsilon)$],

  [$delta(q_3, a, epsilon) -> (q_0, x^1000)$],
  [$delta(q_3, b, epsilon) -> (q_0, x^2000)$],
  [$delta(q_3, c, epsilon) -> (q_0, x^3000)$],
  [$delta(q_3, d, epsilon) -> (q_0, x^4000)$],
  [$delta(q_3, e, epsilon) -> (q_0, x^5000)$],
  [$delta(q_3, f, epsilon) -> (q_0, x^6000)$],
  [$delta(q_3, g, epsilon) -> (q_0, x^7000)$],

  [$delta(q_3, h, epsilon) -> (q_0, x^8000)$],
  [$delta(q_3, i, epsilon) -> (q_0, x^9000)$],
  [$delta(q_3, \#, epsilon) -> (r_0, epsilon)$],
)
