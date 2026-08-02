# 🚦 Módulo 10 - Monitoramento de Concorrência e Deadlocks no SQL Server

## 📖 Sobre o módulo

Este módulo apresenta os principais mecanismos de controle de
concorrência do SQL Server, abordando os níveis de isolamento das
transações, Row Versioning, monitoramento de bloqueios (Blocking) e
identificação de Deadlocks.

Durante as aulas são demonstrados conceitos fundamentais sobre
bloqueios, consistência dos dados e desempenho, além da implementação de
scripts utilizados por DBAs para monitoramento e diagnóstico de
ambientes SQL Server em produção.

## 🎯 Objetivos

-   Compreender o funcionamento dos níveis de isolamento das transações.
-   Identificar os diferentes tipos de bloqueios (Locks).
-   Entender como ocorre o Blocking entre sessões.
-   Configurar e utilizar Row Versioning.
-   Implementar Snapshot Isolation.
-   Monitorar sessões bloqueadas.
-   Utilizar DMVs para diagnóstico.
-   Automatizar o monitoramento de Blocking.
-   Simular e analisar Deadlocks.

## 📂 Estrutura

``` text
modulo-10-monitoramento-concorrencia/
├── 3 - Niveis de Isolamento.pdf
├── 04_niveis_de_isolamento.sql
├── 5 - Row Versioning.pdf
├── 05_row_versioning.sql
├── 06_monitorando_blocking.sql
├── 06_job_monitora_blocking_dba.sql
├── 7 - Monitorando Deadlock.pdf
├── 07_provocando_deadlock.sql
├── 07_profiler_deadlock.sql
├── 07_extended_events_deadlock.sql
└── 07_alerta_deadlock.sql
```

## 📚 Conteúdo estudado

### Níveis de Isolamento

-   READ UNCOMMITTED
-   READ COMMITTED
-   REPEATABLE READ
-   SERIALIZABLE

### Row Versioning

-   Read Committed Snapshot (RCSI)
-   Snapshot Isolation
-   Versionamento de linhas usando TempDB

### Blocking

-   Simulação de bloqueios
-   Diagnóstico com DMVs
-   Sessões bloqueadas e bloqueadoras

### Deadlocks

-   Simulação de Deadlocks
-   SQL Server Profiler
-   Extended Events
-   SQL Server Agent Alerts

## 🛠 Ferramentas

-   SQL Server
-   SQL Server Management Studio (SSMS)
-   SQL Server Agent
-   SQL Server Profiler
-   Extended Events
-   Dynamic Management Views (DMVs)
-   T-SQL

## 💡 Competências desenvolvidas

-   Controle de concorrência
-   Locks e Blocking
-   Snapshot Isolation
-   Row Versioning
-   Diagnóstico de Performance
-   SQL Server Agent
-   Extended Events
-   Deadlock Analysis

## 👨‍💻 Autor

**Andrey Andrade**

Projeto desenvolvido durante o curso **Comunidade SQL Server Expert**,
ministrado pelo **Prof. Landry**.
