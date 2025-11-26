# 📚 E-book Interativo: Estratificação Social

E-book interativo e educacional sobre estratificação social, desenvolvido na engine Godot 4.4 com elementos multimídia e animações físicas para proporcionar uma experiência de aprendizagem imersiva.

## 🎯 Motivação

Este projeto foi desenvolvido como trabalho da **avaliação parcial** da disciplina de **Computação Gráfica e Sistemas Multimídia**, ministrada pelo **Prof. Ewerton Mendonça** na Universidade de Pernambuco (UPE).

O objetivo principal foi criar uma aplicação multimídia interativa que demonstre os conceitos aprendidos em sala, incluindo:
- Animações e física 2D
- Interação com acelerômetro em dispositivos móveis
- Reprodução de áudio e vídeo
- Design de interfaces responsivas
- Manipulação de eventos de entrada (toque e mouse)

## 👤 Autor

**Thiago Alves de Barros**  
Email institucional: [thiago.abarros@upe.br](mailto:thiago.abarros@upe.br)

## 📖 Sobre o Projeto

O e-book apresenta o tema de estratificação social através de 7 páginas interativas, cada uma com mecânicas únicas:

- **Página 2**: Arraste um regador para regar árvores que crescem em velocidades diferentes, demonstrando desigualdade de recursos
- **Página 3**: Interação com zoom e pan em uma árvore utilizando pinça (pinch) em dispositivos móveis
- **Página 4**: Reprodução de vídeo integrado
- **Página 5**: Animação física de árvores controlada por acelerômetro (movimentos de balanço e crescimento)
- **Página 6**: Física de sementes com diferentes pesos e simulação de gravidade
- **Página 7**: Página final com elementos de conclusão

Cada página inclui:
- ✨ Animações suaves com tweens
- 🎵 Narração em áudio
- 💬 Balões de texto explicativos
- 🎮 Mecânicas de interação únicas
- 📱 Suporte para dispositivos móveis e desktop

### 🎨 Interações e Animações por Página

Cada página utiliza diferentes tipos de interação e técnicas de animação para criar uma experiência única:

| Página | Tipo de Interação | Tipo de Animação |
|--------|------------------|------------------|
| **Página 2** | Arrastar | Interpolação (Tweens) |
| **Página 3** | Múltiplos toques (Pinça) | Interpolação (Zoom/Pan) |
| **Página 4** | Toque | Vídeo |
| **Página 5** | Acelerômetro | Várias imagens consecutivas (Sprite Frames) |
| **Página 6** | Arrastar | Física (Simulação de gravidade) |
| **Página 7** | Toque | Várias imagens consecutivas (Sprite Frames) |

**Detalhes das técnicas utilizadas:**

- **Interpolação (Tweens)**: Transições suaves entre valores usando o sistema de animação do Godot
- **Múltiplos toques**: Detecção de gestos multi-touch para interações avançadas como pinça (pinch-to-zoom)
- **Vídeo**: Integração de reprodução de vídeo com controles customizados
- **Acelerômetro**: Uso de sensores do dispositivo para detectar movimento e orientação
- **Física**: Simulação de física customizada com gravidade, colisão e fricção
- **Sprite Frames**: Animação através de sequências de imagens (frame-by-frame animation)

## 🛠️ Tecnologias Utilizadas

- **Engine**: Godot 4.4
- **Linguagem**: GDScript
- **Plataforma-alvo**: Mobile (Android/iOS) e Desktop
- **Recursos**: Acelerômetro, touch input, áudio, vídeo
- **Formato de mídia**: PNG, OGG (áudio), WEBM (vídeo)

## 📁 Estrutura do Repositório

