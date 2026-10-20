# References

List of resources, blogs, documentation, posts that I used for inspiration.

## Integrating Agents into Workflow

- [Mitchell Hashimoto's AI Adoption Journey](https://mitchellh.com/writing/my-ai-adoption-journey) - some inspiration
- [Kun Chen's dotfiles](https://github.com/kunchenguid/dotfiles) - inspiration for agentic config repo

## Agent Skills

- [Claude Docs on Writing Skills](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) - Reference/starting point
- [Matt Pocock Skills](https://github.com/mattpocock/skills) - I don't actually use this, but it gave some ideas

## Agent Instructions

- [agents.md](https://agents.md/) - what agents.md does
- Examples from production code-bases:
  - Apache Airflow's [AGENTS.md](https://github.com/apache/airflow/blob/main/AGENTS.md)
  - OpenAI Python's [AGENTS.md](https://github.com/openai/openai-python/blob/main/AGENTS.md)

## Design Principles

- Mitchell Hashimoto's ["Whiteboard Defense"](https://x.com/mitchellh/status/2100249348345057389?lang=en) - idea of how to use AI responsibily, maintain some level of ownership/responsibility (otherwise why have me at all)

    ```txt
    The "whiteboard defense:" I should be able to pull you aside at any moment and ask you to explain any customer-facing system you've shipped. You should be able to clearly explain how it works and defend the decisions you made. This is my benchmark for responsible AI usage.

    I don't expect line-level familiarity with the code. I don't care if you remember the exact function name or implementation detail. You may not even know it. I don't care.

    But if I ask "why did you do X instead of Y?", "what happens if this actor behaves maliciously?", "what data structure did you use here and why?", or "where does this fail?" you should be able to answer confidently.

    For PoCs, demos, experiments, whatever: I don't care. Generate 100% of it and understand none of it. Speed over quality every time in those specific scenarios.

    But if you're shipping customer-facing work, you can't be shipping things you don't understand at a high level.
    ```

- [Your brain on chatgpt: Accumulation of cognitive debt when using an ai assistant for essay writing task](https://www.media.mit.edu/publications/your-brain-on-chatgpt/) - MIT paper on cognitive debt from LLM-assisted essay writing. Any usage of LLM will likely produce some cognitive debt to me, the least I can do is limit how much debt I accumulate and what areas to focus on

## Other Resources

- [Karpathy's LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) - idea of how to build personal knowledge base using LLMs, whilst I would like to handwrite all this, often I'm burnt out after work, so having LLM at least jot down key notes and let me review them on another day I have free time to re-write them is a huge win, even better for it to organize things, let me focus on jotting down and retaining knowledge/info
