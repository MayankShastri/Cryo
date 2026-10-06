# Iterative Quiz Verification Workflow

When analyzing academic or technical quizzes that involve numerical simulation or physical models (fluid circuits, diffusion equations, ARAP manipulation):

## Workflow

1. **Model the problem** using `execute_code` with a Python script. Do not rely solely on the LLM's textual reasoning for complex multi-step physics or math problems.
2. **Implement constraints** explicitly as defined in the problem statement (e.g., pipe resistances, update rules for $u_i^{t+1}$).
3. **Verify iteratively**:
    - If the user provides an answer and it is marked wrong, do not re-prompt the LLM to "think harder".
    - Debug the simulation logic in the Python script.
    - Validate intermediate steps (e.g., $t=1$ state, $P_D/P_E$ values).
4. **Use session history**: Check past sessions (via `session_search`) to see if similar physics problems were modeled before — reuse proven simulation templates.

## Pitfalls

- **Confusing parameters**: Ensure constants like $dx, dt, D$ are consistently applied in the simulation script.
- **Off-by-one/loop bounds**: Verify the loop ranges (e.g., `i=1` to `size-1`) against the boundary conditions provided in the problem.
- **Truncated reasoning**: If the LLM's CoT is truncated, trust the executed Python script output over the LLM's text.
