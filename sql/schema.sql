-- prevent created FUNCTION to be public by default

ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
-- auth table + roles (anon, user)
\ir _auth.sql
-- auth rpc (/rpc/login, /rpc/register, /rpc/logout)
\ir _auth_jwt.sql

DROP TABLE IF EXISTS public.profile;
CREATE TABLE public.profile (
	"id" name DEFAULT current_setting('request.jwt.claims', true)::json->>'id' PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
	"alias" text,
	"birth" date,
	"secret" text, -- favorite food
	"theme" text DEFAULT '#126359',
	"progress" JSON -- cleared lessons/exams
);

CREATE or replace FUNCTION auth.also_create_profile() returns trigger as $$
begin
	INSERT into public.profile("id", "progress") VALUES (NEW.id, '{}');
	RETURN NEW;
end
$$ language plpgsql;
DROP TRIGGER IF EXISTS setup_profile ON auth.users;
CREATE TRIGGER setup_profile AFTER INSERT ON auth.users FOR EACH ROW EXECUTE PROCEDURE auth.also_create_profile();

grant SELECT ON TABLE public.profile TO "anon";
grant ALL    ON TABLE public.profile TO "user";
-- We want user to be able to see each other
--ALTER TABLE public.profile DISABLE ROW LEVEL SECURITY;
--DROP POLICY IF EXISTS "user_policy" ON public.profile;
--CREATE POLICY "user_policy" ON public.profile
--  USING ("id" = current_setting('request.jwt.claims', true)::json->>'id') -- visibility rule
--  WITH CHECK ("id" = current_setting('request.jwt.claims', true)::json->>'id'); -- mutation rule

NOTIFY pgrst, 'reload schema';