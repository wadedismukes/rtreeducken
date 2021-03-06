#' Plot host and symbiont pair with current associations
#'
#' This function plots a host and symbiont tree given the object returned by
#' `sim_cophyBD`.
#'
#'
#'
#' This function is mostly an altered version of the cophyloplot function
#' written by Damien de Vienne Copyright 2008 - 2010 under GPL.
#' @author Wade Dismukes and Damien de Vienne
#' @param x a tree pair object returned by `sim_cophyBD`
#' @param use_edge_length Boolean to draw trees with edge length or not
#' @param type string "phylogram" or "cladogram"
#' @param col What color to draw links between trees
#' @param lwd Width of links between trees
#' @param lty Type of line to draw between trees
#' @param show_tip_label Boolean for showing labels
#' @param font What font to use (bold, italic (default), etc.)
#' @param fsize What size font as a character expansion factor (same as cex)
#' @param gap Size of the gap between the tips and tip names
#' @param show_div_bar Shows a bar under both trees with ticks where the divergences are (default: F)
#' @param ... other plotting parameters
#' @return a plot of the host and symbiont tree with extant interactions
#' @examples
#' host_mu <- 1.0 # death rate
#' host_lambda <- 2.0 # birth rate
#' numb_replicates <- 10
#' time <- 1.0
#' symb_mu <- 0.2
#' symb_lambda <- 0.4
#' host_shift_rate <- 0.0
#' cosp_rate <- 2.0
#'
#' cophylo_pair <- sim_cophyBD(hbr = host_lambda,
#'                            hdr = host_mu,
#'                            cosp_rate = cosp_rate,
#'                            host_exp_rate = host_shift_rate,
#'                            sdr = symb_mu,
#'                            sbr = symb_lambda,
#'                            numbsim = numb_replicates,
#'
#'                            time_to_sim = time)
#' plot.cophy(cophylo_pair[[1]])
plot.cophy <-
    function(x,
             use_edge_length = TRUE,
             type = "phylogram",
             col = par("fg"),
             lwd = par("lwd"),
             lty = par("lty"),
             show_tip_label = TRUE,
             gap = 1,
             font = 3,
             fsize = 1.0,
             show_div_bar = FALSE,
             ...) {

    if (!inherits(x, "cophy"))
        stop("cophy_obj should be an object of class 'cophy'.")

    show_scalebar = show_div_bar
    scalebar_fsize = 0
    host <- x$host_tree
    symb <- x$symb_tree
    host_tree_pruned <- treeducken::drop_extinct(host)
    symb_tree_pruned <- treeducken::drop_extinct(symb)
    assoc <- which(x$association_mat == 1, arr.ind = TRUE)
    assoc <- cbind(host_tree_pruned$tip.label[assoc[, 1]],
                   symb_tree_pruned$tip.label[assoc[, 2]])
    length_line <- 1

    treeducken::draw_cophy(host,
               symb,
               assoc = assoc,
               use_edge_length = use_edge_length,
               length_line = length_line,
               type = type,
               return = FALSE,
               col = col,
               lwd = lwd,
               lty = lty,
               show_tip_label = show_tip_label,
               font = font,
               fsize = fsize,
               gap = gap,
               show_scalebar = show_scalebar,
               scalebar_fsize = scalebar_fsize,
               ...)

}
#' Internal tree plot function
#' @description internal plot function from ape::plotCophylo2 under GPL v. 2
#'
#' @param x Host tree as phylo object
#' @param y Symb tree as phylo object
#' @param assoc Association matrix
#' @param use_edge_length Boolean to draw trees with edge length or not
#' @param length_line Length of interactions lines
#' @param return Return an object or no (default = FALSE)
#' @param type string "phylogram" or "cladogram"
#' @param col What color to draw links between trees
#' @param lwd Width of links between trees
#' @param lty Type of line to draw between trees
#' @param show_tip_label Boolean for showing labels
#' @param font What font to use (bold, italic (default), etc.)
#' @param fsize What size font as a character expansion factor (same as cex)
#' @param gap Gap between tips and tip names
#' @param show_scalebar Boolean for turning on and off the scalebar
#' @param scalebar_fsize Font size of scalebar
#' @param ... Other plotting parameters
#'
#'
#' @references
#' Paradis E. & Schliep K. 2019. ape 5.0: an environment for modern
#' phylogenetics and evolutionary analyses in R. Bioinformatics 35:
#' 526-528.
#' @keywords Internal

