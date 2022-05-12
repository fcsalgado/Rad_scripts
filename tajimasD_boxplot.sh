vcftools --vcf polythore_popgen.vcf --missing-indv
touch tem_div.txt
cut -f 1 -d "_" out.imiss | sort | uniq | while read pop; 
do grep -E "$pop" out.imiss | cut -f 1 > $pop.txt
vcftools --vcf common_tags.vcf --TajimaD 150 --keep $pop.txt --out $pop
num=$(awk 'NR>1' $pop.Tajima.D | wc -l)
paste <(echo "$(printf "$pop\n%.0s" {1..$num})") <(echo "$(cut -f 4 $pop.Tajima.D | awk 'NR >1')") --delimiters '\t' >> tem_div.txt
;done

##Open R to plot TajimasD
library(ggplot2)
tabla<-read.table("tem_tajima.txt",head=F)
col<-read.table("../../paleta_colores.txt",head=F)
col<-col[order(col$V1),]
pdf("tajimasD.pdf",height=15,width=20)
ggplot(tabla,aes(x=V1,y=V2,fill=V1))+geom_boxplot()+scale_fill_manual(values=as.character(col$V2))+scale_x_discrete(name="Species")+scale_y_continuous(name="Tajima's D",limits=c(-3,4))+theme_classic()
dev.off()




