# Vulcan Defense - Custom Branding

## Tela de Login

- **Logo**: VULCAN DEFENSE com cubo isométrico dourado
- **Tema**: Fundo preto (#0a0a0b) com gradientes dourados sutis
- **Animações**: Fade-in, glow no logo, grid pulsante, linha de brilho no card
- **Título**: "VULCAN DEFENSE" na página de login

## Dashboard (pós-login)

- **Tema preto completo**: Header, sidebar, painéis, tabelas e formulários
- **Acentos dourados**: Bordas, botões primários, itens selecionados
- **Design moderno**: Glassmorphism sutil, scrollbar personalizada, hover states

## Injeção automática de CSS

O nginx (nginx.dashboard) injeta automaticamente o `vulcan-login.css` em todas as páginas, incluindo a tela de login. Não é necessário usar extensão de navegador.

## Estrutura

```
custom-branding/
├── images/
│   └── vulcan-logo.png    # Logo VULCAN DEFENSE (ouro sobre preto)
├── assets/
│   └── vulcan-login.css   # Estilos (tela preta + animações)
├── css/
│   └── vulcan-login.css   # Backup/referência
└── README.md
```

## Fallback (extensão de browser)

Se o nginx não estiver ativo, use Stylus ou Stylish com o conteúdo de `assets/vulcan-login.css` na URL `https://seu-dominio/*`.
