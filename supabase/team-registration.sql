-- Inventário JIT — cadastro individual da equipe e confirmação de presença
-- Pode ser executado mais de uma vez com segurança.

begin;

create table if not exists public.equipe (
  id uuid primary key default gen_random_uuid(),
  sessao text not null default 'inventario_atual',
  nome text not null,
  nome_norm text not null,
  codigo_hash text not null,
  codigo_salt text not null,
  ativo boolean not null default true,
  criado_em timestamptz not null default now(),
  criado_por text,
  atualizado_em timestamptz not null default now(),
  ultimo_acesso timestamptz,
  constraint equipe_nome_unico unique (sessao, nome_norm)
);

alter table public.presencas add column if not exists pronto boolean not null default false;
alter table public.presencas add column if not exists equipe_id uuid references public.equipe(id) on delete set null;

create index if not exists equipe_sessao_ativo_idx on public.equipe (sessao, ativo, nome);
create index if not exists presencas_prontos_idx on public.presencas (sessao, ativo, pronto, ultimo_ping);

alter table public.equipe enable row level security;
drop policy if exists "mvp_equipe" on public.equipe;
create policy "mvp_equipe" on public.equipe for all to anon, authenticated using (true) with check (true);

grant select, insert, update, delete on public.equipe to anon, authenticated;

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'equipe'
  ) then alter publication supabase_realtime add table public.equipe; end if;
end $$;

commit;
