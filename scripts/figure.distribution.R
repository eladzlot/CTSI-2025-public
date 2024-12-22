#' Plot Motivations for Surface and Core Threats
#'
#' This function creates a bar plot to visualize the count of motivations for surface threats (proximal) and core threats.
#'
#' @param sf_list A list of motivations for surface threats (proximal threats).
#' @param cf_list A list of motivations for core threats.
#' @param main A character string specifying the title of the plot. The default is 'CTSI threat values'.
#'
#' @details
#' The function performs the following steps:
#' - Converts the input lists of motivations into frequency tables for plotting.
#' - Sets up an empty plot with appropriate x and y limits, and customizes the x-axis to label each motivation.
#' - Draws red lines representing surface threat counts and blue lines representing core threat counts for each motivation.
#' - Adds a legend to distinguish between surface threats (proximal) and core threats.
#'
#' @examples
#' # Example lists of motivations
#' surface_threats <- list("motivation1", "motivation2", "motivation1")
#' core_threats <- list("motivation2", "motivation3", "motivation3", "motivation1")
#'
#' # Call the function with example data
#' plot_motivations(surface_threats, core_threats, main = 'Threat Motivations Count')
#'
#' @export
plot_motivations = function(sf_list, cf_list, main = 'CTSI Threat Values') {
    move_ambig = function(vec){ c(vec)[c(10,1:9)] }
    N = length(MOTIVATIONS)

    # Prepare data for plotting (converting lists to tables for line heights)
    d_sf = unlist(sf_list) %>% factor(levels = 1:N) %>% table %>% (function(x){x / sum(x)}) %>% move_ambig
    d_cf = unlist(cf_list) %>% factor(levels = 1:N) %>% table %>% (function(x){x / sum(x)}) %>% move_ambig
    
    # Set up the plot space
    plot(NULL, type = "n", xlim = c(0.5, N + 0.5), ylim = c(0, .5) * 1.1, 
         xaxt = "n", lwd = 6, xlab = NA, ylab = "Count", main = main)

    # Custom x-axis
    axis(side = 1, at = 1:N, labels = FALSE, las = 2)
    text(x = 1:N, -.15, labels = MOTIVATIONS %>% move_ambig, srt = 70, pos = 1, xpd = TRUE, cex = .7)

    # Draw the data lines
    pallete = c('#E57A77','#3d65A5')
    for (i in 1:N) {
      lines(c(i, i) - .1, c(0, d_sf[i]), col = pallete[1], lwd = 4)
      lines(c(i, i) + .1, c(0, d_cf[i]), col = pallete[2], lwd = 4)
    }

    # Add legend
    legend("top", legend = c("Proximal", "Core"), col = pallete, lwd = 4, bty='n')
}

# Create a 2x2 layout
par(mfrow = c(2, 2), mar = c(4, 3, 1, 1), oma = c(0, 0, 2, 0))
plot_motivations(agreementLists[[1]]$values_sf, agreementLists[[1]]$values_cf, 'High OC')
plot_motivations(agreementLists[[2]]$values_sf, agreementLists[[2]]$values_cf, 'TICSA')
plot_motivations(agreementLists[[3]]$values_sf, agreementLists[[3]]$values_cf, 'Online')
plot_motivations(agreementLists[[4]]$values_sf, agreementLists[[4]]$values_cf, 'WET')
par(mfrow = c(1, 1))
