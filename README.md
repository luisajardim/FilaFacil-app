# FilaFácil

O FilaFácil é uma API simples para controlar fila de espera de restaurante. A ideia é registrar quem está aguardando, chamar o cliente para uma mesa e depois marcar o atendimento como concluído, mantendo tudo salvo em SQLite.

O projeto foi pensado para ser direto de usar e fácil de testar. Ao subir a aplicação, o banco é criado automaticamente, as mesas padrão são cadastradas e os endpoints já ficam prontos para consumo no Postman ou via cURL.

## Pré-requisitos

- Node.js 18+
- npm instalado junto com o Node.js
- SQLite local gerado automaticamente pelo próprio projeto

## Instalação e execução

```bash
npm install
cp .env.example .env
npm start
```

Se preferir, também dá para usar o modo de desenvolvimento com:

```bash
npm run dev
```

O arquivo `.env` já vem com o caminho padrão do banco, mas você pode ajustar `DB_PATH` se quiser guardar o SQLite em outro lugar. Se a variável `PORT` não for definida, a aplicação sobe na porta `3000`.

## O que a aplicação faz

O fluxo é simples:

1. O cliente entra na fila com nome e quantidade de pessoas.
2. A entrada começa com o status `AGUARDANDO`.
3. Quando a mesa é definida, o status passa para `CHAMADO`.
4. Depois do atendimento, o status muda para `ATENDIDO` e a mesa volta a ficar disponível.

## Estrutura

- `src/app.js`: sobe o Express, registra as rotas e expõe a rota raiz com informações básicas da API.
- `src/database.js`: abre a conexão com o SQLite, cria as tabelas e faz o seed das mesas padrão.
- `src/routes`: concentra os endpoints da fila.
- `src/controllers`: faz a ponte entre as requisições HTTP e a camada de serviço.
- `src/services`: concentra as regras de negócio e as validações principais.
- `src/repositories`: acessa os dados sem misturar regra de negócio com SQL.
- `src/middlewares`: centraliza o tratamento de erros.

## Modelo de dados

O banco trabalha com três entidades principais:

- `cliente`: guarda o nome do cliente e evita duplicidade quando ele entra na fila mais de uma vez.
- `mesa`: representa as mesas disponíveis, com capacidade e status de disponibilidade.
- `fila`: guarda a entrada na fila, relacionando cliente, quantidade de pessoas, mesa e status.

As mesas 1, 2, 3 e 4 são criadas automaticamente na inicialização, com capacidades 2, 4, 4 e 8.

## Endpoints

### `POST /fila`

Cria uma nova entrada na fila.

Body esperado:

```json
{
  "nome": "João",
  "quantidade_pessoas": 4
}
```

Resposta típica:

```json
{
  "id": 1,
  "cliente": {
    "id": 1,
    "nome": "João"
  },
  "quantidade_pessoas": 4,
  "status": "AGUARDANDO",
  "mesa": null,
  "criado_em": "2026-05-10T12:00:00.000Z"
}
```

### `GET /fila`

Lista todas as entradas da fila em ordem de criação.

### `GET /fila/:id`

Busca uma entrada específica pelo ID.

### `PUT /fila/:id/status`

Atualiza o status de uma entrada. O fluxo aceito hoje é:

- `AGUARDANDO` para `CHAMADO`, informando `mesa_id`.
- `CHAMADO` para `ATENDIDO`, sem necessidade de nova mesa.

Exemplo de chamada:

```json
{
  "status": "CHAMADO",
  "mesa_id": 2
}
```

Ao chamar o cliente, a mesa fica indisponível. Quando o atendimento é concluído, a mesa é liberada automaticamente.

## Regras e retornos

- O nome do cliente é obrigatório.
- A quantidade de pessoas precisa ser maior que zero.
- A mesa precisa existir e ter capacidade para o grupo.
- A mesa precisa estar disponível para ser vinculada ao cliente.
- A API responde com `400` para dados inválidos, `404` quando o recurso não existe e `422` quando alguma regra de negócio é violada.

## Como testar

O jeito mais simples é importar `FilaFacil.postman_collection.json` no Postman e apontar a variável `baseUrl` para `http://localhost:3000`.

Se preferir testar na mão, estes comandos resolvem o básico:

```bash
curl -X POST http://localhost:3000/fila -H "Content-Type: application/json" -d '{"nome":"Maria","quantidade_pessoas":2}'
curl http://localhost:3000/fila
curl http://localhost:3000/fila/1
curl -X PUT http://localhost:3000/fila/1/status -H "Content-Type: application/json" -d '{"status":"CHAMADO","mesa_id":1}'
```

## Estrutura de teste recomendada

Para conferir o fluxo completo, vale seguir esta ordem:

1. Criar uma entrada com `POST /fila`.
2. Listar a fila com `GET /fila`.
3. Buscar a entrada com `GET /fila/:id`.
4. Chamar o cliente com `PUT /fila/:id/status` e informar a mesa.
5. Finalizar o atendimento com `PUT /fila/:id/status` marcando `ATENDIDO`.

## Observação final

O projeto foi mantido com uma base enxuta justamente para focar na regra de negócio principal da sprint. Mesmo assim, a documentação cobre o suficiente para entender a ideia, subir a API e validar o comportamento esperado sem depender de adivinhação.
