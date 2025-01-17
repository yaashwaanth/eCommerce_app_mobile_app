create policy "update for auth users"
on "public"."users"
as permissive
for update
to authenticated
using (true);



