# AI understanding — review before green light
# Agreed: The campsite owner previews an exact itemised price for a party that has arrived and is not checked in, before check-in. He provides adults, children aged 7 to 15, children under 7, at most one vehicle, electricity, nights and washing machine uses, and the price follows the fixed rates in every step. A price exists only once the party has at least one adult. He may reduce it by 3, 5 or 10 percent or replace it with an own price, and he can show the itemised price to the guests in a separate guest view, worded in one of seven guest languages with identical figures. He can start again for the next party and bring the previous party back until he provides the first input for the next one. Nothing about any party is stored.
# Decisions: Where does the preview live -> it is the app's start screen; tag board, check-in and checkout are out of scope
# Decisions: Rates -> fixed: adult 7,00, child 7 to 15 4,00, child under 7 free, camper 11,00, caravan 6,00, car 5,00, tent 3,00, motorbike 2,00, bicycle 1,00, electricity 3,00, all per night; washing machine 4,00 per use
# Decisions: Tourist tax -> 1,00 € per adult and per child aged 7 to 15, per night; children under 7 never pay it (changes the source document's once-per-stay rule)
# Decisions: Total -> nights × (8 × adults + 5 × children aged 7 to 15 + vehicle rate + 3 if electricity) + 4 × washing machine uses
# Decisions: Same price at check-in and checkout -> noted; only the preview is checkable in this feature
# Decisions: Who may use it -> anyone using the device; there are no roles and no sign-in
# Decisions: When does a price exist -> only with at least one adult; children of any age without an adult give no price (changes the source document)
# Decisions: What the owner gets while no price exists -> the hint "Add an adult to see the price."; no own price and no showing to guests
# Decisions: Limits -> adults, children and washing machine uses 0 to 20, nights 1 to 60; asking beyond a limit leaves the value at the limit
# Decisions: Amount format -> euros with dot grouping and comma decimals, e.g. 16.520,00 €, identical in every language
# Decisions: Line order -> vehicle, adults, children aged 7 to 15, children under 7, electricity, washing machine, tourist tax, then total; singular and plural forms ("1 adult", "1 night", "2 children")
# Decisions: Percentage reduction -> 3, 5 or 10 percent of the total; choosing the active one again removes it; choosing another replaces it; it follows input changes
# Decisions: Rounding -> only the amount to pay after a percentage, to the nearest 0,10 €, an exact half rounding up; amount taken off is total minus amount to pay
# Decisions: Own price -> replaces the total, lower or higher, with no warning; never rounded; stays fixed when inputs change
# Decisions: Own price accepted -> digits with at most one comma or dot as decimal separator, at most two decimals, above 0 and at most 99.999,99 €
# Decisions: Own price refused -> letters, euro sign, spaces, minus, two separators (including 1.234,50), three or more decimals, zero, above 99.999,99 €
# Decisions: Refused own price -> the owner is told "Enter an amount like 40,00"; the previous amount to pay and reduction stand; the message goes on the next accepted entry
# Decisions: Reduction line -> own price below the total gives "Reduction" with the amount taken off; equal gives "Reduction" 0,00 € with no sign; above gives "Adjusted price" with no sign
# Decisions: Percentage and own price together -> never; providing either removes the other
# Decisions: Removing every adult -> no price, and any reduction (percentage or own price) is removed
# Decisions: Guests -> read the price in a separate guest view, available only while a price exists; returning from it changes nothing
# Decisions: Guest language -> English, German, Dutch, French, Polish, Turkish, Serbian (Cyrillic); one shared choice made from the owner's work or from the guest view
# Decisions: What changes language -> the itemised price for the owner and for the guests; everything else the owner works with stays in English
# Decisions: Translations -> drafted by the AI in features/price-preview.ui.md for the user to correct before the green light
# Decisions: Offline -> every guest language works with no connection
# Decisions: Readable in sunlight -> checked by the size and contrast rule in features/price-preview.ui.md
# Decisions: Start again -> no confirmation; every input, reduction and the guest language return to starting values
# Decisions: Go back -> restores the previous party until the first input for the next party; a guest language choice counts as an input
# Decisions: Reopening the app -> nothing is kept and there is no party to go back to
# Decisions: UI details -> described separately in features/price-preview.ui.md, not in this file
# Out of scope: tag board, check-in, checkout, editing rates, storing or syncing any party, printing or exporting the price, number formats that follow the language
# Checkable by: widget tests binding every scenario below; screenshots of the owner's work and the guest view in English, Dutch and Serbian; a probe of the guest-view total's size and contrast as stated in features/price-preview.ui.md

