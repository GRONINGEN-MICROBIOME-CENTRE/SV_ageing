source(paste0("/Users/helloduck/Documents/SV_MWAS/R/R_scripts/Step1/", "Part3_functions.R"))
source(paste0("/Users/helloduck/Documents/SV_MWAS/R/R_scripts/Step1/", "Part1_functions.R"))
source(paste0("/Users/helloduck/Documents/SV_MWAS/R/R_scripts/Step2/", "Part1_functions.R"))
#### 0.0 import data ####
setwd("/Users/helloduck/Documents/SV_MWAS/R/Raw_data/")
para <- readRDS("./running_list_higher_30.rds")
sample_number <- read.delim("./Running_list/sampleCohorts.id.tsv",sep="\t",row.names = NULL,header = T,check.names = F,fill = F)
sample_number$Cohort_2=NA
sample_number$Cohort_2[sample_number$Cohort==c("300OB")]=c("300ob")
sample_number$Cohort_2[sample_number$Cohort==c("300TZFG")]=c("300tzfg")
sample_number$Cohort_2[sample_number$Cohort==c("500FG_FSK")]=c("500fg_fsk")
sample_number$Cohort_2[sample_number$Cohort==c("LLD1")]=c("lld1")
sample_number$Cohort_2[sample_number$Cohort==c("DMP")]=c("dmp")
physical_score <- read.delim("./202312_physical_activity_DAG3_LLD_To-Yue.tsv",sep="\t",row.names = NULL,header = T,check.names = F,fill = F)
physical_score$ID=physical_score$DAG3_sampleID
physical_score$ID[is.na(physical_score$ID)]=physical_score$LLDEEP_ID[is.na(physical_score$ID)]
row.names(physical_score)=physical_score$ID
physical_score=physical_score[row.names(physical_score)%in%c(sample_number$New_SV_ID),]
Frailty_index <- read.delim("./Frailty_index.csv",sep=",",row.names = NULL,header = T,check.names = F,fill = F)
trans_ID <- read.delim("./key_DAG3_pseudo_id.tsv",sep="\t",row.names = NULL,header = T,check.names = F,fill = F)
Frailty_index=merge(Frailty_index,trans_ID[,1:3],by.x = "PROJECT_PSEUDO_ID",by.y = "PROJECT_PSEUDO_ID",all.x=T)
Frailty_index=Frailty_index[!is.na(Frailty_index$DAG3_sampleID),c("FI64","FI60","FI41_B","FI41_FU","FI39_B","FI39_FU","DAG3_sampleID")]%>% `rownames<-`(.[,'DAG3_sampleID']) %>% dplyr::select(-'DAG3_sampleID')
# Phenotype data
load("./Phenotype_rawdata/full_phen.RData")
full_phen=removeColsAllNa(full_phen)
full_phen=merge(full_phen,physical_score[,c("total_scor_VAL","MVPA_scor_VAL")],by.x = "row.names",by.y = "row.names",all.x = T)%>% `rownames<-`(.[,'Row.names']) %>% dplyr::select(-'Row.names')
full_phen=merge(full_phen,Frailty_index[,c("FI64","FI60","FI41_B","FI41_FU","FI39_B","FI39_FU")],by.x = "row.names",by.y = "row.names",all.x = T)%>% `rownames<-`(.[,'Row.names']) %>% dplyr::select(-'Row.names')
Pheno_info <- read.delim("./Phenotype_info/phenInfoSumm.tsv",sep="\t",row.names = NULL,header = T,check.names = F,fill = F)
Pheno_info=Pheno_info[!Pheno_info$Class==c(""),]
Pheno_info=Pheno_info[-which(Pheno_info$UnifiedName==c("MeatFreqPerWeek")&Pheno_info$Unit==c("4 point scale")),]
load("./readcounts_rawdata/full_read.RData")
full_read$log10_counts=log10(full_read$V2)
pheno_cov=merge(full_phen,full_read[,c("V1","log10_counts"),drop=F],by.x = "row.names",by.y = "V1",all=F)%>% `rownames<-`(.[,'Row.names']) %>% dplyr::select(-'Row.names')
meta_age_significant <- readRDS("~/Documents/SV_MWAS/R/Raw_data/meta_age_significant.rds")

