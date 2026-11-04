-- Gastos Pareja: esquema de la base de datos (Supabase)
-- Córrelo una sola vez en Supabase > SQL Editor > New query > Run.

-- Cada pareja es un "hogar". Un hogar tiene miembros y sus datos.
create table if not exists public.hogares (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  codigo text not null unique default upper(substr(md5(random()::text || clock_timestamp()::text), 1, 6)),
  created_at timestamptz not null default now()
);

create table if not exists public.miembros (
  hogar_id uuid not null references public.hogares(id) on delete cascade,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (hogar_id, user_id)
);

-- Todos los datos de la app: movimientos, MSI, ingresos y gastos fijos, configuración.
create table if not exists public.docs (
  hogar_id uuid not null references public.hogares(id) on delete cascade,
  col text not null,
  id text not null,
  data jsonb not null,
  updated_at timestamptz not null default now(),
  updated_by uuid default auth.uid(),
  primary key (hogar_id, col, id)
);

alter table public.hogares enable row level security;
alter table public.miembros enable row level security;
alter table public.docs enable row level security;

-- ¿El usuario que hace la consulta pertenece a este hogar?
create or replace function public.es_miembro(h uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.miembros where hogar_id = h and user_id = auth.uid());
$$;

drop policy if exists "ver mi hogar" on public.hogares;
create policy "ver mi hogar" on public.hogares for select to authenticated using (public.es_miembro(id));

drop policy if exists "ver miembros de mi hogar" on public.miembros;
create policy "ver miembros de mi hogar" on public.miembros for select to authenticated using (public.es_miembro(hogar_id));

drop policy if exists "datos de mi hogar" on public.docs;
create policy "datos de mi hogar" on public.docs for all to authenticated
  using (public.es_miembro(hogar_id)) with check (public.es_miembro(hogar_id));

-- Crear un hogar nuevo y entrar como miembro.
create or replace function public.crear_hogar(p_nombre text)
returns uuid language plpgsql security definer set search_path = public as $$
declare h uuid;
begin
  if auth.uid() is null then raise exception 'Inicia sesión primero'; end if;
  insert into public.hogares(nombre) values (coalesce(nullif(trim(p_nombre), ''), 'Nuestro hogar')) returning id into h;
  insert into public.miembros(hogar_id, user_id) values (h, auth.uid());
  return h;
end $$;

-- Unirse al hogar de tu pareja con su código de 6 letras.
create or replace function public.unirse_hogar(p_codigo text)
returns uuid language plpgsql security definer set search_path = public as $$
declare h uuid;
begin
  if auth.uid() is null then raise exception 'Inicia sesión primero'; end if;
  select id into h from public.hogares where hogares.codigo = upper(trim(p_codigo));
  if h is null then raise exception 'Código no encontrado'; end if;
  insert into public.miembros(hogar_id, user_id) values (h, auth.uid()) on conflict do nothing;
  return h;
end $$;

revoke all on function public.crear_hogar(text) from anon;
revoke all on function public.unirse_hogar(text) from anon;
grant execute on function public.crear_hogar(text) to authenticated;
grant execute on function public.unirse_hogar(text) to authenticated;

-- Cambios en vivo entre los dos teléfonos.
alter table public.docs replica identity full;
do $$ begin
  alter publication supabase_realtime add table public.docs;
exception when duplicate_object then null; end $$;
