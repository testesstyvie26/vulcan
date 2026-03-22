# Vulcan Defense - Custom Branding

## Tela de Login

- **Tema escuro**: Aplicado via `theme:darkMode` (fundo escuro/preto)
- **Logo animado**: `vulcan-logo.svg` com efeito de pulse suave
- **Título**: "Vulcan Defense" na página de login

## CSS Customizado (tela preta + glassmorphism)

O OpenSearch Dashboards não injeta CSS customizado nativamente. Para fundo preto puro e design moderno:

1. **Extensão de browser** (Stylus ou Stylish):
   - URL do site: `https://seu-dominio/*`
   - Cole o conteúdo de `assets/vulcan-login.css`

2. **Arquivo disponível em**: `https://seu-dominio/ui/assets/vulcan-login.css`
   (após subir os containers)

## Estrutura

```
custom-branding/
├── images/
│   ├── vulcan-logo.png    # Logo estático
│   └── vulcan-logo.svg    # Logo animado (recomendado)
├── assets/
│   └── vulcan-login.css   # Estilos extras (tela preta)
├── css/
│   └── vulcan-login.css   # Backup/ref
└── README.md
```
