# Tech Challenge

 - master: [![Build Status](https://travis-ci.org/ramondelemos/tech-challenge.svg?branch=master)](https://travis-ci.org/ramondelemos/tech-challenge)
 [![Coverage Status](https://coveralls.io/repos/github/ramondelemos/tech-challenge/badge.svg?branch=master)](https://coveralls.io/github/ramondelemos/tech-challenge)

 - dev: [![Build Status](https://travis-ci.org/ramondelemos/tech-challenge.svg?branch=dev)](https://travis-ci.org/ramondelemos/tech-challenge)
 [![Coverage Status](https://coveralls.io/repos/github/ramondelemos/tech-challenge/badge.svg?branch=dev)](https://coveralls.io/github/ramondelemos/tech-challenge)

Bem vindo(a)! Esse é a minha solução para o Tech Challenge Elixir!

---

## [O Desafio Nº 1](https://github.com/ramondelemos/tech-challenge/tree/master/apps/financial_system)

O Sistema Financeiro precisa representar valores monetários. A ideia básica é ter uma estrutura de dados que permita realizar operações financeiras com dinheiro dentro de uma mesma moeda. _Isso é pelo motivo de pontos flutuantes terem problemas de aritmética_, logo encodificamos valores decimais/fracionais/reais como uma estrutura de dados com campos em inteiros, além de mapearmos operações aritméticas sobre tal estrutura. No fim, a implementação acaba sendo uma Estrutura de Dados Abstrata.

Essas operações financeiras precisam ser seguras e devem interromper a execução do programa em caso de erros críticos.

Sobre as operações financeiras que serão realizadas no sistema, é correto afirmar que os valores monetários devem suportar as seguintes operaçoes:

* O sistema realizará split de transações financeiras, então deve ser possível realizar a operação de rateio de valores monetários entre diferentes indivíduos.

* O sistema permite realizar câmbio então os valores monetários possuem uma operação para conversão de moeda.

* O sistema precisa estar em _compliance_ com as organizações internacionais, então é desejável estar em conformidade com a [ISO 4217](https://pt.wikipedia.org/wiki/ISO_4217).

## Requisitos Técnicos

* O código deve estar na linguagem [Elixir](http://elixir-lang.github.io/)

---

## Tech Challenge - Desafio Nº 2

### API de Banking

O sistema deve oferecer a possibilidade de usuários realizarem transações financeiras
como saque e transferencia entre contas.

Um usuário pode se cadastrar e ao completar o cadastro (com verificação de email) ele
recebe R$ 1000,00.

Com isso ele pode transferir dinheiro para outras contas e pode sacar dinheiro. O saque do dinheiro simplesmente manda um email para o usuário informando sobre o saque e reduz o seu saldo.

Nenhuma conta pode ficar com saldo negativo.

É necessário autenticação para realizar qualquer operação.

Alguns relatórios devem ser gerados para o backoffice:
* Total transacionado (R$) por dia, mês, ano e total.
* Número de usuários que não transacionam há mais de 1 mês (por dia)

## Requisitos Técnicos

* O desafio deve ser feito na linguagem [Elixir](http://elixir-lang.github.io/).
* A API pode ser JSON ou GraphQL.
* Docker é um diferencial.

## Comandos básicos do projeto

`mix deps.get` Para obter as dependências.

`mix deps.compile` Para compilar as dependências.

`MIX_ENV=test mix build` Para testar a aplicação.

`mix ecto.setup` Para configuar a base de dados.

`mix phx.server` Para rodar a aplicação.

Certifique-se de que as variáveis de ambiente abaixo estão corretamente configuradas:

* `DB_USERNAME=postgres`
* `DB_PASSWORD=postgres`
* `DB_DATABASE=financial_system_api`
* `DB_HOSTNAME=db`
* `DB_PORT=5432`
* `SECRET_KEY=your-key`
* `BAMBOO_API_KEY=your-key`
* `BAMBOO_DOMAIN=your-domain`
* `APP_HOSTNAME=localhost:4000`
* `PORT=4000`

Para facilitar o setup de teste está disponível meu [ambiente de desenvolvimento elixir](https://github.com/ramondelemos/docker-elixir-phoenix).

## A Solução

Para atender ao que foi proposto foi criado um projeto `umbrella` contendo as aplicações `FinancialSystem` (Desafio Nº 1) e `FinancialSystemApi`, que é uma aplicação Phoenix responsável por servir uma API GraphQL para transações bancárias.

Para a cobertura dos testes foi utilizado o [Coveralls.io](https://coveralls.io/github/ramondelemos).

A análise do código é feita com o [Credo](http://credo-ci.org/) utilizando o parâmetro de execução `--strict` para reforçar o **guia de estilo do credo**.

Para o release da aplicação foram utilizados em conjunto os pacotes [mix docker](https://github.com/Recruitee/mix_docker) e [Distillery](https://github.com/bitwalker/distillery). A aplicação é disponibilizada automaticamente em containers Docker no repositório público [ramondelemos/tech-challenge](https://hub.docker.com/r/ramondelemos/tech-challenge/tags/).

Foram utilizados em conjunto o [Travis CI](https://travis-ci.org/ramondelemos), [Webhooks do Docker Hub](https://docs.docker.com/docker-hub/webhooks/) e o [Rancher 1.6](https://rancher.com/docs/rancher/v1.6/en/) para a orquestração das técnicas de _Continuous Integration_, _Continuous Delivery_ e _Continuous Deployment_.

A aplicação está distribuída em dois servidores geograficamente separados e trabalhando de forma clusterizada.

* Servidor [Linode](https://www.linode.com/) localizado em Fremont, USA
* Servidor [DigitalOcean](https://www.digitalocean.com/) localizado em London, UK 

A adição de novos servidores ao cluster é feita de forma simples e rápida através da API do [Rancher 1.6](https://rancher.com/docs/rancher/v1.6/en/). As aplicações se conectam automaticamente umas as outras utilizando API de Metadata fornecida pelo [Rancher 1.6](https://rancher.com/docs/rancher/v1.6/en/) e um módulo worker `FinancialSystemApi.Rancher` que atualiza as conexões dos nós a cada 5 segundos. O crescimento/encolhimento horizontal pode ser feito de forma programática, mas não implementei para não estender em muito o escopo da solução.

O banco de dados da aplicação é o [PostgreSQL 10](https://www.postgresql.org/) hospedado por [Heroku Postgres](https://www.heroku.com/home).

## API de Banking

A solução está disponível em [http://ramondelemos.com/api](http://ramondelemos.com/api). Para facilitar o uso, no endpoint [http://ramondelemos.com/graphiql](http://ramondelemos.com/graphiql) foi diponibilizada a interface gráfica _GraphiQL_ fornecida pelo módulo `absinthe`.

O sistema permite o registro de novos usuários com confirmação por e-mail, autenticação, consulta de usuários e contas, transferência entre contas e saque. Com exceção do registro e autenticação, para todas as operações os usuários precisarão assinar suas requisições com o token jwt fornecido após a autenticação.

### Registro de Usuários

O registro de novos usuários é feito utilizado a mutation `register`, onde serão informados os dados do usuário.

```javascript
mutation UserRegister {
  register(name:"Ramon de Lemos",  username: "ramondelemos", email: "ramondelemos@gmail.com", password: "password") {
    email
    , name
    , username
    , id
  }
}
```

Logo após o registro o e-mail fornecido receberá um link para confirmação e ativação da conta. Depois de confirmado, o usuário receberá um e-mail de confirmação e uma conta com 1.000,00 BRL de saldo para operações.

### Autenticação

A autenticação na aplicação é feita através da mutation `login`. Se a autenticação for bem sucedida o usuário receberá um token para ser utilizado em todas as demais operações.

```javascript
mutation UserLogin {
  login(email: "ramondelemos@gmail.com", password: "password") {
    token
  }
}
```

### Criação de Contas

O usuário pode abrir novas contas, para isso será necessário informar o código [ISO 4217](https://pt.wikipedia.org/wiki/ISO_4217) da moéda que a conta armazenará. Esta operação é feita com a mutation `createAccount`.

```javascript
mutation CreateAccount {
  createAccount(currency: "BRL") {
    id
    , amount
    , currency
    , transactions {
      id
      , dateTime
      , value
    }
  }
}
```

Contas novas são criadas com saldo 0.0.

### Transferência entre contas

Os usuários podem fazer transferências entre contas, bastando informarem os códigos identificadores das contas de origem e destino e o valor da operação. O usuário não poderá transferir valores superiores ao saldo da conta de origem, para contas de moedas diferentes e de contas de terceiros. Para realizar trasferência utilize a mutation `transfer`.

```javascript
mutation Transfer {
  transfer(from: "1", to: "2", value: 10.5){
    from {
      amount
      , currency
      , transactions {
        value
        , dateTime
      }
    }
  }
}
```

### Saque de valores

Os usuários podem fazer saques de suas contas, bastando informar o código identificador da conta e o valor da operação. Os usuários que realizarem saques receberão uma notificação por e-mail informando o valor retirado e o salda atual da conta. O usuário não poderá sacar valores superiores ao saldo disponível. Para realizar saques utilize a mutation `withdraw`.

```javascript
mutation Withdraw {
  withdraw(from: "1", value: 10.5){
    id
  	, amount
    , currency
    , transactions {
      value
      , dateTime
    }
  }
}
```

## Relatórios de Backoffice.

### Total transacionado por dia, mês, ano e total.

É possível realizar consulta em tempo real dos totais transacionados por moeda pela aplicação utilizando a mutation `balanceReport`. Os valores podem ser agrupados por dia: `DAY`, mês: `MONTH`, ano: `YEAR` ou total: `TOTAL`. Com exceção do agrupamento total: `TOTAL`, as consultas podem ser filtradas atravéz da variável `date`.

```javascript
query Backoffice {
  balanceReport(by: DAY, date: "2018-07-09") {
    credit,
    debit,
    currency,
    date
  }
}
```

### Número de usuários que não transacionam há mais de 1 mês (por dia).

Também é possível realizar consulta em tempo real do total de usuários que não transacionam há mais de 1 mês utilizando a mutation `idleReport`.

```javascript
query Backoffice {
  idleReport {
    count
    , date
  }
}
```

## Material de Referência Utilizado
* [Elixir School - Lições sobre a linguagem de programação Elixir](https://elixirschool.com/pt/)
* [O Guia de Estilo Elixir](https://github.com/gusaiani/elixir_style_guide/blob/master/README_ptBR.md)
* [Boas Práticas na Stone](https://github.com/stone-payments/stoneco-best-practices/blob/master/README_pt.md)
* [Phoenix Framework - A productive web framework that does not compromise speed and maintainability](http://phoenixframework.org/)
* [Ecto, the database wrapper and query generator for Elixir.](https://hexdocs.pm/ecto/Ecto.html)
* [GraphQL - A query language for your API](https://graphql.org/)
* [GraphQL toolkit for Elixir](https://hexdocs.pm/absinthe/overview.html)
* [Phoenix GraphQL Tutorial with Absinthe](https://ryanswapp.com/2016/11/29/phoenix-graphql-tutorial-with-absinthe/)
* [Phoenix 1.3 and GraphQL with Absinthe](https://www.seanclayton.me/post/phoenix-1-3-and-graphql-with-absinthe/)
* [Test your GraphQL API in Elixir](https://nicolasdular.com/blog/2017/09/03/test-your-graphql-api-in-elixir/)
* [Bamboo](https://github.com/thoughtbot/bamboo)
* [Building and configuring a Phoenix app with Umbrella for releasing with Docker](https://cultivatehq.com/posts/elixir-distillery-umbrella-docker/)
* [uilding an Elixir Umbrella App with Phoenix and React](http://www.thegreatcodeadventure.com/building-an-elixir-umbrella-app-part-3/amp/)
* [Mix Docker](https://github.com/Recruitee/mix_docker)
* [Dockerizing Elixir and Phoenix Applications](https://semaphoreci.com/community/tutorials/dockerizing-elixir-and-phoenix-applications)
* [Builder design pattern in Elixir](https://medium.com/kkempin/builder-design-pattern-in-elixir-c841e7cea307)
* [Dependency Injection in Elixir is a Beautiful Thing](https://www.openmymind.net/Dependency-Injection-In-Elixir/)
* [A tour of Elixir performance & monitoring tools](https://hackernoon.com/a-tour-of-elixir-performance-monitoring-tools-aac2df726e8c)
* [Monitoring Phoenix](https://medium.com/@mschae/measuring-your-phoenix-app-d63a77b13bda)
* [dogstatsd-elixir](https://github.com/adamkittelson/dogstatsd-elixir)
* [Elixir Logger And The Power Of Metadata](https://timber.io/blog/elixir-logger-and-the-power-of-metadata/)
* [A Complete Guide to Deploying Elixir & Phoenix Applications on Kubernetes](https://medium.com/polyscribe/a-complete-guide-to-deploying-elixir-phoenix-applications-on-kubernetes-part-1-setting-up-d88b35b64dcd)
* [SETTING UP ELIXIR CLUSTER USING DOCKER AND RANCHER](http://teamon.eu/2017/setting-up-elixir-cluster-using-docker-and-rancher/)
* [Running distributed Erlang & Elixir applications on Docker](https://www.erlang-solutions.com/blog/running-distributed-erlang-elixir-applications-on-docker.html)
* [Rancher - Deploying A Load Balancer](https://blog.programster.org/rancher-deploying-a-load-balancer)
* [Scalable incremental data aggregation on Postgres and Citus](https://www.citusdata.com/blog/2018/06/14/scalable-incremental-data-aggregation/)
* [Deconstructing Elixir's GenServers](https://blog.appsignal.com/2018/06/12/elixir-alchemy-deconstructing-genservers.html)
* [Monitoring Erlang Runtime Statistics](https://medium.com/brightergy-engineering/monitoring-erlang-runtime-statistics-59645e362dc8)
