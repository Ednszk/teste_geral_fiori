# Claude Code + SAP via MCP (`mcp-abap-adt`) — passo a passo

Objetivo: permitir que o Claude Code, rodando **na sua máquina** (que já enxerga o SAP pela rede/VPN da empresa), leia objetos ABAP do sistema `lnl-s4h.opustech.com.br:5200` usando a mesma API REST do Eclipse ADT (`/sap/bc/adt`).

> **Limitação importante:** o servidor `mcp-abap-adt` é **somente leitura** (16 ferramentas de consulta). Ele lê código de classes, programas, CDS, tabelas, pacotes etc., mas **não cria, altera nem ativa** objetos. O fluxo de trabalho fica: o Claude lê o que existe no SAP → propõe/gera o código → você cola e ativa no Eclipse ADT.

---

## 1. Pré-requisitos

| Item | Como verificar |
| --- | --- |
| Acesso de rede ao SAP (rede interna ou VPN ligada) | Abrir `https://lnl-s4h.opustech.com.br:5200/sap/bc/adt/discovery` no navegador — deve pedir login |
| Serviço ICF `/sap/bc/adt` ativo | Transação `SICF` (se o Eclipse ADT já funciona, está ativo) |
| Usuário SAP de **desenvolvimento** (nunca produção) | Mesmo usuário que você usa no ADT, idealmente em DEV/QAS |
| Node.js **22 ou 24 LTS** | `node -v` |
| Claude Code CLI | `claude --version` |

### Instalar o Node.js
Baixe a versão LTS em https://nodejs.org e instale. Depois, em um terminal novo:
```bash
node -v   # deve mostrar v22.x ou v24.x
npm -v
```

### Instalar o Claude Code
```bash
npm install -g @anthropic-ai/claude-code
claude          # na primeira execução faz login com sua conta claude.ai
```
(Alternativa: extensão **Claude Code** no VS Code, que usa a mesma configuração de MCP.)

---

## 2. Testar o servidor MCP isoladamente (opcional, recomendado)

O pacote está publicado no npm, não é preciso clonar nada:
```bash
npx -y mcp-abap-adt
```
Se iniciar sem erro e ficar aguardando, está ok (encerre com `Ctrl+C`). As chamadas ao SAP só acontecem quando as credenciais estiverem configuradas (próximo passo).

---

## 3. Guardar as credenciais fora do repositório

**Nunca** coloque a senha em arquivo versionado. Defina variáveis de ambiente do usuário:

**Windows (PowerShell):**
```powershell
[Environment]::SetEnvironmentVariable("SAP_URL",      "https://lnl-s4h.opustech.com.br:5200", "User")
[Environment]::SetEnvironmentVariable("SAP_USERNAME", "SEU_USUARIO", "User")
[Environment]::SetEnvironmentVariable("SAP_PASSWORD", "SUA_SENHA",   "User")
[Environment]::SetEnvironmentVariable("SAP_CLIENT",   "100",         "User")   # ajuste o mandante
[Environment]::SetEnvironmentVariable("SAP_LANGUAGE", "PT",          "User")   # opcional
```
Feche e reabra o terminal/VS Code para as variáveis valerem.

**macOS / Linux** (em `~/.zshrc` ou `~/.bashrc`):
```bash
export SAP_URL="https://lnl-s4h.opustech.com.br:5200"
export SAP_USERNAME="SEU_USUARIO"
export SAP_PASSWORD="SUA_SENHA"
export SAP_CLIENT="100"
export SAP_LANGUAGE="PT"
```

Observações sobre `SAP_URL`:
- Apenas protocolo + host + porta, **sem** caminho (`/sap/...`), sem barra no final.
- Se a senha tiver `#`, use aspas.

---

## 4. Registrar o MCP no Claude Code

Escolha **uma** das opções.

### Opção A — pela linha de comando (só para você)
```bash
claude mcp add mcp-abap-adt --scope user \
  --env SAP_URL="$SAP_URL" \
  --env SAP_USERNAME="$SAP_USERNAME" \
  --env SAP_PASSWORD="$SAP_PASSWORD" \
  --env SAP_CLIENT="$SAP_CLIENT" \
  -- npx -y mcp-abap-adt
```
> No PowerShell, troque `$SAP_URL` por `$env:SAP_URL` (e assim por diante) e a quebra de linha `\` por `` ` ``.

