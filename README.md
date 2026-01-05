# NBA Scoring Streaks: Exploratory Analysis and Formal Inference

## Overview

Scoring streaks are a deeply ingrained concept in basketball discourse. Players are often described as being “hot” or “cold,” and these narratives frequently influence fan expectations, media coverage, and even betting markets. Intuitively, one might expect regression to the mean following extended streaks—long scoring over-performances followed by under-performances, and vice versa.

This project rigorously evaluates whether such intuitions hold up under statistical scrutiny. Using game-level NBA data and player-specific baselines, we examine whether scoring streaks meaningfully affect next-game performance once uncertainty and player heterogeneity are properly accounted for.

The goal of this study is **not** to establish causality or to build a predictive model, but rather to test whether streak-conditioned performance differs in a statistically meaningful way from baseline behavior.

---

## Key Questions

This analysis is structured around two related questions:

1. **Global Effect**  
   Do scoring streaks, on average, change a player’s probability of exceeding their typical scoring performance in the next game?

2. **Conditional Effects**  
   If an effect exists, does it depend on:
   - streak direction (over vs. under)
   - streak length (short vs. extended streaks)?

---

## Methodology

### Data Preparation
- Game-level player scoring data were collected for a full NBA season.
- Analysis was restricted to **high-usage players** to reduce noise from low-volume scorers.
- Player-specific baselines were defined using rolling season-average scoring thresholds.
- All streak features were constructed using **only prior game information** to avoid outcome leakage.

### Exploratory Analysis
Initial exploratory analysis examined:
- streak frequency distributions
- player-level streak behavior
- apparent streak-related patterns in over- and under-performance

While some patterns appeared visually compelling at this stage, exploratory analysis alone was insufficient to distinguish signal from noise.

### Formal Hypothesis Testing
To rigorously evaluate streak effects, we conducted formal statistical inference:

- **Player-level baseline comparison**  
  For each player, we computed the difference between streak-conditioned over-performance probability and baseline probability.

- **Global inference**
  - One-sample t-test on player-level deviations
  - Nonparametric bootstrap confidence interval

- **Stratified inference**
  - Separate tests by streak direction and length
  - Player-level aggregation to preserve independence
  - Results interpreted as exploratory conditional analyses

---

## Results

### Global Findings
- The average player-level deviation from baseline following scoring streaks is **near zero**.
- A one-sample t-test fails to reject the null hypothesis of no effect.
- A bootstrap confidence interval for the mean deviation comfortably includes zero.
- Effect sizes are extremely small (on the order of 1 percentage point or less).

### Conditional Findings
- Stratified analyses by streak direction and length show **no consistent or monotonic patterns**.
- Nearly all conditional tests are statistically non-significant.
- An isolated nominally significant result for short under-streaks is not robust across bins and is likely attributable to random variation.

### Interpretation
Despite intuitive expectations of regression to the mean, scoring streaks do **not** appear to systematically alter next-game scoring outcomes once player-specific baselines and uncertainty are properly accounted for. Performance remains approximately symmetric around baseline rates across players and streak conditions.

---

## Conclusions

This study finds no evidence that scoring streaks, when considered in isolation, provide reliable predictive signal for next-game scoring performance among high-usage NBA players. Apparent streak-related patterns observed in exploratory analysis largely disappear under formal statistical testing.

These results highlight the importance of:
- player-level baselines
- careful aggregation
- explicit uncertainty quantification

They also caution against over-reliance on streak-based heuristics in analytical or decision-making contexts.

---

## Limitations and Future Extensions

While streaks alone show limited explanatory power, several natural extensions could be explored:

- **Contextual confounders**  
  Incorporating opponent defensive strength, pace, home/away effects, rest days, injuries, and lineup changes.

- **Richer baselines**  
  Modeling baseline performance using minutes, usage rate, and role changes rather than season averages alone.

- **Interaction effects**  
  Evaluating whether streak indicators interact with contextual features in a multivariate setting.

- **Predictive modeling**  
  Testing whether streak-related features contribute marginal value when included alongside broader contextual variables in supervised models.

---

## Final Notes

