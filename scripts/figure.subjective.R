tbl = table(
  rep(1:3, c(agreementLists[[2]]$N,agreementLists[[3]]$N,agreementLists[[4]]$N)),
  c(agreementLists[[2]]$is_real,agreementLists[[3]]$is_real,agreementLists[[4]]$is_real)%>% factor(levels = c(1,3,2))
)
colnames(tbl) <- c('','','')
rownames(tbl) <- c('TD FTF', 'TD Online (He)', 'TD Online (En)')

# Save the original graphical parameters
original_par <- par()

# Create the mosaic plot
mosaicplot(
  tbl, main = "Likelihood of Identifying True Motivator",
  color = c("#0072B2", "#D55E00", "#009E73"),
  xlab = '', ylab = ''
)

# Add the legend below the plot
legend(
  "bottom", inset = -0.2, xpd = TRUE, 
   legend = c('Is Motivation','Not Sure', 'Not Motivation'), 
  fill = c("#0072B2", "#D55E00", "#009E73"), 
  horiz = TRUE, cex = 0.8, bty = "n"
)