#### 1.Humann_gene_metabolites_LLD ####
#/scratch/p303998/SV_MWAS/NM_revision/Humann_gene_metabolites_LLD->/Users/helloduck/Documents/SV_MWAS/NM_reviosion/
Humann_gene_metabolites_LLD <- readRDS("~/Documents/SV_MWAS/NM_reviosion/Humann_gene_metabolites_LLD.rds")
#Humann_gene_metabolites_LLD$p_phenotype[which(Humann_gene_metabolites_LLD$x_uniq_N==2&Humann_gene_metabolites_LLD$x_non_zero_rate<0.1)]=NA
#Humann_gene_metabolites_LLD$p_phenotype[which(Humann_gene_metabolites_LLD$x_uniq_N==2&Humann_gene_metabolites_LLD$x_non_zero_rate>0.9)]=NA
#Humann_gene_metabolites_LLD$p_phenotype[which(Humann_gene_metabolites_LLD$y_uniq_N==2&Humann_gene_metabolites_LLD$y_non_zero_rate>0.9)]=NA
Humann_gene_metabolites_LLD$p_phenotype[which(Humann_gene_metabolites_LLD$y_uniq_N==2&Humann_gene_metabolites_LLD$y_non_zero_rate<0.1)]=NA
Humann_gene_metabolites_LLD$Beta_IDage=NULL;Humann_gene_metabolites_LLD$SE_IDage=NULL;Humann_gene_metabolites_LLD$p_IDage=NULL
Humann_gene_metabolites_LLD=Humann_gene_metabolites_LLD[which(!is.na(Humann_gene_metabolites_LLD$p_phenotype)),]
unique(Humann_gene_metabolites_LLD$Y)%>%length(.)
unique(Humann_gene_metabolites_LLD$X)%>%length(.)
TableS_gene_type <- readRDS("~/Documents/SV_MWAS/NM_reviosion/TableS_gene_type_humann.rds")
rep_LLD <- readRDS("/Users/helloduck/Documents/SV_MWAS/NM_reviosion/replication_result_Humann_LLD.rds")
rep_LLD$Y[which(rep_LLD$X==c("FI41")&rep_LLD$replicated_in_LLD==c("Yes"))]%>%length(.)#208
Humann_gene_metabolites_LLD=Humann_gene_metabolites_LLD[Humann_gene_metabolites_LLD$Y%in%rep_LLD$Y[rep_LLD$X==c("FI41")&rep_LLD$replicated_in_LLD==c("Yes")],]
unique(Humann_gene_metabolites_LLD$Y)%>%length(.)
unique(Humann_gene_metabolites_LLD$X)%>%length(.)
Humann_gene_metabolites_LLD=merge(Humann_gene_metabolites_LLD,TableS_gene_type[TableS_gene_type$X==c("Age"),c(1,6,7)],by.x = "Y",by.y = "Y",all.x = T)
age_metabolites <- readRDS("/Users/helloduck/Documents/SV_MWAS/R/R_scripts/Step1/Results/age_metabolites.rds")
Humann_gene_metabolites_LLD=Humann_gene_metabolites_LLD[Humann_gene_metabolites_LLD$X%in%age_metabolites,]
unique(Humann_gene_metabolites_LLD$Y)%>%length(.)
unique(Humann_gene_metabolites_LLD$X)%>%length(.)
TableS_gene_type=TableS_gene_type[TableS_gene_type$Y%in%rep_LLD$Y[rep_LLD$X==c("FI41")&rep_LLD$replicated_in_LLD==c("Yes")],]