A key takeaway from this project is that intuitively appealing narratives do not always translate into statistically robust signals. Negative results, when obtained through careful methodology and formal inference, are informative and valuable. This study demonstrates how exploratory insights can—and should—be validated through disciplined statistical reasoning.

## Technical and Statistical Approach

This project follows a standard data science workflow, with a deliberate emphasis on exploratory analysis, statistical inference, and uncertainty-aware conclusions rather than predictive modeling. The technical implementation prioritizes correctness, interpretability, and methodological rigor.

---

### Data Preparation and Feature Construction

Game-level NBA player data were processed using a combination of SQL and Python. SQL was used for initial data extraction and feature construction, including:

- player and game identifiers
- rolling season-level scoring baselines
- preliminary streak indicators
- filtering to high-usage players to reduce variance from low-sample noise

Window functions were leveraged to compute rolling statistics and to ensure consistent, season-aware baselines. All features were constructed at the game level prior to aggregation to preserve flexibility in downstream analysis.

A key design decision was enforcing **temporal integrity**: all streak-related features (streak direction and streak length) were derived exclusively from *prior* games. Lagged transformations were applied explicitly to prevent outcome leakage and ensure that streak state reflected information available before each game outcome.

---

### Analytical Stack

The core analysis was conducted in Python using:

- **pandas** for data manipulation, grouping, and player-level aggregation
- **NumPy** for numerical operations and resampling procedures
- **SciPy** for classical hypothesis testing
- **matplotlib / seaborn** for diagnostic and explanatory visualization

Player-level baselines were computed using `groupby` and `transform` operations, enabling per-row annotation while preserving individual-level structure for later aggregation.

---

### Statistical Inference Design

Formal inference was conducted at the **player level**, not the game level, to avoid inflating effective sample sizes and to respect independence assumptions.

For each player, we computed a deviation metric defined as the difference between streak-conditioned over-performance probability and the player’s own baseline probability. This produced a single interpretable statistic per player, which served as the unit of analysis for hypothesis testing.

Two complementary inference approaches were used:

- **One-sample t-tests**  
  Applied to player-level deviations to test whether the mean deviation differed from zero under standard normality assumptions.

- **Bootstrap confidence intervals**  
  Implemented via repeated resampling of player-level deviations to estimate uncertainty in the mean without relying on parametric distributional assumptions.

This dual approach allowed for both classical hypothesis testing and assumption-light uncertainty estimation, strengthening confidence in the results when both methods agreed.

---

### Stratified Analysis and Heterogeneity Checks

To explore whether streak effects varied by context, additional stratified analyses were conducted by streak direction (over vs. under) and streak length. Player-level aggregation was preserved within each bin to maintain valid inference.

These stratified tests were interpreted as **exploratory conditional analyses**, designed to detect structured heterogeneity rather than to serve as primary confirmatory tests.

---

### Visualization and Diagnostics

Visualizations were used primarily for validation and communication rather than discovery. Key plots included:

- distributions of player-level deviations from baseline
- boxplots of deviation by streak direction and length
- scatter plots examining heterogeneity relative to baseline performance

All visualizations were constructed with consistent scaling and explicit reference lines to aid interpretability and prevent overemphasis of small effects.

---

### Reproducibility and Organization

The analysis is organized into sequential notebooks corresponding to major stages of the data science lifecycle:

1. Data extraction and preprocessing  
2. Exploratory data analysis  
3. Formal inference and hypothesis testing  

Each notebook is designed to be readable, modular, and reproducible, with intermediate datasets stored explicitly to support inspection and iteration.

---

### Methodological Principles

Several core data science principles guided the technical implementation:

- **Baseline-centered analysis:**  
  All comparisons were anchored to player-specific baselines to control for skill, role, and usage differences.

- **Aggregation before inference:**  
  Player-level aggregation was performed prior to hypothesis testing to maintain statistical validity.

- **Separation of exploration and inference:**  
  Exploratory analysis was treated as hypothesis-generating, while formal testing was reserved for uncertainty-aware evaluation.

- **Interpretability over complexity:**  
  Simple, transparent statistical methods were favored to support clear conclusions and avoid overfitting narratives to noise.

This approach ensures that conclusions reflect genuine signal (or the absence thereof) rather than artifacts of data processing or aggregation.
