const clienteRepository = require('../repositories/clienteRepository');
const mesaRepository = require('../repositories/mesaRepository');
const filaRepository = require('../repositories/filaRepository');
const { getDatabase } = require('../database');

const TRANSICOES_VALIDAS = {
  AGUARDANDO: 'CHAMADO',
  CHAMADO: 'ATENDIDO',
};

async function entrarNaFila({ nome, quantidade_pessoas }) {
  // Validações de entrada
  if (!nome || typeof nome !== 'string' || nome.trim() === '') {
    const err = new Error('O campo "nome" é obrigatório.');
    err.statusCode = 400;
    throw err;
  }

  if (
    quantidade_pessoas === undefined ||
    quantidade_pessoas === null ||
    !Number.isInteger(quantidade_pessoas) ||
    quantidade_pessoas < 1
  ) {
    const err = new Error('O campo "quantidade_pessoas" deve ser um inteiro maior ou igual a 1.');
    err.statusCode = 400;
    throw err;
  }

  // Encontra ou cria o cliente pelo nome
  const cliente = await clienteRepository.findOrCreate(nome.trim());

  // Cria a entrada na fila
  const entrada = await filaRepository.create({
    cliente_id: cliente.id,
    quantidade_pessoas,
  });

  return entrada;
}

async function listarFila() {
  return filaRepository.findAll();
}

async function buscarPorId(id) {
  const entrada = await filaRepository.findById(id);
  if (!entrada) {
    const err = new Error(`Entrada com id ${id} não encontrada.`);
    err.statusCode = 404;
    throw err;
  }
  return entrada;
}

async function atualizarStatus(id, { status, mesa_id }) {
  // Validação: status obrigatório
  if (!status) {
    const err = new Error('O campo "status" é obrigatório.');
    err.statusCode = 400;
    throw err;
  }

  const statusValidos = ['AGUARDANDO', 'CHAMADO', 'ATENDIDO'];
  if (!statusValidos.includes(status)) {
    const err = new Error(`Status inválido. Valores aceitos: ${statusValidos.join(', ')}.`);
    err.statusCode = 400;
    throw err;
  }

  // Busca a entrada atual
  const entrada = await filaRepository.findById(id);
  if (!entrada) {
    const err = new Error(`Entrada com id ${id} não encontrada.`);
    err.statusCode = 404;
    throw err;
  }

  // Valida transição de estado
  const proximoEstadoValido = TRANSICOES_VALIDAS[entrada.status];
  if (status !== proximoEstadoValido) {
    const err = new Error(
      `Transição inválida: não é possível mudar de "${entrada.status}" para "${status}". ` +
      `A próxima transição válida é: "${proximoEstadoValido}".`
    );
    err.statusCode = 422;
    throw err;
  }

  // Fluxo: AGUARDANDO → CHAMADO
  if (status === 'CHAMADO') {
    if (mesa_id === undefined || mesa_id === null) {
      const err = new Error('O campo "mesa_id" é obrigatório ao chamar um cliente.');
      err.statusCode = 400;
      throw err;
    }

    const mesa = await mesaRepository.findById(mesa_id);
    if (!mesa) {
      const err = new Error(`Mesa com id ${mesa_id} não encontrada.`);
      err.statusCode = 404;
      throw err;
    }

    if (!mesa.disponivel) {
      const err = new Error(`Mesa ${mesa_id} não está disponível.`);
      err.statusCode = 422;
      throw err;
    }

    if (mesa.capacidade < entrada.quantidade_pessoas) {
      const err = new Error(
        `Mesa ${mesa_id} tem capacidade para ${mesa.capacidade} pessoa(s), ` +
        `mas o grupo possui ${entrada.quantidade_pessoas} pessoa(s).`
      );
      err.statusCode = 422;
      throw err;
    }

    // Executa dentro de uma transação
    const db = await getDatabase();
    try {
      await db.exec('BEGIN TRANSACTION');
      await filaRepository.updateStatus(id, { status: 'CHAMADO', mesa_id }, db);
      await mesaRepository.setDisponivel(mesa_id, false, db);
      await db.exec('COMMIT');
    } catch (e) {
      await db.exec('ROLLBACK');
      throw e;
    }
  }

  // Fluxo: CHAMADO → ATENDIDO
  if (status === 'ATENDIDO') {
    const mesa_id_atual = entrada.mesa ? entrada.mesa.id : null;

    const db = await getDatabase();
    try {
      await db.exec('BEGIN TRANSACTION');
      await filaRepository.updateStatus(id, { status: 'ATENDIDO' }, db);
      if (mesa_id_atual) {
        await mesaRepository.setDisponivel(mesa_id_atual, true, db);
      }
      await db.exec('COMMIT');
    } catch (e) {
      await db.exec('ROLLBACK');
      throw e;
    }
  }

  return filaRepository.findById(id);
}

module.exports = { entrarNaFila, listarFila, buscarPorId, atualizarStatus };