fdr_threshold=0.05/(208*804)# 2.989858e-07
Humann_gene_metabolites_LLD$significance=NA
Humann_gene_metabolites_LLD$significance[Humann_gene_metabolites_LLD$p_phenotype<fdr_threshold&Humann_gene_metabolites_LLD$Beta_phenotype>0]=c("significant-positive")
Humann_gene_metabolites_LLD$significance[Humann_gene_metabolites_LLD$p_phenotype<fdr_threshold&Humann_gene_metabolites_LLD$Beta_phenotype<0]=c("significant-negative")
Humann_gene_metabolites_LLD$significance[Humann_gene_metabolites_LLD$p_phenotype>fdr_threshold]=c("non-significant")
Humann_gene_metabolites_LLD$significance=as.factor(Humann_gene_metabolites_LLD$significance)
Humann_gene_metabolites_LLD$significance=factor(Humann_gene_metabolites_LLD$significance,levels = c("significant-positive","significant-negative","non-significant"))
metabolites_info <- read.delim("/Users/helloduck/Documents/SV_MWAS/R/Raw_data/key_lld_1183meta_annotation.tsv",sep="\t",row.names = 1,header = T,check.names = F,fill = F)
Humann_gene_metabolites_LLD=merge(Humann_gene_metabolites_LLD,metabolites_info,by.x = "X", by.y = "row.names", all.x = T)
Humann_gene_metabolites_LLD$Var.20=NULL;Humann_gene_metabolites_LLD$Var.21=NULL;Humann_gene_metabolites_LLD$Var.22=NULL;Humann_gene_metabolites_LLD$Var.23=NULL
Humann_gene_metabolites_LLD$cs_description=NULL
saveRDS(Humann_gene_metabolites_LLD, paste0("/Users/helloduck/Documents/SV_MWAS/NM_reviosion/","Table_Humann_metabolites",".rds"))
write.table(Humann_gene_metabolites_LLD, "/Users/helloduck/Desktop/table1.tsv",sep = "\t", col.names = T, row.names = F, quote = F)

#### 2. correlation between metabolites and age ####
metabolites_info <- read.delim("/Users/helloduck/Documents/SV_MWAS/R/Raw_data/key_lld_1183meta_annotation.tsv",sep="\t",row.names = 1,header = T,check.names = F,fill = F)
cohort=c("lld1")
pheno_cohort=full_phen[row.names(full_phen)%in%sample_number$New_SV_ID[sample_number$Cohort_2==cohort],"Age",drop=F]
metabolites_LLD <- read.delim("/Users/helloduck/Documents/SV_MWAS/R/Raw_data/data_1442samples_LLD_baseline_1183plasma_metabolites.txt",sep="\t",row.names = 1,header = T,check.names = F,fill = F)
pheno_cohort = merge(pheno_cohort,metabolites_LLD,by.x = "row.names",by.y = "row.names",all.x = T)%>% `rownames<-`(.[,'Row.names']) %>% dplyr::select(-'Row.names')
for (i in colnames(pheno_cohort)){pheno_cohort[,i]=as.numeric(pheno_cohort[,i])}
cor_result=data.frame(pheno=NA,rho=NA,p=NA)
for (i in colnames(pheno_cohort)){
  print(i)
  test=pheno_cohort[,c("Age",i)]%>%na.omit(.)
  cor_test <- cor.test(test[,"Age"], test[,i], method = "spearman")
  cor_result[i,"pheno"]=i
  cor_result[i,"rho"]=cor_test$estimate
  cor_result[i,"p"]=cor_test$p.value
}
cor_result$Age=c("Age")
cor_result$fdr=p.adjust(cor_result$p,method = "fdr")
cor_result$rho[cor_result$fdr>0.05]=0
age_metabolites=cor_result$pheno[which(cor_result$fdr<0.05)]
cor_result$name=metabolites_info$name[match(cor_result$pheno,row.names(metabolites_info))]
cor_result <- cor_result %>%
  mutate(direction = case_when(
    rho < 0 ~ "negative",
    rho > 0 ~ "positive"))
saveRDS(age_metabolites, paste0("/Users/helloduck/Documents/SV_MWAS/R/R_scripts/Step1/Results/","age_metabolites",".rds"))
write.table(cor_result, paste0("/scratch/p303998/SV_MWAS/Rdata_0828/","age_metabolites",".tsv"),sep = "\t", quote = F,col.names = T,row.names = F)
#### 3. heatmap ####
humann_metabolites_significant <- readRDS("~/Documents/SV_MWAS/NM_reviosion/Table_Humann_metabolites.rds")
for (i in c("Y","X")){`humann_metabolites_significant`[,i]=as.character(`humann_metabolites_significant`[,i])}
humann_metabolites_significant=humann_metabolites_significant[which(!humann_metabolites_significant$significance==c("non-significant")),]
length(unique(humann_metabolites_significant$X))
length(unique(humann_metabolites_significant$Y))

unique(humann_metabolites_significant$Y[humann_metabolites_significant$type==c("geroprotective")])%>%length(.)#38
unique(humann_metabolites_significant$Y[humann_metabolites_significant$type==c("geropathogenic")])%>%length(.)#16

