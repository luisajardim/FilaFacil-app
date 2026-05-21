# FilaFácil

FilaFácil é um sistema de fila de espera para restaurantes construído com Node.js, Express, banco relacional e RabbitMQ. A Sprint 1 continua cuidando da persistência e das regras principais; a Sprint 2 adiciona comunicação assíncrona orientada a eventos, sem transformar a solução em microserviços.

## Arquitetura

O fluxo segue EDA e MOM de forma simples:

1. A API Express recebe a requisição e persiste no banco, que continua sendo a fonte de verdade.
2. Depois do commit bem-sucedido, o publisher publica o evento no RabbitMQ.
3. Um worker separado consome as mensagens e processa os eventos sem bloquear a API.

As filas criadas são:

- `fila.criada.queue`
- `fila.chamada.queue`
- `fila.finalizada.queue`

## Pré-requisitos

- Node.js 18+
- npm
- Docker e Docker Compose para subir o RabbitMQ
- SQLite local ou PostgreSQL local

## Instalação

```bash
npm install
copy .env.example .env
```

## Variáveis de ambiente

O arquivo `.env` usa os valores abaixo como base:

```env
PORT=3000
RABBITMQ_URL=amqp://localhost
DB_CLIENT=sqlite
DB_PATH=./data/filafacil.sqlite
```

Se `DB_CLIENT=postgres`, o projeto também aceita `DATABASE_URL` ou os pares `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER` e `PGPASSWORD`.

## Como subir o RabbitMQ

```bash
npm run start:rabbit
```

O painel de administração fica em `http://localhost:15672` com usuário `guest` e senha `guest`.

## Como iniciar a API

```bash
npm run dev
```

Ou em modo normal:

```bash
npm start
```

## Como iniciar o consumer

Em outro terminal:

```bash
npm run consumer
```

## Endpoints

### `POST /fila`

Cria uma entrada na fila e publica `fila.criada` após salvar no banco.

Body:

```json
{
  "nome": "João",
  "quantidade_pessoas": 4
}
```

### `GET /fila`

Lista as entradas da fila.

### `GET /fila/:id`

Busca uma entrada por ID.

### `PUT /fila/:id/status`

Atualiza o status da entrada.

Exemplo para chamar cliente:

```json
{
  "status": "CHAMADO",
  "mesa_id": 2
}
```

Exemplo para finalizar atendimento:

```json
{
  "status": "ATENDIDO"
}
```

## Eventos publicados

### `fila.criada`

```json
{
  "filaId": 1,
  "cliente": "João",
  "quantidade_pessoas": 4,
  "status": "AGUARDANDO",
  "timestamp": "2026-05-25T10:00:00Z"
}
```

### `fila.chamada`

```json
{
  "filaId": 1,
  "cliente": "João",
  "mesaId": 2,
  "status": "CHAMADO",
  "timestamp": "2026-05-25T10:05:00Z"
}
```

### `fila.finalizada`

```json
{
  "filaId": 1,
  "cliente": "João",
  "mesaId": 2,
  "status": "ATENDIDO",
  "timestamp": "2026-05-25T11:00:00Z"
}
```

## Logs esperados

- `[API]` para a API HTTP.
- `[DATABASE]` para inicialização e seed do banco.
- `[RABBITMQ]` para conexão e falhas de broker.
- `[PUBLISHER]` para publicação dos eventos.
- `[CONSUMER]` para o worker e consumo.

Exemplos de saída do worker:

```text
[FILA_CRIADA]
Cliente João entrou na fila com grupo de 4 pessoas

[FILA_CHAMADA]
Cliente João foi chamado para mesa 2

[FILA_FINALIZADA]
Atendimento finalizado para cliente João
```

## Demonstração esperada

1. Criar uma entrada com `POST /fila`.
2. Ver o banco salvar o registro e o publisher enviar `fila.criada`.
3. Ver a mensagem no RabbitMQ Management UI.
4. Ver o consumer processar a fila e exibir o log.
5. Chamar o cliente com `PUT /fila/:id/status` e confirmar a publicação de `fila.chamada`.
6. Finalizar o atendimento com `PUT /fila/:id/status` e confirmar a publicação de `fila.finalizada`.

## Evidência Gravada

Vídeo de demonstração da Sprint 2, caso não queira realizar o download:

- https://youtu.be/IAJJ3c4NFOU

Observação: o arquivo de evidência local também está postado no repositório com o nome de VÍDEO_evidência_sprint2.mp4, em sua versão comprimida do arquivo, pois a versão original estava passando dos 100mb permitidos pelo github. Por isso, também postei o vídeo no youtube para facilitar a avaliação pelo profesor. 

## Observações de projeto

- O RabbitMQ não substitui o banco.
- A API continua funcionando mesmo se o broker falhar, porque a publicação é tratada como efeito colateral.
- A lógica de seleção automática de cliente ou mesa não foi adicionada.
- O sistema permanece monolítico, com consumer separado apenas como worker assíncrono.