```
ebook-estratificacao-social/
├── assets/                      # Recursos multimídia
│   ├── audio/                   # Arquivos de áudio (.ogg)
│   │   └── transcriptions/      # Narrações das páginas
│   ├── images/                  # Imagens e sprites
│   │   ├── animations/          # Sprites de animações por página
│   │   ├── instructions/        # Imagens de instruções
│   │   ├── pages/               # Backgrounds das páginas
│   │   └── text-balloon/        # Balões de diálogo
│   └── videos/                  # Vídeos integrados (.webm)
│
├── scenes/                      # Cenas Godot (.tscn)
│   ├── base/                    # Cenas base reutilizáveis
│   │   ├── base_page.tscn       # Template base de página
│   │   └── content_page.tscn    # Template de página de conteúdo
│   ├── components/              # Componentes reutilizáveis
│   │   ├── audio_button.tscn    # Botão de controle de áudio
│   │   └── water_drop.tscn      # Componente de gota d'água
│   └── pages/                   # Páginas do e-book
│       ├── capa.tscn            # Capa (página inicial)
│       ├── page2.tscn           # Página 2: Regador
│       ├── page3.tscn           # Página 3: Zoom na árvore
│       ├── page4.tscn           # Página 4: Vídeo
│       ├── page5.tscn           # Página 5: Acelerômetro
│       ├── page6.tscn           # Página 6: Física de sementes
│       ├── page7.tscn           # Página 7: Conclusão
│       └── contracapa.tscn      # Contracapa
│
├── scripts/                     # Scripts GDScript (.gd)
│   ├── autoload/                # Scripts globais (autoload)
│   │   └── main.gd              # Script global de controle de áudio
│   ├── components/              # Scripts de componentes
│   │   ├── audio_button.gd      # Lógica do botão de áudio
│   │   ├── video_controller.gd  # Controlador de vídeo
│   │   └── water_drop.gd        # Física da gota d'água
│   └── pages/                   # Scripts das páginas
│       ├── page_navigation.gd   # Script base de navegação
│       ├── page2.gd             # Lógica da página 2
│       ├── page3.gd             # Lógica da página 3 (zoom/pan)
│       ├── page4.gd             # Lógica da página 4 (vídeo)
│       ├── page5.gd             # Lógica da página 5 (acelerômetro)
│       ├── page6.gd             # Lógica da página 6 (física)
│       └── page7.gd             # Lógica da página 7
│
├── .gitignore                   # Arquivos ignorados pelo Git
├── export_presets.cfg           # Configurações de exportação
├── icon.svg                     # Ícone customizado do projeto
├── project.godot                # Arquivo de configuração do projeto
└── README.md                    # Este arquivo
```

## 🚀 Como Executar

### Pré-requisitos

- [Godot Engine 4.4](https://godotengine.org/download) ou superior

### Passos para Execução

1. **Clone o repositório**:
   ```bash
   git clone https://github.com/thiago-abarros/ebook-estratificacao-social.git
   cd ebook-estratificacao-social
   ```

2. **Abra o projeto no Godot**:
   - Abra o Godot Engine
   - Clique em "Importar"
   - Navegue até a pasta do projeto e selecione o arquivo `project.godot`
   - Clique em "Importar e Editar"

3. **Execute o projeto**:
   - Pressione `F5` ou clique no botão "Executar Projeto" no canto superior direito
   - A aplicação iniciará na capa do e-book

### Controles

- **Desktop**: 
  - Mouse para clicar e arrastar elementos
  - Scroll do mouse para zoom (Página 3)
  
- **Mobile**:
  - Toque para interação
  - Pinça (pinch) para zoom (Página 3)
  - Movimento do dispositivo para interação com acelerômetro (Página 5)

### Exportação

Para exportar o projeto para Android, iOS ou outras plataformas:

1. Vá em `Projeto > Exportar`
2. Selecione a plataforma desejada
3. Configure as opções de exportação
4. Clique em "Exportar Projeto"

## 🎨 Destaques Técnicos

### Física Customizada
- Sistema de física próprio para gotas d'água com gravidade e colisão
- Simulação de sementes com pesos diferentes e coeficientes de fricção
- Animações físicas baseadas em dados do acelerômetro

### Interação Multimídia
- Sistema global de controle de áudio persistente entre páginas
- Integração de vídeo com controles personalizados
- Animações suaves usando o sistema Tween do Godot

### Arquitetura
- Padrão de herança para páginas (base_page → content_page → páginas específicas)
- Scripts autoload para gerenciamento de estado global
- Componentes reutilizáveis para elementos comuns

### Responsividade
- Layout adaptativo usando Control nodes e anchors
- Suporte para diferentes orientações e resoluções
- Tratamento unificado de eventos de mouse e toque

## 📝 Licença

Este projeto foi desenvolvido para fins educacionais como parte da disciplina de Computação Gráfica e Sistemas Multimídia da UPE.

## 🤝 Agradecimentos

- **Prof. Ewerton Mendonça** pela orientação e conhecimentos compartilhados
- **Godot Engine Community** pelos excelentes recursos e documentação
- **UPE - Universidade de Pernambuco** pelo apoio acadêmico

---

**Desenvolvido com ❤️ por Thiago Alves de Barros**
