# 🚀 SQL Server Expert — Módulo 11
## Alta Disponibilidade e Always On

![SQL Server](https://img.shields.io/badge/SQL%20Server-Always%20On-red?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![T-SQL](https://img.shields.io/badge/T--SQL-Language-blue?style=for-the-badge)
![Azure](https://img.shields.io/badge/Microsoft-Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![High Availability](https://img.shields.io/badge/High%20Availability-HA-success?style=for-the-badge)
![Disaster Recovery](https://img.shields.io/badge/Disaster%20Recovery-DR-orange?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Concluído-brightgreen?style=for-the-badge)

---

## 📑 Índice

- [📖 Sobre o módulo](#-sobre-o-módulo)
- [🎯 Objetivos](#-objetivos)
- [📂 Estrutura do projeto](#-estrutura-do-projeto)
- [📚 Conteúdo estudado](#-conteúdo-estudado)
- [🚚 Log Shipping](#-log-shipping)
- [🔄 Database Mirroring](#-database-mirroring)
- [⚡ Always On Availability Groups](#-always-on-availability-groups)
- [🔀 Modos de sincronização](#-modos-de-sincronização)
- [🌐 Listener](#-listener)
- [📖 Réplicas de leitura](#-réplicas-de-leitura)
- [🔄 Failover](#-failover)
- [☁️ Cloud Witness](#️-cloud-witness)
- [🛠 Ferramentas utilizadas](#-ferramentas-utilizadas)
- [📜 Scripts desenvolvidos](#-scripts-desenvolvidos)
- [🧠 Competências desenvolvidas](#-competências-desenvolvidas)
- [💼 Aplicações práticas](#-aplicações-práticas)
- [🚀 Resultados obtidos](#-resultados-obtidos)
- [👨‍💻 Autor](#-autor)

---

# 📖 Sobre o módulo

Este módulo apresenta os principais conceitos e tecnologias de **Alta Disponibilidade (High Availability)** e **Disaster Recovery (DR)** no Microsoft SQL Server.

Ao longo das aulas foram estudadas diferentes arquiteturas e estratégias para manter bancos de dados disponíveis, reduzir impactos de falhas e permitir a continuidade das operações.

O conteúdo combina teoria e laboratórios práticos envolvendo:

- Log Shipping;
- Database Mirroring;
- Always On Availability Groups;
- Réplicas síncronas e assíncronas;
- Failover;
- Listener;
- Read-Only Intent Routing;
- Monitoramento de sincronização;
- Cloud Witness;
- Atualizações planejadas em ambientes Always On.

---

# 🎯 Objetivos

Ao concluir este módulo, desenvolvi conhecimentos para:

- Compreender os conceitos de Alta Disponibilidade.
- Diferenciar soluções de HA e DR.
- Configurar e administrar Log Shipping.
- Realizar sincronização por Backup e Restore.
- Recuperar a sincronização de servidores secundários.
- Executar troca de papéis no Log Shipping.
- Compreender a arquitetura do Database Mirroring.
- Conhecer os modos High-Safety e High-Performance.
- Compreender o funcionamento do Always On Availability Groups.
- Trabalhar com réplicas primárias e secundárias.
- Entender sincronização síncrona e assíncrona.
- Executar Failover.
- Trabalhar com Listener.
- Configurar réplicas para leitura.
- Implementar Read-Only Intent Routing.
- Monitorar o estado de sincronização das réplicas.
- Trabalhar com Cloud Witness.
- Executar procedimentos de atualização em ambiente Always On.

---

# 📂 Estrutura do projeto

```text
modulo-11-alta-disponibilidade/
│
├── 📄 1 - Introdução à Alta Disponibilidade.pdf
│
├── 📄 2 - Log Shipping.pdf
├── 📜 02_log_shipping.sql
├── 📜 03_log_shipping.sql
├── 📜 04_log_shipping_troca_de_papeis.sql
│
├── 📄 5 - Database Mirroring.pdf
├── 📜 05_database_mirroring.sql
│
├── 📄 6 - Always On Introdução.pdf
│
├── 📜 09_alwayson.sql
├── 📄 M11A09 AlwaysOn.txt
│
├── 📜 10_alwayson_replica_leitura.sql
└── 📜 11_alwayson_atualizacao.sql
```

---

# 📚 Conteúdo estudado

## 🚦 Introdução à Alta Disponibilidade

A primeira aula apresenta as principais tecnologias estudadas no módulo:

- Failover Cluster;
- Database Mirroring;
- Always On Availability Groups;
- Log Shipping.

Também são apresentadas diferentes arquiteturas e seus componentes.

---

# 🚚 Log Shipping

O **Log Shipping** realiza a sincronização utilizando o processo de:

```text
Servidor Primário
       │
       │ Backup do Log
       ▼
   Arquivo .TRN
       │
       │ Cópia
       ▼
Servidor Secundário
       │
       │ Restore
       ▼
Banco Secundário
```

O processo utiliza Jobs para:

1. Backup do Log no servidor primário.
2. Cópia do backup para o servidor secundário.
3. Restore do backup no servidor secundário.

### ⚙️ Configuração

Foram estudados requisitos como:

- Recovery Model `FULL`;
- criação de pasta compartilhada;
- permissões para a conta de serviço do SQL Server Agent;
- Backup FULL;
- Restore utilizando `NORECOVERY`;
- habilitação do Log Shipping.

### 🔄 Sincronização

Também foi realizado um laboratório para restabelecer a sincronização do servidor secundário utilizando Backup FULL e Restore.

### 🔁 Troca de papéis

Foi realizado um laboratório de **Role Switch**, demonstrando a troca entre servidor Primário e Secundário por meio de Backup e Restore.

---

# 🔄 Database Mirroring

O **Database Mirroring** foi estudado como uma tecnologia de Alta Disponibilidade disponível a partir do SQL Server 2005 SP1 e posteriormente substituída pelo Always On a partir do SQL Server 2012.

### 🏗 Arquitetura

```text
             ┌───────────────┐
             │    Witness    │
             │   (Opcional)  │
             └───────┬───────┘
                     │
          ┌──────────┴──────────┐
          │                     │
┌─────────▼─────────┐  ┌────────▼─────────┐
│      Principal     │  │      Mirror      │
│      Online        │  │      Offline     │
└────────────────────┘  └──────────────────┘
```

### ⚙️ Modos estudados

#### 🔒 High-Safety

- Sincronização síncrona.
- Disponível na edição Standard segundo o material.
- Mantém os bancos sincronizados.
- Pode gerar impacto no desempenho.

#### ⚡ High-Performance

- Sincronização assíncrona.
- Disponível na edição Enterprise segundo o material.
- A transação é finalizada primeiro no Principal.
- Não garante que os dois bancos estejam imediatamente iguais.

### 🔧 Configuração

Foram estudadas etapas envolvendo:

- Recovery Model FULL;
- Backup FULL;
- Backup do Log;
- Restore no Mirror;
- Endpoints;
- permissões de conexão;
- habilitação da sessão de Mirroring.

---

# ⚡ Always On Availability Groups

O **Always On Availability Groups** foi o principal foco prático do módulo.

O material apresenta o Always On como uma solução de Alta Disponibilidade disponível a partir do SQL Server 2012, utilizando o serviço de Cluster do Windows.

Entre os recursos estudados estão:

- Failover automático;
- Failover manual;
- réplicas secundárias;
- consultas em réplicas secundárias;
- backups em réplicas secundárias;
- sincronização síncrona;
- sincronização assíncrona;
- Listener;
- Read-Only Intent Routing.

---

# 🔄 Modos de sincronização

## 🔒 Síncrono

Fluxo:

```text
Primary
   │
   │ Alteração
   ▼
Secondary
   │
   │ ACK
   ▼
Primary
   │
   ▼
Aplicação
```

A réplica secundária confirma a aplicação da alteração antes da confirmação da operação para a aplicação.

**Benefício:** maior proteção dos dados.

**Consideração:** pode gerar impacto no desempenho.

---

## ⚡ Assíncrono

```text
Primary ─────────► Secondary
   │
   └──► Aplicação
```

A réplica primária pode finalizar a operação antes da confirmação da réplica secundária.

**Benefício:** menor impacto na performance.

**Consideração:** existe possibilidade de diferença temporária entre as réplicas.

---

# 🌐 Listener

O **Listener** fornece um nome único para que as aplicações acessem o Availability Group.

```text
              Aplicação
                  │
                  ▼
              Listener
                  │
          ┌───────┴───────┐
          ▼               ▼
       Primary         Secondary
```

Durante um Failover, o Listener direciona as conexões para a nova réplica primária, evitando a necessidade de alteração da aplicação.

---

# 📖 Réplicas de leitura

O módulo também apresenta a utilização de réplicas secundárias para atividades de leitura.

Entre os benefícios estudados:

- distribuição da atividade de leitura;
- redução da carga sobre o servidor de produção;
- melhor utilização do hardware;
- execução de consultas;
- execução de backups.

---

# 🔀 Read-Only Intent Routing

Foi realizado um laboratório específico para configurar o roteamento de conexões somente leitura.

A aplicação pode informar sua intenção por meio de:

```text
ApplicationIntent=ReadOnly
```

As réplicas são configuradas com:

```sql
SECONDARY_ROLE
(
    ALLOW_CONNECTIONS = ALL
)
```

e recebem URLs para o roteamento de conexões.

Também foi configurada uma lista de roteamento para direcionar as conexões de leitura para a réplica secundária adequada.

O laboratório inclui testes após Failover para validar o comportamento do roteamento.

---

# 🔄 Failover

Foram realizados testes de Failover entre as réplicas.

Comando utilizado no laboratório:

```sql
ALTER AVAILABILITY GROUP [AG-CursoAdm] FAILOVER
```

Após o Failover, foram realizadas consultas para verificar o servidor que assumiu o papel de Primary:

```sql
SELECT @@SERVERNAME
```

Esse procedimento permitiu observar na prática a troca de papéis entre as réplicas.

---

# 📊 Monitoramento das réplicas

Foram utilizadas DMVs para acompanhar o estado do Availability Group.

Entre as informações monitoradas estão:

- servidor da réplica;
- estado de sincronização;
- saúde da sincronização;
- suspensão do movimento de dados;
- taxa de envio do Log;
- fila de Log;
- taxa de Redo.

Exemplo utilizado nos laboratórios:

```sql
SELECT
    b.replica_server_name,
    a.synchronization_state_desc,
    a.synchronization_health_desc,
    a.is_suspended
FROM sys.dm_hadr_database_replica_states a
JOIN sys.availability_replicas b
    ON b.replica_id = a.replica_id
WHERE a.database_id = DB_ID('HandsOn');
```

---

# ☁️ Cloud Witness

O módulo também apresenta a utilização de **Cloud Witness** para o quorum do cluster.

Foi apresentado o comando PowerShell:

```powershell
Set-ClusterQuorum -CloudWitness `
    -AccountName "Storage_Account_Name" `
    -AccessKey "Storage_Account_Access_Key"
```

Esse procedimento utiliza um Storage Account como Witness do cluster.

---

# 🔧 Atualização em ambiente Always On

O último laboratório apresenta um procedimento de atualização planejada em ambiente **Always On no Azure**.

A sequência estudada foi:

1. Desabilitar o Failover Automático.
2. Suspender o movimento de dados para a réplica secundária.
3. Aplicar a atualização no secundário.
4. Retomar o movimento de dados.
5. Verificar se a réplica está sincronizada.
6. Realizar Failover para o secundário.
7. Repetir o procedimento no outro servidor.

Para suspender o movimento de dados:

```sql
ALTER DATABASE HandsOn
SET HADR SUSPEND;
```

Para retomar:

```sql
ALTER DATABASE HandsOn
SET HADR RESUME;
```

E para executar o Failover:

```sql
ALTER AVAILABILITY GROUP [AG-CursoAdm]
FAILOVER;
```

Esse laboratório demonstra uma abordagem prática para realizar manutenção de forma controlada em um ambiente de alta disponibilidade.

---

# 🛠 Ferramentas utilizadas

| Tecnologia | Utilização |
|---|---|
| Microsoft SQL Server | Banco de dados |
| SQL Server Management Studio | Administração |
| T-SQL | Configuração e administração |
| SQL Server Agent | Automação do Log Shipping |
| Always On | Alta Disponibilidade |
| Availability Groups | HA e DR |
| Windows Failover Cluster | Clusterização |
| PowerShell | Administração do Cluster |
| Azure | Ambiente de laboratório |
| DMVs | Monitoramento |

---

# 📜 Scripts desenvolvidos

| Script | Finalidade |
|---|---|
| `02_log_shipping.sql` | Configuração do Log Shipping |
| `03_log_shipping.sql` | Restabelecimento da sincronização |
| `04_log_shipping_troca_de_papeis.sql` | Troca de papéis no Log Shipping |
| `05_database_mirroring.sql` | Laboratório de Database Mirroring |
| `09_alwayson.sql` | Laboratório de Always On |
| `10_alwayson_replica_leitura.sql` | Configuração de réplica para leitura |
| `11_alwayson_atualizacao.sql` | Procedimento de atualização em Always On |

---

# 🧠 Principais conceitos aprendidos

### Alta Disponibilidade

- High Availability (HA)
- Disaster Recovery (DR)
- Failover
- Failback
- Quorum
- Witness

### Log Shipping

- Transaction Log Backup
- Restore
- NORECOVERY
- Recovery Model FULL
- Role Switch
- SQL Server Agent

### Database Mirroring

- Principal
- Mirror
- Witness
- High-Safety
- High-Performance
- Endpoints

### Always On

- Availability Group
- Primary Replica
- Secondary Replica
- Synchronous Commit
- Asynchronous Commit
- Automatic Failover
- Manual Failover
- Listener
- Read-Only Intent Routing
- Cloud Witness
- HADR
- Réplicas de leitura

---

# 🧠 Competências desenvolvidas

Ao finalizar este módulo, desenvolvi conhecimentos práticos em:

- ✅ Administração de ambientes de Alta Disponibilidade.
- ✅ Configuração de Log Shipping.
- ✅ Administração de servidores Primário e Secundário.
- ✅ Recuperação de sincronização.
- ✅ Troca de papéis.
- ✅ Database Mirroring.
- ✅ Always On Availability Groups.
- ✅ Configuração de réplicas.
- ✅ Sincronização síncrona e assíncrona.
- ✅ Failover.
- ✅ Listener.
- ✅ Read-Only Intent Routing.
- ✅ Monitoramento de sincronização.
- ✅ Cloud Witness.
- ✅ Procedimentos de manutenção em ambientes HA.

---

# 💼 Aplicações práticas

Os conhecimentos deste módulo podem ser aplicados em ambientes corporativos que necessitam de:

- Alta disponibilidade de bancos de dados;
- redução de indisponibilidade;
- continuidade de negócios;
- Disaster Recovery;
- servidores redundantes;
- distribuição de consultas;
- manutenção planejada;
- recuperação após falhas;
- monitoramento de réplicas;
- estratégias de proteção de dados.

---

# 🚀 Resultados obtidos

Ao concluir este módulo, desenvolvi uma visão mais ampla sobre **arquiteturas de Alta Disponibilidade e Disaster Recovery no SQL Server**, passando desde soluções tradicionais, como Log Shipping e Database Mirroring, até a utilização de **Always On Availability Groups**.

Os laboratórios permitiram praticar não apenas a configuração inicial, mas também operações importantes para um ambiente corporativo, como:

- sincronização;
- recuperação de réplicas;
- troca de papéis;
- Failover;
- monitoramento;
- roteamento de conexões de leitura;
- utilização de Witness;
- manutenção planejada.

Esse conjunto de conhecimentos fortalece minha preparação para atuar em atividades relacionadas à administração e sustentação de ambientes **SQL Server**.

---

# ⭐ Destaques do módulo

```text
                    SQL SERVER HA / DR
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
   Log Shipping      Mirroring          Always On
        │                  │                  │
   Backup/Restore     Principal/Mirror    AG / Replicas
        │                  │                  │
   Role Switch          Witness          Failover
                                             │
                                    ┌────────┴────────┐
                                    │                 │
                                 Listener       Read-Only
                                                   Routing
```

---

# 👨‍💻 Autor

**Andrey Andrade**

📚 **Curso:** Comunidade SQL Server Expert  
👨‍🏫 **Instrutor:** Prof. Landry  

🎯 **Objetivo:** desenvolver competências práticas em Administração de Banco de Dados SQL Server, construindo um portfólio profissional voltado para oportunidades de **DBA SQL Server**, Administração de Banco de Dados e áreas relacionadas à infraestrutura de dados.

---

<div align="center">

### 🚀 SQL Server Expert — Alta Disponibilidade

**Estudo • Prática • Administração • Alta Disponibilidade • Disaster Recovery**

</div>