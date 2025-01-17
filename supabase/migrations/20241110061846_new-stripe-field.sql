alter table "public"."users" add column "stripe_customer_id" text;


-- npx supabase db diff -f new-stripe-field
--  npx supabase db push                 