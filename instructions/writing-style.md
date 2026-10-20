<!-- load: eager | when: Writing any prose, including chat replies -->

<!-- style-check: skip-file (this file quotes the banned patterns on purpose) -->

# Writing Style

Applies to all prose you produce: READMEs, docs, PR descriptions, commit bodies, comments, and chat replies.

## Shape

- Lead with the thing. Command, answer, or conclusion first. Explanation underneath.
- Bullets over paragraphs. If a paragraph runs past 3 sentences, it should probably be a list.
- Intro sections are 2 sentences maximum. No "in this document we will".
- Anything longer than 5 lines of supporting detail goes in a `<details>` block or a link to another page.
- A reader should be able to scroll the page in 10 seconds and know whether it is worth reading closely.
- Reference docs to imitate: Stripe API, FastAPI, Django, MDN.

## Banned

Never use these. They are checked by `scripts/style-check.sh`.

- Em dashes. Use a comma, a colon, parentheses, or two sentences.
- Emoji, anywhere, including headings and bullet markers.
- Words: load-bearing, seam, genuinely, crucial, delve, robust, leverage (as a verb), elegant, powerful, seamless, journey.
- Phrases: "it's not just X, it's Y", "that said", "at the end of the day", "it's worth noting", "in today's world", "let's dive in".

## Rewrites

Contrastive parallelism. Say the thing once.

```
Bad:  The real bottleneck: connections, not CPU.
Good: Connections are the bottleneck.

Bad:  This isn't a config change, it's an architecture change.
Good: This changes the architecture.
```

Filler vocabulary.

```
Bad:  This creates a natural seam for testing.
Good: You can test this part on its own.

Bad:  The retry logic is load-bearing here.
Good: Removing the retry logic breaks reconnection.
```

Narration.

```
Bad:  Now that we've covered installation, let's take a look at how
      configuration works. Configuration is an important part of the
      system and there are several options available to you.
Good: ## Configuration
      - `TIMEOUT` (default 30) seconds before a request is dropped
      - `RETRIES` (default 3) attempts per request
```

Hedging stacked on hedging.

```
Bad:  It's worth noting that this may potentially cause issues in
      some cases.
Good: This fails when the cache is cold.
```

## Honesty

- If something was not tested, say so. Do not describe untested code as working.
- If a step was skipped, say which one and why.
- No "production-ready", "battle-tested", or "enterprise-grade" unless there is evidence.
