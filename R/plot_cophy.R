#' Plot host and symbiont pair with current associations
#'
#' This function plots a host and symbiont tree given the object returned by
#' `sim_cophylo_bdp`.
#'
#'
#'
#' This function is mostly an altered version of the cophyloplot function
#' written by Damien de Vienne Copyright 2008 - 2010 under GPL.
#' @param x a tree pair object returned by `sim_cophylo_bdp`
#' @param use_edge_length Boolean to draw trees with edge length or not
#' @param type string "phylogram" or "cladogram"
#' @param col What color to draw links between trees
#' @param lwd Width of links between trees
#' @param lty Type of line to draw between trees
#' @param show_tip_label Boolean for showing labels
#' @param font What font to use (bold, italic (default), etc.)
#' @param fsize What size font as a character expansion factor (same as cex)
#' @param scalebar_size Size of scalebars (default is 0 -> no scalebar)
#' @param scalebar_fsize Font size of scalebars (default is 0 -> no scalebar)
#' @param ... other plotting parameters
#' @return a plot of the host and symbiont tree with extant interactions
#' @examples
#'
#' tr_pair <- sim_cophylo_bdp(hbr = 0.1,
#'                            hdr = 0.05,
#'                            sdr = 0.1,
#'                            host_exp_rate = 0.4,
#'                            sbr = 0.05,
#'                            cosp_rate =1.0,
#'                            numbsim = 10,
#'                            time_to_sim = 2)
#' plot.cophy(tr_pair[[1]])
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
             scalebar_size = 0,
             scalebar_fsize = 0,
            ...) {

    if (!inherits(x, "cophy"))
        stop("cophy_obj should be an object of class 'cophy'.")


    host <- x$host_tree
    symb <- x$symb_tree
    host_tree_pruned <- geiger::drop.extinct(host)
    symb_tree_pruned <- geiger::drop.extinct(symb)
    rownames(x$association_mat) <- symb_tree_pruned$tip.label
    colnames(x$association_mat) <- host_tree_pruned$tip.label
    assoc <- which(x$association_mat == 1, arr.ind = TRUE)
    assoc <- cbind(host_tree_pruned$tip.label[assoc[, 2]],
                   symb_tree_pruned$tip.label[assoc[, 1]])
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
               ...)

    if (any(scalebar_size > 0)) {
        if (scalebar_fsize == 0)
            scalebar_fsize <- 1.0
        treeducken::add_scalebar(x, c(scalebar_size, scalebar_size), scalebar_fsize)
    }
}
#' Internal tree plot function
#' @description internal plot function from ape::plotCophylo2 under GPL v. 2
#'
#' @param x Host tree as phylo object
#' @param y Symb tree as phylo object
#' @param assoc Association matrix as a two column list of strings
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
#' @param ... Other plotting parameters
#'
#'
#' @references
#' TODO: add in the ref
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
             ...) {
    res <- list()

###choice of the minimum space between the trees
    if (show_tip_label) {
        left <- max(nchar(x$tip.label, type = "width")) * fsize
        right <- max(nchar(y$tip.label, type = "width")) * fsize
    }
    else {
        gap <- -gap
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
    # b is coordinates of symbiont
    b <- ape::plotPhyloCoor(y,
                            use_edge_length = use_edge_length,
                            direction = "leftwards",
                            type = type)
###for the two trees to have the extreme leaves at the same ordinate.
    a[, 2] <- a[, 2] - min(a[, 2])
    b[, 2] <- b[, 2] - min(b[, 2])
    res$b <- b
    b2 <- b

    b2[, 1] <- b[seq_len(nrow(b)), 1] * (max(a[, 1]) / max(b[, 1])) +
        space + max(a[, 1])
    b2[, 2] <- b[seq_len(nrow(b)), 2] * (max(a[, 2]) / max(b[, 2]))
    res$b2 <- b2
    c <- matrix(ncol = 2, nrow = nrow(a) + nrow(b))
    c[seq_len(nrow(a)), ] <- a[seq_len(nrow(a)), ]
    c[nrow(a) + seq_len(nrow(b)), 1] <- b2[, 1]
    c[nrow(a) + seq_len(nrow(b)), 2] <- b2[, 2]
    res$c <- c
    plot(c, type = "n", xlim = NULL, ylim = NULL, log = "", main = NULL,
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
                segments(a[x$edge[x$edge[, 1] == i, ][1, 1],
                  1], a[x$edge[x$edge[, 1] == i, 2], 2][1], a[x$edge[x$edge[,
                  1] == i, ][1, 1], 1], a[x$edge[x$edge[, 1] ==
                  i, 2], 2][j])
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
    }
    if (show_tip_label) {
        # add host tips
        make_textbox(a[1:n_tip_x, 1], a[1:n_tip_x, 2],
                    label = x$tip.label,
                    pos = 4,
                    offset = 0.1,
                    cex = fsize,
                    font = font)
        # symb tips
        make_textbox(b2[1:n_tip_y, 1], b2[1:n_tip_y, 2],
                    label = y$tip.label,
                    pos = 2,
                    offset = 0.1,
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
            decx[i] <- strwidth(x$tip.label[lsa[x$tip.label == assoc[i, 1]]]) * fsize + 0.2
            decy[i] <- strwidth(y$tip.label[lsb[y$tip.label == assoc[i, 2]]]) * fsize + 0.2
        } else {
            decx[i] <- decy[i] <- 0.2
        }
        segments(a[lsa[x$tip.label == assoc[i, 1]], 1] + decx[i],
                 a[lsa[x$tip.label == assoc[i, 1]], 2],
                 b2[lsb[y$tip.label == assoc[i, 2]], 1] - decy[i],
                 b2[lsb[y$tip.label == assoc[i, 2]], 2],
                 col = colors[i], lwd = lwidths[i], lty = ltype[i])
    }
    if (return == TRUE)  res
}



#' Internal tree plot function
#' @description internal function to make textbox for tip labels
#' modified from phytools::TEXTBOX package under GPL v. 2
#'
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
#'
#' @references
#' Revell, L.J. (2012), phytools: an R package for phylogenetic comparative biology (and other things). Methods in Ecology and Evolution, 3: 217-223. doi:10.1111/j.2041-210X.2011.00169.x
#' @keywords Internal
draw_curve <- function(x, y, scale=0.01, ...){
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
#' `sim_cophylo_bdp`.
#'
#' @param obj An object of class `cophy`
#' @param scale.bar A list of 2 numeric values to indicate position of scale bars on plot
#' @param fsize Font size of scale bar
#' @keywords Internal
add_scalebar <- function(obj, scale.bar, fsize) {
    # host scale
    if (scale.bar[1] > 0) {
        s1 <- (max(fsize * strwidth(obj$host_tree$tip.label))) /
            max(ape::node.depth.edgelength(obj$host_tree))
        lines(c(-0.5,scale.bar[1] * s1), rep(-0.3, 2))
        lines(rep(-0.5, 2), c(-0.1, -0.06))
        lines(rep(-0.5 + scale.bar[1] * s1, 2), c(-0.3, -0.06))
        text(mean(c(-0.5, -0.5 + scale.bar[1] * s1)),
           rep(-0.1, 2), scale.bar[1], pos = 1)
    }
    # symbiont scale
    if (scale.bar[2] > 0) {
        s2 <- (max(fsize * strwidth(obj$symb_tree$tip.label))) /
             max(ape::node.depth.edgelength(obj$symb_tree))
        lines(c(0.5 - scale.bar[2] * s2, 0.5), rep(-0.3, 2))
        lines(rep(0.5 - scale.bar[2] * s2, 2), c(-0.3, -0.06))
        lines(rep(0.5, 2), c(-0.3, -0.06))
        text(mean(c(0.5 - scale.bar[2] * s2, 0.5)),
            rep(-0.1, 2), scale.bar[2], pos = 1)
    }
}

# this function was taken from Liam Revell's phytools
# package copied under GNU public license 2
#' @describeIn plot.cophy Plots multiple cophy plots
#' @param x object of class multiCophy
#' @export
plot.multiCophy <- function(x, ...) {
    par(ask = TRUE)
    for (i in seq_len(length(x))) {
        plot.cophy(x[[i]], ...)
    }
}