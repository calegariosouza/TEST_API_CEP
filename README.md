# 🔍 TEST_API_CEP

![Robot Framework](https://img.shields.io/badge/Robot_Framework-000000?style=flat&logo=robot-framework&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.11+-3776AB?style=flat&logo=python&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub_Actions-2088FF?style=flat&logo=github-actions&logoColor=white)

Testes automatizados de APIs de consulta de CEP utilizando **Robot Framework**. O projeto valida os endpoints das APIs [ViaCEP](https://viacep.com.br) e [OpenCEP](https://opencep.com) com uma lista de CEPs de cidades mineiras.

---

## 📁 Estrutura

```
TEST_API_CEP/
├── tests/
│   ├── viaCep.robot           # Suite de testes para a API ViaCEP
│   ├── openCep.robot          # Suite de testes para a API OpenCEP
│   └── ceps.csv               # Base de CEPs utilizados nos testes
└── .github/
    └── workflows/
        └── robot_cep_test.yml # Pipeline CI/CD
```

---

## ✅ O que é testado

Para cada CEP no arquivo `ceps.csv`, os testes verificam:

- Status HTTP `200` na resposta
- Presença dos campos `cep`, `localidade` e `uf` no JSON retornado
- Tratamento adequado de CEPs não encontrados (sem falha no pipeline)

---

## 🚀 Como executar

### Pré-requisitos

```bash
pip install robotframework robotframework-requests
```

### Rodando os testes

```bash
# ViaCEP
cd tests
robot --outputdir ../results/viacep viaCep.robot

# OpenCEP
cd tests
robot --outputdir ../results/opencep openCep.robot
```

> Os resultados (`log.html`, `report.html`, `output.xml`) serão gerados na pasta `results/`.

---

## ⚙️ CI/CD

O pipeline executa automaticamente via **GitHub Actions** nos seguintes gatilhos:

| Gatilho | Descrição |
|---|---|
| `push` | Branches `main` e `develop` |
| `schedule` | A cada 10 minutos (cron) |
| `workflow_dispatch` | Execução manual |

Após os testes, os resultados são publicados como artefatos e um resumo é enviado para o **Microsoft Teams** via webhook.

> ⚠️ Para ativar a notificação do Teams, configure o secret `TEAMS_WEBHOOK_URI` nas configurações do repositório.
