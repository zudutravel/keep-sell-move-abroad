# Keep or Sell Planner: setup guide

About 30 minutes, best done on a computer. Everything here is free at this scale.

## What's in the folder

| File | What it is |
|---|---|
| `index.html` | The app |
| `config.js` | Your Supabase details and payment link (you fill this in) |
| `offers.json` | The bank offers everyone sees |
| `supabase-setup.sql` | Creates the members list and saved-data tables |
| `netlify.toml` | Hosting settings |

## Test mode (no database needed)

Leave `config.js` as it is and upload the folder to Netlify. The app opens straight in with no sign-in, shows a "Test mode" badge, and saves figures on that device only. Anyone with the link can use it, so don't share the link widely while it's in test mode.

When you're ready to sell, fill in `config.js` (step 2) and upload again. The sign-in screen and members list switch on automatically.

**If Supabase says you've hit the free limit:** the free plan allows 2 active projects in total, across all your organisations. Either pause a project you're not using (Project Settings > General > Pause project; paused projects don't count), or run `supabase-setup.sql` inside an existing project. Its tables are named `members`, `admins` and `user_models`, so they won't clash unless that project already has tables with those names.

## How access works

1. A buyer pays you through Buy Me a Coffee or PayPal.
2. You add their email in the app's **Members** tab (only you see this tab).
3. They open the site, tap **Create your account** with that email, and they're in.
4. Remove someone in the Members tab and they lose access on their next visit.

People who sign up but aren't on the list see a "Get access" screen with your payment link. Each person's figures save to their account and sync between phone and computer. Nobody can see anyone else's figures, including you.

## 1. Create the database (Supabase)

1. Go to supabase.com, sign up, and create a new project. Pick the Singapore or Sydney region. Save the database password somewhere safe.
2. Open **SQL Editor > New query**. Paste in all of `supabase-setup.sql`.
3. On the last line, change `you@example.com` to the email you'll sign in with. Click **Run**. It should say "Success".
4. Go to **Authentication > Sign In / Providers > Email** and turn **Confirm email** off. Save.
   Supabase's built-in email service only sends a handful of emails and may only deliver to your own address, so leave confirmations off unless you add your own email service (see "Later" below).

## 2. Connect the app to your database

1. In Supabase, open **Project Settings > API** (it may be called **Data API** or **API Keys**).
2. Copy the **Project URL** and the **anon / public** key.
3. Open `config.js` in a text editor and paste them in. Add your Buy Me a Coffee or PayPal link as `buyUrl`.

The anon key is designed to be public. The rules in the SQL file are what stop people reading data they shouldn't.

## 3. Put it online (Netlify)

**Quick way:** Netlify > **Add new site > Deploy manually**, then drag the whole folder in. Rename the site under **Site configuration**, e.g. `keep-or-sell.netlify.app`.

**Better way, for automatic bank-offer updates:** put the folder in a GitHub repository and connect it with Netlify > **Add new site > Import an existing project**. Netlify republishes whenever `offers.json` changes, so the weekly bank-offer check can update every customer's copy without you doing anything.

## 4. Make yourself the first user

Open your site, tap **Create your account**, and use the email you put in the SQL file. You'll land in the app with a **Members** tab.

## Updating bank offers

- **With GitHub connected:** tell Claude the repository name. The weekly check can then update `offers.json` and Netlify publishes it automatically.
- **Without GitHub:** replace `offers.json` and drag the folder into Netlify again.

The app shows "Bank offers checked [date]" at the top so customers can see how fresh the rates are.

## Good to know

- **Free Supabase projects pause after about a week with no visits.** You can restore one from the dashboard; regular use keeps it awake. Upgrade if paying customers start relying on it.
- **Password resets need an email service.** Until you add one, a customer who forgets their password can email you. You can delete them under **Authentication > Users** so they can sign up again, but that also deletes their saved figures.
- **Later:** add a free Resend account under **Authentication > SMTP Settings** to turn on confirmation emails and "forgot password".
- **Keep the disclaimer.** The footer says it's general information, not financial advice. Keep that wording, and avoid promising returns or telling people which account is right for them.
