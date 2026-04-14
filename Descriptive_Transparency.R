# Install once if needed
# install.packages(c("readxl", "dplyr", "tidyr", "stringr", "janitor", "writexl", "ggplot2", "forcats", "scales", "tibble"))

library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(janitor)
library(writexl)
library(ggplot2)
library(forcats)
library(scales)
library(tibble)

# ---- 1. Read dataset ----
df <- read_excel("C:/Users/HP/Desktop/STAT 5620/STAT 5620 PROTECT - TEAM 8/Datasets 1.xlsx") %>%
  clean_names()

# Check names
names(df)

# ---- 2. Clean and expand ethical keywords ----
themes_long <- df %>%
  select(title, doi, year, domain_filter, location, ethical_keywords) %>%
  filter(!is.na(ethical_keywords), ethical_keywords != "") %>%
  separate_rows(ethical_keywords, sep = ",") %>%
  mutate(
    ethical_keywords = str_trim(str_to_lower(ethical_keywords)),
    domain_filter = str_trim(domain_filter),
    location = str_trim(location),
    year = as.factor(year)
  ) %>%
  filter(ethical_keywords != "")%>%
  distinct(doi, year, domain_filter, location, ethical_keywords, .keep_all = TRUE)

# ---- 3. PAPER-LEVEL DESCRIPTIVE TABLES ----

descriptive_summary <- tibble(
  metric = c(
    "Total papers",
    "Papers with coded themes",
    "Papers without coded themes",
    "Unique ethical themes",
    "Number of domains",
    "Earliest year",
    "Latest year"
  ),
  value = c(
    nrow(df),
    sum(!is.na(df$ethical_keywords) & df$ethical_keywords != ""),
    nrow(df) - sum(!is.na(df$ethical_keywords) & df$ethical_keywords != ""),
    n_distinct(themes_long$ethical_keywords),
    n_distinct(df$domain_filter[!is.na(df$domain_filter) & df$domain_filter != ""]),
    min(df$year, na.rm = TRUE),
    max(df$year, na.rm = TRUE)
  )
)

papers_by_domain <- df %>%
  filter(!is.na(domain_filter), domain_filter != "") %>%
  count(domain_filter, sort = TRUE) %>%
  mutate(percent = round(n / sum(n) * 100, 1))

papers_by_year <- df %>%
  filter(!is.na(year)) %>%
  count(year, sort = FALSE) %>%
  mutate(percent = round(n / sum(n) * 100, 1))

# ---- 4. THEME FREQUENCIES ----
theme_frequencies <- themes_long %>%
  count(ethical_keywords, sort = TRUE) %>%
  mutate(percent_of_theme_mentions = round(n / sum(n) * 100, 1))

# ---- 5. KEEP TOP THEMES FOR CHARTS ----
top_n <- 14

top_themes <- theme_frequencies %>%
  slice_max(n, n = top_n) %>%
  pull(ethical_keywords)

themes_top <- themes_long %>%
  filter(ethical_keywords %in% top_themes)

theme_order <- theme_frequencies %>%
  filter(ethical_keywords %in% top_themes) %>%
  arrange(n) %>%
  pull(ethical_keywords)

themes_top <- themes_top %>%
  mutate(ethical_keywords = factor(ethical_keywords, levels = theme_order))

# ---- 6. TABLES THAT MATCH THE HEATMAPS AND STACKED BARS ----
# These are within-domain and within-year percentages

theme_domain_pct <- themes_top %>%
  count(domain_filter, ethical_keywords) %>%
  group_by(domain_filter) %>%
  mutate(
    pct = n / sum(n),
    percent = round(pct * 100, 1)
  ) %>%
  ungroup()

theme_year_pct <- themes_top %>%
  count(year, ethical_keywords) %>%
  group_by(year) %>%
  mutate(
    pct = n / sum(n),
    percent = round(pct * 100, 1)
  ) %>%
  ungroup()

