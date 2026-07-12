begin;

create extension if not exists pgcrypto;

create table if not exists public.contagens (
  id uuid primary key default gen_random_uuid(),
  sessao text not null,
  codigo text not null,
  "desc" text,
  local text,
  local_cadastro text,
  zona text,
  sistema numeric not null default 0,
  contado numeric not null default 0,
  icc text,
  un text,
  usuario text not null,
  hora text not null,
  recontagem boolean not null default false,
  avaria boolean not null default false,
  achado_outra_loc boolean not null default false,
  foto text,
  foto_tipo text,
  modo text,
  bipado boolean not null default false,
  criado_em timestamptz not null default now(),
  constraint contagens_evento_unico unique (sessao, codigo, local, usuario, hora)
);

create table if not exists public.solicitacoes (
  id uuid primary key default gen_random_uuid(),
  sessao text not null,
  tipo text not null,
  codigo text,
  "desc" text,
  local text,
  local_cadastro text,
  local_achado text,
  qtd numeric,
  usuario text not null,
  hora text not null,
  criado_em timestamptz not null default now(),
  constraint solicitacoes_evento_unico unique (sessao, tipo, usuario, hora, codigo)
);

create table if not exists public.liberacoes (
  sessao text not null,
  zona text not null,
  liberada boolean not null default false,
  atualizado_em timestamptz not null default now(),
  primary key (sessao, zona)
);

create table if not exists public.config (
  sessao text primary key,
  modo text not null default 'atribuido',
  selecao jsonb not null default '{"ativa":false,"itens":null,"iccs":null}'::jsonb,
  itens jsonb,
  recontar jsonb not null default '{}'::jsonb,
  atualizado_em timestamptz not null default now()
);

create index if not exists contagens_sessao_codigo_idx on public.contagens (sessao, codigo);
create index if not exists contagens_sessao_criado_idx on public.contagens (sessao, criado_em);
create index if not exists solicitacoes_sessao_criado_idx on public.solicitacoes (sessao, criado_em);

alter table public.contagens enable row level security;
alter table public.solicitacoes enable row level security;
alter table public.liberacoes enable row level security;
alter table public.config enable row level security;

-- MVP interno: o aplicativo estatico usa a chave publica e pode ler/gravar.
-- Estas quatro politicas ficam isoladas para futura troca por Supabase Auth.
drop policy if exists "mvp_contagens" on public.contagens;
create policy "mvp_contagens" on public.contagens for all to anon, authenticated using (true) with check (true);
drop policy if exists "mvp_solicitacoes" on public.solicitacoes;
create policy "mvp_solicitacoes" on public.solicitacoes for all to anon, authenticated using (true) with check (true);
drop policy if exists "mvp_liberacoes" on public.liberacoes;
create policy "mvp_liberacoes" on public.liberacoes for all to anon, authenticated using (true) with check (true);
drop policy if exists "mvp_config" on public.config;
create policy "mvp_config" on public.config for all to anon, authenticated using (true) with check (true);

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'contagens'
  ) then alter publication supabase_realtime add table public.contagens; end if;
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'solicitacoes'
  ) then alter publication supabase_realtime add table public.solicitacoes; end if;
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'liberacoes'
  ) then alter publication supabase_realtime add table public.liberacoes; end if;
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'config'
  ) then alter publication supabase_realtime add table public.config; end if;
end $$;

insert into public.config (sessao) values ('inventario_atual')
on conflict (sessao) do nothing;

commit;
