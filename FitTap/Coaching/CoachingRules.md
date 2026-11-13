# Coaching rules

What the coach suggests on an exercise's progress screen, why, and how sure we are. This file is the written source for the rules in `Rules/`: when a rule changes, both change together. It is also the knowledge the deeper analysis screen will hand to the larger model.

Last updated: 2026-11-13.

## How it works

- Swift rules read an exercise's logged sessions and pick one `Suggestion`. The same history always gives the same suggestion; no model takes part in the decision.
- `SuggestionWording` turns the suggestion into the title and sentence on the card. This is the step a language model takes over later.
- Tapping the card opens the Analysis screen, which will explain more than the card can.

## Words used below

| Word | Meaning |
|---|---|
| **Session** | One day the exercise was logged. |
| **Clean** | Every set done: nothing marked failed, and every set has the same reps. |
| **Missed set** | A set marked failed, or one logged with fewer reps than the rest. |
| **Straight session** | Every set used the same weight. Only these are judged. |
| **Top reps** | The most reps completed cleanly in the last ten sessions. The app learns this; the user never sets it. |
| **Step** | The next weight up or down that the user's equipment allows. |

## Decisions that shape the rules

- **A failed set only means "missed".** Its reps may still be the planned number, so the rules count missed sets and never read how many reps short a set was.
- **Effort feeds the rules.** Each exercise is rated easy, medium or hard after its sets. Medium is meant as "could have done one more rep". These definitions are not shown to the user yet.
- **Two sessions before moving up.** One good session never leads to "add", even when it felt easy.
- **No suggestion before three sessions.** An exercise needs three logged sessions in total.
- **Rest is not measured.** Timing rests is more than this app's user wants. "Try a longer rest" may appear as plain advice.
- **Reps or weight: we offer one.** The card says "add reps" or "add weight". How the two differ is explained on the Analysis screen, not on the card.

## The rules, in the order they are asked

The first rule that fits wins.

### 1. Stay (`StayRule`)

- **When:** the latest session missed any sets.
- **Says, up to half the sets missed:** "Stay at this weight. You finished most of your sets. Try a longer rest between them, and get them all before moving up."
- **Says, more than half missed:** "Stay at this weight. Most sets were missed this time. Keep this weight until you finish every set, or go down a step for one or two sessions."
- **Why:** missed sets mean the weight is at or past the limit for now. The step is to keep the weight until every set is done.
- **Source:** common coaching practice. "Go down a step" appears on coaching sites; no study supports a specific amount.

### 2. Done, but it was hard (`HardButDoneRule`)

- **When:** the latest session was clean and rated hard.
- **Says:** "Done, but it was hard. Repeat this until it feels medium, or add weight if you feel ready."
- **Why:** the sets were finished, so the weight isn't too heavy, but there was nothing left.
- **Source:** our own reading of the effort rating. Supported in principle by research on "reps in reserve": people judge how many reps they had left to within about one rep.

### 3. New weight achieved (`NewWeightRule`)

- **When:** the latest session was clean and heavier than the session before.
- **Says:** "New weight achieved. Hold it for one or two more sessions before moving up."
- **Why:** one clean session shows the weight can be done, not that it is settled.
- **Source:** our own rule. It fits the two-session idea below; no source found for it directly.

### 4. You got all your sets (`FirstCleanRule`)

- **When:** the latest session was clean, at the same weight as the session before, and that earlier session had missed sets.
- **Says:** "You got all your sets. Stay at this weight for one or two more sessions and let your body get used to it."
- **Why:** same as rule 3: done once is not settled.
- **Source:** our own rule; no source found for it directly.

### 5. Try heavier (`RepsClimbingRule`)

- **When:** the last three sessions were all clean at the same weight, and the reps went up each time (4×8, 4×9, 4×10).
- **Says:** "Try heavier. Your reps keep going up at this weight. Go up a step, you can do it."
- **Why:** double progression. Rising reps at one weight show the weight has become too light.
- **Source:** double progression is standard practice. "Three sessions, rising each time" is our own trigger.

