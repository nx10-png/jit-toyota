# Inventário JIT Toyota

Aplicativo web móvel para contagem cega de estoque, acompanhamento por zonas, divergências, recontagens e relatórios. Os aparelhos sincronizam em tempo real pelo Supabase e continuam com uma cópia local para tolerar instabilidade de conexão.

## Uso no dia do inventário

1. Abra o aplicativo e entre como líder.
2. Acesse **Exportar > Base do estoque**.
3. Carregue o arquivo Excel (`.xlsx` ou `.xls`) atualizado. CSV também é aceito.
4. Confira a quantidade de itens e zonas exibida na tela.
5. Peça para cada estoquista abrir o aplicativo, informar o nome completo e entrar. Eles ficarão como ativos e aguardando.
6. Em **Abertura**, confira a equipe ativa, marque quem participará e pressione **Distribuir**.
7. O sistema dividirá os itens em blocos equilibrados de rota e liberará uma fila exclusiva para cada pessoa.
8. Nos aparelhos dos estoquistas, pressione **Verificar agora** caso a fila não apareça imediatamente.

O sistema lê a primeira aba do Excel. CSV com vírgula ou ponto e vírgula também é aceito. Os nomes reconhecidos incluem:

- `codigo`, `descricao`, `local`, `quantidade`, `custo`, `icc`, `unidade`;
- alternativas comuns como `qtd`, `saldo`, `estoque`, `endereco`, `valor` e `un`.

As colunas **código** e **local** são obrigatórias. Ao importar uma nova base, a distribuição anterior é cancelada para impedir o uso de uma lista desatualizada.

## Banco de dados

O arquivo `supabase/schema.sql` documenta a estrutura usada no Supabase, incluindo índices, prevenção de duplicidades, políticas do MVP interno e publicação no Realtime.

## Segurança

Esta versão é um MVP interno e usa políticas públicas controladas pela chave publicável do projeto. Antes de disponibilizar o sistema de forma corporativa, substituir o PIN local por Supabase Auth e políticas por usuário/perfil.
