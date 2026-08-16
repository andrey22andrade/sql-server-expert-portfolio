# 🚀 SQL Server Expert — Módulo 13
## Replicação

<div align="center">

![SQL Server](https://img.shields.io/badge/SQL%20Server-Replication-red?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![T-SQL](https://img.shields.io/badge/T--SQL-Language-blue?style=for-the-badge)
![Replication](https://img.shields.io/badge/Replication-SQL%20Server-success?style=for-the-badge)
![Troubleshooting](https://img.shields.io/badge/Troubleshooting-Advanced-orange?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Concluído-brightgreen?style=for-the-badge)

**Último módulo da trilha SQL Server Expert — SQL Server On-Premise**

</div>

---

## 📑 Índice

- [📖 Sobre o módulo](#-sobre-o-módulo)
- [🎯 Objetivos](#-objetivos)
- [📂 Estrutura do projeto](#-estrutura-do-projeto)
- [🏗️ Arquitetura da replicação](#️-arquitetura-da-replicação)
- [📸 Snapshot Replication](#-snapshot-replication)
- [🔄 Transactional Replication](#-transactional-replication)
- [🔗 Peer-to-Peer Replication](#-peer-to-peer-replication)
- [🔀 Merge Replication](#-merge-replication)
- [🛠️ Troubleshooting](#️-troubleshooting)
- [⚔️ Resolução de conflitos](#️-resolução-de-conflitos)
- [🔢 Autonumeração e Sequence](#-autonumeração-e-sequence)
- [📊 Monitoramento](#-monitoramento)
- [📜 Scripts desenvolvidos](#-scripts-desenvolvidos)
- [🧠 Competências desenvolvidas](#-competências-desenvolvidas)
- [💼 Aplicações práticas](#-aplicações-práticas)
- [🚀 Resultados obtidos](#-resultados-obtidos)
- [🏆 Conclusão da trilha](#-conclusão-da-trilha)
- [👨‍💻 Autor](#-autor)

---

# 📖 Sobre o módulo

Este módulo apresenta os principais conceitos e laboratórios de **Replicação no Microsoft SQL Server**, abordando estratégias para distribuição e sincronização de dados entre diferentes instâncias.

O conteúdo combina teoria e prática, passando por diferentes modalidades de replicação e por cenários operacionais envolvendo sincronização, troubleshooting, conflitos e geração de identificadores.

Ao longo do módulo foram estudados:

- 📸 Snapshot Replication
- 🔄 Transactional Replication
- 🔗 Peer-to-Peer Replication
- 🔀 Merge Replication
- 🛠️ Troubleshooting
- ⚔️ Resolução de conflitos
- 📊 Monitoramento
- 🔢 Autonumeração com Sequence
- 🏗️ Publisher, Distributor e Subscriber
- 🔁 Push e Pull Subscriptions
- 🎯 Filtros de replicação
- 🔄 Sincronia inicial

---

# 🎯 Objetivos

Ao concluir este módulo, desenvolvi conhecimentos para:

- Compreender o conceito de replicação de dados no SQL Server.
- Identificar os principais componentes de uma arquitetura de replicação.
- Diferenciar Snapshot, Transactional, Peer-to-Peer e Merge Replication.
- Compreender o funcionamento de Publisher, Distributor e Subscriber.
- Trabalhar com sincronia inicial.
- Compreender assinaturas Push e Pull.
- Trabalhar com filtros horizontais e verticais.
- Analisar cenários de baixa latência na replicação transacional.
- Realizar troubleshooting de ambientes replicados.
- Analisar alterações de estrutura em objetos replicados.
- Trabalhar com Log Reader Agent.
- Simular acúmulo de alterações e backlog.
- Trabalhar com replicação Ponto-a-Ponto.
- Compreender conflitos na Merge Replication.
- Trabalhar com regras de resolução de conflitos.
- Monitorar conflitos através de alertas.
- Utilizar Sequence para geração distribuída de identificadores.
- Evitar colisões de valores em ambientes com múltiplos nós de escrita.

---

# 📂 Estrutura do projeto

```text
modulo-13-replicacao/
│
├── 📄 1 - Introducao a Replicacao.pdf
│
├── 📜 02_replicacao_transacional.sql
├── 📜 03_replicacao_transacional_troubleshooting.sql
├── 📜 04_replicacao_transacional_ponto_a_ponto.sql
│
├── 📄 6 - Replicacao Merge - Conflito.pdf
├── 📜 06_replicacao_merge_conflito.sql
└── 📜 06_replicacao_merge_autonumeracao.sql
```

> Os nomes e a numeração dos arquivos são mantidos conforme os materiais utilizados durante o módulo.

---

# 🏗️ Arquitetura da replicação

A introdução ao módulo apresenta os principais componentes envolvidos na replicação:

```text
                       SQL SERVER REPLICATION

                             Publisher
                                │
                         Publication
                                │
                                ▼
                           Distributor
                                │
                     ┌──────────┴──────────┐
                     │                     │
                  Snapshot            Transaction
                   Agent                Log Reader
                     │                     │
                     └──────────┬──────────┘
                                │
                                ▼
                            Subscriber
```

### Principais conceitos

- **Publisher** — instância que disponibiliza os dados para replicação.
- **Distributor** — componente responsável pela distribuição das alterações.
- **Subscriber** — instância que recebe os dados replicados.
- **Publication** — conjunto de dados disponibilizado para replicação.
- **Article** — objeto publicado dentro de uma publicação.
- **Subscription** — relação entre a publicação e o Subscriber.

O material também apresenta filtros horizontais e verticais, além das modalidades Push e Pull.

---

# 📸 Snapshot Replication

A **Snapshot Replication** trabalha enviando todos os dados durante a sincronização.

Uma característica importante apresentada no módulo é que o Snapshot também participa da **sincronia inicial** de outros tipos de replicação.

```text
Publisher
    │
    │ Snapshot
    ▼
Distributor
    │
    ▼
Subscriber
```

---

# 🔄 Transactional Replication

A **Replicação Transacional** trabalha com as alterações realizadas nos dados, em vez de reenviar todos os dados a cada sincronização.

O material destaca:

- sincronização das alterações;
- menor tempo de latência;
- utilização do Log Reader Agent;
- menor necessidade de transferência de dados quando comparada ao Snapshot.

### Fluxo simplificado

```text
Publisher
    │
    │ Transaction Log
    ▼
Log Reader Agent
    │
    ▼
Distributor
    │
    ▼
Subscriber
```

## 🧪 Laboratório — Replicação Transacional

O arquivo `02_replicacao_transacional.sql` prepara o banco `VendasDB` e cria objetos como:

- `dbo.Cliente`
- `dbo.Venda`
- `vw_Venda`
- `spu_Venda`

Depois são realizados testes de sincronização através da inclusão de novos registros.

O laboratório também demonstra que alterações estruturais, como modificações em uma View, podem exigir uma nova etapa de Snapshot para serem propagadas.

---

# 🛠️ Troubleshooting

O arquivo `03_replicacao_transacional_troubleshooting.sql` aprofunda a administração da Replicação Transacional através de cenários de troubleshooting.

Foram trabalhados:

- análise da estrutura das tabelas com `sp_help`;
- alterações de schema;
- inclusão e remoção de colunas;
- alteração de tipos de dados;
- procedures relacionadas à replicação;
- Log Reader Agent;
- geração de grande volume de dados;
- acúmulo de alterações;
- backups FULL;
- backups de Transaction Log.

### Simulação de backlog

O laboratório interrompe o **Log Reader Agent** e gera uma grande quantidade de registros para criar um cenário de acúmulo de alterações.

```sql
DECLARE @i INT = 5

WHILE @i <= 100000
BEGIN
    INSERT dbo.Cliente
    VALUES (
        @i,
        'Landry ' + LTRIM(STR(@i)),
        '4444-4444'
    )

    SET @i += 1
END
```

---

# 🔗 Peer-to-Peer Replication

O arquivo `04_replicacao_transacional_ponto_a_ponto.sql` trabalha um cenário de **Replicação Transacional Ponto-a-Ponto**.

O laboratório aborda:

- preparação do banco;
- Backup FULL;
- Restore;
- sincronia inicial;
- Publisher;
- Subscriber;
- alterações de dados;
- cenário bidirecional.

> **Observação:** o cabeçalho do material utilizado identifica o Hands On como “Replicação Merge”, enquanto o nome do arquivo indica “Replicação Transacional Ponto-a-Ponto”. A documentação mantém essa nomenclatura conforme os arquivos originais.

---

# 🔀 Merge Replication

A **Merge Replication** permite alterações tanto no Publisher quanto nos Subscribers.

O material destaca:

- possibilidade de períodos mais longos sem sincronização;
- controle de alterações;
- utilização de tabelas e triggers;
- utilização de `uniqueidentifier`;
- tratamento de conflitos.

```text
                 MERGE REPLICATION

                    Publisher
                    ↕       ↕
                    ↕       ↕
              Subscriber  Subscriber
                    ↕       ↕
                    └───↔───┘
```

---

# ⚔️ Resolução de conflitos

A aula **`6 - Replicacao Merge - Conflito.pdf`** é dedicada à resolução de conflitos na Merge Replication.

O material explica que a resolução padrão utiliza prioridades:

- **Publisher:** prioridade `100`;
- **Subscribers:** valores entre `0` e `99.99`;
- conflito padrão em nível de **linha (row-level)**;
- possibilidade de alteração para **column-level**.

## 🏆 Regras de resolução

| Regra | Comportamento |
|---|---|
| **Additive** | Soma os valores; para strings, concatena |
| **Averaging** | Calcula a média |
| **DATETIME (Earlier Wins)** | Vence a alteração mais antiga |
| **DATETIME (Later Wins)** | Vence a alteração mais recente |
| **Download Only** | Distribui somente alterações do Publisher |
| **Maximum** | Escolhe o maior valor numérico |
| **Merge Text Columns** | Combina strings alteradas |
| **Minimum** | Escolhe o menor valor numérico |
| **Priority Column** | Utiliza o nível de prioridade de uma coluna |
| **Subscriber Always Wins** | O Subscriber sempre vence |
| **Upload Only** | Distribui somente alterações dos Subscribers |
| **Stored Procedure** | Utiliza uma Stored Procedure para resolver o conflito |

---

# 🧪 Laboratório — Conflitos

O arquivo `06_replicacao_merge_conflito.sql` simula conflitos de atualização.

### Exemplo

No Publisher:

```sql
UPDATE dbo.Cliente
SET Telefone = 'AAAA-AAAA'
WHERE ClienteID = 1
```

No Subscriber:

```sql
UPDATE dbo.Cliente
SET Telefone = 'BBBB-BBBB'
WHERE ClienteID = 1
```

O mesmo registro é alterado nos dois lados antes da sincronização.

---

# 📊 Monitoramento de conflitos

O laboratório também trabalha com o alerta:

```text
Replication: Merge Conflicts
```

Configurado como:

```text
Tipo:
Performance condition alert

Objeto:
SQL Replication Merge Conflicts

Contador:
Conflicts/sec

Condição:
rises above 0
```

Assim, o exercício demonstra tanto a geração de conflitos quanto seu monitoramento através de alertas.

---

# 🔢 Autonumeração e Sequence

O último laboratório, `06_replicacao_merge_autonumeracao.sql`, aborda a geração de identificadores em um cenário no qual existem inserções em diferentes nós.

Primeiramente é analisado o comportamento de `IDENTITY`:

```sql
SELECT IDENT_CURRENT('dbo.Venda') AS ValorAtual
```

Depois o laboratório trabalha com **Sequence**.

### Publisher

```sql
CREATE SEQUENCE VendedorSeq
START WITH 1
INCREMENT BY 10
```

Produz valores como:

```text
1, 11, 21, 31...
```

### Subscriber

```sql
CREATE SEQUENCE VendedorSeq
START WITH 2
INCREMENT BY 10
```

Produz valores como:

```text
2, 12, 22, 32...
```

Dessa maneira, cada ambiente utiliza uma sequência diferente de identificadores, reduzindo o risco de colisões de chave quando existem inserções independentes.

## 🧱 Tabela utilizando Sequence

```sql
CREATE TABLE dbo.Vendedor (
    VendedorID INT DEFAULT NEXT VALUE FOR VendedorSeq PRIMARY KEY,
    Nome VARCHAR(100)
)
```

O laboratório realiza inserções tanto no Publisher quanto no Subscriber para validar a geração distribuída dos identificadores.

---

# 📜 Scripts desenvolvidos

| Script | Finalidade |
|---|---|
| `02_replicacao_transacional.sql` | Laboratório de Replicação Transacional |
| `03_replicacao_transacional_troubleshooting.sql` | Troubleshooting da Replicação Transacional |
| `04_replicacao_transacional_ponto_a_ponto.sql` | Laboratório de Replicação Transacional Ponto-a-Ponto |
| `06_replicacao_merge_conflito.sql` | Simulação e monitoramento de conflitos na Merge Replication |
| `06_replicacao_merge_autonumeracao.sql` | Autonumeração e Sequence em ambiente Merge |

## 📚 Materiais teóricos

| Arquivo | Conteúdo |
|---|---|
| `1 - Introducao a Replicacao.pdf` | Introdução aos tipos e componentes de Replicação |
| `6 - Replicacao Merge - Conflito.pdf` | Resolução de conflitos na Merge Replication |

---

# 🧠 Competências desenvolvidas

### Replicação

- ✅ Snapshot Replication
- ✅ Transactional Replication
- ✅ Peer-to-Peer Replication
- ✅ Merge Replication

### Arquitetura

- ✅ Publisher
- ✅ Distributor
- ✅ Subscriber
- ✅ Publication
- ✅ Article
- ✅ Subscription

### Sincronização

- ✅ Sincronia inicial
- ✅ Push Subscription
- ✅ Pull Subscription
- ✅ Latência
- ✅ Filtros

### Administração

- ✅ Log Reader Agent
- ✅ Troubleshooting
- ✅ Alterações de schema
- ✅ Backlog de alterações
- ✅ Monitoramento

### Merge Replication

- ✅ Conflitos
- ✅ Prioridades
- ✅ Resolução de conflitos
- ✅ Alertas
- ✅ Autonumeração
- ✅ Sequence

---

# 💼 Aplicações práticas

Os conhecimentos desenvolvidos neste módulo podem ser aplicados em cenários que necessitam de:

- distribuição de dados entre diferentes servidores;
- sincronização entre ambientes;
- disponibilização de dados para diferentes consumidores;
- replicação de alterações;
- ambientes com múltiplos nós;
- baixa latência na distribuição de dados;
- operação com Subscribers;
- monitoramento de falhas e conflitos;
- tratamento de conflitos de atualização;
- estratégias para geração de identificadores distribuídos.

---

# 🚀 Resultados obtidos

Ao concluir este módulo, desenvolvi uma visão prática sobre **Replicação no SQL Server**, passando por diferentes arquiteturas e necessidades operacionais.

O estudo evoluiu dos fundamentos:

```text
Publisher
    ↓
Publication
    ↓
Distributor
    ↓
Subscriber
```

para cenários mais avançados:

```text
Replicação
    │
    ├── Snapshot
    │
    ├── Transactional
    │       └── Troubleshooting
    │
    ├── Peer-to-Peer
    │
    └── Merge
            ├── Conflitos
            ├── Monitoramento
            └── Autonumeração
```

Dessa forma, o módulo não ficou restrito à configuração: também envolveu **sincronização, alterações, troubleshooting, conflitos, monitoramento e operação em cenários distribuídos**.

---

# 🏆 Conclusão da trilha

Este módulo representa o **último módulo da trilha SQL Server Expert — SQL Server On-Premise**.

Com sua conclusão:

# 🎓 13 / 13 módulos — 100% concluído

A jornada passou por diferentes áreas da administração de SQL Server, incluindo:

- Infraestrutura;
- Administração de bancos;
- Backup e Restore;
- Recuperação;
- Tabelas e Índices;
- Segurança;
- In-Memory OLTP;
- Automação;
- Monitoramento;
- Concorrência;
- Alta Disponibilidade;
- Always On;
- Replicação.

O Módulo 13 encerra a trilha adicionando conhecimentos sobre **distribuição e sincronização de dados**, complementando os conhecimentos de **Alta Disponibilidade e Disaster Recovery** desenvolvidos anteriormente.

---

# 🛠️ Tecnologias e ferramentas

| Tecnologia | Utilização |
|---|---|
| Microsoft SQL Server | Banco de dados e replicação |
| SQL Server Management Studio | Administração e execução dos laboratórios |
| T-SQL | Scripts e operações |
| SQL Server Agent | Agentes e automação da replicação |
| Transaction Log | Origem das alterações transacionais |
| Replication Agents | Processamento da replicação |
| Performance Condition Alerts | Monitoramento de conflitos |

---

# ⭐ Destaques do módulo

```text
                 SQL SERVER REPLICATION
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
     Snapshot        Transactional        Merge
        │                 │                 │
        │            ┌────┴────┐       Conflitos
        │            │         │           │
        │       Troubleshooting       Resolução
        │            │                     │
        │         Peer-to-Peer          Sequence
        │
        └──────────────┬───────────────────┘
                       │
                 DISTRIBUIÇÃO
                  DE DADOS
```

---

# 👨‍💻 Autor

**Andrey Andrade**

📚 **Trilha:** SQL Server Expert — SQL Server On-Premise

🎯 **Objetivo profissional:** desenvolver competências práticas em Administração de Banco de Dados SQL Server, infraestrutura, alta disponibilidade, troubleshooting e ambientes corporativos de dados.

---

<div align="center">

### 🚀 SQL Server Expert — Replicação

**Estudo • Prática • Troubleshooting • Replicação • Administração**

### 🎓 Trilha concluída — 13/13 módulos

</div>