# x is the host
# y is the symb
draw_cophy <-
    function(x,
             y,
             assoc = assoc,
             use_edge_length = use_edge_length,
             length_line = length_line,
             type = type,
             return = return,
             col = col,
             lwd=lwd,
             lty=lty,
             show_tip_label = show_tip_label,
             font = font,
             fsize = fsize,
             gap = gap,
             show_scalebar = show_scalebar,
             scalebar_fsize = scalebar_fsize,
             ...) {
    res <- list()

###choice of the minimum space between the trees
    if (show_tip_label) {
        left <- max(nchar(x$tip.label, type = "width")) * fsize
        right <- max(nchar(y$tip.label, type = "width")) * fsize
        if (gap <= (left + right))
            gap <- -gap
    }
    else {
        left <- 0.0
        right <- 0.0
    }


    n_tip_x <- ape::Ntip(x)
    n_tip_y <- ape::Ntip(y)

    space <- left + right + gap * 2
    res$n_tip_x <- n_tip_x
    res$n_tip_y <- n_tip_y
    # a is coordinates of host
    a <- ape::plotPhyloCoor(x,
                            use_edge_length = use_edge_length,
                            type = type)
    res$a <- a
    p <- a
    h_root_row <- a[which(min(a[,1]) == p[,1]), ]
    h_root_row[1] <- h_root_row[1] - x$root.edge
    # b is coordinates of symbiont
    b <- ape::plotPhyloCoor(y,
                            use_edge_length = use_edge_length,
                            direction = "leftwards",
                            type = type)



    ###for the two trees to have the extreme leaves at the same ordinate.
    a[, 2] <- a[, 2] - min(a[, 2])
    b[, 2] <- b[, 2] - min(b[, 2])

    h_root_row[2] <- h_root_row[2] - min(a[,2])

    res$b <- b
    b2 <- b

    b2[, 1] <- b[seq_len(nrow(b)), 1] * (max(a[, 1]) / max(b[, 1])) +
        space + max(a[, 1])
    b2[, 2] <- b[seq_len(nrow(b)), 2] * (max(a[, 2]) / max(b[, 2]))
    res$b2 <- b2


    # find symbiont root
    p2 <- b2

    s_root_row <- b2[which(max(b2[,1]) == p2[,1]), ]
    s_root_row[1] <- s_root_row[1] + y$root.edge


    c <- matrix(ncol = 2, nrow = nrow(a) + nrow(b))
    c[seq_len(nrow(a)), ] <- a[seq_len(nrow(a)), ]
    c[nrow(a) + seq_len(nrow(b)), 1] <- b2[, 1]
    c[nrow(a) + seq_len(nrow(b)), 2] <- b2[, 2]
    res$c <- c
    graphics::plot(c, type = "n", xlim = c(h_root_row[1], s_root_row[1]), ylim = NULL, log = "", main = NULL,
        mar = c(0, 0, 0, 0),
        sub = NULL, xlab = NULL, ylab = NULL, ann = FALSE, axes = FALSE,
        frame.plot = FALSE)
 ###segments for cladograms
   if (type == "cladogram") {
        for (i in 1:(nrow(a) - 1)) segments(a[x$edge[i, 1], 1],
            a[x$edge[i, 1], 2], a[x$edge[i, 2], 1], a[x$edge[i,
                2], 2], col = "red")
        for (i in 1:(nrow(b) - 1))
            segments(b2[y$edge[i, 1], 1], b2[y$edge[i, 1], 2],
                     b2[y$edge[i, 2], 1], b2[y$edge[i, 2], 2])
    }
###segments for phylograms
    if (type == "phylogram") {
        for (i in (n_tip_x + 1):nrow(a)) {
            l <- length(x$edge[x$edge[, 1] == i, ][, 1])
            for (j in 1:l) {
                segments(a[x$edge[x$edge[, 1] == i, ][1, 1], 1],
                  a[x$edge[x$edge[, 1] == i, 2], 2][1],
                  a[x$edge[x$edge[, 1] == i, ][1, 1], 1],
                  a[x$edge[x$edge[, 1] == i, 2], 2][j])
                segments(a[x$edge[x$edge[, 1] == i, ][1, 1], 1],
                         a[x$edge[x$edge[, 1] == i, 2], 2][j],
                         a[x$edge[x$edge[, 1] == i, 2], 1][j],
                         a[x$edge[x$edge[, 1] == i, 2], 2][j])
            }
        }
        for (i in (n_tip_y + 1):nrow(b)) {
            l <- length(y$edge[y$edge[, 1] == i, ][, 1])
            for (j in 1:l) {
                segments(b2[y$edge[y$edge[, 1] == i, ][1, 1], 1],
                         b2[y$edge[y$edge[, 1] == i, 2], 2][1],
                         b2[y$edge[y$edge[, 1] == i, ][1, 1], 1],
                         b2[y$edge[y$edge[, 1] == i, 2], 2][j])
                segments(b2[y$edge[y$edge[, 1] == i, ][1, 1], 1],
                         b2[y$edge[y$edge[, 1] == i, 2], 2][j],
                         b2[y$edge[y$edge[, 1] == i, 2], 1][j],
                         b2[y$edge[y$edge[, 1] == i, 2], 2][j])
            }
        }
        segments(h_root_row[1],
                 (a[x$edge[x$edge[, 1] == (n_tip_x + 1), 2], 2][1] +
                     a[x$edge[x$edge[, 1] == (n_tip_x + 1), 2], 2][2]) / 2 ,
                 min(a[,1]),
                 (a[x$edge[x$edge[, 1] == (n_tip_x + 1), 2], 2][1] +
                      a[x$edge[x$edge[, 1] == (n_tip_x + 1), 2], 2][2]) / 2)
            segments(max(b2[,1]),
                 (b2[y$edge[y$edge[, 1] == (n_tip_y + 1), 2], 2][1] +
                     b2[y$edge[y$edge[, 1] == (n_tip_y + 1), 2], 2][2]) / 2,
                 s_root_row[1],
                 (b2[y$edge[y$edge[, 1] == (n_tip_y + 1), 2], 2][1] +
                      b2[y$edge[y$edge[, 1] == (n_tip_y + 1), 2], 2][2]) / 2)


    }
    if (show_tip_label) {
        # add host tips
        make_textbox(a[1:n_tip_x, 1], a[1:n_tip_x, 2],
                    label = x$tip.label,
                    pos = 4,
                    offset = 0.4,
                    cex = fsize,
                    font = font)
        # symb tips
        make_textbox(b2[1:n_tip_y, 1], b2[1:n_tip_y, 2],
                    label = y$tip.label,
                    pos = 2,
                    offset = 0.4,
                    cex = fsize,
                    font = font)


    }
###
## Plot links between associated taxa.
## Takes into account the size of the character strings of the taxa names.


    lsa <- 1:n_tip_x
    lsb <- 1:n_tip_y
    decx <- array(nrow(assoc))
    decy <- array(nrow(assoc))


    #colors
    if (length(col) == 1) colors <- c(rep(col, nrow(assoc)))
    else if (length(col) >= nrow(assoc)) colors <- col
    else  colors <- c(rep(col, as.integer(nrow(assoc) / length(col)) + 1))

    #lwd
    if (length(lwd) == 1) lwidths <- c(rep(lwd, nrow(assoc)))
    else if (length(lwd) >= nrow(assoc)) lwidths <- lwd
    else  lwidths <- c(rep(lwd, as.integer(nrow(assoc) / length(lwd)) + 1))

    #lty
    if (length(lty) == 1) ltype <- c(rep(lty, nrow(assoc)))
    else if (length(lty) >= nrow(assoc)) ltype <- lty
    else  ltype <- c(rep(lty, as.integer(nrow(assoc) / length(lty)) + 1))


    for (i in seq_len(nrow(assoc))) {
        if (show_tip_label) {
            decx[i] <- strwidth(x$tip.label[lsa[x$tip.label == assoc[i, 1]]]) * fsize + 0.35
            decy[i] <- strwidth(y$tip.label[lsb[y$tip.label == assoc[i, 2]]]) * fsize + 0.35
        } else {
            decx[i] <- decy[i] <- 0.2
        }
        segments(a[lsa[x$tip.label == assoc[i, 1]], 1] + decx[i],
                 a[lsa[x$tip.label == assoc[i, 1]], 2],
                 b2[lsb[y$tip.label == assoc[i, 2]], 1] - decy[i],
                 b2[lsb[y$tip.label == assoc[i, 2]], 2],
                 col = colors[i], lwd = lwidths[i], lty = ltype[i])
    }


    if (show_scalebar) {
        if (scalebar_fsize == 0)
            scalebar_fsize <- 1.0
        treeducken::add_scalebar(a, b2, scalebar_fsize)
    }


    if (return == TRUE)  res
}



