---
name: mealie-import
description: Import a recipe from a URL (or from text) into the self-hosted Mealie at mealie.home.jonas-milkovits.com, mapped onto the curated foods, units, labels, tags and categories. Use when asked to add, import or save a recipe to Mealie, or to add foods, tags or labels there.
---

# Mealie import
> recipes go in clean: every ingredient linked to an existing food, English names, the curated vocabulary, nothing written without an approved preview

## Access
- base url: `https://mealie.home.jonas-milkovits.com/api` (Mealie v3, household slug `family`), reachable from the home network only
- token: the file `/run/secrets/mealie-api-token`, read by curl itself through `--variable tok@<file> --expand-header` so the value never enters a command line or the process list - never printed, copied or written anywhere
- every write needs the preview approved first, reads need no approval

## Workflow
1. read the vocabulary live, never from memory: `foods`, `units`, `groups/labels`, `organizers/tags`, `organizers/categories`, `recipes` (all with `?perPage=-1`)
2. read the recipe: the schema.org `Recipe` JSON-LD of the page (`curl -sSL -A "Mozilla/5.0"`, parse `<script type="application/ld+json">`, may sit inside `@graph`); a site that answers 403 is read with a fetch tool instead, its image is then added by hand
3. map each ingredient line to quantity / unit / food / note against the existing foods and units, translating German names
4. show the preview and wait for the OK:
    - table original line -> Mealie line, new foods marked with their proposed label
    - translated steps, category, tags, servings + yield, times, source url
    - every adaptation the user asked for (scaling, swaps, removals, toppings), and open questions
5. after the OK: create the new foods, create the empty recipe, patch the data, scrape only the image, read the recipe back and report it

Mealie's own url scraper and ingredient parser are not used: they create duplicate or German foods and import the site's categories as new categories or tags.

## Conventions
### Names and language
- recipe name, steps and food names in English; German recipes are translated
- "Vegan" is dropped from recipe names, everything is vegan
- vegan alternatives are named for what they are: `Vegan Butter` (not margarine), `Vegan Grated Cheese`, `Soy Cream`, `Soy Yoghurt`, `Soy Milk`
- distinct products stay distinct foods (`Tofu` / `Smoked Tofu`, dried `Oregano` / `Fresh Oregano`, `Corn on the Cob` / canned corn)
- brands and pack details go in the ingredient note, never in the food name

### Labels (by type, not by store layout)
- fresh produce and fresh herbs -> `Produce`, dried spices and blends, stock -> `Spices & Seasonings`
- all legumes, canned or dried -> `Legumes & Beans`
- tofu, tempeh, seitan, TVP, vital wheat gluten, hummus -> `Plant Protein`
- long-lasting staples always at home are marked on hand instead (`householdsWithIngredientFood: ["family"]`), e.g. salt, pepper, sugar, flour, common spice powders, nutritional yeast, vital wheat gluten, water

### Categories and tags
- category = the dish type (`Main`, `Side`, `Sauce`, `Breakfast`, ...), never the occasion
- occasion -> `occasion/...` tag, cuisine -> `cuisine/...`, form -> `format/...`
- protein tags by source: `protein/tofu`, `protein/tvp`, `protein/tempeh`, `protein/seitan`, `protein/legumes`
- `time/quick`: total time 20 minutes or less
- `diet/high_protein`: main dishes with an estimated 30 g protein or more per serving, never sides or components
- `mealprep`: keeps several days or freezes, eaten over multiple days
- a new tag needs the user's OK and an entry in the vault note (see below)

### Amounts, servings, times
- servings = countable pieces where possible (steaks, skewers, rolls), else portions; `recipeYield` carries the word (`steaks`, `portions (150g)`)
- liquids in ml, never decimal liters (Mealie renders 1.3 l as "1 ³/₁₀")
- times as `X minutes` / `X hours Y minutes`, prep + cook adding up to total
- no preheating: baking steps say "place in the cold oven" with 5-10 minutes more
- toppings and serving items are ingredients with a note (`for topping`, `for serving`), no redundant notes (`fresh` on a Produce food)
- section titles (`For the sauce`) when the source has them, no nutrition values

## API
```sh
B=https://mealie.home.jonas-milkovits.com/api
curl() { command curl -sS --variable tok@/run/secrets/mealie-api-token --expand-header "Authorization: Bearer {{tok:trim}}" "$@"; }
curl "$B/foods?perPage=-1"                                    # vocabulary reads, the function above adds the token
curl -X POST -H "Content-Type: application/json" "$B/foods" -d '{"name":"Dill","labelId":"<label id>"}'
curl -X POST -H "Content-Type: application/json" "$B/recipes" -d '{"name":"Cucumber Salad"}'   # returns the slug
curl -X PATCH -H "Content-Type: application/json" "$B/recipes/<slug>" -d @body.json
curl -X POST -H "Content-Type: application/json" "$B/recipes/<slug>/image" -d '{"url":"<image url>"}'
```

- the body shape for `PATCH /recipes/<slug>`: read one existing recipe and mirror it - two things it does not show:
    - `unit` and `food` are the full objects from the vocabulary reads, `unit: null` for counted items, `quantity: null` with unit `to taste`
    - `recipeIngredient`, `tags` and `recipeCategory` replace the whole list, so a single fix sends the read-back list with one entry changed
- `PUT /foods/<id>` takes the full food object without its `label` field, with `labelId`, `name` or `householdsWithIngredientFood` changed
- `POST /organizers/tags` with `{"name": "..."}` creates a tag
- the Groceries shopping list orders its sections by label: `PUT /households/shopping/lists/<id>/label-settings`

## Vault note
- the Mealie note in the Obsidian vault lists categories, tags and labels (labels in shopping list order) and mirrors Mealie - the user names the file when it is needed
- a new or removed tag, category or label is mirrored there, as its own proposed edit - vault edits need the user's approval
