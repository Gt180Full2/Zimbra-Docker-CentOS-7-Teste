[![](https://images.microbadger.com/badges/image/busybox42/zimbra-docker-centos.svg)](https://microbadger.com/images/busybox42/zimbra-docker-centos "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/busybox42/zimbra-docker-centos.svg)](https://microbadger.com/images/busybox42/zimbra-docker-centos "Get your own version badge on microbadger.com")

# Zimbra
Neste repositório, você encontrará como instalar o Zimbra no Docker

# Docker
## Como instalar o Docker
Mantenha-se informado das alterações no Zimbra Wiki - https://wiki.zimbra.com/wiki/Deploy_Zimbra_Collaboration_using_docker

Depende do seu sistema operacional, você precisa instalar o Docker de maneiras diferentes, consulte o site oficial - https://docs.docker.com/engine/installation/

Uma das vantagens do uso do docker é que o sistema operacional host não importa, os contêineres funcionarão em qualquer plataforma.

## Download da imagem
A primeira etapa é inserir esta imagem no ambiente do docker, para isso basta executar a próxima:
```bash
docker pull 
```

## Criando contêiner Zimbra
Agora que temos uma imagem chamada "", podemos executar uma janela de encaixe com alguns parâmetros especiais, como este:
```bash
docker run -p 25:25 -p 80:80 -p 465:465 -p 587:587 -p 110:110 -p 143:143 -p 993:993 -p 995:995 -p 443:443 -p 8080:8080 -p 8443:8443 -p 7071:7071 -p 9071:9071 -p 514:514 -h zimbra.dockertest.io --dns 127.0.0.1 --dns 8.8.8.8 -i -t -e PASSWORD=Zimbra2019 zimbra_docker_centos
```
Como você pode ver, informamos ao contêiner as portas que queremos expor e em qual porta também especificamos o nome do host do contêiner, a senha da conta de administrador do Zimbra e a imagem a ser usada.

É isso aí! Agora você pode visitar o IP do seu Docker Machine usando HTTPS ou experimentar o Admin Console com HTTPS e porta 7071.

## Contribua para o projeto
Se você gosta de contribuir com o projeto, é livre para fazê-lo, basta dividir este repositório e enviar as alterações.

# Processo manual - não é realmente recomendado

<details>
  <summary>Processo manual</summary>

## Criando a imagem do Zimbra

  O conteúdo do Dockerfile e do start.sh é baseado no próximo script - ZimbraEasyInstall. O Dockerfile cria uma imagem do CentOS 7 e instala nele todas as dependências do SO que o Zimbra precisa, quando o contêiner é iniciado, inicia automaticamente com o script start.sh que cria um arquivo de configuração automática que é injetado durante a instalação do zimbra.

### Usando git
Baixe no github, você precisará do git instalado no seu sistema operacional

```bash
git clone 
```
### Usando o wget
Para quem deseja usar o wget, siga as próximas instruções para baixar o pacote Zimbra-docker. Pode ser necessário instalar e descompactar o wget no seu sistema operacional
```bash
wget 
unzip master.zip
```

### Crie a imagem usando o Dockerfile
O `Makefile` no diretório docker / fornece uma maneira conveniente de criar sua imagem do docker. Você precisará fazer no seu sistema operacional. Apenas rode

```bash
cd zimbra-docker-centos/docker
sudo make
```

O nome da imagem padrão é zimbra_docker.

### Implantar o contêiner do Docker
Agora, implante o contêiner com base na imagem anterior. Além de publicar as portas do Zimbra Collaboration, o nome do host e o DNS adequado, como você deseja usar o bind como um servidor de nomes DNS local dentro do contêiner, também enviaremos a senha que queremos para o nosso Servidor Zimbra, como senha de administrador, caixa de correio, LDAP, etc .: Sintaxe:
```bash
docker run -p PORTS -h HOSTNAME.DOMAIN --dns DNSSERVER -i -t -e PASSWORD=YOURPASSWORD NAMEOFDOCKERIMAGE
```
Exemplo:
```bash
docker run -p 25:25 -p 80:80 -p 465:465 -p 587:587 -p 110:110 -p 143:143 -p 993:993 -p 995:995 -p 443:443 -p 8080:8080 -p 8443:8443 -p 7071:7071 -p 9071:9071 -h zimbra-docker.zimbra.io --dns 127.0.0.1 --dns 8.8.8.8 -i -t -e PASSWORD=Zimbra2019 zimbra_docker_centos
```
Dependendo das configurações de limites, pode ser necessário adicionar uma opção --ulimits.
Exemplo:
```bash
docker run -p 25:25 -p 80:80 -p 465:465 -p 587:587 -p 110:110 -p 143:143 -p 993:993 -p 995:995 -p 443:443 -p 8080:8080 -p 8443:8443 -p 7071:7071 -p 9071:9071 -h zimbra-docker.zimbra.io --dns 127.0.0.1 --dns 8.8.8.8 -i -t -e PASSWORD=Zimbra2019 --ulimit nofile=524288:524288 zimbra_docker_centos
```

Isso criará o contêiner em alguns segundos e executará automaticamente o start.sh:

* Instale um servidor DNS com base no dnsmasq
* Configure todo o servidor DNS para resolver automaticamente o MX interno e o nome do host que definimos ao iniciar o contêiner.
* Instale um novo Zimbra Collaboration 8.8.8 no Zimbra Chat and Drive!
* Crie 2 arquivos para automatizar a instalação do Zimbra Collaboration, as teclas digitadas e os config.defaults.
* Inicie a instalação do Zimbra baseada apenas em .install.sh -s
* Injete no arquivo config.defaults todos os parâmetros configurados automaticamente com o nome do host, domínio, IP e senha que você definiu anteriormente.

O script leva alguns minutos, dependendo da velocidade da Internet e dos recursos.

</details>

## Problemas conhecidos

Após a instalação automatizada do Zimbra, se você fechar ou sair do console bash do contêiner, o contêiner do docker poderá sair e permanecer no estado parado, basta executar os próximos comandos para iniciar o seu Zimbra Container:

```bash
docker ps -a 
docker start YOURCONTAINERID
docker exec -it YOURCONTAINERID bash
su - zimbra
zmcontrol restart
```
