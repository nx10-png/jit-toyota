begin;

alter table public.config add column if not exists distribuicao_ativa boolean not null default false;
alter table public.config add column if not exists distribuido_em timestamptz;
alter table public.config add column if not exists distribuido_por text;

create table if not exists public.presencas (
  sessao text not null,
  usuario text not null,
  dispositivo_id text not null,
  ativo boolean not null default true,
  ultimo_ping timestamptz not null default now(),
  primary key (sessao, usuario)
);

create table if not exists public.atribuicoes (
  id uuid primary key default gen_random_uuid(),
  sessao text not null,
  codigo text not null,
  local text not null,
  usuario text not null,
  ordem text,
  peso numeric not null default 1,
  criado_em timestamptz not null default now(),
  constraint atribuicao_item_unico unique (sessao, codigo, local)
);

create index if not exists presencas_ativos_idx on public.presencas (sessao, ativo, ultimo_ping);
create index if not exists atribuicoes_usuario_idx on public.atribuicoes (sessao, usuario, ordem);

alter table public.presencas enable row level security;
alter table public.atribuicoes enable row level security;

drop policy if exists "mvp_presencas" on public.presencas;
create policy "mvp_presencas" on public.presencas for all to anon, authenticated using (true) with check (true);
drop policy if exists "mvp_atribuicoes" on public.atribuicoes;
create policy "mvp_atribuicoes" on public.atribuicoes for all to anon, authenticated using (true) with check (true);

do $$
begin
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='presencas')
  then alter publication supabase_realtime add table public.presencas; end if;
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='atribuicoes')
  then alter publication supabase_realtime add table public.atribuicoes; end if;
end $$;

commit;
