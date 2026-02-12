# Indexador de Perfis do GitHub

Aplicação desenvolvida em **Ruby on Rails** para indexação de perfis públicos do GitHub, com coleta automática de dados via scraping e disponibilização por **API REST**.

## Objetivo

Permitir o cadastro de perfis do GitHub a partir de uma URL pública, coletando dados relevantes de forma assíncrona e expondo essas informações via interface web e API.

## Funcionalidades

- Cadastro de perfis via URL do GitHub  
- Web scraping de dados públicos:
  - username, followers, following, stars  
  - contribuições no último ano  
  - avatar, localização e organizações  
- Processamento assíncrono com controle de estado  
- Reprocessamento seguro em caso de falha  
- Interface web para listagem e visualização  
- API REST paginada para consumo externo  

## Tecnologias Utilizadas

- Ruby on Rails 8
- PostgreSQL + Redis
- ActiveJob + Sidekiq para filas
- Pagy 6 para paginação
- Faraday + Nokogiri para scraping HTTP/HTML
- Bootstrap, Sass e CSS Bundling
- ESBuild + Stimulus para JavaScript



## Web Scraping

Os dados são coletados diretamente a partir do HTML público do GitHub, utilizando seletores específicos.  
O processo é executado de forma assíncrona para não impactar a experiência do usuário.

## Processamento Assíncrono

O scraping roda em background utilizando **ActiveJob** com **Sidekiq**.  
Cada perfil possui um campo `scrape_status` com os seguintes estados:

- `pending`
- `processing`
- `success`
- `failed`

Há proteção contra concorrência e recuperação de jobs travados.

## API REST

| Método | Endpoint | Descrição |
| --- | --- | --- |
| GET | `/api/profiles` | Listagem paginada com filtros `q`, `status`, `per_page`. |
| GET | `/api/profiles/:id` | Detalhes completos do perfil informado. |
| POST | `/api/profiles` | Cria um novo perfil (`name`, `github_url`). |
| POST | `/api/profiles/:id/reprocess` | Reenfileira a coleta do perfil. |

Todas as respostas incluem metadados de paginação (`pagy`) e códigos HTTP apropriados.

## Configuração do Ambiente

1. **Dependências**
   - Ruby 3.3+
   - Node.js 20+
   - Yarn 1.x
   - PostgreSQL 14+ e Redis em execução
2. **Instalação**
   ```bash
   bundle install
   yarn install
   bin/rails db:setup
   ```

## Como subir a aplicação

- Servidor + build de assets em modo desenvolvimento:
  ```bash
  bin/dev
  ```
  O script inicia `rails server`, `esbuild` e `cssbundling` em paralelo.
- Alternativa manual:
  ```bash
  bin/rails server
  # em outro terminal
  yarn build --watch
  yarn build:css --watch
  ```
- **Sidekiq** é necessário para processar os scrapes:
  ```bash
  bundle exec sidekiq
  ```
  Certifique-se de ter o Redis ativo (`redis-server`).

## Testes da aplicação e da API

- Suite completa (inclui controllers web, modelos, jobs e API):
  ```bash
  bin/rails test
  ```
- Apenas testes da API (controllers JSON):
  ```bash
  bin/rails test test/controllers/api
  ```
- Para testar apenas o fluxo web:
  ```bash
  bin/rails test test/controllers/
  ```

Os testes utilizam **Minitest** (padrão do Rails); não há RSpec configurado.

## Melhorias já implementadas

- Testes automatizados (amém?) cobrindo controllers web/API, modelos e jobs. Use `bin/rails test`
- Paginação unificada (web e API) via Pagy
- Interface redesenhada com filtros, cards e status coloridos
- Seeds pré-configurados para perfis demonstrativos (os meus). (`db/seeds.rb`)

## Possíveis Melhorias

- Testes automatizados (não mais!)
- Cache de resultados  
- Uso da API oficial do GitHub  
- Rate limiting  
- Monitoramento e alertas de falhas  
