# FilaFácil

FilaFácil é um sistema distribuído de fila de espera para restaurantes. O cliente entra na fila pelo app móvel e é notificado quando sua mesa ficar disponível; o operador do restaurante (prestador) gerencia chamadas e status pelo backend.

Projeto Integrador — LDAMD | PUC Minas | Engenharia de Software | 1º Semestre 2026

---

## Visão Geral do Sistema

O sistema é composto por três componentes que se comunicam de forma assíncrona:

| Componente | Tecnologia | Função |
|---|---|---|
| Backend REST | Node.js + Express + SQLite/PostgreSQL | Persiste dados, expõe endpoints e publica eventos no MOM |
| Middleware (MOM) | RabbitMQ | Recebe eventos do backend e os distribui aos consumidores |
| App Flutter — Cliente | Flutter/Dart | Consome a API REST e atualiza o estado via polling assíncrono |

---

## Pré-requisitos

**Backend:**
- Node.js 18+
- npm
- Docker e Docker Compose (para RabbitMQ)
- SQLite local ou PostgreSQL local

**App Flutter (Cliente):**
- Flutter 3.10+ e Dart 3.x
- Android Studio ou VS Code com extensão Flutter
- Emulador Android/iOS ou dispositivo físico

---

## Instalação e Execução

**1. Backend:**

```bash
npm install
copy .env.example .env