#' Internal tree plot function
#' @description internal function to make textbox for tip labels
#' modified from phytools::TEXTBOX package under GPL v. 2
#' @author Wade Dismukes and Liam J Revell
#' @param x x coordinates
#' @param y y coordinates
#' @param label Labels as vector of strings
#' @param pos Position in plot environment
#' @param offset How offset from tips
#' @param cex a numerical vector giving the amount by which characters
#' should be scaled relative to the default
#' @param font font choice
#'
#'
#' @references
#' Revell, L.J. (2012), phytools: an R package for phylogenetic comparative
#' biology (and other things). Methods in Ecology and Evolution, 3: 217-223.
#' doi:10.1111/j.2041-210X.2011.00169.x
#' @keywords Internal
make_textbox <- function(x, y, label, pos, offset, cex, font) {
    rect(x, y - 0.5 * strheight(label, cex = cex, font = font),
         x + if (pos == 4) strwidth(label, cex = cex, font = font)
             else -strwidth(label, cex = cex, font = font),
         y + 0.5 * strheight(label, cex = cex, font = font), border = FALSE,
         col = if (par()$bg %in% c("white", "transparent")) "white"
               else par()$bg)
    text(x = x,
         y = y,
         label = label,
         pos = pos,
         offset = offset,
         cex = cex,
         font = font)
}


