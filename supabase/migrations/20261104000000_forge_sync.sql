create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  github_repo_url text,
  last_synced_commit text,
  updated_at timestamptz not null default now()
);

create table if not exists public.project_files (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  file_path text not null,
  content_hash text not null,
  storage_path text,
  updated_at timestamptz not null default now(),
  unique (project_id, file_path)
);

create table if not exists public.ai_sessions (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  assigned_cloud_model text not null,
  generated_plan jsonb,
  requested_files jsonb,
  status text not null default 'planning',
  created_at timestamptz not null default now()
);

do $$ begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'project_files'
  ) then
    alter publication supabase_realtime add table public.project_files;
  end if;
end $$;

alter table public.projects enable row level security;
alter table public.project_files enable row level security;
alter table public.ai_sessions enable row level security;

create policy "Users manage their projects" on public.projects
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users manage files in their projects" on public.project_files
  for all to authenticated
  using (exists (
    select 1 from public.projects p
    where p.id = project_id and p.user_id = auth.uid()
  ))
  with check (exists (
    select 1 from public.projects p
    where p.id = project_id and p.user_id = auth.uid()
  ));

create policy "Users manage AI sessions in their projects" on public.ai_sessions
  for all to authenticated
  using (exists (
    select 1 from public.projects p
    where p.id = project_id and p.user_id = auth.uid()
  ))
  with check (exists (
    select 1 from public.projects p
    where p.id = project_id and p.user_id = auth.uid()
  ));

insert into storage.buckets (id, name, public)
values ('project-files', 'project-files', false)
on conflict (id) do update set public = false;

grant select, insert, update, delete on public.projects to authenticated;
grant select, insert, update, delete on public.project_files to authenticated;
grant select, insert, update, delete on public.ai_sessions to authenticated;

create policy "Users access files in their own project folders"
  on storage.objects for all to authenticated
  using (
    bucket_id = 'project-files'
    and (storage.foldername(name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'project-files'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
