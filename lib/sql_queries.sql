-- created users table

create table users (
user_id bigint primary key generated always as identity,
name text not null,
email_id text not null,
password text not null
);

-- created whiteboards table

create table whiteboards (
  whiteboard_id bigint primary key generated always as identity,
  title text not null,
  created_at timestamp not null,
  user_id bigint not null references users(user_id) on delete cascade
);

-- created strokes table

create table strokes (
  stroke_id bigint primary key generated always as identity,
  size int not null,
  color text not null,
  stroke_offset jsonb not null,
  whiteboard_id bigint not null references whiteboards(whiteboard_id) on delete cascade
);

-- updated strokes color from text to integer

alter table strokes alter column color type int using color::integer;

--

create policy "public can read countries"
on public.countries
for select to anon
using (true);

-- query for finding the constraint name 
SELECT constraint_name 
FROM information_schema.table_constraints 
WHERE table_name = 'whiteboards' AND constraint_type = 'FOREIGN KEY';

--dropping the foreign key of whiteboards
alter table whiteboards drop constraint whiteboards_user_id_fkey;

--dropped users table

drop table users;

--
alter table whiteboards drop column user_id;

--added user_id to whiteboards
ALTER TABLE whiteboards 
add COLUMN user_id uuid;

--added auth users id as foreign key to whiteboards table

ALTER TABLE whiteboards 
alter column user_id type uuid,
add constraint fk_user_id foreign key (user_id) references auth.users(id) on delete cascade;

--changed size to float

alter table strokes alter column size type float using size::float;

--

-- Turn on security
alter table "whiteboards"
enable row level security;

-- Allow anonymous access
create policy "Allow anonymous access"
on whiteboards
for select
to anon
using (true);


--
CREATE POLICY all_operations ON whiteboards
  FOR ALL
  TO PUBLIC
  USING (TRUE)
  WITH CHECK (TRUE);

--

alter table "strokes"
enable row level security;

--

CREATE POLICY all_operations ON strokes
  FOR ALL
  TO PUBLIC
  USING (TRUE)
  WITH CHECK (TRUE);


create table usersWhiteboards (
  usersWhiteboards_id bigint primary key generated always as identity,
  user_id uuid not null references auth.users(id) on delete cascade,
  whiteboard_id bigint not null references whiteboards(whiteboard_id) on delete cascade
);

--
alter table whiteboards drop column user_id;
--

alter table userswhiteboards enable row level security;

--

CREATE POLICY all_operations ON userswhiteboards
  FOR ALL
  TO PUBLIC
  USING (TRUE)
  WITH CHECK (TRUE);

--

alter table whiteboards add column invite_key bigint unique;

--

alter table userswhiteboards add constraint unique_user unique(user_id, whiteboard_id);

--



