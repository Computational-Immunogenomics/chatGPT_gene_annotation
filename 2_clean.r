library(data.table)
library(tidyverse)

df <- fread("go_annotation.csv", skip = 1)

names(df) <- c("gene", "cancer_related", "label", "cancer_pathway", "protein_type", "subcellular_location", "description", "other")

a <- 
df %>% 
 filter(other == "") %>%
 select(-other)

b <- 
df %>% 
 filter(other != "") %>% 
 mutate(cancer_pathway = protein_type, 
          protein_type = subcellular_location, 
          subcellular_location = description, 
          description = other) %>% 
 select(-other)

c <- rbind(a, b) %>% mutate(gene = gsub("\\*", "", gene))

d <- 
c %>% 
 mutate(cancer_pathway = ifelse(grepl("Not ", cancer_pathway) | 
                                cancer_pathway %in% c("Unknown", "N/A", "-", "None", "None identified", "Unclear"), 
                                NA, str_to_title(cancer_pathway)), 
         cancer_pathway = gsub("Pathways", "", cancer_pathway), 
         cancer_pathway = gsub("Pathway", "", cancer_pathway),
         cancer_pathway = gsub("Yes", "", cancer_pathway),
         cancer_pathway = gsub("\\(", "", cancer_pathway),
         cancer_pathway = gsub("\\)", "", cancer_pathway)) %>% 
  mutate(cancer_related = ifelse(cancer_related != "Yes", "No", "Yes"),
         cancer_related = ifelse(is.na(cancer_pathway), "No", cancer_related)) %>% 
  filter(label != "")

fwrite(d, "chatGPT_gene_annotation.csv")
