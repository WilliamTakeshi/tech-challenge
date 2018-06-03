# Tech Challenge - Desafio Nº 2

 - master: [![Build Status](https://travis-ci.org/ramondelemos/tech-challenge.svg?branch=master)](https://travis-ci.org/ramondelemos/tech-challenge)
 [![Coverage Status](https://coveralls.io/repos/github/ramondelemos/tech-challenge/badge.svg?branch=master)](https://coveralls.io/github/ramondelemos/tech-challenge)

 - dev: [![Build Status](https://travis-ci.org/ramondelemos/tech-challenge.svg?branch=dev)](https://travis-ci.org/ramondelemos/tech-challenge)
 [![Coverage Status](https://coveralls.io/repos/github/ramondelemos/tech-challenge/badge.svg?branch=dev)](https://coveralls.io/github/ramondelemos/tech-challenge)

Bem vindo(a)! Esse é a minha solução para o Tech Challenge Elixir!

---

# O Desafio

## API de Banking

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
* A API pode ser JSON ou GraphQL
* Docker é um diferencial.

## A Solução

Para atender ao que foi proposto foi criado o projeto `FinancialSystemApi`, que é uma aplicação Phoenix responsável por servir uma API GraphQL para transações bancárias. A API principal da aplicação está disponível em [http://ramondelemos.com/api](http://ramondelemos.com/api). Para facilitar o uso da solução, no endpoint [http://ramondelemos.com/graphiql](http://ramondelemos.com/graphiql) foi diponibilizada a interface gráfica _GraphiQL_ fornecida pelo módulo `absinthe`.

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

### Relatórios

* Total transacionado (R$) por dia, mês, ano e total. [Em construção]
* Número de usuários que não transacionam há mais de 1 mês (por dia). [Em construção]

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
* [A tour of Elixir performance & monitoring tools](https://hackernoon.com/a-tour-of-elixir-performance-monitoring-tools-aac2df726e8c)
* [Monitoring Phoenix](https://medium.com/@mschae/measuring-your-phoenix-app-d63a77b13bda)
* [dogstatsd-elixir](https://github.com/adamkittelson/dogstatsd-elixir)
* [Elixir Logger And The Power Of Metadata](https://timber.io/blog/elixir-logger-and-the-power-of-metadata/)
* [A Complete Guide to Deploying Elixir & Phoenix Applications on Kubernetes](https://medium.com/polyscribe/a-complete-guide-to-deploying-elixir-phoenix-applications-on-kubernetes-part-1-setting-up-d88b35b64dcd)
* [SETTING UP ELIXIR CLUSTER USING DOCKER AND RANCHER](http://teamon.eu/2017/setting-up-elixir-cluster-using-docker-and-rancher/)
* [Running distributed Erlang & Elixir applications on Docker](https://www.erlang-solutions.com/blog/running-distributed-erlang-elixir-applications-on-docker.html)
