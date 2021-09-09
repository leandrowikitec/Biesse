# quick-start

Bem vindo ao repositório de customizações do Protheus.

Neste repositório Git de customizações você encontrará a seguinte estrutura:

```
      raiz
        |--src
            |-- .prw, .prx, .aph, .gif
            |-- .ch (customizados)
        |--protheus_data
            |-- .xml, .ini
        dictionary.json
```

Mantenha sempre seu código fonte dentro da pastar ```src/ ```, caso em sua customização haja arquivos de include (.ch), os mesmos podem ficar juntos com os arquivos compiláveis (pasta src).

Sempre que um commit é realizado neste reposítorio ele será submetido à um *pipeline* onde os arquivos da branch são submetidos à ferramenta *Sonarqube* para uma análise estática, caso não sejam encontrados problemas, os fontes são liber>

O projeto segue uma regra onde a atualização de ve ser total, ou seja, todos os fontes da branch são compilados, ou em caso de falha em algum deles, nenhum fonte é compilado.

