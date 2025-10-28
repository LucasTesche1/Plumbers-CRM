# 🧰 Plumbers CRM — Salesforce Field Service Management System

> CRM completo desenvolvido na plataforma **Salesforce**, voltado à **gestão de serviços de encanamento** (Plumbing Services).  
> O projeto combina automação de processos, experiência mobile para técnicos, relatórios dinâmicos e governança de dados — seguindo padrões **SFDX**, **Flows**, **LWC**, e **Apex** para um produto final funcional e escalável.

---

## Visão Geral do Projeto

O **Plumbers CRM** foi criado como um **projeto de portfólio completo** com foco em demonstrar domínio sobre o ecossistema Salesforce, desde a modelagem de dados até deploy.  

Ele simula um **sistema de atendimento de encanadores**, em que solicitações de clientes são recebidas, atribuíções à técnicos de campo, executadas com controle de materiais e custos, e monitoradas por dashboards gerenciais.

### 🔹 Objetivo
Criar um CRM de ponta a ponta que represente um ciclo real de **Service Management**, incluindo intake público, automações inteligentes e acompanhamento via relatórios.

------

## Funcionalidades Principais

### 👷‍♂️ Gestão de Ordens de Serviço
- Cadastro de **Work Orders** com cliente, endereço, custo estimado e status.
- Controle de **materiais utilizados** por trabalho (com preço e quantidade).
- Atribuição a **técnicos por território**.
- Controle de **custos finais** e validação da margem de variação de ±15%.

### 💬 Intake Público (LWC)
- Formulário público desenvolvido em **Lightning Web Components** para registro de novos atendimentos.
- Criação automática de **Contact** e **Work Order**.
- Envio de **confirmação por e-mail** e feedback visual ao usuário.

### 🔄 Automação & Roteamento (Flow)
- Fluxos automatizados para:
  - Enfileiramento inicial (`Plumbers_Queue`).
  - Atribuição de ordens conforme **território** e disponibilidade.
  - Reatribuição manual (via **Quick Actions** no Lightning Console).

### 📱 Aplicativo do Técnico (LWC Mobile)
- Interface mobile-first para técnicos de campo.
- Listagem de ordens atribuídas.
- Registro de materiais, horas trabalhadas e descrição do serviço.
- Botão **“Finalizar Job”** que executa o cálculo de custo e dispara automações.

### 💰 Regras de Cálculo e Exceções
- Cálculo automático do **Final Cost** (materiais + horas + fixos).
- Validação de variação de custo (±15% da estimativa).
- Notificação ao gerente via **Chatter** ou e-mail.

### 📊 Dashboards e Relatórios
- Relatórios:
  - **Open Work Orders by Territory**
  - **Jobs Completed by Technician**
  - **Cost Variance Exceptions**
- Dashboard com KPIs:
  - Total de jobs realizados
  - Tempo médio de execução
  - Percentual de exceções
  - Materiais mais utilizados

------

## Arquitetura Técnica

### 🔹 Stack e Ferramentas
- **Salesforce SFDX (Salesforce DX)**
- **Lightning Web Components (LWC)**
- **Flow Builder / Process Automation**
- **Apex (lógica de cálculo e automação)**
- **Dynamic Dashboards & Reports**


### 🔹 Objetos Customizados
| Objeto | Descrição | Principais Campos |
|--------|------------|------------------|
| `Work_Order__c` | Ordem de serviço principal | Customer, Address, Status, Estimated_Cost__c, Final_Cost__c, Assigned_Tech__c, Territory__c |
| `Material_Item__c` | Materiais usados no serviço | Product_Name, Quantity, Unit_Price, Line_Total |
| `Tech_Profile__c` | Perfil do técnico | User__c, Jobs_Completed__c, Territory__c |
| `Territory__c` | Área de atendimento | Name, Priority |

---

### 🔐 Segurança e Permissões
- **Roles:** Admin, Manager, Field_Tech, Agent  
- **Permission Sets:**  
  - *Tech_Permissions* — Criação/Edição de Work Orders e Material Items  
  - *Agent_Permissions* — Acesso à criação via intake  
  - *Manager_Permissions* — Acesso a relatórios e exceções  
- **Sharing Model:** privado por território, com regras específicas para supervisores.

---

## 🔹 Integrações Futuras
-  **API de Preços de Peças** (Named Credential + Apex Callout)  
-  **Integração com Google Maps** para estimar rotas e tempos (ETA).  
-  **Integração LMS** para atribuição de treinamentos automáticos em casos de exceção.

---

## 🔹 Testes e QA
- Cobertura mínima de **75%** em classes Apex.
- **Testes manuais** realizados com cenários como:
  - Criação de Work Order via LWC.
  - Cálculo de custo final.
  - Visualização de relatórios e dashboards.

---

| Fase | Descrição                        | Status         |
| ---- | -------------------------------- | ------------   |
| 0    | Preparação do repositório e SFDX | ✅            |
| 1    | Modelagem de dados               | ✅            |
| 2    | Permissões e segurança           | ✅            |
| 3    | Intake público (LWC)             | ✅            |
| 4    | Roteamento e atribuição (Flow)   | ✅            |
| 5    | App do técnico (LWC)             | ✅            |
| 6    | Cálculo e exceções               | ✅            |
| 7    | Relatórios e dashboards          | ✅            |
| 8    | QA                               | ✅            |

## 👨‍💻 Autor

Lucas Tesche
Salesforce Developer | CRM | Automação de Processos
LinkedIn : https://www.linkedin.com/in/lucastesche1/