Feature: Preview the price of a stay
  The campsite owner gets an exact, itemised price for a party before check-in,
  can reduce it, and shows it to the guests in their own language.
  Afterwards he starts again for the next party and nothing is kept.

  Rule: A price exists only once the party has an adult

    Scenario: Price preview 01 - Nothing is priced before the owner begins
      Given the owner has provided nothing yet
      When the owner begins a price preview
      Then no price exists
      And the owner is told "Add an adult to see the price."
      And every input is at its starting value:
        | input                 | starting value |
        | adults                | 0              |
        | children aged 7 to 15 | 0              |
        | children under 7      | 0              |
        | vehicle               | none           |
        | electricity           | not wanted     |
        | nights                | 1              |
        | washing machine uses  | 0              |
        | guest language        | English        |
        | reduction             | none           |

    Scenario Outline: Price preview 02 - Children without an adult give no price
      Given the owner has provided <children> and no adult
      Then no price exists
      And the owner is told "Add an adult to see the price."
      And the owner cannot provide an own price
      And the owner cannot show the price to the guests

      Examples:
        | children                                      |
        | 3 children under 7                            |
        | 2 children aged 7 to 15                       |
        | 2 children aged 7 to 15 and 1 child under 7   |

    Scenario: Price preview 03 - The first adult brings the price
      Given the owner has provided nothing yet
      When the owner provides 1 adult
      Then the total is 8,00 €

  Rule: The price follows the rates for every input

    Scenario: Price preview 04 - The worked example is itemised line by line
      Given the owner has provided 3 nights, 2 adults, 1 child aged 7 to 15, 1 child under 7, a camper and electricity
      Then the itemised price is:
        | line              | worked out as          | amount   |
        | Camper            | 3 nights × 11,00 €     | 33,00 €  |
        | 2 adults          | 2 × 3 nights × 7,00 €  | 42,00 €  |
        | 1 child (7 to 15) | 1 × 3 nights × 4,00 €  | 12,00 €  |
        | 1 child (under 7) | free                   | 0,00 €   |
        | Electricity       | 3 nights × 3,00 €      | 9,00 €   |
        | Tourist tax       | 3 × 3 nights × 1,00 €  | 9,00 €   |
        | Total             |                        | 105,00 € |

    Scenario Outline: Price preview 05 - The total matches the rates to the cent
      Given the owner has provided <nights> nights, <adults> adults, <children> children aged 7 to 15, <small> children under 7, vehicle "<vehicle>", electricity "<electricity>" and <washes> washing machine uses
      Then the total is <total>

      Examples:
        | nights | adults | children | small | vehicle   | electricity | washes | total       |
        | 1      | 1      | 0        | 0     | none      | not wanted  | 0      | 8,00 €      |
        | 3      | 2      | 1        | 1     | camper    | wanted      | 0      | 105,00 €    |
        | 5      | 2      | 0        | 0     | caravan   | not wanted  | 0      | 110,00 €    |
        | 1      | 3      | 0        | 0     | tent      | not wanted  | 0      | 27,00 €     |
        | 2      | 1      | 0        | 5     | bicycle   | not wanted  | 3      | 30,00 €     |
        | 4      | 1      | 2        | 0     | motorbike | wanted      | 1      | 96,00 €     |
        | 60     | 20     | 20       | 20    | camper    | wanted      | 20     | 16.520,00 € |

    Scenario Outline: Price preview 06 - Each input shows in the price before the next one
      Given the owner has provided 2 adults for 1 night
      And the total is 16,00 €
      When the owner changes <input> to <value>
      Then the total is <total>
      And every other input is unchanged

      Examples:
        | input                 | value  | total   |
        | electricity           | wanted | 19,00 € |
        | nights                | 2      | 32,00 € |
        | vehicle               | car    | 21,00 € |
        | washing machine uses  | 1      | 20,00 € |
        | children aged 7 to 15 | 1      | 21,00 € |
        | children under 7      | 2      | 16,00 € |
        | adults                | 3      | 24,00 € |

    Scenario: Price preview 07 - Only the newly chosen vehicle applies
      Given the owner has provided 3 nights, 2 adults and a camper
      When the owner chooses a car instead
      Then the itemised price has the line "Car" worked out as "3 nights × 5,00 €" for 15,00 €
      And the itemised price has no line "Camper"
      And the total is 63,00 €

    Scenario: Price preview 08 - Electricity is charged for every night
      Given the owner has provided 1 night, 2 adults and electricity
      When the owner changes the nights to 4
      Then the itemised price has the line "Electricity" worked out as "4 nights × 3,00 €" for 12,00 €

    Scenario: Price preview 09 - Washing machine uses do not depend on the nights
      Given the owner has provided 1 night, 2 adults and 2 washing machine uses
      When the owner changes the nights to 5
      Then the itemised price has the line "Washing machine" worked out as "2 uses × 4,00 €" for 8,00 €

    Scenario Outline: Price preview 10 - The tourist tax is charged per adult and child aged 7 to 15, per night
      Given the owner has provided <nights> nights, <adults> adults, <children> children aged 7 to 15 and <small> children under 7
      Then the itemised price has the line "Tourist tax" worked out as "<worked out as>" for <amount>
      And the itemised price has exactly one tourist tax line

      Examples:
        | nights | adults | children | small | worked out as          | amount     |
        | 1      | 1      | 0        | 0     | 1 × 1 night × 1,00 €   | 1,00 €     |
        | 3      | 2      | 1        | 1     | 3 × 3 nights × 1,00 €  | 9,00 €     |
        | 2      | 1      | 0        | 5     | 1 × 2 nights × 1,00 €  | 2,00 €     |
        | 60     | 20     | 20       | 20    | 40 × 60 nights × 1,00 € | 2.400,00 € |

    Scenario: Price preview 11 - Items with nothing to charge have no line, except children under 7
      Given the owner has provided 1 night, 1 adult and 4 children under 7
      Then the itemised price has the line "4 children (under 7)" worked out as "free" for 0,00 €
      And the itemised price has no line for a vehicle, children aged 7 to 15, electricity or the washing machine

    Scenario: Price preview 12 - Free amenities never appear in the price
      Given the owner has provided 3 nights, 2 adults, 1 child aged 7 to 15, 1 child under 7, a camper and electricity
      Then the itemised price has no line for water, waste disposal, showers, the fridge or the pools

    Scenario Outline: Price preview 13 - Inputs stay within their limits
      Given <input> is <value>
      When the owner asks for <direction>
      Then <input> stays <value>

      Examples:
        | input                 | value | direction |
        | nights                | 1     | fewer     |
        | nights                | 60    | more      |
        | adults                | 0     | fewer     |
        | adults                | 20    | more      |
        | children aged 7 to 15 | 0     | fewer     |
        | children aged 7 to 15 | 20    | more      |
        | children under 7      | 0     | fewer     |
        | children under 7      | 20    | more      |
        | washing machine uses  | 0     | fewer     |
        | washing machine uses  | 20    | more      |

  Rule: A percentage reduction takes 3, 5 or 10 percent off, rounded once to 0,10 €

    Scenario Outline: Price preview 14 - The amount to pay is rounded to the nearest 0,10 €
      Given the calculated total is <total>
      When the owner chooses a <percent> % reduction
      Then the price shows the total <total>, the reduction "Reduction <percent> %" of <taken off> and the amount to pay <to pay>

      Examples:
        | total    | percent | taken off | to pay   |
        | 101,00 € | 10      | −10,10 €  | 90,90 €  |
        | 97,00 €  | 3       | −2,90 €   | 94,10 €  |
        | 101,00 € | 3       | −3,00 €   | 98,00 €  |
        | 359,00 € | 3       | −10,80 €  | 348,20 € |
        | 25,00 €  | 5       | −1,20 €   | 23,80 €  |
        | 97,00 €  | 5       | −4,80 €   | 92,20 €  |
        | 105,00 € | 10      | −10,50 €  | 94,50 €  |

    Scenario: Price preview 15 - Choosing the active percentage again removes it
      Given a 10 % reduction applies to a total of 101,00 €
      When the owner chooses the 10 % reduction again
      Then no reduction applies
      And the amount to pay is the total 101,00 €

    Scenario: Price preview 16 - A different percentage replaces the active one
      Given a 10 % reduction applies to a total of 101,00 €
      When the owner chooses a 5 % reduction
      Then only the 5 % reduction applies
      And the amount to pay is 96,00 €

    Scenario: Price preview 17 - A percentage follows a change of inputs
      Given the owner has provided 5 nights, 2 adults and a caravan
      And a 10 % reduction applies to a total of 110,00 €
      When the owner changes the nights to 6
      Then the price shows the total 132,00 €, the reduction "Reduction 10 %" of −13,20 € and the amount to pay 118,80 €

  Rule: An own price replaces the total, is never rounded and stays fixed

    Scenario Outline: Price preview 18 - An own price lower, equal or higher than the total
      Given the calculated total is 97,00 €
      When the owner provides an own price of "<own price>"
      Then the price shows the total 97,00 €, the line "<line>" of <difference> and the amount to pay <to pay>
      And the owner gets no warning

      Examples:
        | own price | line           | difference | to pay   |
        | 40,00     | Reduction      | −57,00 €   | 40,00 €  |
        | 96,99     | Reduction      | −0,01 €    | 96,99 €  |
        | 97,00     | Reduction      | 0,00 €     | 97,00 €  |
        | 110,00    | Adjusted price | 13,00 €    | 110,00 € |

    Scenario Outline: Price preview 19 - Own prices the owner may provide
      Given the calculated total is 97,00 €
      When the owner provides an own price of "<entry>"
      Then the amount to pay is <to pay>

      Examples:
        | entry    | to pay      |
        | 40       | 40,00 €     |
        | 40,5     | 40,50 €     |
        | 40.50    | 40,50 €     |
        | 0,01     | 0,01 €      |
        | 1234,50  | 1.234,50 €  |
        | 99999,99 | 99.999,99 € |

    Scenario Outline: Price preview 20 - A refused own price leaves the previous amount to pay standing
      Given a 10 % reduction applies to a total of 101,00 €
      When the owner provides an own price of "<entry>"
      Then the own price is refused
      And the owner is told "Enter an amount like 40,00"
      And the 10 % reduction still applies
      And the amount to pay is 90,90 €

      Examples:
        | entry     |
        | 40a       |
        | 1.234,50  |
        | 40.5.0    |
        | 40,505    |
        | 0         |
        | 0,00      |
        | -40       |
        | 40 €      |
        | 4 0       |
        | 100000    |
        | 99999,999 |

    Scenario: Price preview 21 - The refusal message goes once an own price is accepted
      Given the owner was told "Enter an amount like 40,00"
      When the owner provides an own price of "40,00"
      Then the amount to pay is 40,00 €
      And the owner is no longer told "Enter an amount like 40,00"

    Scenario: Price preview 22 - An own price stays fixed when inputs change
      Given the owner has provided 5 nights, 2 adults and a caravan
      And an own price of 40,00 € applies
      When the owner changes the nights to 6
      Then the total is 132,00 €
      And the amount to pay stays 40,00 €

    Scenario: Price preview 23 - An own price replaces a percentage
      Given a 10 % reduction applies to a total of 101,00 €
      When the owner provides an own price of "40,00"
      Then only the own price applies
      And the amount to pay is 40,00 €

    Scenario: Price preview 24 - A percentage replaces an own price
      Given an own price of 40,00 € applies to a total of 101,00 €
      When the owner chooses a 5 % reduction
      Then only the 5 % reduction applies
      And the amount to pay is 96,00 €

  Rule: The owner can always return to the calculated price

    Scenario Outline: Price preview 25 - Removing a reduction brings back the calculated total
      Given the owner has provided 5 nights, 2 adults and a caravan
      And <reduction> applies
      When the owner removes the reduction
      Then no reduction applies
      And the amount to pay is the total 110,00 €
      And every input is unchanged

      Examples:
        | reduction                |
        | a 10 % reduction         |
        | an own price of 40,00 €  |
        | an own price of 120,00 € |

    Scenario Outline: Price preview 26 - Removing every adult removes the price and its reduction
      Given the owner has provided 5 nights, 2 adults, 1 child aged 7 to 15 and a caravan
      And <reduction> applies
      When the owner removes every adult
      Then no price exists
      And no reduction applies
      When the owner provides 2 adults again
      Then the amount to pay is the total 135,00 €

      Examples:
        | reduction               |
        | a 10 % reduction        |
        | an own price of 40,00 € |

  Rule: The guests read the itemised price in a view of their own

    Scenario: Price preview 27 - The guests see every line, the reduction and the amount to pay
      Given the owner has provided 3 nights, 2 adults, 1 child aged 7 to 15, 1 child under 7, a camper and electricity
      And a 10 % reduction applies
      When the owner shows the price to the guests
      Then the guests see the itemised price:
        | line              | worked out as          | amount   |
        | Camper            | 3 nights × 11,00 €     | 33,00 €  |
        | 2 adults          | 2 × 3 nights × 7,00 €  | 42,00 €  |
        | 1 child (7 to 15) | 1 × 3 nights × 4,00 €  | 12,00 €  |
        | 1 child (under 7) | free                   | 0,00 €   |
        | Electricity       | 3 nights × 3,00 €      | 9,00 €   |
        | Tourist tax       | 3 × 3 nights × 1,00 €  | 9,00 €   |
        | Total             |                        | 105,00 € |
        | Reduction 10 %    |                        | −10,50 € |
        | To pay            |                        | 94,50 €  |

    Scenario: Price preview 28 - The guests can read the total at arm's length in sunlight
      Given the owner is showing the price to the guests
      Then the total is readable at arm's length in sunlight

    Scenario: Price preview 29 - The price cannot be shown to the guests while no price exists
      Given no price exists
      Then the owner cannot show the price to the guests

    Scenario: Price preview 30 - Returning from the guests changes nothing
      Given the owner is showing the guests a price of 105,00 € with a 10 % reduction in Dutch
      When the owner returns to his own work
      Then every input, the 10 % reduction and the guest language Dutch are unchanged
      And the amount to pay is 94,50 €

  Rule: The itemised price is worded in the guest language and its figures never change

    Scenario Outline: Price preview 31 - The itemised price is worded in the chosen guest language
      Given the owner has provided 3 nights, 2 adults, 1 child aged 7 to 15, 1 child under 7, a camper and electricity
      And a 10 % reduction applies
      When the owner chooses <language> as the guest language
      Then the owner and the guests read every word of the itemised price in <language>
      And the itemised price has the lines "<adults line>", "<tourist tax>", "<total>" and "<to pay>"
      And the child under 7 is worked out as "<free>"

      Examples:
        | language | adults line   | free       | tourist tax        | total   | to pay      |
        | English  | 2 adults      | free       | Tourist tax        | Total   | To pay      |
        | German   | 2 Erwachsene  | kostenlos  | Kurtaxe            | Gesamt  | Zu zahlen   |
        | Dutch    | 2 volwassenen | gratis     | Toeristenbelasting | Totaal  | Te betalen  |
        | French   | 2 adultes     | gratuit    | Taxe de séjour     | Total   | À payer     |
        | Polish   | 2 dorosłych   | bezpłatnie | Opłata miejscowa   | Razem   | Do zapłaty  |
        | Turkish  | 2 yetişkin    | ücretsiz   | Turist vergisi     | Toplam  | Ödenecek    |
        | Serbian  | 2 одрасле     | бесплатно  | Боравишна такса    | Укупно  | За плаћање  |

    Scenario Outline: Price preview 32 - Every figure is identical in every guest language
      Given the owner has provided 3 nights, 2 adults, 1 child aged 7 to 15, 1 child under 7, a camper and electricity
      And a 10 % reduction applies
      When the owner chooses <language> as the guest language
      Then the amounts in the itemised price are 33,00 €, 42,00 €, 12,00 €, 0,00 €, 9,00 €, 9,00 €, 105,00 €, −10,50 € and 94,50 €
      And the rates and counts are the same as in English

      Examples:
        | language |
        | German   |
        | Dutch    |
        | French   |
        | Polish   |
        | Turkish  |
        | Serbian  |

    Scenario: Price preview 33 - Large amounts keep one format in every guest language
      Given the owner has provided 60 nights, 20 adults, 20 children aged 7 to 15, 20 children under 7, a camper, electricity and 20 washing machine uses
      When the owner chooses Polish as the guest language
      Then the total is 16.520,00 €

    Scenario: Price preview 34 - The guest language chosen while showing the guests is the one choice
      Given the owner is showing the price to the guests in English
      When the owner chooses French as the guest language
      Then the guests read the itemised price in French
      And after the owner returns to his own work, the guest language is French

    Scenario: Price preview 35 - Only the itemised price changes language
      Given the owner has provided 2 adults for 1 night
      When the owner chooses Turkish as the guest language
      Then everything else the owner works with stays in English

    Scenario: Price preview 36 - Every guest language works without a connection
      Given the device has no connection
      And the owner has provided 2 adults for 1 night
      When the owner chooses Serbian as the guest language
      Then the owner and the guests read every word of the itemised price in Serbian

  Rule: Starting again keeps nothing, but a mistaken start again can be undone

    Scenario: Price preview 37 - Starting again returns every input to its starting value
      Given the owner has provided 3 nights, 2 adults, 1 child aged 7 to 15, 1 child under 7, a camper and electricity
      And a 10 % reduction applies
      And the guest language is Dutch
      When the owner starts again for the next party
      Then no price exists
      And every input is at its starting value
      And no reduction applies
      And the guest language is English

    Scenario: Price preview 38 - Going back after a mistaken start again restores the previous party
      Given the owner priced a party of 3 nights, 2 adults, 1 child aged 7 to 15, 1 child under 7, a camper and electricity with a 10 % reduction in Dutch
      And the owner has started again for the next party
      When the owner goes back to the previous party
      Then every input of the previous party returns
      And the 10 % reduction applies
      And the guest language is Dutch
      And the amount to pay is 94,50 €

    Scenario Outline: Price preview 39 - The previous party is gone once the next party has an input
      Given the owner priced a party of 5 nights, 2 adults and a caravan
      And the owner has started again for the next party
      When the owner provides <input> for the next party
      Then the owner cannot go back to the previous party

      Examples:
        | input                     |
        | 1 adult                   |
        | 2 nights                  |
        | Turkish as guest language |

    Scenario: Price preview 40 - Nothing is kept when the app is opened again
      Given the owner has provided 5 nights, 2 adults and a caravan
      When the app is closed and opened again
      Then no price exists
      And every input is at its starting value
      And the owner cannot go back to the previous party
