

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE OR REPLACE FUNCTION "public"."decrement_product_quantity"("product_id" bigint, "quantity" bigint) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  UPDATE product
  SET maxQuantity = maxQuantity - quantity
  WHERE id = product_id AND maxQuantity >= quantity;
END;
$$;


ALTER FUNCTION "public"."decrement_product_quantity"("product_id" bigint, "quantity" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin 
    if new.raw_user_meta_data->> 'avatar_url' is null or new.raw_user_meta_data->>'avatar_url' = '' then
    new.raw_user_meta_data = jsonb_set(new.raw_user_meta_data,'{avatar_url}','"https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"':: jsonb);
    end if;
    insert into public.users(id,email,avatar_url)
    values(new.id,new.email,new.raw_user_meta_data->>'avatar_url');
    return new;
end;
$$;

-- on authuser insert, create a new user in the public schema 
create or replace trigger on_auth_user_created 
after insert on auth.users for each row execute procedure public.handle_new_user (); 


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin 
    if new.raw_user_meta_data->> 'avatar_url' is null or new.raw_user_meta_data->>'avatar_url' = '' then
    new.raw_user_meta_data = jsonb_set(new.raw_user_meta_data,'{avatar_url}','"https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png"':: jsonb);
    end if;
    insert into public.users(id,email,avatar_url)
    values(new.id,new.email,new.raw_user_meta_data->>'avatar_url');
    return new;
end;
$$;


ALTER FUNCTION "public"."handle_user"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."category" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" "text" NOT NULL,
    "imageUrl" "text" NOT NULL,
    "slug" "text" NOT NULL,
    "products" bigint[]
);


ALTER TABLE "public"."category" OWNER TO "postgres";


ALTER TABLE "public"."category" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."category_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."order_item" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "product" bigint NOT NULL,
    "order" bigint NOT NULL,
    "quantity" bigint NOT NULL
);


ALTER TABLE "public"."order_item" OWNER TO "postgres";


ALTER TABLE "public"."order_item" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."order_item_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."orders" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "status" "text" NOT NULL,
    "description" "text",
    "user" "uuid" NOT NULL,
    "slug" "text" NOT NULL,
    "totalPrice" double precision NOT NULL
);


ALTER TABLE "public"."orders" OWNER TO "postgres";


ALTER TABLE "public"."orders" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."orders_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."product" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "title" "text" NOT NULL,
    "slug" "text" NOT NULL,
    "imagesUrl" "text"[] NOT NULL,
    "price" bigint NOT NULL,
    "heroImage" "text" NOT NULL,
    "category" bigint NOT NULL,
    "maxQuantity" bigint NOT NULL
);


ALTER TABLE "public"."product" OWNER TO "postgres";


ALTER TABLE "public"."product" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."product_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" "uuid" NOT NULL,
    "email" "text" NOT NULL,
    "type" "text" DEFAULT 'USER'::"text",
    "avatar_url" "text" NOT NULL,
    "created_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "users_type_check" CHECK (("type" = ANY (ARRAY['USER'::"text", 'ADMIN'::"text"])))
);


ALTER TABLE "public"."users" OWNER TO "postgres";


ALTER TABLE ONLY "public"."category"
    ADD CONSTRAINT "category_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."category"
    ADD CONSTRAINT "category_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."order_item"
    ADD CONSTRAINT "order_item_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_slug_key" UNIQUE ("slug");



ALTER TABLE ONLY "public"."product"
    ADD CONSTRAINT "product_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."product"
    ADD CONSTRAINT "product_title_key" UNIQUE ("title");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."order_item"
    ADD CONSTRAINT "order_item_order_fkey" FOREIGN KEY ("order") REFERENCES "public"."orders"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."order_item"
    ADD CONSTRAINT "order_item_product_fkey" FOREIGN KEY ("product") REFERENCES "public"."product"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_user_fkey" FOREIGN KEY ("user") REFERENCES "public"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."product"
    ADD CONSTRAINT "product_category_fkey" FOREIGN KEY ("category") REFERENCES "public"."category"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "users_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id");



CREATE POLICY "Allow all operation for auth users" ON "public"."orders" TO "authenticated" USING (true) WITH CHECK (true);



CREATE POLICY "Allow all operations for all users" ON "public"."order_item" TO "authenticated" USING (true) WITH CHECK (true);



CREATE POLICY "Enable delete for admins only" ON "public"."category" FOR DELETE TO "authenticated" USING ((( SELECT "users"."type"
   FROM "public"."users"
  WHERE ("users"."id" = "auth"."uid"())) = 'ADMIN'::"text"));



CREATE POLICY "Enable delete for users admin only" ON "public"."product" FOR DELETE TO "authenticated" USING ((( SELECT "users"."type"
   FROM "public"."users"
  WHERE ("users"."id" = "auth"."uid"())) = 'ADMIN'::"text"));



CREATE POLICY "Enable insert for admin users only" ON "public"."product" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "users"."type"
   FROM "public"."users"
  WHERE ("users"."id" = "auth"."uid"())) = 'ADMIN'::"text"));



CREATE POLICY "Enable insert for admins only" ON "public"."category" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "users"."type"
   FROM "public"."users"
  WHERE ("users"."id" = "auth"."uid"())) = 'ADMIN'::"text"));



CREATE POLICY "Enable read access for all users" ON "public"."product" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."users" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable update for admins only" ON "public"."category" FOR UPDATE TO "authenticated" USING ((( SELECT "users"."type"
   FROM "public"."users"
  WHERE ("users"."id" = "auth"."uid"())) = 'ADMIN'::"text")) WITH CHECK ((( SELECT "users"."type"
   FROM "public"."users"
  WHERE ("users"."id" = "auth"."uid"())) = 'ADMIN'::"text"));



CREATE POLICY "Enable update for auth users " ON "public"."product" FOR UPDATE TO "authenticated" USING (true) WITH CHECK (true);



ALTER TABLE "public"."category" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "enable read for all users" ON "public"."category" FOR SELECT TO "authenticated" USING (true);



ALTER TABLE "public"."order_item" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."orders" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."product" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."users" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."orders";



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";




















































































































































































GRANT ALL ON FUNCTION "public"."decrement_product_quantity"("product_id" bigint, "quantity" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."decrement_product_quantity"("product_id" bigint, "quantity" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."decrement_product_quantity"("product_id" bigint, "quantity" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_user"() TO "service_role";


















GRANT ALL ON TABLE "public"."category" TO "anon";
GRANT ALL ON TABLE "public"."category" TO "authenticated";
GRANT ALL ON TABLE "public"."category" TO "service_role";



GRANT ALL ON SEQUENCE "public"."category_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."category_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."category_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."order_item" TO "anon";
GRANT ALL ON TABLE "public"."order_item" TO "authenticated";
GRANT ALL ON TABLE "public"."order_item" TO "service_role";



GRANT ALL ON SEQUENCE "public"."order_item_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."order_item_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."order_item_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."orders" TO "anon";
GRANT ALL ON TABLE "public"."orders" TO "authenticated";
GRANT ALL ON TABLE "public"."orders" TO "service_role";



GRANT ALL ON SEQUENCE "public"."orders_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."orders_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."orders_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."product" TO "anon";
GRANT ALL ON TABLE "public"."product" TO "authenticated";
GRANT ALL ON TABLE "public"."product" TO "service_role";



GRANT ALL ON SEQUENCE "public"."product_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."product_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."product_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;
