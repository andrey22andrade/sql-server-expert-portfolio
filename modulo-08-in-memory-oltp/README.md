# 📘 Módulo 08 --- In-Memory OLTP

------------------------------------------------------------------------

# 📌 Contexto do Módulo

Este módulo foi focado no recurso **In-Memory OLTP** do SQL Server, uma
tecnologia voltada para otimização de desempenho através do uso de
estruturas em memória.

Durante as práticas foram explorados conceitos relacionados a tabelas
Memory-Optimized, comparação com tabelas tradicionais armazenadas em
disco, índices In-Memory e Stored Procedures compiladas nativamente.

Os laboratórios desenvolvidos neste módulo representam cenários de
otimização e análise de performance utilizados por DBAs em ambientes
onde existe necessidade de alto desempenho e baixa latência.

------------------------------------------------------------------------

# 🎯 Objetivo

Desenvolver conhecimentos práticos relacionados a:

-   Conceito de In-Memory OLTP
-   Criação de Memory-Optimized Tables
-   Configuração de durabilidade dos dados
-   Migração de tabelas tradicionais para memória
-   Análise de consumo de memória
-   Comparação Disk-Based x Memory-Optimized
-   Natively Compiled Stored Procedures
-   Otimização de desempenho no SQL Server

------------------------------------------------------------------------

# 📂 Estrutura do Módulo

``` bash
modulo-08-in-memory-oltp/
│
├── PDFs/
│
├── Queries/
│   ├── 01_inmemory_oltp.sql
│   ├── 03_migrando_para_memory_optimized_tables.sql
│   └── 04_memory_optimized_tables_x_disk_base_tables.sql
│
├── Imagens/
│   ├── 02_01_memory_optimized_tables_persistencia.png
│   ├── 03_01_migrando_para_memory_optimized_tables.png
│   └── 04_01_memory_optimized_tables_x_disk_base_tables.png
│
└── README.md
```

------------------------------------------------------------------------

# 🧠 Conceitos Abordados

## 🔹 In-Memory OLTP

O In-Memory OLTP é uma tecnologia do SQL Server criada para melhorar
desempenho utilizando estruturas otimizadas em memória.

Diferente das tabelas tradicionais, os dados podem permanecer em
estruturas otimizadas para acesso rápido.

------------------------------------------------------------------------

## 🔹 Memory-Optimized Tables

Foram criadas tabelas utilizando:

``` sql
MEMORY_OPTIMIZED = ON
```

Essas tabelas utilizam estruturas específicas do SQL Server para
processamento em memória.

Também foram estudados os modos:

-   SCHEMA_ONLY
-   SCHEMA_AND_DATA

Onde:

**SCHEMA_ONLY**

-   mantém somente a estrutura
-   dados são perdidos após reinicialização

**SCHEMA_AND_DATA**

-   mantém estrutura e dados

------------------------------------------------------------------------

## 🔹 Filegroup Memory Optimized

Para utilizar In-Memory OLTP foi necessário preparar o banco de dados
com:

``` sql
MEMORY_OPTIMIZED_DATA
```

Esse recurso permite o armazenamento das estruturas necessárias para
tabelas otimizadas em memória.

------------------------------------------------------------------------

## 🔹 Índices In-Memory

Foram estudados índices específicos para tabelas Memory-Optimized.

Entre eles:

-   Hash Index
-   Nonclustered Bw-Tree

O objetivo é melhorar pesquisas e operações sobre os dados em memória.

------------------------------------------------------------------------

## 🔹 Migração para Memory-Optimized Tables

Foi realizado um cenário de migração de tabelas tradicionais para
tabelas otimizadas.

Durante a prática foram analisados:

-   consumo de memória
-   estatísticas das tabelas
-   objetos In-Memory

Utilizando recursos como:

``` sql
sys.dm_db_xtp_table_memory_stats
```

------------------------------------------------------------------------

## 🔹 Disk-Based x Memory-Optimized

Foi realizada uma comparação prática entre:

### Tabelas tradicionais

-   armazenamento em disco
-   processamento convencional

### Memory-Optimized Tables

-   estruturas em memória
-   menor latência
-   maior desempenho em determinados cenários

------------------------------------------------------------------------

## 🔹 Natively Compiled Stored Procedure

Foram estudadas Stored Procedures compiladas nativamente.

Características:

-   desenvolvidas para tabelas Memory-Optimized
-   compiladas para maior desempenho
-   utilizam processamento otimizado

------------------------------------------------------------------------

# 📸 Evidências Práticas

## 🔹 Memory-Optimized Tables

![Memory Optimized
Tables](Imagens/02_01_memory_optimized_tables_persistencia.png)

------------------------------------------------------------------------

## 🔹 Migração para Memory-Optimized Tables

![Migração Memory
Optimized](Imagens/03_01_migrando_para_memory_optimized_tables.png)

------------------------------------------------------------------------

## 🔹 Comparação Memory-Optimized x Disk-Based

![Comparação
Performance](Imagens/04_01_memory_optimized_tables_x_disk_base_tables.png)

------------------------------------------------------------------------

# 🧪 Aplicação Prática (Visão DBA)

Os cenários executados neste módulo representam atividades relacionadas
à otimização de ambientes SQL Server:

-   análise de desempenho
-   melhoria de consultas
-   redução de latência
-   utilização de memória
-   escolha adequada de arquitetura de armazenamento

O conhecimento de In-Memory OLTP é importante em ambientes com grande
volume de transações e necessidade de alta performance.

------------------------------------------------------------------------

# 📚 Aprendizados

Ao final deste módulo foi possível desenvolver conhecimentos em:

-   In-Memory OLTP
-   Memory-Optimized Tables
-   Filegroup Memory Optimized
-   Índices Hash
-   Bw-Tree
-   Migração de tabelas
-   Análise de memória
-   Natively Compiled Stored Procedures
-   Otimização SQL Server

------------------------------------------------------------------------

# 🚀 Conclusão

Este módulo consolidou conhecimentos relacionados à arquitetura interna
e otimização de desempenho no SQL Server.

Os laboratórios demonstraram como utilizar recursos avançados para
melhorar processamento e reduzir gargalos em ambientes que exigem alta
performance.

O conteúdo complementa os módulos anteriores do portfólio, adicionando
conhecimentos de tuning e administração avançada de bancos de dados.
