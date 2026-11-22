# Price preview — UI notes

Free-form companion to `price-preview.feature`. The feature file says what the owner and guests experience; this file says how the screens deliver it. Draft for review before the green light.

## Owner screen (the app's start screen)

- One screen, usable on phone, tablet and laptop. On wide screens inputs sit left and the itemised price right; on a phone the itemised price sits below the inputs and the total stays visible.
- Counts (adults, children aged 7 to 15, children under 7, nights, washing machine uses) are steppers with − and +. At a limit the button is disabled; nothing is typed.
- Vehicle is a single-choice row of chips: none, camper, caravan, car, tent, motorbike, bicycle.
- Electricity is a switch.
- Guest language is a picker showing each language in its own name (English, Deutsch, Nederlands, Français, Polski, Türkçe, Српски).
- Reductions are chips 3 %, 5 %, 10 % (tapping the active chip clears it) plus an own-price field and a "Remove reduction" action while one applies.
- Own-price field accepts a numeric keyboard; the refusal message "Enter an amount like 40,00" sits directly under it in the error colour.
- While no price exists the price area shows the hint "Add an adult to see the price."; the own-price field and "Show to guests" are disabled.
- "Start again" is always available, without a confirmation dialog. Right after it, a "Go back to previous party" action appears (for example a snackbar action) until the first input for the next party.
- Owner-facing labels are always English; only the itemised price panel switches language.

## Guest view

- Opened with "Show to guests"; full screen, no owner inputs.
- Shows the itemised price, any reduction line and "To pay", worded in the guest language, with the language picker available.
- A clear "Back" returns to the owner screen with everything unchanged.
- Always light theme, whatever the device's dark mode.
- Readable at arm's length in sunlight: the total (or the amount to pay when a reduction applies) is at least 64 logical pixels tall, dark text on a light background with a contrast ratio of at least 7:1. Line text is at least 20 logical pixels.

## Amount format

- `14.121,00 €`: dot grouping, comma decimals, a space before €, the true minus sign `−` for amounts taken off. Same everywhere and in every language.

## Guest wording (draft — please correct)

| English | German | Dutch | French | Polish | Turkish | Serbian |
|---|---|---|---|---|---|---|
| 1 adult / 2 adults | 1 Erwachsener / 2 Erwachsene | 1 volwassene / 2 volwassenen | 1 adulte / 2 adultes | 1 dorosły / 2 dorosłych | 1 yetişkin / 2 yetişkin | 1 одрасла / 2 одрасле / 5 одраслих |
| child (7 to 15) / children (7 to 15) | Kind (7 bis 15) / Kinder (7 bis 15) | kind (7 t/m 15) / kinderen (7 t/m 15) | enfant (7 à 15 ans) / enfants (7 à 15 ans) | dziecko (7–15 lat) / dzieci (7–15 lat) | çocuk (7–15 yaş) | дете / 2 детета / 5 деце (7–15) |
| child (under 7) / children (under 7) | Kind (unter 7) / Kinder (unter 7) | kind (onder 7) / kinderen (onder 7) | enfant (moins de 7 ans) / enfants (moins de 7 ans) | dziecko (poniżej 7 lat) / dzieci (poniżej 7 lat) | çocuk (7 yaş altı) | дете / 2 детета / 5 деце (млађе од 7) |
| night / nights | Nacht / Nächte | nacht / nachten | nuit / nuits | noc / 2 noce / 5 nocy | gece | ноћ / ноћи |
| use / uses | Nutzung / Nutzungen | keer / keer | utilisation / utilisations | użycie / 2 użycia / 5 użyć | kullanım | коришћење / коришћења |
| free | kostenlos | gratis | gratuit | bezpłatnie | ücretsiz | бесплатно |
| Camper | Wohnmobil | Camper | Camping-car | Kamper | Karavan (motorlu) | Камп-возило |
| Caravan | Wohnwagen | Caravan | Caravane | Przyczepa kempingowa | Çekme karavan | Камп-приколица |
| Car | Auto | Auto | Voiture | Samochód | Araba | Аутомобил |
| Tent | Zelt | Tent | Tente | Namiot | Çadır | Шатор |
| Motorbike | Motorrad | Motor | Moto | Motocykl | Motosiklet | Мотоцикл |
| Bicycle | Fahrrad | Fiets | Vélo | Rower | Bisiklet | Бицикл |
| Electricity | Strom | Elektriciteit | Électricité | Prąd | Elektrik | Струја |
| Washing machine | Waschmaschine | Wasmachine | Machine à laver | Pralka | Çamaşır makinesi | Веш-машина |
| Tourist tax | Kurtaxe | Toeristenbelasting | Taxe de séjour | Opłata miejscowa | Turist vergisi | Боравишна такса |
| Total | Gesamt | Totaal | Total | Razem | Toplam | Укупно |
| Reduction | Rabatt | Korting | Réduction | Rabat | İndirim | Попуст |
| Adjusted price | Angepasster Preis | Aangepaste prijs | Prix ajusté | Cena skorygowana | Düzeltilmiş fiyat | Коригована цена |
| To pay | Zu zahlen | Te betalen | À payer | Do zapłaty | Ödenecek | За плаћање |

Polish and Serbian have more than two plural forms (e.g. Polish 2–4 vs 5+, Serbian 2–4 vs 5+); the implementation uses each language's own plural rules for these words.
