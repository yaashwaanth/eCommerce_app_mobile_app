// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import Stripe from 'npm:stripe';
import { getOrCreateStripeCustomerForSupabaseUser } from "../supabase.ts";

const stripe = Stripe(Deno.env.get('STRIPE_SECRET_KEY'),{
  httpClient: Stripe.createFetchHttpClient()
})

Deno.serve(async (req) => {
  const { totalAmount } = await req.json()
  console.log(totalAmount,"lun");

  const customer = await getOrCreateStripeCustomerForSupabaseUser(req);
  const ephemeralKey = await stripe.ephemeralKeys.create({customer},{apiVersion:'2020-08-27' })
  
  const paymentIntent = await stripe.paymentIntents.create({
    amount: totalAmount,
    currency: 'usd',
    description: "a product",
    customer, // This will link the payment to the customer
    shipping: {
      name: 'Customer Name', // Required for exports
      address: {
        line1: '123 Main Street',
        city: 'Mumbai',
        state: 'Maharashtra',
        postal_code: '400001',
        country: 'IN',
      },
    }
  })
  console.log(paymentIntent);
  
  const response ={
    paymentIntent: paymentIntent.client_secret,
    publicKey: Deno.env.get('STRIPE_PUBLISHABLE_KEY'),
    ephemeralKey: ephemeralKey.secrets,
    customer
  }
  return new Response(
    JSON.stringify(response),
    { headers: { "Content-Type": "application/json" } },
  )
})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/stripe-checkout' \
    --header 'Authorization: Bearer 
    --header 'Content-Type: application/json' \
    --data '{"totalAmount":"Functions"}'

*/

// pushing secrets for .env to remote -> npx supabase secrets set STRIPE_PUBLISHABLE_KEY=
