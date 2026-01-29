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
- PostgreSQL  
- ActiveJob + Sidekiq  

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

- **GET /api/profiles** — listagem paginada  
- **GET /api/profiles/:id** — detalhes de um perfil  

## Possíveis Melhorias

- Testes automatizados  
- Cache de resultados  
- Uso da API oficial do GitHub  
- Rate limiting  
- Monitoramento e alertas de falhas  
