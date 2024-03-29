library(tidyverse)
library(readxl)

setwd("C:/Users/kathy/Documents/dataviz/city_migration")

path <- "data/metro-to-metro-2012-2016 - edited.xlsx"
sheets <- excel_sheets(path)

mig <- list()

for (s in sheets) {
  mig[[s]] <- read_xlsx(path, s, skip = 4)
}

mig_2 <- bind_rows(mig) %>% 
  select(-starts_with("X_")) %>% 
  filter(!is.na(y1_pop))

y1 <- mig_2 %>% 
  select(starts_with("y1"), starts_with("from_")) %>% 
  distinct() %>% 
  replace(is.na(.), 0) %>% 
  mutate(in_total = from_diff_metro + from_other_us,
         in_pct = in_total / y1_pop)

y0 <- mig_2 %>% 
  select(starts_with("y0"), starts_with("to_")) %>% 
  distinct() %>% 
  replace(is.na(.), 0) %>% 
  mutate(out_total = to_diff_metro + to_other_us,
         out_pct = out_total / y0_pop)

mig_3 <- y1 %>% 
  left_join(y0, by = c("y1_metro_cd" = "y0_metro_cd")) %>% 
  rename(metro_cd = y1_metro_cd,
         metro = y1_metro) %>% 
  select(-y0_metro)

write_csv(mig_3, "data/viz_data.csv")

ggplot(mig_3) +
  geom_point(aes(x=in_pct, y=out_pct, size=y1_pop/1000), alpha = 0.5)

ggplot(mig_3) +
  geom_point(aes(x=in_total/1000, y=out_total/1000, size=y1_pop/1000), alpha = 0.5)