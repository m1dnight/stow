#!/bin/bash

for account in loomy gmail; do
  echo "Processing account: $account"

  page=0
  while true; do
    json=$(himalaya envelope list --account $account --output json --page-size 10000 --page $page) || break

    echo "Processing page $page for $account..."

    # remove subject-based
    echo "$json" | jq '[.[] | select(
      .subject |
        startswith("The Philips project role team at") or
        startswith("Nieuwe panden op Zimmo") or
        startswith("I want to connect") or
        startswith("vzdump backup status") or
        startswith("Pi.Alert Report") or
        startswith("A new device has logged in to your") or
        startswith("[Loomy] Bestellen") or
        endswith("just messaged you") or
        startswith("New sign-in to your Plex account") or
        startswith("New event: ") or
        startswith("Je ontving gisteren een pakje van ons") or
        endswith("sent you a connection request") or
        startswith("Security alert") or
        startswith("Documenten Maandelijkse mail documenten")

    )]' \
    | jq '.[].id' \
    | xargs -r himalaya message move '[Gmail]/Bin' --account $account;

    # remove from name based
    echo "$json" | jq '[
      .[] | select(
        .from.name == "'"'"'bpost'"'"' via administratie" or
        .from.name == "'"'"'Loomy (Shopify)'"'"' via winkel" or
        .from.name == "'"'"'Doccle'"'"' via administratie" or
        .from.name == "'"'"'Google Play'"'"' via hallo" or
        .from.name == "Aiven" or
        .from.name == "Amazon Prime" or
        .from.name == "Amazon.com.be" or
        .from.name == "Audible.co.uk" or
        .from.name == "bpost" or
        .from.name == "Doccle" or
        .from.name == "Broeikas" or
        .from.name == "Brussels Airlines" or
        .from.name == "Corey Quinn" or
        .from.name == "Cursor Team" or
        .from.name == "DFRobot Service" or
        .from.name == "Digital Ocean" or
        .from.name == "Duolingo" or
        .from.name == "Erlang Ecosystem Foundation" or
        .from.name == "Flux50" or
        .from.name == "Goodreads" or
        .from.name == "Google Scholar Alerts" or
        .from.name == "Google Scholar-meldingen" or
        .from.name == "Hoplr Erembodegem" or
        .from.name == "Jellow" or
        .from.name == "Le Petit Vapoteur" or
        .from.name == "LinkedIn Job Alerts" or
        .from.name == "LinkedIn" or
        .from.name == "Linux Foundation Education" or
        .from.name == "Mailchimp Account Insights" or
        .from.name == "Mannenzaak.be" or
        .from.name == "Miles & More" or
        .from.name == "Nostalux" or
        .from.name == "PayPal Communications" or
        .from.name == "Postmark Team" or
        .from.name == "Postmark" or
        .from.name == "Bonsai Shop" or
        .from.name == "Samsung" or
        .from.name == "Thangs3D" or
        .from.name == "The Philips Project." or
        .from.name == "Transmission Manager" or
        .from.name == "VUB Alumni" or
        .from.name == "Warp Team" or
        .from.name == "Basic-Fit" or
        .from.name == "Welcome to the Jungle" or
        .from.name == "Elixir Programming Languages Forum" or
        .from.name == "Wellfound" or
        (.from.name // "" | startswith("The Philips project role"))
        (.from.name // "" | contains("Testaankoop"))
        (.from.name // "" | contains("Helan"))
        (.from.name // "" | contains("Todoist"))
        (.from.name // "" | contains("EasyEDA"))
      )
    ]' \
    | jq '.[].id' \
    | xargs -r himalaya message move '[Gmail]/Bin' --account $account;


    # remove address-based
    echo "$json" | jq '[
      .[] | select(
        .from.addr == "updates-noreply@linkedin.com" or
        .from.addr == "jobalerts-noreply@linkedin.com" or
        .from.addr == "no-reply@trakt.tv" or
        .from.addr == "notifications@github.com" or
        .from.addr == "messages-noreply@linkedin.com" or
        .from.addr == "info@email.bol.com" or
        .from.addr == "info@editorial.theguardian.com" or
        .from.addr == "hello@tailscale.com" or
        .from.addr == "account-update@amazon.com.be" or
        .from.addr == "support@keychron.be" or
        (.from.addr // "" | endswith("@maxevent.be")) or
        .from.addr == "venyu@mail.beehiiv.com"
      )
    ]' \
    | jq '.[].id' \
    | xargs -r himalaya message move '[Gmail]/Bin' --account $account;


    ((page++))
  done

  echo "Finished processing account: $account"
  echo ""
done