### Opção B — arquivo `.mcp.json` na raiz do projeto (compartilhável com a equipe)
O Claude Code expande `${VAR}`, então o arquivo não contém segredos:
```json
{
  "mcpServers": {
    "mcp-abap-adt": {
      "command": "npx",
      "args": ["-y", "mcp-abap-adt"],
      "env": {
        "SAP_URL": "${SAP_URL}",
        "SAP_USERNAME": "${SAP_USERNAME}",
        "SAP_PASSWORD": "${SAP_PASSWORD}",
        "SAP_CLIENT": "${SAP_CLIENT}",
        "SAP_LANGUAGE": "${SAP_LANGUAGE}"
      }
    }
  }
}
```
Na primeira vez que abrir o Claude Code no projeto, ele pergunta se você aprova esse servidor MCP.

### Verificar
```bash
claude mcp list          # deve listar mcp-abap-adt como "connected"
```
Dentro do Claude Code, o comando `/mcp` mostra o status e as ferramentas disponíveis.

---

## 5. Certificado HTTPS (se der erro de TLS)

Se o SAP usa certificado de uma CA interna da empresa, o Node vai recusar a conexão (`unable to verify the first certificate` / `self-signed certificate`).

1. Exporte o certificado raiz da CA (pelo navegador, ou peça ao time de Basis) em formato **PEM** (`.pem`/`.crt` Base64).
2. Aponte o MCP para ele:
   ```
   SAP_CA_FILE=C:\certs\ca-empresa.pem
   ```
   (adicione como variável de ambiente e inclua `"SAP_CA_FILE": "${SAP_CA_FILE}"` no `env` da configuração).

Evite `TLS_REJECT_UNAUTHORIZED=0` — desliga a verificação de certificado; use apenas para diagnóstico rápido.

---

## 6. Ferramentas disponíveis

| Ferramenta | O que faz |
| --- | --- |
| `SearchObject` | Busca objetos por nome/padrão (ex.: `Z*WF*`) |
| `GetClass` / `GetInterface` | Código de classes e interfaces |
| `GetProgram` / `GetInclude` | Código de programas e includes |
| `GetFunctionGroup` / `GetFunction` | Grupos e módulos de função |
| `GetTable` / `GetStructure` / `GetTypeInfo` | Definições do DDIC |
| `GetTableContents` | Conteúdo de tabela (limite de linhas) |
| `GetCDSView` | Fonte DDL de CDS |
| `GetBehaviorDefinition` / `GetServiceDefinition` | Objetos RAP (BDEF/SRVD) |
| `GetPackage` | Objetos de um pacote |
| `GetTransaction` | Detalhes de transação |

---

## 7. Usando no Workflow Flexível CTC

Com o MCP conectado, exemplos de pedidos ao Claude Code:

- "Liste os objetos do pacote `<SEU_PACOTE_WF>` e explique o que cada classe faz."
- "Procure classes `Z*CTC*` e mostre as que implementam regras de agente ou precondições do workflow."
- "Leia a classe `<ZCL_...>` e proponha a implementação da regra de responsável para o cenário CTC."
- "Mostre a estrutura da tabela `<ZTAB_...>` usada para determinar os aprovadores."

O Claude devolve o código proposto; você cria/ajusta e ativa no Eclipse ADT (ou via abapGit).

---

## 8. Problemas comuns

| Sintoma | Causa provável / solução |
| --- | --- |
| `ECONNREFUSED` / timeout | VPN desligada ou porta 5200 bloqueada; teste a URL de discovery no navegador |
| `401 Unauthorized` | Usuário/senha/mandante errados; confira `SAP_CLIENT` |
| `403 Forbidden` | Falta autorização ADT (`S_ADT_RES`, `S_DEVELOP`) — falar com Basis/segurança |
| Erro de certificado | Veja a seção 5 (`SAP_CA_FILE`) |
| Erro de redirect | `SAP_URL` deve ser a origem final (sem proxy que redirecione) |
| MCP não aparece no `/mcp` | Variáveis não carregadas: reabra o terminal/VS Code; rode `claude mcp list` |
| Erro de versão do Node | Use Node 22 ou 24 LTS |

---

## Segurança — checklist

- [ ] Usuário de **DEV/QAS**, nunca produção.
- [ ] Senha só em variável de ambiente (nada em `.mcp.json`, `.env` versionado, prints ou chat).
- [ ] `.env` continua no `.gitignore` (já está neste repositório).
- [ ] Revisar o código do pacote `mcp-abap-adt` (projeto da comunidade: https://github.com/mario-andreschak/mcp-abap-adt) conforme a política da empresa antes de usar.
