-- Keep or Sell Planner: database setup.
-- Paste all of this into Supabase > SQL Editor > New query, change the email on the last line, then Run.

-- People who have paid. You add and remove rows from the Members tab in the app.
create table if not exists public.members (
  email      text primary key,
  note       text,
  added_at   timestamptz not null default now()
);

-- You (and anyone else who manages members).
create table if not exists public.admins (
  email text primary key
);

-- Each person's saved figures, one row per account.
create table if not exists public.user_models (
  user_id    uuid primary key references auth.users(id) on delete cascade,
  data       jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.members     enable row level security;
alter table public.admins      enable row level security;
alter table public.user_models enable row level security;

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins a where lower(a.email) = lower(auth.jwt() ->> 'email'));
$$;

create or replace function public.is_member() returns boolean
language sql stable security definer set search_path = public as $$
  select public.is_admin()
      or exists (select 1 from public.members m where lower(m.email) = lower(auth.jwt() ->> 'email'));
$$;

revoke all on function public.is_admin()  from public, anon;
revoke all on function public.is_member() from public, anon;
grant execute on function public.is_admin()  to authenticated;
grant execute on function public.is_member() to authenticated;

-- members: admins manage everything; a member can see their own row only.
drop policy if exists members_read  on public.members;
drop policy if exists members_write on public.members;
create policy members_read  on public.members for select to authenticated
  using (public.is_admin() or lower(email) = lower(auth.jwt() ->> 'email'));
create policy members_write on public.members for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- admins: only admins can see the list; changes are made here in SQL, not in the app.
drop policy if exists admins_read on public.admins;
create policy admins_read on public.admins for select to authenticated using (public.is_admin());

-- user_models: you can only read and write your own row, and only while you're a member.
drop policy if exists own_model on public.user_models;
create policy own_model on public.user_models for all to authenticated
  using (user_id = auth.uid() and public.is_member())
  with check (user_id = auth.uid() and public.is_member());

-- Store emails in lower case so matching is reliable.
create or replace function public.lower_email() returns trigger language plpgsql as $$
begin new.email := lower(trim(new.email)); return new; end $$;
drop trigger if exists members_lower on public.members;
create trigger members_lower before insert or update on public.members for each row execute function public.lower_email();
drop trigger if exists admins_lower on public.admins;
create trigger admins_lower before insert or update on public.admins for each row execute function public.lower_email();

-- >>> Change this to the email you'll sign in with, then run. <<<
insert into public.admins (email) values ('you@example.com') on conflict do nothing;
