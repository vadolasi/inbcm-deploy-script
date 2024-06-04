# Script de Deploy do INBCM

Este script foi criado para facilitar o deploy do INBCM. Ele é capaz de clonar os repositórios necessários, criar os containers e subir a aplicação, e executa um consumidor de webhook para atualizar a aplicação automaticamente a cada push no repositório.

## Pré-requisitos

Para garantir o funcionamento correto deste script, a máquina onde será realizado o deploy precisa atender aos seguintes requisitos:

- A máquina deve ser acessível via internet.
- As portas 80 (TCP) e 443 (TCP e UDP) devem estar liberadas.
- É necessáio um domínio válido apontando a máquina onde será realizado o deploy. Além do dominio principal, é necessário os sequintes subdomínios:
  - admin (admin.seudominio.com)
  - traefik (traefik.seudominio.com)

### Instalações Necessárias

Certifique-se de que as seguintes ferramentas estão instaladas na sua máquina:

- [Docker](https://docs.docker.com/get-docker/) e [Docker Compose](https://docs.docker.com/compose/install/)
- [Git](https://git-scm.com/downloads)

## Configuração de Chave SSH

Também é necessário ter acesso ao repositório privado do INBCM no GitHub. Para isso, você deve configurar a chave SSH no seu computador. Siga os passos abaixo para configurar:

1. Gerar uma nova chave SSH id_ed25519:

Se você ainda não tem uma chave SSH, gere uma nova com o comando:

```bash
ssh-keygen -t ed25519 -C "seu_email@example.com"
Siga as instruções e pressione Enter para aceitar os padrões recomendados. Isso criará uma nova chave SSH em ~/.ssh/id_ed25519.
```

2. Adicionar a chave SSH ao agente SSH:

Inicie o agente SSH e adicione a sua chave SSH:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

Adicionar a chave SSH à sua conta GitHub:

3. Copie o conteúdo da sua chave **pública** e adicione à sua conta GitHub:

```bash
cat ~/.ssh/id_ed25519.pub
```

Vá até a página de configurações de SSH do GitHub, clique em "New SSH key", cole a chave pública no campo "Key" e dê um título para a chave.

## Configuração do Script

Antes de executar o script, é necessário configurar algumas variáveis de ambiente. Sendo elas:

- `DOMAIN`: Domínio que será utilizado para acessar a aplicação.
- `EMAIL`: E-mail que será utilizado para gerar o certificado SSL.
- `GITHUB_SECRET`: Token para o webhook do GitHub.

Você pode salvar essas variáveis em um arquivo `.env` na raiz do projeto. Ou difini-las de maneira tradicional via terminal.

```bash
export DOMAIN=seu-dominio.com
export EMAIL=seu@email.com
```

## Configuração dos containers

Os containers do frontend (tanto o público quanto o admin) não precisam de nenhuma configuração adicional. Já o container do backend precisa de algumas variáveis de ambiente para funcionar corretamente. Que você pode conferir [aqui](https://github.com/Nocs-lab/inbcm-backend?tab=readme-ov-file#3configurando-o-arquivo-env). Você pode salvar essas variáveis em um arquivo `.env` na raiz do projeto ou dentro da pasta `inbcm-backend`, ou defini-las de maneira tradicional via terminal.

## Utilização do Script

```bash
Dê permissão de execução:

```bash
chmod +x setup.sh
```

Execute o script com o comando:

```bash
./setup.sh
```

Verificar se o Docker está instalado e em execução.
Verificar se a configuração SSH está correta.
Criar a rede Docker traefik.
Subir os containers iniciais com Docker Compose.
Clonar os repositórios necessários e construir os containers para cada um.
Subir o dashboard do Traefik.

Após a execução do script, é esperado que a aplicação INBCM estará em execução e acessível através dos seguintes endereços:

- https://[seu dominio] (Interface pública para os museus enviarem as declarações)
- https://admin.[seu dominio] (Interface administrativa)