### 6. Time to add weight (`AddWeightRule`)

- **When:** the last two sessions were both clean at the same weight and reps, the latest wasn't hard, and those reps are already the user's top reps.
- **Says:** "Time to add weight. Your top reps are going well. Go up one step; fewer reps is fine."
- **Why:** double progression: once the top of the range is repeated without a miss, the load goes up and the reps start again lower.
- **Source:** double progression, and the 2-for-2 rule for "two sessions in a row".

### 7. Time to add reps (`AddRepsRule`)

- **When:** the same as rule 6, but the reps are still below the user's top reps.
- **Says:** "Time to add reps. This weight is going well. Try one more rep per set."
- **Why:** one more rep is a smaller step than the next weight, especially on light loads.
- **Source:** the same as rule 6.

## When the coach says nothing

- Fewer than three sessions.
- The latest session used mixed weights, or is a bodyweight or hold exercise.
- The latest session was clean at a lighter weight than before (no rule yet).
- One clean session at medium or unrated that fits none of the rules above.

## Rules not written yet

- **Stalled:** three sessions in a row with misses still says "stay" every time. It should ease off instead.
- **Lighter and clean:** after going down a step, something like "one more session here, then go back up".
- **After a break:** start lighter than last time.
- **Jump size:** nothing checks whether the next step is too big (see the 2–10% finding below).

## What the research says

Checked on 2026-11-13 with a short web search. Most sources are study guides and summaries, not the original textbooks, so treat the numbers as conventions.

| Finding | Source | What it means for us |
|---|---|---|
| Adding reps and adding weight gave similar muscle growth over 8 weeks in 43 trained people. Strength gains leaned slightly toward adding weight; one of four muscles leaned slightly toward adding reps. | Plotkin et al. 2022 | Offering either is sound. The small differences are what the Analysis screen should explain. |
| "2-for-2": raise the load when the last set has two or more reps over the target, in two sessions in a row. One strong session doesn't count. | NSCA study guides | We follow the two-session part. We use clean sets and the effort rating in place of extra reps. |
| Raise the load by 2–10% when one or two reps over the planned number are possible. | ACSM position stand (2002 text; replaced in 2009, not re-checked) | On light weights a step is often over 10% (20 → 22.5 kg is 12.5%), so reps first is right there. |
| Typical steps: 1–2 kg for upper body, 2–4 kg for lower body, for smaller or less trained people. | CSCS study guide | Matches the plates most gyms have. |
| People judge "reps left" to within about one rep; beginners manage it too, better at lower reps. | Stronger by Science review and a 2022 novice study | Supports using easy / medium / hard as a signal. |
| Deloads reduce training stress to manage fatigue. One study summary found no strength or growth difference with or without them. | Bell et al. (NSCA journal), study summary | A "stalled" rule should be framed as easing off, not as a proven fix. No source supports "drop 10%". |

### Links

- Plotkin et al. 2022, load vs repetition progression: https://peerj.com/articles/14142
- ACSM position stand, Progression Models in Resistance Training: https://pubmed.ncbi.nlm.nih.gov/19204579/
- ACSM position stand, 2002 text: https://sfu.ca/~ryand/kin343/ACSMresistance.pdf
- CSCS study guide, program design (2-for-2 rule, load steps): https://open-exam-prep.com/study-guides/cscs/program-design/resistance-training-program-design
- NSCA-CPT study guide, progression plans: https://open-exam-prep.com/study-guides/nsca-cpt/acute-variables/progression-reassessment
- Stronger by Science, reps in reserve: https://www.strongerbyscience.com/reps-in-reserve
- Double progression, definition and examples: https://www.fitbudd.com/academy/double-progression-definition-and-examples
- Bell et al., A Practical Approach to Deloading: https://www.nsca.com/globalassets/certification/rscc/2026-renewal/scj--practical-guide-to-deloading.pdf
- Deloads, first study summary: https://biolayne.com/reps/issue-8/deloads-for-strength-and-physique-sports-the-first-study-to-explore-the-concept/