theme_by_domain_table <- theme_domain_pct %>%
  select(domain_filter, ethical_keywords, n, percent) %>%
  pivot_wider(
    names_from = domain_filter,
    values_from = percent,
    values_fill = 0
  )

theme_by_year_table <- theme_year_pct %>%
  select(year, ethical_keywords, n, percent) %>%
  pivot_wider(
    names_from = year,
    values_from = percent,
    values_fill = 0
  )

# ---- 7. THEME x DOMAIN x YEAR COUNTS ----
theme_domain_year <- themes_top %>%
  count(domain_filter, year, ethical_keywords, sort = TRUE)

# ---- 8. COLORS AND THEME ----
n_themes <- length(unique(themes_top$ethical_keywords))

custom_colors <- c(
  "#4E79A7", "#F28E2B", "#E15759", "#76B7B2", "#59A14F",
  "#EDC948", "#B07AA1", "#FF9DA7", "#9C755F", "#BAB0AC",
  "#2F4B7C", "#A05195", "#D45087", "#7A9E9F", "#6B8E23",
  "#C17C74", "#8C8C8C", "#4B6A9B", "#CC7A00", "#5F9EA0"
)

base_theme <- theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(size = 10),
    axis.text.y = element_text(size = 10),
    legend.position = "bottom",
    legend.title = element_text(size = 10),
    legend.text = element_text(size = 8),
    strip.text = element_text(face = "bold", size = 11)
  )

# ---- 9. CHARTS ----

# p1. Frequency of top themes
p1_data <- theme_frequencies %>%
  filter(ethical_keywords %in% top_themes) %>%
  mutate(ethical_keywords = factor(ethical_keywords, levels = theme_order))

p1 <- ggplot(p1_data, aes(x = ethical_keywords, y = n)) +
  geom_col(fill = "#2C7FB8") +
  geom_text(aes(label = n), hjust = -0.1, size = 3.5) +
  coord_flip() +
  expand_limits(y = max(p1_data$n) * 1.1) +
  labs(
    title = "Frequency of Top Ethical Themes",
    x = "Theme",
    y = "Count"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14)
  )

print(p1)

# p2. Proportion of top themes by domain
p2 <- ggplot(themes_top, aes(x = domain_filter, fill = ethical_keywords)) +
  geom_bar(position = "fill", color = "white") +
  coord_flip() +
  scale_y_continuous(labels = percent_format()) +
  scale_fill_manual(values = custom_colors[1:n_themes]) +
  labs(
    title = "Proportion of Top Ethical Themes by Domain",
    x = "Domain",
    y = "Percentage",
    fill = "Theme"
  ) +
  base_theme +
  theme(axis.text.y = element_text(face = "bold")) +
  guides(fill = guide_legend(nrow = 2))

print(p2)

# p3. Proportion of top themes by year
p3 <- ggplot(themes_top, aes(x = year, fill = ethical_keywords)) +
  geom_bar(position = "fill", color = "white") +
  coord_flip() +
  scale_y_continuous(labels = percent_format()) +
  scale_fill_manual(values = custom_colors[1:n_themes]) +
  labs(
    title = "Proportion of Top Ethical Themes by Year",
    x = "Year",
    y = "Percentage",
    fill = "Theme"
  ) +
  base_theme +
  theme(axis.text.y = element_text(face = "bold")) +
  guides(fill = guide_legend(nrow = 2))

print(p3)

