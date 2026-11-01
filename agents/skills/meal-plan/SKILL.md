---
name: meal-plan
description: Plan the next week's meals in the self-hosted Mealie (mealie.home.jonas-milkovits.com) and build the Groceries shopping list from that plan. Use when asked to plan meals, propose a meal plan, fill the meal planner, or create the shopping list for the week - also when a scheduled run asks for it.
---

# Meal plan
> one week of meals for one person from the recipes in Mealie, written as a proposal the user edits, then turned into one shopping list

## Access
- same Mealie, token and curl function as the `mealie-import` skill: base url `https://mealie.home.jonas-milkovits.com/api`, token file `/run/secrets/mealie-api-token`, never printed
- reads need no approval
- writes: in an interactive session, show the plan or the list first and wait for the OK; in a scheduled run the prompt itself is the approval for exactly the two writes below, nothing else
- never delete or change existing meal plan entries, recipes, foods or shopping list items

## Two tasks
| Task | When | Writes |
| --- | --- | --- |
| propose the plan | Friday, for Monday-Sunday of next week | meal plan entries |
| build the list | Saturday morning, from the plan as the user left it | items on the `Groceries` list |

Each ends with a short summary (a few lines, plain text) that a notification can carry.

## Propose the plan
### Read first
- all recipes with tags, category, servings, yield, total time and rating
- the meal plan of the target week: if it already has entries, stop and report - no second plan on top
- the meal plans of the last 3 weeks, to avoid repeats

### Slots
- every day gets 4 entries: `breakfast`, `lunch`, `snack`, `dinner` - no empty slots, the user replaces entries when plans change
- one person: a recipe with 4 portions covers 4 meals

### Rules
- **meal prep:** batches are cooked on Sunday; lunch is always a meal prep portion (`mealprep` tag, category `Main`)
    - usually 2 batches a week, sized so lunches and the meal prep dinners use them up by Sunday
    - a batch recipe is planned in full: its portions spread over the week's lunches and dinners
    - portions eaten more than 4 days after Sunday are frozen on Sunday - the summary says which
- **dinner:** 3-4 from the meal prep batches, the rest quick (`time/quick` or about 30 minutes total, e.g. the air fryer bowl, TVP Italian Beef)
- **breakfast:** rotates through the `Breakfast` recipes; a meal prep breakfast (jars, casserole, egg muffins) covers as many days as it has portions; quick ones on the other days
- **snack:** the post-workout protein shake every day
- **protein bases:** a recipe that needs Chickwheat, seitan sausages, seitan steaks or Tray Seitan gets that base on the Sunday before, as an entry with `text` "Sunday prep: <base>", unless a batch is likely still in the freezer
- **protein:** aim for 130-160 g a day, estimated from the ingredients; prefer `diet/high_protein` recipes
- **variety:** different protein sources and cuisines across the week; no recipe from the last 2 weeks unless it is a breakfast or the shake; higher rated recipes first; at most 1 recipe the user has never had
- **3 layers** (weekly goal, not daily): legumes most days, leafy greens and cruciferous veg several times (the garlic kale salad as a side while kale is in season, roughly October to February), berries several times (yoghurt bowl, overnight oats)
- **season:** no kale outside its season, use the salad's noted alternatives

### Write
- `POST /households/mealplans` per entry: `{"date": "YYYY-MM-DD", "entryType": "lunch", "recipeId": "<id>"}`; a note-only entry uses `title` and `text` instead of `recipeId`
- read the week back and summarize: batches to cook on Sunday, the dinners, any Sunday prep, the estimated protein range per day

## Build the list
### Read first
- the plan of the target week as it is now (the user may have edited it)
- every planned recipe, and every recipe linked inside one (`referencedRecipe`), recursively
- the `Groceries` list and its unchecked items
- the foods with their labels and on-hand state

### Amounts
- a meal prep batch counts once per batch, whole recipe, however many entries share it
- other recipes: planned portions / recipe servings, rounded up to the next half recipe
- a linked recipe contributes its own ingredients at the linked quantity (servings of the linked recipe / its servings), not itself
- a linked recipe that is itself planned as a batch that week adds nothing - the batch already covers it
- convert to one unit per food before merging: tbsp = 15 ml, tsp = 5 ml, a smoked tofu pack = 175 g, a protein powder serving = 30 g; count-based amounts stay counts
- merge equal food + unit; keep the larger note where they differ
- leave out foods that are on hand (`householdsWithIngredientFood` contains `family`)
- `to taste` items that are not on hand go on the list once, without quantity
- round up to what a shop sells: whole pieces (1 cucumber, 2 limes), a head of garlic for 6 or more cloves, whole cans and packs (175 g smoked tofu, 1 l soy milk cartons)
- the fallback staples come on top of the plan, once a week: 1 pack smoked tofu, 1 bag frozen edamame, 1 soy yoghurt - added to the planned amount, not as a second line

### Write
- `POST /households/shopping/items/create-bulk` with a list of `{"shoppingListId", "foodId", "unitId", "quantity", "note", "labelId"}` - the food's own label, so the list sorts by aisle
- an unchecked item already on the list with the same food and unit is not added again
- summarize: number of items, anything unusual (a rare product, a big amount), then the Sunday cook plan

### Sunday cook plan
> part of the Saturday summary, short enough for a notification - what to cook, in what order, in what amount
- one line per batch: recipe, multiplier (`x1`), portions, which portions to freeze (eaten more than 4 days after Sunday)
- the cooking order with rough times: seitan bases first, they need to cool - then the oven dish - stove dishes in parallel - cold things last (the kale salad, filling the overnight oats jars)
- Sunday prep entries from the plan (`Sunday prep: <base>`) are batches too and go first
- no overview of the week, the plan in Mealie has it

## Not part of this skill
- the schedule (systemd timers) and the notification (ntfy) live in the Nix config; a run calls one of the two tasks and passes the summary on
