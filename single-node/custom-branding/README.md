# Vulcan Defense - Custom Branding

## Tema Azulado

Paleta: azul (#3b82f6, #60a5fa), fundo slate (#0f172a). Menu lateral estilo slim com itens compactos e destaque azul no item ativo.

## Tela de Login

- **Logo**: VULCAN DEFENSE
- **Tema**: Fundo slate escuro (#0f172a) com gradientes azulados
- **Animações**: Fade-in, glow no logo, grid pulsante
- **Título**: "VULCAN DEFENSE" na página de login

## Dashboard (pós-login)

- **Tema preto completo**: Header, sidebar, painéis, tabelas e formulários
- **Acentos dourados**: Bordas, botões primários, itens selecionados
- **Design moderno**: Glassmorphism sutil, scrollbar personalizada, hover states

## Tela de Health Check (verificação)

- **Fundo preto** com gradientes dourados e grid sutil
- **Logo 3D**: Animação flutuante com leve rotação em Y
- **Cubo 3D**: Elemento animado durante a verificação
- **Anéis pulsantes**: Efeito de onda durante o loading
- **Card glassmorphism**: Painel dos checks com perspectiva 3D
- **Itens animados**: Entrada sequencial com stagger effect

## Data Explorer (/app/data-explorer/)

- **Sidebar de campos**: Largura fixa (280px), seções com títulos em maiúsculas e borda dourada
- **Itens de campo**: Hover com destaque e borda lateral dourada
- **Barra de busca**: Card com bordas e fundo escuro
- **Toolbar**: Organização horizontal com gap consistente
- **Filtros ativos**: Chips em formato pill com estilo dourado
- **Botão toggle sidebar**: Mais visível e acessível
- **Tabela de resultados**: Bordas arredondadas e sombra suave

## Injeção automática de CSS

O nginx (nginx.dashboard) injeta automaticamente o `vulcan-login.css` em todas as páginas, incluindo a tela de login. Não é necessário usar extensão de navegador.

## Estrutura

```
custom-branding/
├── images/
│   └── vulcan-logo.png    # Logo VULCAN DEFENSE (ouro sobre preto, usado também como favicon)
├── assets/
│   └── vulcan-login.css   # Estilos (tela preta + animações)
├── css/
│   └── vulcan-login.css   # Backup/referência
└── README.md
```

## Fallback (extensão de browser)

Se o nginx não estiver ativo, use Stylus ou Stylish com o conteúdo de `assets/vulcan-login.css` na URL `https://seu-dominio/*`.