# p4. Heatmap of theme proportions by domain
p4 <- ggplot(theme_domain_pct, aes(x = domain_filter, y = ethical_keywords, fill = pct)) +
  geom_tile(color = "white") +
  geom_text(aes(label = percent(percent / 100, accuracy = 0.1)), size = 3) +
  scale_fill_gradient(low = "#DCEAF7", high = "#2C7FB8", labels = percent_format()) +
  labs(
    title = "Heatmap of Theme Proportions by Domain",
    x = "Domain",
    y = "Theme",
    fill = "Percentage"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

print(p4)


# Heatmap of theme proportions by year (ALL keywords)

theme_year_pct_all <- themes_long %>%
  count(year, ethical_keywords) %>%
  group_by(year) %>%
  mutate(pct = n / sum(n)) %>%
  ungroup()

p5 <- ggplot(theme_year_pct_all, aes(x = year, y = ethical_keywords, fill = pct)) +
  geom_tile(color = "white") +
  geom_text(aes(label = ifelse(pct >= 0.03,
                               scales::percent(pct, accuracy = 0.1),
                               "")),
            size = 2.5) +
  scale_fill_gradient(low = "#DCEAF7", high = "#2C7FB8",
                      labels = scales::percent_format()) +
  labs(
    title = "Heatmap of Theme Proportions by Year (All Themes)",
    x = "Year",
    y = "Theme",
    fill = "Percentage"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.text.y = element_text(size = 8)
  )

print(p5)
# p6. Proportion of top themes by year within each domain
p6 <- ggplot(themes_top, aes(x = year, fill = ethical_keywords)) +
  geom_bar(position = "fill", color = "white") +
  coord_flip() +
  facet_wrap(~ domain_filter, ncol = 2) +
  scale_y_continuous(labels = percent_format()) +
  scale_fill_manual(values = custom_colors[1:n_themes]) +
  labs(
    title = "Proportion of Top Ethical Themes by Year Within Each Domain",
    x = "Year",
    y = "Percentage",
    fill = "Theme"
  ) +
  base_theme +
  theme(axis.text.y = element_text(face = "bold")) +
  guides(fill = guide_legend(nrow = 2))

print(p6)

# ---- 10. OPTIONAL EXTRA CHARTS FOR PAPER-LEVEL DESCRIPTIVES ----

# p7. Number of papers by domain
p7 <- ggplot(papers_by_domain, aes(x = fct_reorder(domain_filter, n), y = n)) +
  geom_col(fill = "#2C7FB8") +
  geom_text(aes(label = n), hjust = -0.1, size = 3.5) +
  coord_flip() +
  expand_limits(y = max(papers_by_domain$n) * 1.1) +
  labs(
    title = "Number of Papers by Domain",
    x = "Domain",
    y = "Count"
  ) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(face = "bold", size = 14))

print(p7)

# p8. Number of papers by year
p8 <- ggplot(papers_by_year, aes(x = factor(year), y = n, group = 1)) +
  geom_line(color = "#2C7FB8", linewidth = 1) +
  geom_point(color = "#2C7FB8", size = 3) +
  geom_text(aes(label = n), vjust = -0.8, size = 3.2) +
  labs(
    title = "Number of Papers by Year",
    x = "Year",
    y = "Count"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

print(p8)

# ---- 11. EXPORT TABLES ----
write_xlsx(
  list(
    descriptive_summary = descriptive_summary,
    papers_by_domain = papers_by_domain,
    papers_by_year = papers_by_year,
    theme_frequencies = theme_frequencies,
    theme_by_domain_pct = theme_by_domain_table,
    theme_by_year_pct = theme_by_year_table,
    theme_domain_year = theme_domain_year
  ),
  "theme_analysis_results_with_charts_tables.xlsx"
)

# ---- 12. SAVE PLOTS ----
ggsave("p1_theme_frequency_blue.png", p1, width = 8, height = 6, dpi = 300)
ggsave("p2_theme_proportion_by_domain_horizontal.png", p2, width = 10, height = 6, dpi = 300)
ggsave("p3_theme_proportion_by_year_horizontal.png", p3, width = 10, height = 6, dpi = 300)
ggsave("p4_theme_domain_percentage_heatmap.png", p4, width = 10, height = 7, dpi = 300)
ggsave("p5_theme_year_percentage_heatmap.png", p5, width = 10, height = 7, dpi = 300)
ggsave("p6_theme_proportion_by_year_within_domain_horizontal.png", p6, width = 12, height = 8, dpi = 300)
ggsave("p7_papers_by_domain.png", p7, width = 8, height = 6, dpi = 300)
ggsave("p8_papers_by_year.png", p8, width = 8, height = 6, dpi = 300)