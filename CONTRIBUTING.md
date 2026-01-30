# Contributing to Agent Skills

## Adding a New Skill

1. Copy `templates/skill-template/` to `skills/your-skill/`
2. Fill in SKILL.md, README.md
3. Test locally in `~/clawd/skills/`
4. Submit PR

## Skill Structure

```
skills/your-skill/
├── SKILL.md           # Required: What it does, how to use
├── README.md          # Required: Quick start
├── CONTRIBUTING.md    # Optional: Specific to this skill
├── scripts/           # Required: Entry points
│   └── main.sh
└── examples/          # Optional: Usage examples
```

## Dependencies Between Skills

Document them in SKILL.md:

```markdown
## Dependencies
- [other-skill](../other-skill/) - Required for auth
```
