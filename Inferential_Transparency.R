# Install if needed
# install.packages(c("readxl", "dplyr", "stringr", "janitor"))

library(readxl)
library(dplyr)
library(stringr)
library(janitor)

# 1. Load data
df <- read_excel("Datasets.xlsx") %>%
  clean_names()

# 2. Define keyword groups
transparency_terms <- c(
  "explain","interpret","transparent","accountab","ethic","govern",
  "oversight","audit","compliance","disclosure","responsib"
)

trust_terms <- c(
  "fair","bias","equity","reliab","robust","trust",
  "confidence","safe","secure","privacy"
)

# 3. Create binary indicators from abstract
df <- df %>%
  mutate(
    abstract_lower = str_to_lower(coalesce(abstract, "")),
    transparency = ifelse(
      sapply(abstract_lower, function(txt)
        any(sapply(transparency_terms, function(term)
          str_detect(txt, fixed(term))))
      ), 1, 0),
    trust = ifelse(
      sapply(abstract_lower, function(txt)
        any(sapply(trust_terms, function(term)
          str_detect(txt, fixed(term))))
      ), 1, 0),
    transparency_label = factor(ifelse(transparency == 1, "Yes", "No")),
    trust_label = factor(ifelse(trust == 1, "Yes", "No"))
  )

# 4. Contingency table
tt_table <- table(df$transparency_label, df$trust_label)
print(tt_table)

# 5. Chi-square test
chi_result <- chisq.test(tt_table)
print(chi_result)

# 6. Expected counts (assumption check)
print(chi_result$expected)

# 7. Fisher’s Exact Test (if needed)
fisher_result <- fisher.test(tt_table)
print(fisher_result)

# 8. Effect size (Cramér’s V)
cramers_v <- sqrt(
  as.numeric(chi_result$statistic) /
    (sum(tt_table) * min(nrow(tt_table)-1, ncol(tt_table)-1))
)

print(cramers_v)

# 9. Clean reporting output
cat("\n--- Chi-square Test Result ---\n")
cat("Chi-square =", round(as.numeric(chi_result$statistic), 3), "\n")
cat("df =", as.numeric(chi_result$parameter), "\n")
cat("p-value =", chi_result$p.value, "\n")
cat("Cramer's V =", round(cramers_v, 3), "\n")

library(ggplot2)
library(dplyr)
library(scales)
library(viridis)

chi_plot <- df %>%
  count(transparency_label, trust_label) %>%
  group_by(transparency_label) %>%
  mutate(pct = n / sum(n)) %>%
  ggplot(aes(x = transparency_label, y = pct, fill = trust_label)) +
  geom_col(width = 0.6) +
  # Percentage labels inside bars
  geom_text(aes(label = percent(pct)),
            position = position_stack(vjust = 0.5),
            size = 3.5,
            color = "white") +
  scale_y_continuous(labels = percent_format()) +
  # 🎨 COOL color palette
  scale_fill_viridis_d(option = "G", begin = 0.2, end = 0.8) +
  labs(
    title = "Association Between Transparency and Trust Indicators",
    x = "Transparency",
    y = "Percentage",
    fill = "Trust"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom",
    axis.text = element_text(color = "black")
  )

print(chi_plot)

chi_plot <- df %>%
  count(transparency_label, trust_label) %>%
  group_by(transparency_label) %>%
  mutate(
    pct = n / sum(n),
    label = paste0(n, " (", percent(pct, accuracy = 0.1), ")")
  ) %>%
  ggplot(aes(x = transparency_label, y = pct, fill = trust_label)) +
  geom_col(width = 0.6) +
  
  # 🔥 Updated labels
  geom_text(aes(label = label),
            position = position_stack(vjust = 0.5),
            size = 3.5,
            color = "white") +
  
  scale_y_continuous(labels = percent_format()) +
  scale_fill_viridis_d(option = "G", begin = 0.2, end = 0.8) +
  
  labs(
    title = "Contingency Table Plot Showing the Association Between Transparency and Trust Indicators",
    x = "Transparency",
    y = "Percentage",
    fill = "Trust"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom",
    axis.text = element_text(color = "black")
  )

print(chi_plot)

tt_table <- table(df$transparency_label, df$trust_label)

addmargins(tt_table)