## function to draw sigmoidal links
## modified from phytools which is
## modified from https://stackoverflow.com/questions/32046889/connecting-two-points-with-curved-lines-s-ish-curve-in-r
## plot links between tip taxa according to assoc
## written by Liam J. Revell 2015, 2016, 2019
#' Curve draw function
#' @description internal function to draw curved links between tips modified from Liam Revell phytools package under GPL v. 2
#'
#' @param x x positions on graph
#' @param y y positions on graph
#' @param scale Scale of the logistic (which is where the curve comes from)
#' @param ... Other plotting parameters
#' @author Wade Dismukes and Liam J Revell
#' @references
#' Revell, L.J. (2012), phytools: an R package for phylogenetic comparative biology (and other things). Methods in Ecology and Evolution, 3: 217-223. doi:10.1111/j.2041-210X.2011.00169.x
#' @keywords Internal
draw_curve <- function(x, y, scale=0.01, ...) {
    x1 <- x[1]
    x2 <- x[2]
    y1 <- y[1]
    y2 <- y[2]
    curve(plogis(x,
                 scale = scale,
                 location = (x1 + x2) / 2) * (y2 - y1) + y1,
                 x1,
                 x2,
                 add = TRUE,
                 ...)
}


#' Add scale bar to cophylo plot
#'
#' This function plots a host and symbiont tree given the object returned by
#' `sim_cophyBD`.
#'
#' @param host_coords Host x,y coordinates
#' @param symb_coords Symb x,y coordinates
#' @param fsize Font size of scale bar
#' @keywords Internal
add_scalebar <- function(host_coords, symb_coords, fsize) {
    # host scale

    # the long line
    segments(min(host_coords[, 1]),
            -0.3,
            max(host_coords[, 1]))
    # print ticks at branching events
    for(i in seq_len(nrow(host_coords))) {
        segments(x0 = host_coords[i, 1],
                  y0 = -0.3,
                  y1 = -0.4)
    }


    # symb sclae

    # the long line
    segments(min(symb_coords[, 1]),
            -0.3,
            max(symb_coords[, 1]))
    # print ticks at branching events
    for(i in seq_len(nrow(symb_coords))) {
        segments(x0 = symb_coords[i, 1],
                  y0 = -0.3,
                  y1 = -0.4)
    }
}

#' @describeIn plot.cophy Plots multiple cophy plots
#' @param x object of class multiCophy
#' @export
plot.multiCophy <- function(x, ...) {
    par(ask = TRUE)
    for (i in seq_len(length(x))) {
        plot.cophy(x[[i]], ...)
    }
}



