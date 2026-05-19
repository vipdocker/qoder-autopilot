<!-- version: 9.5.0 -->
# Phase Exit Self-Check Protocol

## When to Use

**Before printing ANY `TRANSITION: X → Y` block.** No exceptions.
**Also: after any context compression recovery.**

## Pre-Check: Context Recovery

Before running the self-check, verify:
```
Was this session resumed after context compression?
  YES → Did I execute the Context Compression Recovery Protocol?
        YES → proceed with self-check
        NO  → STOP. Go back and execute recovery first:
              1. Call Skill(skill="qoder-autopilot") to reload
              2. Read the current phase file
              3. Reconstruct skills_invoked state
```

## Steps

### Step 1: Re-read the phase file

**Literally re-read it.** Execute `Read("./phases/phase-N-*.md")` for the current phase.
Do NOT rely on your memory of what the phase requires — the file is the source of truth.
After reading, list every ⛔ BLOCKING step mentioned.

### Step 2: Fill the verification table

```
PHASE EXIT SELF-CHECK: {current_phase} → {next_phase}
┌───┬──────────────────────────────┬──────────┬──────────────────────────────────────┐
│ # │ Required Action              │ Done?    │ Evidence (first line / path / quote)  │
├───┼──────────────────────────────┼──────────┼──────────────────────────────────────┤
│ 1 │ ...                          │ YES / NO │ ...                                  │
└───┴──────────────────────────────┴──────────┴──────────────────────────────────────┘
```

Rules:
- **"Done?"** = you LITERALLY called `Skill(skill="...")` via the Skill tool. Thinking ≠ doing.
- **"Evidence"** = FIRST LINE of the Skill tool's output. If you can't paste it, you didn't call it.
- Documents = actual file path where the document was saved.
- Human Gates = direct quote from user's response message.
- Conditional steps ("IF FRONTEND") = "N/A" with justification if not applicable, or "YES" if applicable.
- Subagent delegation: if a subagent was supposed to call a skill, show the subagent's reported proof.

### Step 3: Check for gaps

If ANY row shows "NO" or has no evidence:

```
⛔ SELF-CHECK FAILED — {N} items incomplete.
   Missing: {list each missing item}
   Action: Going back to complete them now.
```

1. STOP — do NOT print TRANSITION
2. Perform each missing action NOW (call the Skill, save the document, etc.)
3. Re-print the FULL table with updated evidence
4. Only print TRANSITION when ALL rows = YES (or justified N/A)

## Prohibited Shortcuts — THESE ARE THE REAL-WORLD FAILURE MODES

Based on actual execution audits, these are the ways the protocol gets violated:

- **"I'll do it in the next phase"** → NO. Each phase owns its skills. The next phase has different skills.
- **"Implicitly covered by my own work"** → NO. You writing code ≠ calling test-driven-development. Only Skill tool calls count.
- **"Not necessary for this feature"** → NO. Mandatory means mandatory. "The feature is simple" is not an exemption.
- **"YES" without pasteable proof** → That is fabrication. If you can't paste the first line, you didn't call it.
- **"Everything went smoothly"** → Smooth runs need checking MORE, because you're likely on autopilot (ironic).
- **"The subagent handled it"** → Show the subagent's skill proof in its report. No proof = not done.
- **"I know how to do TDD/review/verification"** → Knowing ≠ calling the Skill tool. The skill may contain project-specific instructions you don't have.
- **Skipping the self-check entirely** → This is the #1 failure mode in real runs. ALWAYS print the table.
