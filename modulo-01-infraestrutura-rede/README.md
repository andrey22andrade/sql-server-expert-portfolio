# 📌 Módulo 01 — Introdução à Infraestrutura de Rede

---

## 📖 Contexto

Este módulo apresenta os fundamentos de infraestrutura de rede e ambiente computacional necessários para o funcionamento de sistemas como o SQL Server.

Antes de trabalhar diretamente com banco de dados, é essencial entender onde ele está hospedado, como se comunica com outras aplicações e quais camadas garantem sua disponibilidade e segurança.

O conteúdo aborda desde conceitos de redes (TCP/IP, DNS, portas) até infraestrutura (On-Premise vs Nuvem, Windows Server e Virtualização), formando a base para atuação em ambientes corporativos.

---

## 🎯 Objetivo do Módulo

Compreender como funciona a infraestrutura por trás de um banco de dados, incluindo:

- Onde o SQL Server pode ser hospedado  
- Como ocorre a comunicação entre sistemas  
- Como controlar acessos e segurança  
- Como simular ambientes reais utilizando máquinas virtuais  

---

## 🗂️ Estrutura do Módulo

- 📄 Documentação: Material teórico do curso (não incluído no repositório)
- 💻 Scripts SQL: Não aplicável neste módulo (conteúdo conceitual)

---

## 🧩 Conceitos Abordados

### ☁️ On-Premise vs Computação em Nuvem

- **On-Premise**: infraestrutura local, onde a empresa é responsável por hardware, manutenção e gestão.
- **Cloud Computing**: uso de recursos sob demanda via internet, com escalabilidade e pagamento conforme uso.

**Modelos importantes:**
- CapEx (On-Premise)
- OpEx (Cloud)
- IaaS, PaaS, SaaS
- Cloud Pública, Privada e Híbrida

---

### 🌐 Redes de Computadores e TCP/IP

Uma rede de computadores permite a comunicação entre dispositivos através de protocolos.

**Principais conceitos:**
- Endereço IP (IPv4 e IPv6)
- Subredes (CIDR)
- Portas de comunicação (0–65535)
- Protocolo TCP (conexão) vs UDP (sem conexão)

**Exemplo importante:**
- SQL Server utiliza a porta **1433/TCP**

---

### 🔎 DNS e DHCP

- **DNS (Domain Name System)**: traduz nomes (ex: google.com) para IPs
- **DHCP**: distribui automaticamente endereços IP na rede

Esses serviços são essenciais para funcionamento de aplicações em rede.

---

### 🔥 Firewall

Responsável por controlar o tráfego de rede com base em regras.

**Funções principais:**
- Permitir ou bloquear conexões
- Proteger contra acessos não autorizados

**Exemplo prático:**
- Liberação da porta 1433 é necessária para acesso remoto ao SQL Server

---

### 🖥️ Windows Server e Gerenciamento de Contas

Sistema operacional voltado para ambientes corporativos.

**Principais conceitos:**

- **Contas Locais**:
  - Existem apenas na máquina
  - Difíceis de gerenciar em escala

- **Active Directory (AD)**:
  - Gerenciamento centralizado de usuários
  - Permite autenticação única (SSO)
  - Utiliza Domain Controller (DC)

---

### 💻 Virtualização e Máquinas Virtuais

Permite criar ambientes isolados dentro de um único computador físico.

**Ferramentas abordadas:**
- Hyper-V (Microsoft)
- VirtualBox (Oracle)
- VMware Workstation

**Benefícios:**
- Simulação de ambientes corporativos
- Testes seguros
- Economia de hardware
- Criação de laboratórios locais

---

### ⚙️ Administração de Máquinas Virtuais

Principais operações:

- **Save**: salva o estado atual da VM
- **Checkpoint**: cria ponto de restauração
- **Export/Import**: backup e recuperação de VMs

---

## 🌍 Aplicação Prática

Os conceitos deste módulo são amplamente utilizados no dia a dia de profissionais de dados e infraestrutura.

**Exemplos reais:**

- Falha de conexão com SQL Server causada por porta bloqueada no firewall  
- Problemas de acesso relacionados a DNS ou IP incorreto  
- Gerenciamento de usuários via Active Directory em ambientes corporativos  
- Criação de ambientes de teste utilizando máquinas virtuais  
- Migração de ambientes On-Premise para Cloud  

---

## 🧠 Aprendizados

- Entendimento da comunicação entre aplicações e banco de dados  
- Importância da infraestrutura para funcionamento do SQL Server  
- Noções de segurança de rede (firewall e portas)  
- Diferença entre ambientes locais e em nuvem  
- Base para criação de laboratórios com máquinas virtuais  
- Visão mais ampla além de queries e manipulação de dados  

---

## 📚 Fonte de Estudo

Conteúdo baseado no módulo de Infraestrutura de Rede do curso Comunidade SQL Server Expert, adaptado e documentado com foco prático para aplicação profissional.

---