humann_metabolites_significant$X=humann_metabolites_significant$name
humann_metabolites_significant$X[is.na(humann_metabolites_significant$X)]=c("Unknown metabolite")
plot_matrix <- reshape2::dcast(humann_metabolites_significant, X ~ Y, value.var = "Beta_phenotype");row.names(plot_matrix)=plot_matrix$X;plot_matrix=plot_matrix[,-1]
gene_groups <- data.frame(genes = colnames(plot_matrix),
                          Group = as.character(humann_metabolites_significant$type[match(colnames(plot_matrix),humann_metabolites_significant$Y)]))
qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
set.seed(1993); group_colors = sample(col_vector, length(unique(gene_groups$Group)), replace = F)
names(group_colors) <- unique(gene_groups$Group)

#all colours
colours <- list(Group=group_colors)
ha <- HeatmapAnnotation(df = gene_groups[,2,drop=F], show_legend = TRUE,which='column',col = colours)
metabolites_info=metabolites_info[which(row.names(metabolites_info)%in%age_metabolites),]
metabolites_group <- data.frame(
  unified_name = row.names(plot_matrix),
  #SuperClass = factor(Pheno_info$SubClass[match(row.names(plot_matrix), Pheno_info$UnifiedName)]),
  metabolite_class=as.character(metabolites_info$class[match(row.names(plot_matrix),metabolites_info$name)]),
  age_direction=factor(cor_result$direction[match(row.names(plot_matrix),cor_result$name)])
)
metabolites_group$metabolite_class[!metabolites_group$metabolite_class%in%c("tryptophan metabolites")]=c("NA")
qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
set.seed(1994); age_colors <- sample(col_vector, length(unique(metabolites_group$age_direction)))
names(age_colors) <- unique(metabolites_group$age_direction)
set.seed(1994); metabolite_colors <- sample(col_vector, length(unique(metabolites_group$metabolite_class)))
names(metabolite_colors) <- unique(metabolites_group$metabolite_class)

colours2 <- list(
  Age_direction=age_colors,
  metabolite_colors=metabolite_colors
)
ha2 <- rowAnnotation(df = metabolites_group[,2:3,drop=F],col = colours2)
plot_matrix[is.na(plot_matrix)]=0
Heatmap(plot_matrix,
        name = "Beta",
        #row_km = 2, border = TRUE,
        #clustering_distance_columns = "spearman",
        #clustering_method_columns = "complete",
        #rect_gp = gpar(col = "white", lwd = 1.5),
        cluster_rows = T,  # 聚类Y轴
        show_row_names = TRUE,
        cluster_columns = T,  # 聚类X轴
        show_column_names = TRUE,
        top_annotation=ha,
        right_annotation = ha2,
        col = colorRamp2(c(min(plot_matrix),0, max(plot_matrix)), c("blue", "white","red")),
        #show_heatmap_legend = FALSE
        #cell_fun = function(j, i, x, y, width, height, fill) {
        #grid.text(p2[i, j], x, y, vjust = 0.7,
        #gp = gpar(fontsize = 13,col="brown"))
        #}
)
test=as.data.frame(table(humann_metabolites_significant$X))
#Oxidanesulfonic acid*
#{3-[(E)-2-[3,5-dihydroxy-4-(3-methylbut-2-en-1-yl)phenyl]ethenyl]-2,6-dihydroxyphenyl}oxidanesulfonic acid
#chromen-4-one*
#2−(2,4−dihydroxyphenyl)−3−(3,7−dimethylocta−2,6−dien−1−yl)−5,7−dihydroxy−6−(4−hydroxy−3−methylbut−2−en−1−yl)−4H−chromen−4−one

#### 4. metabolites enrichment analysis using clusterProfiler ####
# Combine together with the resutls of the metabolite-related genes which are extracted from the age-associated SVs
shortbred_metabolites_significant <- readRDS("~/Documents/SV_MWAS/NM_reviosion/Table_Shortbred_metabolites.rds")
for (i in c("Y","X")){`shortbred_metabolites_significant`[,i]=as.character(`shortbred_metabolites_significant`[,i])}
shortbred_metabolites_significant=shortbred_metabolites_significant[which(!shortbred_metabolites_significant$significance==c("non-significant")),]
length(unique(shortbred_metabolites_significant$X))#63 metabolites
length(unique(shortbred_metabolites_significant$Y))#73 genes

