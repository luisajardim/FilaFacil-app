# FilaFácil — Backend REST

Sistema de gerenciamento de fila de espera para restaurante.

---

## Pré-requisitos

- Node.js >= 18
- MySQL >= 8

---

## Instalação

```bash
# Instalar dependências
npm install

# Criar o arquivo .env
cp .env.example .env
# Edite o .env com suas credenciais do MySQL
```

### Criar o banco de dados no MySQL

```sql
CREATE DATABASE filafacil CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

---

## Variáveis de ambiente (`.env`)

```
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=sua_senha
DB_NAME=filafacil
PORT=3000
```

---

## Executar

```bash
# Produção
npm start

# Desenvolvimento (com hot-reload)
npm run dev
```

Ao iniciar, o sistema:
1. Cria as tabelas automaticamente (se não existirem)
2. Insere as 4 mesas pré-cadastradas (seed)

---

## Estrutura do Projeto

```
src/
├── app.js                          # Ponto de entrada / Express
├── database.js                     # Conexão + inicialização do BD
├── routes/
│   └── filaRoutes.js               # Definição das rotas
├── controllers/
│   └── filaController.js           # Camada HTTP (req/res)
├── services/
│   └── filaService.js              # Regras de negócio
├── repositories/
│   ├── clienteRepository.js        # Acesso a dados: cliente
│   ├── mesaRepository.js           # Acesso a dados: mesa
│   └── filaRepository.js           # Acesso a dados: fila
└── middlewares/
    └── errorHandler.js             # Tratamento centralizado de erros
```

---

## Endpoints

### POST `/fila` — Entrar na fila

Cria o cliente automaticamente se não existir.

**Body:**
```json
{
  "nome": "João",
  "quantidade_pessoas": 4
}
```

**Resposta 201:**
```json
{
  "id": 1,
  "cliente": { "id": 1, "nome": "João" },
  "quantidade_pessoas": 4,
  "status": "AGUARDANDO",
  "mesa": null,
  "criado_em": "2024-01-15T10:00:00.000Z"
}
```

---

### GET `/fila` — Listar fila

Retorna todas as entradas ordenadas por `criado_em ASC`.

**Resposta 200:**
```json
[
  {
    "id": 1,
    "cliente": { "id": 1, "nome": "João" },
    "quantidade_pessoas": 4,
    "status": "AGUARDANDO",
    "mesa": null,
    "criado_em": "2024-01-15T10:00:00.000Z"
  }
]
```

---

### GET `/fila/:id` — Buscar por ID

**Resposta 200:** mesmo formato acima  
**Resposta 404:** `{ "erro": "Entrada com id 99 não encontrada." }`

---

### PUT `/fila/:id/status` — Atualizar status

#### Chamar cliente (AGUARDANDO → CHAMADO)

**Body:**
```json
{
  "status": "CHAMADO",
  "mesa_id": 2
}
```

Validações:
- `mesa_id` é obrigatório
- Mesa deve existir
- Mesa deve estar disponível (`disponivel = true`)
- `mesa.capacidade >= quantidade_pessoas`

Ao chamar: `mesa.disponivel` muda para `false`.

#### Finalizar atendimento (CHAMADO → ATENDIDO)

**Body:**
```json
{
  "status": "ATENDIDO"
}
```

Ao finalizar: `mesa.disponivel` muda automaticamente para `true`.

---

## Códigos de erro

| Código | Significado                         |
|--------|-------------------------------------|
| 400    | Dados inválidos / campos ausentes   |
| 404    | Recurso não encontrado              |
| 422    | Regra de negócio violada            |

---

## Fluxo completo (exemplo Postman)

```
1. POST /fila           → { nome: "João", quantidade_pessoas: 4 }   → status: AGUARDANDO
2. GET  /fila           → lista a fila
3. PUT  /fila/1/status  → { status: "CHAMADO", mesa_id: 2 }         → mesa fica indisponível
4. PUT  /fila/1/status  → { status: "ATENDIDO" }                    → mesa liberada automaticamente
```

---

## Mesas pré-cadastradas (seed automático)

| ID | Capacidade | Disponível |
|----|-----------|------------|
| 1  | 2         | true       |
| 2  | 4         | true       |
| 3  | 4         | true       |
| 4  | 8         | true       |

As mesas são criadas automaticamente ao iniciar o sistema.  
**Não existe endpoint de CRUD para mesas.**

---

## Testando a API

### Opção 1: Postman
1. Importe o arquivo `FilaFacil.postman_collection.json`
2. Configure a variável `baseUrl` como `http://localhost:3000`
3. Execute os requests em ordem

### Opção 2: cURL
```bash
# Criar entrada na fila
curl -X POST http://localhost:3000/fila \
  -H "Content-Type: application/json" \
  -d '{"nome":"Maria","quantidade_pessoas":2}'

# Listar fila
curl http://localhost:3000/fila

# Buscar entrada por ID
curl http://localhost:3000/fila/1

# Atualizar status
curl -X PUT http://localhost:3000/fila/1/status \
  -H "Content-Type: application/json" \
  -d '{"status":"CHAMADO","mesa_id":1}'
```

---

## Sprint 1 - Verificação de Requisitos

✅ Backend REST funcional com 4 endpoints  
✅ Banco de dados MySQL com schema bem estruturado  
✅ Clean Architecture (controllers, services, repositories)  
✅ Validações e tratamento de erros  
✅ Coleção de testes Postman (FilaFacil.postman_collection.json)  
✅ Proposta do projeto (PROPOSTA_PROJETO.txt)  
✅ Código commitado no Git com histórico representativo

---

## Próximas etapas

- **Sprint 2:** Integração com MOM (RabbitMQ/Redis)
- **Sprint 3:** App Flutter para Cliente
- **Sprint 4:** App Flutter para Prestador + Integração Completa

---

## Autores

Desenvolvido como projeto integrador da disciplina de Desenvolvimento de Aplicações Móveis e Distribuídas (LDAMD) - PUC Minas, Engenharia de Software, 1º Semestre 2026.
