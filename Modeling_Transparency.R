# ============================================================
# PENALIZED LOGISTIC REGRESSION (Firth)
# trust ~ transparency + domain
# with conditional-probability dot plot and explicit legend
# ============================================================

# Install if needed:
# install.packages(c("readxl", "dplyr", "stringr", "janitor", "ggplot2", "logistf"))

library(readxl)
library(dplyr)
library(stringr)
library(janitor)
library(ggplot2)
library(logistf)

# -----------------------------
# 1. Read data
# -----------------------------
df <- read_excel("Datasets 1.xlsx") %>%
  clean_names()

# -----------------------------
# 2. Define keyword groups
# -----------------------------
transparency_terms <- c(
  "explain","interpret","transparent","accountab","ethic",
  "govern","oversight","audit","compliance","disclosure"
)

trust_terms <- c(
  "trust","trustworthy","fair","fairness","bias",
  "equity","reliab","reliable","robust"
)

# -----------------------------
# 3. Create indicators
# -----------------------------
df <- df %>%
  mutate(
    abstract_lower = str_to_lower(coalesce(abstract, "")),
    
    transparency_indicator = ifelse(
      sapply(
        abstract_lower,
        function(txt) any(sapply(transparency_terms, function(term) str_detect(txt, fixed(term))))
      ),
      1, 0
    ),
    
    trust_indicator = ifelse(
      sapply(
        abstract_lower,
        function(txt) any(sapply(trust_terms, function(term) str_detect(txt, fixed(term))))
      ),
      1, 0
    ),
    
    domain_filter = str_trim(as.character(domain_filter)),
    domain_filter = case_when(
      str_to_lower(domain_filter) %in% c("technology", "tech") ~ "Technology",
      str_to_lower(domain_filter) %in% c("health", "healthcare") ~ "Health",
      str_to_lower(domain_filter) %in% c("education", "educational") ~ "Education",
      str_to_lower(domain_filter) %in% c("hiring", "hr", "employment") ~ "Hiring",
      str_to_lower(domain_filter) %in% c("law", "legal") ~ "Law",
      TRUE ~ domain_filter
    )
  ) %>%
  filter(!is.na(domain_filter), domain_filter != "")

# -----------------------------
# 4. Factor setup
# -----------------------------
df$domain_filter <- factor(df$domain_filter)

if ("Technology" %in% levels(df$domain_filter)) {
  df$domain_filter <- relevel(df$domain_filter, ref = "Technology")
}

# -----------------------------
# 5. Check variation
# -----------------------------
cat("\n=== Trust indicator distribution ===\n")
print(table(df$trust_indicator))

cat("\n=== Transparency x Trust ===\n")
print(table(df$transparency_indicator, df$trust_indicator))

cat("\n=== Domain x Trust ===\n")
print(table(df$domain_filter, df$trust_indicator))

if (length(unique(df$trust_indicator)) < 2) {
  stop("trust_indicator has no variation. Penalized logistic regression cannot be estimated.")
}

# -----------------------------
# 6. Penalized logistic regression (Firth)
# -----------------------------
model <- logistf(
  trust_indicator ~ transparency_indicator + domain_filter,
  data = df
)

cat("\n=== Model summary ===\n")
print(summary(model))

# -----------------------------
# 7. Results table (OR + CI)
# -----------------------------
results <- data.frame(
  term = names(model$coefficients),
  estimate = as.numeric(model$coefficients),
  odds_ratio = exp(as.numeric(model$coefficients)),
  conf_low = exp(model$ci.lower),
  conf_high = exp(model$ci.upper),
  p_value = model$prob
)

results$term <- dplyr::recode(
  results$term,
  `(Intercept)` = "Intercept",
  transparency_indicator = "Transparency indicator",
  domain_filterHealth = "Health vs Technology",
  domain_filterEducation = "Education vs Technology",
  domain_filterHiring = "Hiring vs Technology",
  domain_filterLaw = "Law vs Technology"
)

cat("\n=== Odds ratios and confidence intervals ===\n")
print(results)

# -----------------------------
# 8. Predicted probabilities
# -----------------------------
pred_df <- expand.grid(
  transparency_indicator = c(0, 1),
  domain_filter = levels(df$domain_filter)
)

pred_df$predicted_prob <- predict(
  model,
  newdata = pred_df,
  type = "response"
)

pred_df$transparency_label <- factor(
  pred_df$transparency_indicator,
  levels = c(0, 1),
  labels = c("No", "Yes")
)

cat("\n=== Predicted probabilities ===\n")
print(pred_df)

# -----------------------------
# 9. Conditional-probability dot plot
# -----------------------------
p_pen <- ggplot(
  pred_df,
  aes(
    x = predicted_prob,
    y = domain_filter,
    color = transparency_label
  )
) +
  geom_line(aes(group = domain_filter), color = "gray70", linewidth = 0.8) +
  geom_point(size = 4) +
  geom_text(
    aes(label = round(predicted_prob, 2)),
    nudge_x = 0.02,
    size = 3.8,
    show.legend = FALSE
  ) +
  scale_color_manual(
    values = c("#9ecae1", "#2C7FB8"),
    labels = c(
      "P(trust = Yes | transparency = No)",
      "P(trust = Yes | transparency = Yes)"
    ),
    name = NULL
  ) +
  scale_x_continuous(limits = c(0, 1.05)) +
  labs(
    title = "Predicted Probability of Trust Indicator (Penalized Model)",
    subtitle = "Conditional probability of trust given transparency status",
    x = "Predicted Probability",
    y = "Domain"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    legend.position = "bottom"
  )

print(p_pen)

# -----------------------------
# 10. Save outputs
# -----------------------------
write.csv(results, "penalized_logistic_results.csv", row.names = FALSE)
write.csv(pred_df, "penalized_predicted_probabilities.csv", row.names = FALSE)

ggsave(
  "penalized_logistic_dotplot.png",
  p_pen,
  width = 9,
  height = 6,
  dpi = 300
)