humann_metabolites_significant <- readRDS("~/Documents/SV_MWAS/NM_reviosion/Table_Humann_metabolites.rds")
for (i in c("Y","X")){`humann_metabolites_significant`[,i]=as.character(`humann_metabolites_significant`[,i])}
humann_metabolites_significant=humann_metabolites_significant[which(!humann_metabolites_significant$significance==c("non-significant")),]
length(unique(humann_metabolites_significant$X))#67 metabolites
length(unique(humann_metabolites_significant$Y))#58 gene families

metabolite_all = unique(unique(shortbred_metabolites_significant$X),unique(humann_metabolites_significant$X))
length(metabolite_all)#63

library(clusterProfiler)
metabolites_info <- read.delim("/Users/helloduck/Documents/SV_MWAS/R/Raw_data/key_lld_1183meta_annotation.tsv",sep="\t",row.names = 1,header = T,check.names = F,fill = F)
age_metabolites <- readRDS("/Users/helloduck/Documents/SV_MWAS/R/R_scripts/Step1/Results/age_metabolites.rds")
metabolites_info=metabolites_info[row.names(metabolites_info)%in%age_metabolites,]

# interest metabolite list
metabolite_list = metabolites_info$name[which(row.names(metabolites_info)%in%metabolite_all)]

# Enrichment analysis
go_rich <- enricher(gene = metabolite_list,
                    TERM2GENE = metabolites_info[,c("class","name")], 
                    TERM2NAME = metabolites_info[,c("class","class")], 
                    pvalueCutoff = 1, 
                    pAdjustMethod = 'bonferroni', 
                    qvalueCutoff = 0.05, 
                    maxGSSize = 500)
metabolites_reasult <- data.frame(go_rich@result)
saveRDS(metabolites_reasult, "/Users/helloduck/Documents/SV_MWAS/NM_reviosion/Final R scripts/metabolites_reasult_final.rds")
write.table(metabolites_reasult, "/Users/helloduck/Desktop/table1.tsv",sep = "\t", col.names = T, row.names = F, quote = F)

#### 5.1 UniRef90_R5P1L6 ~ Indole-3-propionic acid  ####
Humann4.0_LLD <- readRDS("~/Documents/SV_MWAS/NM_reviosion/Humann4.0_LLD.rds")
metabolites_LLD <- read.delim("/Users/helloduck/Documents/SV_MWAS/R/Raw_data/data_1442samples_LLD_baseline_1183plasma_metabolites.txt",sep="\t",row.names = 1,header = T,check.names = F,fill = F)
pheno_cohort = metabolites_LLD
sample_name = Reduce(intersect, list(row.names(pheno_cohort), row.names(Humann4.0_LLD), row.names(pheno_cov)))
covar=c( "Sex","Age","log10_counts")
lm_input<-data.frame(Y_shortbred = Humann4.0_LLD[sample_name,"UniRef90_R5P1L6"], X_phenotype = pheno_cohort[sample_name, "meta_357"],pheno_cov[sample_name,covar]) %>% sapply(as.numeric) %>% na.omit %>% as.data.frame
print(colnames(lm_input))
lm_input$Y_shortbred[lm_input$Y_shortbred==0]=min(lm_input$Y_shortbred[lm_input$Y_shortbred>0])/2
if (length(unique(lm_input$X_phenotype)) == 2){lm_input$X_phenotype=factor(lm_input$X_phenotype,levels=c("0","1"))}
if (length(unique(lm_input$X_phenotype)) > 2){ for (a in c("X_phenotype")){lm_input[,a]=qtrans(lm_input[,a])}}
if (length(unique(lm_input$Y_shortbred)) > 2){for (b in c("Y_shortbred")){lm_input[,b]=log2(lm_input[,b])}}
if (c("Sex")%in%colnames(lm_input)){lm_input$Sex=as.factor(lm_input$Sex)}
if (length(unique(lm_input$Sex)) < 2){lm_input$Sex=NULL}
if (c("Age")%in%colnames(lm_input)){for (c in c("Age")){lm_input[,c]=qtrans(lm_input[,c])}}
if (c("SV")%in%colnames(lm_input)){for (c in c("SV")){lm_input[,c]=qtrans(lm_input[,c])}}

if ("DNA.Concentration" %in% names(lm_input)){
  for (d in c("DNA.Concentration")){lm_input[,d]=qtrans(lm_input[,d])}}
if ("log10_counts" %in% names(lm_input)){
  for (d in c("log10_counts")){lm_input[,d]=qtrans(lm_input[,d])}}

