# FilaFácil

FilaFácil é um sistema distribuído de fila de espera para restaurantes. O cliente entra na fila pelo app móvel e é notificado quando sua mesa fica disponível; o operador gerencia chamadas e mesas pelo próprio app Flutter.

**Projeto Integrador — LDAMD | PUC Minas | Engenharia de Software | 1º Semestre 2026**

---

## Sumário

1. [Visão Geral](#visão-geral)
2. [Pré-requisitos](#pré-requisitos)
3. [Instalação e Execução](#instalação-e-execução)
4. [Variáveis de Ambiente](#variáveis-de-ambiente)
5. [Banco de Dados](#banco-de-dados)
6. [API REST](#api-rest)
7. [Eventos MOM (RabbitMQ)](#eventos-mom-rabbitmq)
8. [Apps Flutter](#apps-flutter)
9. [Fluxo Ponta a Ponta](#fluxo-ponta-a-ponta)
10. [Entregas por Sprint](#entregas-por-sprint)
11. [Observações](#observações)

---

## Visão Geral

O sistema é composto por quatro componentes que se comunicam de forma assíncrona:

| Componente              | Tecnologia                            | Função                                                        |
| ----------------------- | ------------------------------------- | ------------------------------------------------------------- |
| Backend REST            | Node.js + Express + SQLite/PostgreSQL | Persiste dados, expõe endpoints e publica eventos no MOM      |
| Middleware (MOM)        | RabbitMQ                              | Recebe eventos do backend e os distribui aos consumidores     |
| App Flutter — Cliente   | Flutter/Dart                          | Permite ao cliente entrar na fila e acompanhar seu status     |
| App Flutter — Prestador | Flutter/Dart                          | Permite ao operador gerenciar a fila e as mesas em tempo real |

```text
[App Flutter — Cliente]   [App Flutter — Prestador]
         |                          |
         | HTTP REST (polling)      | HTTP REST (polling)
         ↓                          ↓
           [Backend Express — API REST]
                    |            |
                    | SQL        | AMQP
                    ↓            ↓
               [SQLite /     [RabbitMQ]
               PostgreSQL]       |
                                 ↓
                          [Worker Consumer]
```

O fluxo segue **EDA (Event-Driven Architecture)**:

1. A API recebe a requisição e persiste no banco, que permanece como fonte de verdade.
2. Após o commit bem-sucedido, o publisher publica o evento no RabbitMQ.
3. O worker consumer processa as mensagens de forma assíncrona, sem bloquear a API.

---

## Pré-requisitos

**Backend**
- Node.js 18+, npm
- Docker e Docker Compose (para RabbitMQ)
- SQLite local ou PostgreSQL local

**Apps Flutter**
- Flutter 3.10+ e Dart 3.x
- Android Studio ou VS Code com extensão Flutter
- Emulador Android/iOS ou dispositivo físico

---

## Instalação e Execução

### 1. Instalar dependências do backend

```bash
npm install
copy .env.example .env
```

### 2. Instalar dependências dos apps Flutter

```bash
cd flutter_app
flutter pub get
cd ../flutter_prestador
flutter pub get
```

### 3. Subir o RabbitMQ

```bash
npm run start:rabbit
```

Painel de administração: `http://localhost:15672` — usuário `guest`, senha `guest`

### 4. Iniciar a API

```bash
npm run dev
```

### 5. Iniciar o Consumer (outro terminal)

```bash
npm run consumer
```

### 6. Iniciar o App do Cliente (outro terminal)

```bash
cd flutter_app
flutter run
```

### 7. Iniciar o App do Prestador (outro terminal)

```bash
cd flutter_prestador
flutter run
```

> Para rodar ambos os apps simultaneamente, use dois emuladores ou `flutter run -d <device-id>` em terminais separados.

### Configuração de IP

Por padrão os apps conectam em `http://localhost:3000`. Para outros ambientes, atualize `baseUrl` em:

```
flutter_app/lib/core/constants/api_constants.dart
flutter_prestador/lib/core/constants/api_constants.dart
```

| Ambiente                    | URL                          |
| --------------------------- | ---------------------------- |
| Desktop / iOS Simulator     | `http://localhost:3000`      |
| Emulador Android            | `http://10.0.2.2:3000`       |
| Dispositivo físico (LAN)    | `http://<IP-da-máquina>:3000`|

---

## Variáveis de Ambiente

```env
PORT=3000
RABBITMQ_URL=amqp://localhost
DB_CLIENT=sqlite
DB_PATH=./data/filafacil.sqlite
```

Se `DB_CLIENT=postgres`, também são aceitos: `DATABASE_URL`, `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, `PGPASSWORD`.

---

## Banco de Dados

### Tabela `fila`

| Coluna             | Tipo       | Descrição                       |
| ------------------ | ---------- | ------------------------------- |
| id                 | INTEGER PK | Identificador único             |
| nome               | TEXT       | Nome do cliente                 |
| quantidade_pessoas | INTEGER    | Tamanho do grupo                |
| status             | TEXT       | AGUARDANDO, CHAMADO ou ATENDIDO |
| mesa_id            | INTEGER FK | Mesa atribuída (nullable)       |
| created_at         | DATETIME   | Data/hora de entrada na fila    |

### Tabela `mesa`

| Coluna     | Tipo       | Descrição                           |
| ---------- | ---------- | ----------------------------------- |
| id         | INTEGER PK | Número da mesa                      |
| capacidade | INTEGER    | Quantidade de lugares               |
| disponivel | BOOLEAN    | `true` se livre, `false` se ocupada |

---

## API REST

| Método | Rota               | Descrição                            |
| ------ | ------------------ | ------------------------------------ |
| POST   | `/fila`            | Cria entrada na fila                 |
| GET    | `/fila`            | Lista todas as entradas              |
| GET    | `/fila/:id`        | Busca entrada por ID                 |
| PUT    | `/fila/:id/status` | Atualiza status (CHAMADO / ATENDIDO) |
| GET    | `/mesa`            | Lista mesas e disponibilidade        |

### POST `/fila`

```json
{ "nome": "João", "quantidade_pessoas": 4 }
```

### PUT `/fila/:id/status` — Chamar cliente

```json
{ "status": "CHAMADO", "mesa_id": 2 }
```

### PUT `/fila/:id/status` — Finalizar atendimento

```json
{ "status": "ATENDIDO" }
```

---

## Eventos MOM (RabbitMQ)

### Filas

- `fila.criada.queue`
- `fila.chamada.queue`
- `fila.finalizada.queue`

### Tabela de Eventos

| Evento          | Disparado em                         | Fila                  |
| --------------- | ------------------------------------ | --------------------- |
| fila.criada     | POST `/fila`                         | fila.criada.queue     |
| fila.chamada    | PUT `/fila/:id/status` → CHAMADO     | fila.chamada.queue    |
| fila.finalizada | PUT `/fila/:id/status` → ATENDIDO    | fila.finalizada.queue |

### Payloads

```json
// fila.criada
{ "filaId": 1, "cliente": "João", "quantidade_pessoas": 4, "status": "AGUARDANDO", "timestamp": "..." }

// fila.chamada
{ "filaId": 1, "cliente": "João", "mesaId": 2, "status": "CHAMADO", "timestamp": "..." }

// fila.finalizada
{ "filaId": 1, "cliente": "João", "mesaId": 2, "status": "ATENDIDO", "timestamp": "..." }
```

### Logs do Worker

| Prefixo       | Camada                        |
| ------------- | ----------------------------- |
| `[API]`       | API HTTP                      |
| `[DATABASE]`  | Inicialização e seed do banco |
| `[RABBITMQ]`  | Conexão e falhas do broker    |
| `[PUBLISHER]` | Publicação de eventos         |
| `[CONSUMER]`  | Worker e consumo de mensagens |

```text
[FILA_CRIADA]    Cliente João entrou na fila com grupo de 4 pessoas
[FILA_CHAMADA]   Cliente João foi chamado para mesa 2
[FILA_FINALIZADA] Atendimento finalizado para cliente João
```

---

## Apps Flutter

Ambos os apps seguem **Clean Architecture** com camadas `presentation`, `application`, `domain` e `infrastructure`.

### App Cliente (`flutter_app/`)

| Tela           | Descrição                                                   |
| -------------- | ----------------------------------------------------------- |
| Entrar na Fila | Formulário para informar nome e número de pessoas           |
| Lista da Fila  | Exibe posição na fila e status atual                        |
| Mesas          | Mostra a disponibilidade de mesas em tempo real             |

**Polling automático:**

| Timer                    | Intervalo | Inicia em                        | Cancela em                   |
| ------------------------ | --------- | -------------------------------- | ---------------------------- |
| Status da fila           | 7 s       | `entrarNaFila()` / inicialização | `sairDaFila()` / `dispose()` |
| Disponibilidade de mesas | 5 s       | `carregarMesas()`                | `dispose()`                  |

### App Prestador (`flutter_prestador/`)

| Tela   | Descrição                                                                              |
| ------ | -------------------------------------------------------------------------------------- |
| Fila   | Lista de clientes aguardando; permite chamar o próximo e atribuir uma mesa             |
| Mesas  | Exibe status de cada mesa (livre/ocupada/capacidade); permite liberar mesa manualmente |
| Painel | Dashboard com estatísticas em tempo real: fila, mesas livres, total atendidos          |

**Polling automático:** `OperadorProvider` atualiza fila e mesas em paralelo a cada **5 segundos**, iniciando automaticamente ao ser criado.

```dart
_timer = Timer.periodic(ApiConstants.pollingInterval, (_) => _silentRefresh());

Future<void> _silentRefresh() async {
  final results = await Future.wait([_service.listarFila(), _service.listarMesas()]);
  _fila  = results[0] as List<FilaModel>;
  _mesas = results[1] as List<MesaModel>;
  notifyListeners();
}
```

---

## Fluxo Ponta a Ponta

```text
1. Cliente entra na fila pelo app
2. Backend persiste e publica fila.criada no RabbitMQ
3. Worker consumer processa o evento (log assíncrono)
4. App do prestador detecta novo cliente via polling (≤ 5 s)
5. Operador chama o cliente e atribui uma mesa
6. Backend publica fila.chamada; mesa marcada como ocupada
7. App do cliente detecta status CHAMADO via polling (≤ 7 s)
8. Operador finaliza o atendimento; mesa liberada automaticamente
9. Backend publica fila.finalizada
```

---

## Entregas por Sprint

| Sprint | Prazo      | Pontos | Entrega principal                              | Vídeo                                          |
| ------ | ---------- | ------ | ---------------------------------------------- | ---------------------------------------------- |
| 1      | 11/05/2026 | 20 pts | Arquitetura, banco de dados e API REST         | —                                              |
| 2      | 25/05/2026 | 20 pts | Integração com RabbitMQ (MOM)                  | https://youtu.be/IAJJ3c4NFOU                  |
| 3      | 15/06/2026 | 20 pts | App Flutter do cliente com polling assíncrono  | https://youtu.be/7_15n1wKLTw?si=HDy1ScnnQi-3SQQe |
| 4      | 03/07/2026 | 20 pts | App Flutter do prestador + integração final    | https://youtu.be/1rmlek3UXvU                  |

> Os vídeos não foram enviados ao GitHub por restrições de tamanho de arquivo.

---

## Observações

- O RabbitMQ não substitui o banco de dados; o banco permanece como fonte de verdade.
- A publicação de eventos é efeito colateral: se o broker falhar, a API continua funcionando.
- Os apps Flutter não se conectam diretamente ao RabbitMQ; utilizam polling HTTP sobre a API REST.
- A seleção automática de mesa não foi implementada; o operador atribui manualmente.
- O consumer roda como processo separado (`npm run consumer`) e processa eventos de forma assíncrona.
