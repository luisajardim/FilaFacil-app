# FilaFácil

FilaFácil é um sistema distribuído de fila de espera para restaurantes. O cliente entra na fila pelo app móvel e é notificado quando sua mesa ficar disponível; o operador do restaurante (prestador) gerencia chamadas e status pelo backend.

**Projeto Integrador — LDAMD | PUC Minas | Engenharia de Software | 1º Semestre 2026**

---

# Visão Geral do Sistema

O sistema é composto por três componentes que se comunicam de forma assíncrona:

| Componente            | Tecnologia                            | Função                                                        |
| --------------------- | ------------------------------------- | ------------------------------------------------------------- |
| Backend REST          | Node.js + Express + SQLite/PostgreSQL | Persiste dados, expõe endpoints e publica eventos no MOM      |
| Middleware (MOM)      | RabbitMQ                              | Recebe eventos do backend e os distribui aos consumidores     |
| App Flutter — Cliente | Flutter/Dart                          | Consome a API REST e atualiza o estado via polling assíncrono |

---

# Pré-requisitos

## Backend

* Node.js 18+
* npm
* Docker e Docker Compose (para RabbitMQ)
* SQLite local ou PostgreSQL local

## App Flutter (Cliente)

* Flutter 3.10+ e Dart 3.x
* Android Studio ou VS Code com extensão Flutter
* Emulador Android/iOS ou dispositivo físico

---

# Instalação e Execução

## 1. Backend

```bash
npm install
copy .env.example .env
```

## 2. App Flutter

```bash
cd flutter_app
flutter pub get
```

## 3. Subir o RabbitMQ

```bash
npm run start:rabbit
```

Painel de administração: `http://localhost:15672`

**Usuário:** `guest`
**Senha:** `guest`

## 4. Iniciar a API

```bash
npm run dev
```

## 5. Iniciar o Consumer (outro terminal)

```bash
npm run consumer
```

## 6. Iniciar o App Flutter (outro terminal)

```bash
cd flutter_app
flutter run
```

O app conecta por padrão em:

```text
http://localhost:3000
```

Para rodar em dispositivo físico, atualize `baseUrl` em:

```text
lib/core/constants/api_constants.dart
```

com o IP da máquina na rede local.

---

# Variáveis de Ambiente

O arquivo `.env` usa os valores abaixo como base:

```env
PORT=3000
RABBITMQ_URL=amqp://localhost
DB_CLIENT=sqlite
DB_PATH=./data/filafacil.sqlite
```

Se `DB_CLIENT=postgres`, também são aceitos:

* `DATABASE_URL`
* `PGHOST`
* `PGPORT`
* `PGDATABASE`
* `PGUSER`
* `PGPASSWORD`

---

# Sprint 1 — Arquitetura e Backend REST

**Prazo:** 11/05/2026
**Pontuação:** 20 pts

## Domínio

Sistema de fila de espera para restaurantes.

O cliente (usuário final) entra na fila pelo app móvel e acompanha sua posição em tempo real. O prestador (operador do restaurante) gerencia o estado da fila e das mesas pelo backend.

## Arquitetura

```text
[App Flutter — Cliente]
         |
         | HTTP REST (polling)
         ↓
[Backend Express — API REST]
         |            |
         | SQL         | AMQP
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

## Endpoints REST

| Método | Rota               | Descrição                            |
| ------ | ------------------ | ------------------------------------ |
| POST   | `/fila`            | Cria entrada na fila                 |
| GET    | `/fila`            | Lista todas as entradas              |
| GET    | `/fila/:id`        | Busca entrada por ID                 |
| PUT    | `/fila/:id/status` | Atualiza status (CHAMADO / ATENDIDO) |
| GET    | `/mesa`            | Lista mesas e disponibilidade        |

### POST `/fila`

Cria uma entrada na fila e publica o evento `fila.criada` no RabbitMQ.

```json
{
  "nome": "João",
  "quantidade_pessoas": 4
}
```

### PUT `/fila/:id/status` — Chamar Cliente

```json
{
  "status": "CHAMADO",
  "mesa_id": 2
}
```

### PUT `/fila/:id/status` — Finalizar Atendimento

```json
{
  "status": "ATENDIDO"
}
```

---

# Sprint 2 — Integração com MOM (RabbitMQ)

**Prazo:** 25/05/2026
**Pontuação:** 20 pts

## Filas Criadas

* `fila.criada.queue`
* `fila.chamada.queue`
* `fila.finalizada.queue`

---

## Documentação dos Eventos

| Evento          | Produtor                             | Consumidor                | Tópico/Fila           | Payload                                                                                                         |
| --------------- | ------------------------------------ | ------------------------- | --------------------- | --------------------------------------------------------------------------------------------------------------- |
| fila.criada     | API Express — POST `/fila`           | Worker `eventConsumer.js` | fila.criada.queue     | `{"filaId":1,"cliente":"João","quantidade_pessoas":4,"status":"AGUARDANDO","timestamp":"2026-05-25T10:00:00Z"}` |
| fila.chamada    | API Express — PUT `/fila/:id/status` | Worker `eventConsumer.js` | fila.chamada.queue    | `{"filaId":1,"cliente":"João","mesaId":2,"status":"CHAMADO","timestamp":"2026-05-25T10:05:00Z"}`                |
| fila.finalizada | API Express — PUT `/fila/:id/status` | Worker `eventConsumer.js` | fila.finalizada.queue | `{"filaId":1,"cliente":"João","mesaId":2,"status":"ATENDIDO","timestamp":"2026-05-25T11:00:00Z"}`               |

---

## Payloads Completos

### fila.criada

```json
{
  "filaId": 1,
  "cliente": "João",
  "quantidade_pessoas": 4,
  "status": "AGUARDANDO",
  "timestamp": "2026-05-25T10:00:00Z"
}
```

### fila.chamada

```json
{
  "filaId": 1,
  "cliente": "João",
  "mesaId": 2,
  "status": "CHAMADO",
  "timestamp": "2026-05-25T10:05:00Z"
}
```

### fila.finalizada

```json
{
  "filaId": 1,
  "cliente": "João",
  "mesaId": 2,
  "status": "ATENDIDO",
  "timestamp": "2026-05-25T11:00:00Z"
}
```

---

## Comunicação Assíncrona

O consumer é um processo separado (`src/workers/eventConsumer.js`) que consome as filas sem chamadas REST diretas ao backend.

A API publica o evento como efeito colateral após o commit bem-sucedido; se o broker estiver indisponível, a publicação é descartada silenciosamente e a API continua funcionando normalmente.

---

## Logs Esperados

| Prefixo       | Camada                        |
| ------------- | ----------------------------- |
| `[API]`       | API HTTP                      |
| `[DATABASE]`  | Inicialização e seed do banco |
| `[RABBITMQ]`  | Conexão e falhas do broker    |
| `[PUBLISHER]` | Publicação de eventos         |
| `[CONSUMER]`  | Worker e consumo de mensagens |

### Exemplo de saída do Worker

```text
[FILA_CRIADA]
Cliente João entrou na fila com grupo de 4 pessoas