lm_res <- summary(lm(Y_shortbred~.,data = lm_input))
lm_res$coefficients
lm_input$Y_shortbred=resid(lm(Y_shortbred~Sex+Age+log10_counts,data=lm_input))
p1=ggplot(data = lm_input, mapping = aes(x =`X_phenotype`, y =`Y_shortbred`))+
  geom_point(color="brown",alpha=0.5,size=2)+
  geom_smooth(data =lm_input, mapping = aes(x =`X_phenotype`,y = `Y_shortbred`), method = "lm", formula = y ~ x,color="black")+
  labs(x = "Indole-3-propionic acid", y = "UniRef90_R5P1L6\nPutative signal-transducing histidine kinase")+
  theme_bw()+
  theme(axis.text.y = element_text(face="plain",size=16,colour="black"),
        axis.text.x = element_text(face="plain",size=16,colour="black"),
        axis.title.y = element_text(face="bold",size=16,colour="black"),
        axis.title.x = element_text(face="bold",size=16,colour="black"))+
  scale_y_continuous(n.breaks = 8)+
  scale_x_continuous(n.breaks = 7)

#### 5.2 UniRef90_R5P1L6 ~ thiamine ####
cohort = c("lld1")
pheno_cohort = metabolites_LLD
sample_name = Reduce(intersect, list(row.names(pheno_cohort), row.names(Humann4.0_LLD), row.names(pheno_cov)))
covar=c( "Sex","Age","log10_counts")
lm_input<-data.frame(Y_shortbred = Humann4.0_LLD[sample_name,"UniRef90_R5P1L6"], X_phenotype = pheno_cohort[sample_name, "meta_586"],pheno_cov[sample_name,covar]) %>% sapply(as.numeric) %>% na.omit %>% as.data.frame
print(colnames(lm_input))
lm_input$Y_shortbred[lm_input$Y_shortbred==0]=min(lm_input$Y_shortbred[lm_input$Y_shortbred>0])/2
if (length(unique(lm_input$X_phenotype)) == 2){lm_input$X_phenotype=factor(lm_input$X_phenotype,levels=c("0","1"))}
if (length(unique(lm_input$X_phenotype)) > 2){ for (a in c("X_phenotype")){lm_input[,a]=qtrans(lm_input[,a])}}
if (length(unique(lm_input$Y_shortbred)) > 2){for (b in c("Y_shortbred")){lm_input[,b]=log2(lm_input[,b])}}
if (c("Sex")%in%colnames(lm_input)){lm_input$Sex=as.factor(lm_input$Sex)}
if (length(unique(lm_input$Sex)) < 2){lm_input$Sex=NULL}
if (c("Age")%in%colnames(lm_input)){for (c in c("Age")){lm_input[,c]=qtrans(lm_input[,c])}}
if (c("SV")%in%colnames(lm_input)){for (c in c("SV")){lm_input[,c]=qtrans(lm_input[,c])}}

if ("DNA.Concentration" %in% names(lm_input)){
  for (d in c("DNA.Concentration")){lm_input[,d]=qtrans(lm_input[,d])}}
if ("log10_counts" %in% names(lm_input)){
  for (d in c("log10_counts")){lm_input[,d]=qtrans(lm_input[,d])}}

lm_res <- summary(lm(Y_shortbred~.,data = lm_input))
lm_input$Y_shortbred=resid(lm(Y_shortbred~Sex+Age,data=lm_input))

p2=ggplot(data = lm_input, mapping = aes(x =`X_phenotype`, y =`Y_shortbred`))+
  geom_point(color="brown",alpha=0.5,size=2)+
  geom_smooth(data =lm_input, mapping = aes(x =`X_phenotype`,y = `Y_shortbred`), method = "lm", formula = y ~ x,color="black")+
  labs(x = "thiamine", y = "UniRef90_R5P1L6\nPutative signal-transducing histidine kinase")+
  theme_bw()+
  theme(axis.text.y = element_text(face="plain",size=16,colour="black"),
        axis.text.x = element_text(face="plain",size=16,colour="black"),
        axis.title.y = element_text(face="bold",size=16,colour="black"),
        axis.title.x = element_text(face="bold",size=16,colour="black"))+
  scale_y_continuous(n.breaks = 8)+
  scale_x_continuous(n.breaks = 7)
library(patchwork)
p1+p2
