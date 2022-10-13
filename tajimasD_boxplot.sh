vcftools --vcf polythore_popgen.vcf --missing-indv
touch tem_div.txt
cut -f 1 -d "_" out.imiss | sort | uniq | while read pop; 
do grep -E "$pop" out.imiss | cut -f 1 > $pop.txt
vcftools --vcf common_tags.vcf --TajimaD 150 --keep $pop.txt --out $pop
num=$(awk 'NR>1' $pop.Tajima.D | wc -l)
paste <(echo "$(printf "$pop\n%.0s" {1..$num})") <(echo "$(cut -f 4 $pop.Tajima.D | awk 'NR >1')") --delimiters '\t' >> tem_div.txt
;done

##Open R to plot TajimasD
library(tidyverse)
datos<-read_delim("tem_div.txt",col_names=F)
names(datos)<-c("tag","value","pop")
niveles<-c("beata","mutata","spnov2","concinna","spnov1","procera","gigantea","terminata","derivata","ornata","neopicta","victoria")
datos$pop<-factor(datos$pop,levels=niveles,ordered=TRUE)
paleta1<-c("#00802a","#e8d479","#d82567","#ff72ce","#536200","#00ddcb","#002277","#ff9a7c","#95e790","#cf6c0f","#4b64db","#7a002d")
ggplot(datos,aes(pop,value,fill=pop))+geom_point(shape = 21,size=2, position = position_jitter(width = .05),alpha=0.75)+geom_violin(alpha=0.4, position = position_dodge(width = .75),size=1)+geom_boxplot(outlier.size = -1,lwd=1.2, alpha = 0.7)+
     #stat_summary(fun.data = "mean_sdl", geom = "pointrange", mult=1,colour = "black")+
     scale_fill_manual(values=paleta1)+
     scale_colour_manual(values=paleta1)+
     theme_classic()




