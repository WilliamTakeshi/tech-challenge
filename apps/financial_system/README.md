# Tech Challenge - Desafio Nº 1

 - master: [![Build Status](https://travis-ci.org/ramondelemos/tech-challenge.svg?branch=master)](https://travis-ci.org/ramondelemos/tech-challenge)
 [![Coverage Status](https://coveralls.io/repos/github/ramondelemos/tech-challenge/badge.svg?branch=master)](https://coveralls.io/github/ramondelemos/tech-challenge)

 - dev: [![Build Status](https://travis-ci.org/ramondelemos/tech-challenge.svg?branch=dev)](https://travis-ci.org/ramondelemos/tech-challenge)
 [![Coverage Status](https://coveralls.io/repos/github/ramondelemos/tech-challenge/badge.svg?branch=dev)](https://coveralls.io/github/ramondelemos/tech-challenge)

Bem vindo(a)! Esse é a minha solução para o Tech Challenge Elixir!

---

# O Desafio

O Sistema Financeiro precisa representar valores monetários. A ideia básica é ter uma estrutura de dados que permita realizar operações financeiras com dinheiro dentro de uma mesma moeda. _Isso é pelo motivo de pontos flutuantes terem problemas de aritmética_, logo encodificamos valores decimais/fracionais/reais como uma estrutura de dados com campos em inteiros, além de mapearmos operações aritméticas sobre tal estrutura. No fim, a implementação acaba sendo uma Estrutura de Dados Abstrata.

Essas operações financeiras precisam ser seguras e devem interromper a execução do programa em caso de erros críticos.

Sobre as operações financeiras que serão realizadas no sistema, é correto afirmar que os valores monetários devem suportar as seguintes operaçoes:

* O sistema realizará split de transações financeiras, então deve ser possível realizar a operação de rateio de valores monetários entre diferentes indivíduos.

* O sistema permite realizar câmbio então os valores monetários possuem uma operação para conversão de moeda.

* O sistema precisa estar em _compliance_ com as organizações internacionais, então é desejável estar em conformidade com a [ISO 4217](https://pt.wikipedia.org/wiki/ISO_4217).

## Requisitos Técnicos

* O código do desafio está na linguagem [Elixir](http://elixir-lang.github.io/)

## Comandos básicos do projeto

`mix deps.get` Para baixar as dependências do projeto.

`iex -S mix` Para rodar em modo interativo.

`mix build` Task para execução conjunta dos comandos:
 - `mix clean`
 - `mix docs`
 - `mix test`
 - `mix coveralls`
 - `mix format`
 - `mix credo --strict`

## A Solução

Minha solução foi construída em duas etapas, a criação do pacote `:ex_dinheiro` para manipulação de dinheiro e a implementação de funcionalidades que contemplem o que foi proposto na pasta `/test` para o módulo `FinancialSystem`.

Foi utilizado o [Travis CI](https://travis-ci.org/ramondelemos) para a orquestração das técnicas de _Continuous Integration_, _Continuous Delivery_ e _Continuous Deployment_.

Para a cobertura dos testes foi utilizado o [Coveralls.io](https://coveralls.io/github/ramondelemos).

A análise do código é feita com o [Credo](http://credo-ci.org/) utilizando o parâmetro de execução `--strict` para reforçar o **guia de estilo do credo**.

### O Pacote `:ex_dinheiro`

[![Build Status](https://travis-ci.org/ramondelemos/ex_dinheiro.svg?branch=master)](https://travis-ci.org/ramondelemos/ex_dinheiro?branch=master)
 [![Coverage Status](https://coveralls.io/repos/github/ramondelemos/ex_dinheiro/badge.svg?branch=master)](https://coveralls.io/github/ramondelemos/ex_dinheiro?branch=master)

Decidi pela construção do pacote [`:ex_dinheiro`](https://github.com/ramondelemos/ex_dinheiro) para remover do projeto principal a lógica de manipulação  de dinheiro, implementar _Continuous Integration_ e _Continuous Deployment_ e contribuir com a comunidade Elixir pelo seu repositório oficial [https://hex.pm/](https://hex.pm/).

O pacote foi construído seguindo o [Martin Fowler's Money Pattern](https://martinfowler.com/eaaCatalog/money.html) e está em conformidade com a [ISO 4217](https://pt.wikipedia.org/wiki/ISO_4217).

Para permitir maior flexibilidade o pacote permite que algumas propriedades sejam configuradas diretamente no `config.exs` da aplicação dependênte:

```elixir
use Mix.Config

unofficial_currencies = %{
  XBT: %{
    name: "Bitcoin",
    symbol: '฿',
    alpha_code: "XBT",
    num_code: 0,
    exponent: 8
  },
  RLC: %{
    name: "Ramon de Lemos's Currency",
    symbol: 'RL€',
    alpha_code: "RLC",
    num_code: 0,
    exponent: 7
  }
}

config :ex_dinheiro, :unofficial_currencies, unofficial_currencies
config :ex_dinheiro, :thousand_separator, "."
config :ex_dinheiro, :decimal_separator, ","
config :ex_dinheiro, :display_currency_symbol, false
config :ex_dinheiro, :display_currency_code, true

```

Mantive o nome do pacote e de seus módulos em Português com o objetivo de deixar uma assinatura de sua nacionalidade.

Para maiores informações a documentação em Inglês pode ser encontrada em [https://hexdocs.pm/ex_dinheiro](https://hexdocs.pm/ex_dinheiro).

### O módulo `FinancialSystem`

Para atender ao que foi proposto no diretório `/test` foram implementados os métodos `transfer!/3` e `exchange!/3`. Seguindo as conveções da comunidade Elixir também disponibilizei os métodos wrapper `transfer/3` e `exchange/3`.

Foram adicionados os módulos `Account` e `AccountTransaction` para separar do módulo principal a lógica para manipulação de contas e suas transações.

Nesse módulo apliquei as técnicas de _Continuous Integration_ e _Continuous Delivery_ com o objetivo de manter o branch master sempre atualizado e somente com código funcional.

## Material de Referência Utilizado
* [Elixir School - Lições sobre a linguagem de programação Elixir](https://elixirschool.com/pt/)
* [O Guia de Estilo Elixir](https://github.com/gusaiani/elixir_style_guide/blob/master/README_ptBR.md)
* [Boas Práticas na Stone](https://github.com/stone-payments/stoneco-best-practices/blob/master/README_pt.md)
* [Credo's Elixir Style Guide](https://github.com/rrrene/elixir-style-guide)
* [Specifications and types · Elixir School](https://elixirschool.com/en/lessons/advanced/typespec/#defining-custom-type)
* [Error Handling . Elixir School](https://elixirschool.com/en/lessons/advanced/error-handling/)
* [Option parameters with keyword lists · Elixir Recipes](http://elixir-recipes.github.io/functions/option-parameters-with-keyword-lists/)
* [Erlang -- float_to_binary/1](http://erlang.org/doc/man/erlang.html#float_to_binary-1)
* [ExUnit.Callbacks – ExUnit v1.6.1](https://hexdocs.pm/ex_unit/ExUnit.Callbacks.html)
* [Elixir is just cool. An example with pattern matching and structs.](http://learningwithjb.com/posts/elixir-is-just-cool-an-example-with-pattern-matching-and-structs)
* [Mix – Mix v1.6.2](https://hexdocs.pm/mix/Mix.html)
* [How to create and publish Hex.pm package (Elixir) – kkempin’s dev blog – Medium](https://medium.com/kkempin/how-to-create-and-publish-hex-pm-package-elixir-90cb33e2592d)
* [Automatic Hex Package Publishing with Travis-CI](http://erlware.org/automatic-hex-package-publishing-with-travis-ci/)
* [Continous Documentation of Elixir packages with Hex and Travis CI by René Föhring · trivelop](http://trivelop.de/2014/10/17/continous-docs-in-elixir-with-hex-and-travis/)
* [Auto-Merging with Travis-CI and Configuring Coveralls to Elixir](https://medium.com/@allanbrados/automerge-with-travis-ci-and-coveralls-to-elixir-248d1c6d2531)
* [Continuous integration vs. continuous delivery vs. continuous deployment](https://www.atlassian.com/continuous-delivery/ci-vs-ci-vs-cd)
* [Martin Fowler's Money Pattern](https://martinfowler.com/eaaCatalog/money.html)
* [ISO 4217 Currency codes](https://www.iso.org/iso-4217-currency-codes.html)
* [Current currency & funds code list – ISO Currency](https://www.currency-iso.org/en/home/tables/table-a1.html)
* [XE - World Currency Symbols](http://www.xe.com/symbols.php)
