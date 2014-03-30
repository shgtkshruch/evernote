drop table if exists favorites;
create table favorites( 
  id integer  primary key,
  title text,
  url text,
  created_at,
  updated_at
);

drop table if exists tags;
create table tags(
  id integer primary key,
  favorite_id integer,
  name text,
  created_at,
  updated_at
);