#' Add events from sim_cophyBD to plot.cophy
#'
#' @description This will plot the classical cophylogenetic events onto
#' the plot from plot.cophy if event_history is non-empty. At present this
#' only works with phylograms.
#'
#' @param cophy_obj Cophylogenetic object
#' @param pch Length 8 vector of plotting symbols to be used
#' @param col Length 8 vector of colors to be used in plot
#' @param gap the gap between the two trees
#' @param fsize the font size of tips (this must be set the same as used in plot.cophy)
#' @param show_tip_label Boolean indicating whether the plot has tip labels or not
#' @param type the type of graph ("phylogram" or "cladogram")
#' @param legend Boolean to turn on or off the legend
#' @return NULL
#' @details
#' The pch and color vectors place symbols or colors for the different events.
#' The order this vector is input determines which symbol corresponds to which
#' event.
#'   * Position 1 = cospeciation
#'   * Position 2 = host speciation
#'   * Position 3 = host extinction
#'   * Position 4 = symbiont speciation
#'   * Position 5 = symbiont extinction
#'   * Position 6 = host spread or host-switch symbiont speciation
#'   * Position 7 = anagenetic symbiont dispersal
#'   * Position 8 = anagenetic symbiont extirpation
#'
#'  By default a color vector is used in this order: purple, red, blue,
#'  darkorange, cyan, yellow, brown, seagreen
#' @examples
#' host_mu <- 1.0 # death rate
#' host_lambda <- 2.0 # birth rate
#' numb_replicates <- 10
#' time <- 1.0
#' symb_mu <- 0.2
#' symb_lambda <- 0.4
#' host_shift_rate <- 0.0
#' cosp_rate <- 2.0
#'
#' cophylo_pair <- sim_cophyBD(hbr = host_lambda,
#'                            hdr = host_mu,
#'                            cosp_rate = cosp_rate,
#'                            host_exp_rate = host_shift_rate,
#'                            sdr = symb_mu,
#'                            sbr = symb_lambda,
#'                            numbsim = numb_replicates,
#'
#'                            time_to_sim = time)
#' plot.cophy(cophylo_pair[[1]])
#' add_events(cophylo_pair[[1]], legend = FALSE)
add_events <- function(cophy_obj, legend = TRUE, pch = NULL, col = NULL, gap = 1, fsize = 1.0, type = "phylogram", show_tip_label = TRUE) {
    if (!inherits(cophy_obj, "cophy"))
        stop("cophy_obj should be an object of class 'cophy'.")
    if(is.null(cophy_obj$event_history)) {
        stop("you put in a cophy_obj with no events so I will do no plotting")
    }

    if(is.null(pch) && is.null(col))

        col <- c("purple", "red", "blue", "darkorange", "cyan", "yellow", "brown", "seagreen")
    else{
        if(!is.null(pch)) {
            if(length(pch) != 8)
                stop("pch given is incorrect length, needs to be 8.")
        }
        if(!is.null(col)) {
            if(length(col) != 8)
                stop("col given is incorrect length, needs to be 8.")
        }
    }
    if(!(type %in% c("phylogram", "cladogram"))){
        stop("type must be phylogram or cladogram")
    }
    host_tree <- cophy_obj$host_tree
    symb_tree <- cophy_obj$symb_tree
    events <- cophy_obj$event_history

###choice of the minimum space between the trees
    if (show_tip_label) {
        left <- max(nchar(host_tree$tip.label, type = "width")) * fsize
        right <- max(nchar(symb_tree$tip.label, type = "width")) * fsize
        if (gap <= (left + right))
           gap <- -gap
    }
    else {
        left <- 0.0
        right <- 0.0
    }

    space <- left + right + gap * 2

    n_tip_symb_tree <- ape::Ntip(symb_tree)


    # deal with host tree first
    n_tip_host_tree <- ape::Ntip(host_tree)

    host_speciations <- subset(events, "HSP" == events[,3])
    host_speciations$Event_Time <- round(host_speciations$Event_Time - host_tree$root.edge,
                                    digits = 6)
    cospeciations <- subset(events, "CSP" == events[,3])
    cospeciations$Event_Time <- round(cospeciations$Event_Time - host_tree$root.edge,
                                    digits = 6)

    host_extinctions <- subset(events, "HX" == events[,3])
    host_extinctions$Event_Time <- round(host_extinctions$Event_Time - host_tree$root.edge,
                                    digits = 6)
    host_events <- rbind(host_extinctions, cospeciations, host_speciations)

    host_coords <- ape::plotPhyloCoor(host_tree,
                                      use_edge_length = T,
                                      type = type)
    host_coords[, 2] <- host_coords[, 2] - min(host_coords[, 2])



    symb_cospeciations <- subset(events, "CSP" == events[,3])
    symb_speciations <- subset(events, "SSP" == events[,3])
    symb_extinctions <- subset(events, "SX" == events[,3])
    host_expansions <- subset(events, "SHE" == events[,3])
    dispersals <- subset(events, "DISP" == events[,3])
    extirpations <- subset(events, "EXTP" == events[,3])
    symb_events <- rbind(symb_speciations,
                 symb_cospeciations,
                 symb_extinctions,
                 host_expansions)

    anagenetic_events <- rbind(dispersals, extirpations)

    # symb_events$Event_Time <- round(symb_events$Event_Time - host_tree$root.edge,
    #                                 digits = 6)
    symb_events$Event_Time <- -symb_events$Event_Time

    symb_events$Event_Time <- symb_events$Event_Time + max(host_coords[,1]) +
            host_tree$root.edge


    ### get x and y coords for the host and symb tree

    symb_coords <- ape::plotPhyloCoor(symb_tree,
                            use_edge_length = T,
                            direction = "leftwards",
                            type = type)
###for the two trees to have the extreme leaves at the same ordinate.sr

# for coorfs of events subtract root roun to 6 places
# then its in coors  only ticky part is figuring out
# the symb sie an the symbols
    symb_coords[, 2] <- symb_coords[, 2] - min(symb_coords[, 2])
    symb_coords2 <- symb_coords

    # shift over
    symb_coords2[, 1] <- symb_coords[seq_len(nrow(symb_coords)), 1] * (max(host_coords[, 1]) / max(symb_coords[, 1])) + space + max(host_coords[, 1])
    symb_events$Event_Time <- round(symb_events$Event_Time * (max(host_coords[, 1]) / max(symb_coords[, 1])) + space + max(host_coords[, 1]), digits = 6)

    symb_coords2[, 2] <- symb_coords[seq_len(nrow(symb_coords)), 2] * (max(host_coords[, 2]) / max(symb_coords[, 2]))



    if(nrow(anagenetic_events) != 0) {
        anagenetic_events$Event_Time <- -anagenetic_events$Event_Time
        anagenetic_events$Event_Time <- anagenetic_events$Event_Time + max(host_coords[,1]) +
            host_tree$root.edge
        anagenetic_events$Event_Time <- round(anagenetic_events$Event_Time * (max(host_coords[, 1]) / max(symb_coords[, 1])) + space + max(host_coords[, 1]), digits = 6)
        anagenetic_events2 <- get_ana_events(symb_tree, symb_coords2, anagenetic_events)
    }
    # add to a big coords matrixxq
    coords <- matrix(ncol = 2, nrow = nrow(host_coords) + nrow(symb_coords))
    coords[seq_len(nrow(host_coords)), ] <- host_coords[seq_len(nrow(host_coords)), ]
    coords[nrow(host_coords) + seq_len(nrow(symb_coords)), 1] <- symb_coords2[, 1]
    coords[nrow(host_coords) + seq_len(nrow(symb_coords)), 2] <- symb_coords2[, 2]
    coords <- round(coords, digits = 6)

   # rows_w_evnts <- which(round(coords[, 1], digits = 6) %in% host_events$Event_Time)
   # rows_w_sy_evnts <- which(round(coords[, 1], digits = 6) %in% symb_events$Event_Time)
    rows_w_evnts <- vector(length = nrow(host_events))
    rows_w_sy_evnts <- vector(length = nrow(symb_events))
    for(j in seq_len(nrow(host_events))) {
        rows_w_evnts[j] <- which.min(abs(coords[,1] - host_events$Event_Time[j]))
    }
    for(i in seq_len(nrow(symb_events))) {
        rows_w_sy_evnts[i] <- which.min(abs(coords[,1] - symb_events$Event_Time[i]))
    }
    host_event_coords <- coords[rows_w_evnts,]
    host_event_coords <- host_event_coords[order(host_event_coords[,1]),]
    host_events <- host_events[order(host_events$Event_Time),]
    host_events$y <- host_event_coords[,2]

    symb_event_coords <- coords[rows_w_sy_evnts,]
    symb_event_coords <- symb_event_coords[order(symb_event_coords[,1]),]
    symb_events <- symb_events[order(symb_events$Event_Time),]
    symb_events$y <- symb_event_coords[,2]
    if(is.null(pch)) {
        with(subset(host_events, host_events[,3] == "CSP"), points(Event_Time, y, pch = 16, col = col[1]))
        with(subset(host_events, host_events[,3] == "HSP"), points(Event_Time, y, pch = 16, col = col[2]))
        with(subset(host_events, host_events[,3] == "HX"), points(Event_Time, y, pch = 16, col = col[3]))
        with(subset(symb_events, symb_events[,3] == "CSP"), points(Event_Time, y, pch = 16, col = col[1]))
        with(subset(symb_events, symb_events[,3] == "SSP"), points(Event_Time, y, pch = 16, col = col[4]))
        with(subset(symb_events, symb_events[,3] == "SX"), points(Event_Time, y, pch = 16, col = col[5]))
        with(subset(symb_events, symb_events[,3] == "SHE"), points(Event_Time, y, pch = 16,  col = col[6]))
        if(nrow(anagenetic_events) != 0) {
            with(subset(anagenetic_events2, anagenetic_events2[,3] == "DISP"), points(Event_Time, y_coords, pch = 16,  col = col[7]))
            with(subset(anagenetic_events2, anagenetic_events2[,3] == "EXTP"), points(Event_Time, y_coords, pch = 16,  col = col[8]))
        }
        if(legend) {
            legend(x = (min(coords[,1]) + max(coords[,1])) * 0.0075,
                   y = max(coords[,2]) + max(coords[,2]) * 0.275,
                   pch = 16, col = col,
                   legend = c("Cospeciation",
                              "Host Speciation",
                              "Host Extinction",
                              "Symbiont Speciation",
                              "Symbiont Extinction",
                              "Host Spreading",
                              "Dispersal",
                              "Extirpation"),
                   xpd = TRUE, bty = "n", cex = 1, ncol = 3)
        }

    }
    else{
        with(subset(host_events, host_events[,3] == "CSP"), points(Event_Time, y, pch = pch[1]))
        with(subset(host_events, host_events[,3] == "HSP"), points(Event_Time, y, pch = pch[2]))
        with(subset(host_events, host_events[,3] == "HX"), points(Event_Time, y, pch = pch[3]))

        with(subset(symb_events, symb_events[,3] == "CSP"), points(Event_Time, y, pch = pch[1]))
        with(subset(symb_events, symb_events[,3] == "SSP"), points(Event_Time, y, pch = pch[4]))
        with(subset(symb_events, symb_events[,3] == "SX"), points(Event_Time, y, pch = pch[5]))
        with(subset(symb_events, symb_events[,3] == "SHE"), points(Event_Time, y, pch = pch[6]))

        if(nrow(anagenetic_events) != 0) {
            with(subset(anagenetic_events2, anagenetic_events2[,3] == "DISP"), points(Event_Time, y_coords, pch = pch[7]))
            with(subset(anagenetic_events2, anagenetic_events2[,3] == "EXTP"), points(Event_Time, y_coords, pch = pch[8]))
        }
        if(legend) {
            legend(x = (min(coords[,1]) + max(coords[,1])) * 0.0075,
                   y = max(coords[,2]) + max(coords[,2]) * 0.275,
                   pch = pch,
                   legend = c("Cospeciation",
                              "Host Speciation",
                              "Host Extinction",
                              "Symbiont Speciation",
                              "Symbiont Extinction",
                              "Host Spreading",
                              "Dispersal",
                              "Extirpation"),
                   xpd = TRUE, bty = "n", cex = 1, ncol = 3)
        }
    }





}
#' Internal function for plotting anagenetic events
#' @param symb_tree the symb tree on which to plot the events
#' @param symb_coords the xy coordinates of `symb_tree` (obtained from the ape::plotPhyloCoor() function)
#' @param anagenetic_event_df a data frame formatted with these columns Host Index, Symbiont Index, Event Type, Event Time
#' @keywords internal
get_ana_events <- function(symb_tree, symb_coords, anagenetic_event_df) {
    # find row that is closest to event times
    # then make that y I tihnk?
    y_coords <- vector(length = nrow(anagenetic_event_df))
    s_indices <- anagenetic_event_df$Symbiont_Index
    for (i in seq_len(nrow(anagenetic_event_df))) {
        y_coords[i] <- symb_coords[s_indices[i],2]
    }

    anagenetic_event_df2 <- cbind(anagenetic_event_df, y_coords)
    anagenetic_event_df2
}
