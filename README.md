# FilaFácil

FilaFácil é um sistema distribuído de fila de espera para restaurantes. O cliente entra na fila pelo app móvel e é notificado quando sua mesa ficar disponível; o prestador (operador do restaurante) gerencia chamadas e status pelo backend.

O projeto é composto por três componentes:

- **Backend REST** — Node.js + Express, persiste dados em SQLite/PostgreSQL e publica eventos no RabbitMQ.
- **Middleware de Mensagens (MOM)** — RabbitMQ com filas de eventos orientadas a domínio (Sprint 2).
- **App Flutter — Cliente** — Aplicativo móvel em Flutter/Dart que consome a API REST e atualiza o estado via polling assíncrono (Sprint 3).

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

**Backend:**
- Node.js 18+
- npm
- Docker e Docker Compose (para subir o RabbitMQ)
- SQLite local ou PostgreSQL local

**App Flutter (Cliente):**
- Flutter 3.10+ e Dart 3.x
- Android Studio ou VS Code com extensão Flutter
- Emulador Android/iOS ou dispositivo físico

## Instalação

**Backend:**

```bash
npm install
copy .env.example .env
```

**App Flutter (Cliente):**

```bash
cd flutter_app
flutter pub get
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

## Como iniciar o App Flutter (Cliente)

Com o backend e o RabbitMQ já em execução, em outro terminal:

```bash
cd flutter_app
flutter run
```

O app conecta por padrão em `http://localhost:3000`. Para rodar em dispositivo físico ou emulador com backend na máquina local, atualize `BASE_URL` em `lib/core/constants/api_constants.dart` com o IP da sua máquina na rede local.

### Telas disponíveis

| Tela | Descrição |
|------|-----------|
| Entrar na Fila | Formulário para o cliente entrar na fila informando nome e número de pessoas |
| Lista da Fila | Exibe a posição do usuário na fila e o status (Aguardando / Chamado / Atendido) |
| Mesas | Mostra a disponibilidade de mesas em tempo real |

O app atualiza o estado automaticamente via polling a cada **7 segundos** (status da fila) e **5 segundos** (disponibilidade de mesas), sem necessidade de ação manual do usuário.

### Arquitetura do App Flutter

O app segue Clean Architecture com quatro camadas:

```
presentation/   → Screens, Widgets, Providers (gerência de estado com Provider)
application/    → Services e Use Cases (FilaService, NotificationService)
domain/         → Models/Entities (FilaModel, ClienteModel, MesaModel)
infrastructure/ → Repositories com chamadas HTTP (FilaRepository, MesaRepository)
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

## Evidências Gravadas

**Sprint 2 — Integração MOM (RabbitMQ):**

- https://youtu.be/IAJJ3c4NFOU

**Sprint 3 — App Flutter (Cliente):**

- https://youtu.be/7_15n1wKLTw?si=HDy1ScnnQi-3SQQe

Observação: os arquivos de evidência locais também estão postados no repositório em suas versões comprimidas, pois os originais ultrapassavam os 100 MB permitidos pelo GitHub.

## Observações de projeto

- O RabbitMQ não substitui o banco.
- A API continua funcionando mesmo se o broker falhar, porque a publicação é tratada como efeito colateral.
- A lógica de seleção automática de cliente ou mesa não foi adicionada.
- O sistema permanece monolítico, com consumer separado apenas como worker assíncrono.