[FILA_CHAMADA]
Cliente João foi chamado para mesa 2

[FILA_FINALIZADA]
Atendimento finalizado para cliente João
```

---

# Sprint 3 — Aplicativo Flutter (Cliente)

**Prazo:** 15/06/2026
**Pontuação:** 20 pts

## Telas

| Tela           | Descrição                                                   |
| -------------- | ----------------------------------------------------------- |
| Entrar na Fila | Formulário para o cliente informar nome e número de pessoas |
| Lista da Fila  | Exibe posição na fila e status atual                        |
| Mesas          | Mostra a disponibilidade de mesas em tempo real             |

---

## Arquitetura do App (Clean Architecture)

```text
flutter_app/lib/
├── presentation/
│   ├── Screens
│   ├── Widgets
│   └── Providers
├── application/
│   └── Services
├── domain/
│   └── Models/Entities
└── infrastructure/
    └── Repositories
```

A separação garante que a camada de apresentação não conheça detalhes de rede ou persistência; toda comunicação com o backend passa pelos repositórios da camada de infraestrutura.

---

## Atualização Assíncrona de Estado — Polling

O app atualiza o estado automaticamente por meio de dois timers independentes.

### Status da fila — a cada 7 segundos

```dart
static const Duration pollingInterval = Duration(seconds: 7);
```

Serviço responsável:

```dart
void startPolling(int filaId, StatusCallback onUpdate) {
  _timer?.cancel();
  _timer = Timer.periodic(ApiConstants.pollingInterval, (_) async {
    try {
      final updated = await _repository.fetchById(filaId);
      onUpdate(updated);
    } catch (_) {
      // erros de rede transientes são ignorados
    }
  });
}
```

O polling é iniciado:

* Na inicialização do `FilaProvider`
* Após o cliente entrar na fila

### Disponibilidade de mesas — a cada 5 segundos

```dart
void _startMesasPolling() {
  _mesasTimer?.cancel();

  _mesasTimer = Timer.periodic(
    const Duration(seconds: 5),
    (_) async {
      try {
        _mesas = await _mesaRepository.fetchAll();
        notifyListeners();
      } catch (_) {}
    },
  );
}
```

Ativado ao entrar na tela de Mesas via `carregarMesas()`.

---

## Ciclo de Vida dos Timers

| Timer                    | Intervalo | Inicia em                        | Cancela em                   |
| ------------------------ | --------- | -------------------------------- | ---------------------------- |
| Status da fila           | 7 s       | `entrarNaFila()` / inicialização | `sairDaFila()` / `dispose()` |
| Disponibilidade de mesas | 5 s       | `carregarMesas()`                | `dispose()`                  |

---

# Sprint 4 — App do Prestador e Integração Final

**Prazo:** 03/07/2026
**Pontuação:** 20 pts

## Entregas Previstas

* App Flutter funcional para o operador do restaurante (prestador)
* Fluxo completo ponta a ponta:

  * Cliente entra na fila
  * Backend publica evento no MOM
  * Prestador é notificado
  * Prestador chama cliente
  * Cliente é notificado
* Screencast de demonstração (3–5 min)
* Relatório Técnico Final (mínimo 4 páginas)

---

# Evidências Gravadas

## Sprint 2 — Integração MOM (RabbitMQ)

```text
https://youtu.be/IAJJ3c4NFOU
```

## Sprint 3 — App Flutter (Cliente)

```text
https://youtu.be/7_15n1wKLTw?si=HDy1ScnnQi-3SQQe
```

Não consegui fazer o upload dos arquivos no github devido ao tamanho. 

---

# Observações de Projeto

* O RabbitMQ não substitui o banco de dados; o banco permanece como fonte de verdade.
* A publicação de eventos é tratada como efeito colateral.
* A API continua funcionando mesmo se o broker falhar.
* A lógica de seleção automática de cliente ou mesa não foi implementada.
* O operador realiza a chamada manualmente pelo backend.
* O sistema permanece monolítico, com o consumer separado apenas como worker assíncrono.
