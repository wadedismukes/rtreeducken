// This is a simple example of exporting a C++ function to R. You can
// source this function into an R session using the Rcpp::sourceCpp
// function (or via the Source button on the editor toolbar). Learn
// more about Rcpp at:
//
//   http://www.rcpp.org/
//   http://adv-r.had.co.nz/Rcpp.html
//   http://gallery.rcpp.org/
//
#include "Simulator.h"
#include <string.h>

//' Simulates species tree using constant rate birth-death process
//'
//' @description Forward simulates to a number of tips. This function does so using
//'     the general algorithm of Hartmann et al. 2010.
//' @param sbr species birth rate (i.e. speciation rate)
//' @param sdr species death rate (i.e. extinction rate)
//' @param numbsim number of species trees to simulate
//' @param n_tips number of tips to simulate to
//' @return List of objects of the tree class (as implemented in APE)
//' @references
//' K. Hartmann, D. Wong, T. Stadler. Sampling trees from evolutionary models.
//'     Syst. Biol., 59(4): 465-476, 2010.
//'
//' T. Stadler. Simulating trees on a fixed number of extant species.
//'     Syst. Biol., 60: 676-684, 2011.
//' @examples
//' mu <- 0.5 # death rate
//' lambda <- 2.0 # birth rate
//' numb_replicates <- 10
//' numb_extant_tips <- 4
//' # simulate trees under the GSA so first simulates a tree with
//' # numb_extant_tips * 100 tips counting each time we have a tree with 10 tips
//' # then randomly picks one of those trees
//'
//' tree_list <- sim_sptree_bdp(sbr_ = lambda,
//'                 sdr_ = mu,
//'                 numbsim_ = numb_replicates,
//'                 n_tips_ = numb_extant_tips)
// [[Rcpp::export]]
Rcpp::List sim_sptree_bdp(SEXP sbr, SEXP sdr, SEXP numbsim, SEXP n_tips){
    double sbr_ = as<double>(sbr);
    double sdr_ = as<double>(sdr);
    unsigned numbsim_ = as<int>(numbsim);
    unsigned n_tips_ = as<int>(n_tips);
    RNGScope scope;
    if(sbr_ <= 0.0)
        stop("'sbr' must be bigger than 0.0.");
    if(sbr_ < sdr_)
        stop("'sbr' must be greater than 'sdr'");
    if(numbsim_ < 1)
        stop("'numbsim' must be more than 1");
    if(sdr_ < 0.0)
        stop("'sdr' must be 0.0 or greater.");
    if(n_tips_ < 1)
        stop("'n_tips' must be greater than 1.");
    return bdsim_species_tree(sbr_, sdr_, numbsim_, n_tips_);
}
//' Simulates species tree using constant rate birth-death process to a time
//'
//' @description Forward simulates a tree until a provided time is reached.
//' @param sbr_ species birth rate (i.e. speciation rate)
//' @param sdr_ species death rate (i.e. extinction rate)
//' @param numbsim_ number of species trees to simulate
//' @param t_ time to simulate to
//' @return List of objects of the tree class (as implemented in APE)
//' @references
//' K. Hartmann, D. Wong, T. Stadler. Sampling trees from evolutionary models.
//'     Syst. Biol., 59(4): 465-476, 2010.
//'
//' T. Stadler. Simulating trees on a fixed number of extant species.
//'     Syst. Biol., 60: 676-684, 2011.
//' @examples
//' mu <- 0.5 # death rate
//' lambda <- 2.0 # birth rate
//' numb_replicates <- 10
//' time <- 4
//'
//' tree_list <- sim_sptree_bdp_time(sbr_ = lambda,
//'                 sdr_ = mu,
//'                 numbsim_ = numb_replicates,
//'                 t_ = time)
// [[Rcpp::export]]
Rcpp::List sim_sptree_bdp_time(SEXP sbr, SEXP sdr, SEXP numbsim, SEXP t){
    double sbr_ = as<double>(sbr);
    double sdr_ = as<double>(sdr);
    unsigned numbsim_ = as<int>(numbsim);
    double t_ = as<double>(t);
    if(sbr_ <= 0.0)
        stop("'sbr' must be bigger than 0.0.");
    if(sbr_ < sdr_)
        stop("'sbr' must be greater than 'sdr'");
    if(numbsim_ < 1)
        stop("'numbsim' must be more than 1");
    if(sdr_ < 0.0)
        stop("'sdr' must be 0.0 or greater.");
    if(t_ <= 0.0)
        stop("'t' must be greater than 0.");
    return sim_bdsimple_species_tree(sbr_, sdr_, numbsim_, t_);
}
//' Simulates locus tree using constant rate birth-death-transfer process
//'
//' @description Given a species tree simulates a locus or gene family tree along
//'     the species tree.
//' @param species_tree species tree to simulate along
//' @param gbr gene birth rate
//' @param gdr gene death rate
//' @param lgtr gene trasnfer rate
//' @param num_loci number of locus trees to simulate
//' @return List of objects of the tree class (as implemented in APE)
//' @references
//' Rasmussen MD, Kellis M. Unified modeling of gene duplication, loss, and
//'     coalescence using a locus tree. Genome Res. 2012;22(4):755–765.
//'     doi:10.1101/gr.123901.111
//' @examples
//' # first simulate a species tree
//' mu <- 0.5 # death rate
//' lambda <- 2.0 # birth rate
//' numb_replicates <- 10
//' numb_extant_tips <- 4
//' # simulate trees under the GSA so first simulates a tree with
//' # numb_extant_tips * 100 tips counting each time we have a tree with 10 tips
//' # then randomly picks one of those trees
//'
//' sp_tree <- sim_sptree_bdp(sbr_ = lambda,
//'                 sdr = mu,
//'                 numbsim = numb_replicates,
//'                 n_tips = numb_extant_tips)
//'
//' gene_br <- 1.0
//' gene_dr <- 0.2
//' transfer_rate <- 0.2
//' sim_locustree_bdp(species_tree = sp_tree,
//'                   gbr = gene_br,
//'                   gdr = gene_dr,
//'                   lgtr = transfer_rate,
//'                   num_loci = 10)
// [[Rcpp::export]]
Rcpp::List sim_locustree_bdp(SEXP species_tree,
                             SEXP gbr,
                             SEXP gdr,
                             SEXP lgtr,
                             SEXP num_loci){
    Rcpp::List species_tree_ = as<Rcpp::List>(species_tree);
    RNGScope scope;
    double gbr_ = as<double>(gbr);
    double gdr_ = as<double>(gdr);
    double lgtr_ = as<double>(lgtr);
    unsigned numLoci = as<int>(num_loci);
    if(gbr_ < 0.0)
        stop("'gbr' must be a positive number or 0.0");
    if(gbr_ < gdr_){
        if(gbr_ == gdr_)
            stop("'gbr' can only be equal to 'gdr' if both are 0.0");
        stop("'gbr' must be greater than 'gdr'");
    }
    if(numLoci < 1)
        stop("'num_loci' must be greater than 1");
    if(lgtr_ < 0.0)
        stop("'lgtr' must be a positive number or 0.0");
    if(gdr_ < 0.0)
        stop("'gdr' must be greater than or equal to 0.0");
    if(strcmp(species_tree_.attr("class"), "phylo") != 0)
        stop("species_tree must be an object of class phylo'.");
    Rcout << "%%%%%%%%%" << std::endl;

    SpeciesTree* specTree = new SpeciesTree(species_tree_);
    return sim_locus_tree(specTree, gbr_, gdr_, lgtr_, numLoci);
}
//' Simulates a cophylogenetic system using a paired birth-death process
//'
//' @details Simulates a cophylogenetic system using birth-death processes. The
//'     host tree is simulated following a constant rate birth-death process
//'     with an additional parameter - the cospeciation rate. This rate works as
//'     the speciation rate with the additional effect that if cospeciation
//'     occurs the symbiont tree also speciates. The symbiont tree is related to
//'     the host tree via an association matrix that describes which lineages
//'     are associated with which. The symbiont tree has an independent
//'     birth-death process with the addition of a host shift speciation rate
//'     that allows for the addition of more associated hosts upon symbiont
//'     speciation.
//' @param hbr host tree birth rate
//' @param hdr host tree death rate
//' @param sbr symbiont tree birth rate
//' @param sdr symbiont tree death rate
//' @param host_exp_rate host shift speciation rate
//' @param cosp_rate cospeciation rate
//' @param timeToSimTo time units to simulate until
//' @param numbsim number of replicates
//' @return A list containing the `host_tree`, the `symbiont_tree`, the
//'     association matrix at present, and the history of events that have
//'     occurred.
//' @examples
//'
//' host_mu <- 0.5 # death rate
//' host_lambda <- 2.0 # birth rate
//' numb_replicates <- 10
//' time <- 1.0
//' symb_mu <- 0.2
//' symb_lambda <- 0.4
//' host_shift_rate <- 0.1
//' cosp_rate <- 2.0
//'
//' cophylo_pair <- sim_cophylo_bdp(hbr = host_lambda,
//'                            hdr = host_mu,
//'                            cosp_rate = cosp_rate,
//'                            host_exp_rate = host_shift_rate,
//'                            sdr = symb_mu,
//'                            sbr = symb_lambda,
//'                            numbsim = numb_replicates,
//'                            timeToSimTo = time)
//'
// [[Rcpp::export]]
Rcpp::List sim_cophylo_bdp(SEXP hbr,
                           SEXP hdr,
                           SEXP sbr,
                           SEXP sdr,
                           SEXP host_exp_rate,
                           SEXP cosp_rate,
                           SEXP timeToSimTo,
                           SEXP numbsim){
    double hbr_ = as<double>(hbr);
    double hdr_ = as<double>(hdr);
    double sbr_ = as<double>(sbr);
    double sdr_ = as<double>(sdr);
    double cosp_rate_ = as<double>(cosp_rate);
    double host_exp_rate_ = as<double>(host_exp_rate);
    double timeToSimTo_ = as<double>(timeToSimTo);
    int numbsim_ = as<int>(numbsim);
    RNGScope scope;
    if(hbr_ < 0.0){
         stop("'hbr' must be positive or 0.0.");
    }
    if((hbr_ + cosp_rate_) < hdr_){
        stop("'hbr + cosp_rate' must be greater than 'hdr'.");
    }
    if(hdr_ < 0.0){
        stop("'hdr' must be a positive value or 0.0.");
    }
    if(host_exp_rate_ < 0.0){
        stop("'host_exp_rate' must be a positive value or 0.0.");
    }
    if(numbsim_ < 1){
        stop("'numbsim' must be larger than 1.");
    }
    if(cosp_rate_ < 0.0)
        stop("'cosp_rate' must be a positive value or 0.0.");
    if(timeToSimTo_ < 0.0)
        stop("'timeToSimTo' must be a positive value or 0.0.");

    return sim_host_symb_treepair(hbr_,
                                  hdr_,
                                  sbr_,
                                  sdr_,
                                  host_exp_rate_,
                                  cosp_rate_,
                                  timeToSimTo_,
                                  numbsim_);
}
//' Simulate locus tree within species tree and gene trees within locus tree
//'
//' @description First simulates a locus tree within the confines of the input species tree using a constant-rate birth-death process
//' based on values of `gbr`, `gdr` and `lgtr`. Then simulates gene trees within that locus tree using the multi-locus coalescent process.
//' @param species_tree input species tree of class "phylo"
//' @param gbr gene birth rate
//' @param gdr gene death rate
//' @param lgtr lateral gene transfer rate'
//' @param theta the population genetic parameter
//' @param num_sampled_individuals number of individuals sampled within each locus lineage
//' @param num_loci number of loci to simulate
//' @param num_genes_per_locus number of genes to simulate within each locus
//'
//' @return A list of lists of length 2. The first element of each list of length 2 is `locus.tree` the locus tree and the second element is a list of the gene trees simulated within that locus tree. All trees are of class "phylo".
//'
//' @seealso sim_locustree_bdp
//'
//' @examples
//' # first simulate a species tree
//' mu <- 0.5
//' lambda <- 1.0
//' nt <- 6
//' tr <- sim_sptree_bdp(sbr = lambda, sdr = mu, numbsim = 1, n_tips = nt)
//' # for a locus tree with 100 genes sampled per locus tree
//' loctr_gentr <- sim_locustree_genetree_mlc(tr[[1]],
//'                                            gbr = 0.1,
//'                                            gdr = 0.0,
//'                                            lgtr = 0.0,
//'                                            theta = 1,
//'                                            num_sampled_individuals = 1,
//'                                            num_loci = 4,
//'                                            num_genes_per_locus = 100)
//'
//' @references
//' Mallo D, de Oliveira Martins L, Posada D (2015) SimPhy: Phylogenomic Simulation of Gene, Locus and Species Trees. Syst. Biol. doi: http://dx.doi.org/10.1093/sysbio/syv082
//'
// [[Rcpp::export]]
Rcpp::List sim_locustree_genetree_mlc(SEXP species_tree,
                             SEXP gbr,
                             SEXP gdr,
                             SEXP lgtr,
                             SEXP num_loci,
                             SEXP num_sampled_individuals,
                             SEXP theta,
                             SEXP num_genes_per_locus){
    Rcpp::List species_tree_ = as<Rcpp::List>(species_tree);
    double gbr_ = as<double>(gbr);
    double gdr_ = as<double>(gdr);
    double lgtr_ = as<double>(lgtr);
    unsigned numLoci = as<int>(num_loci);
    RNGScope scope;
    int num_sampled_individuals_ = as<int>(num_sampled_individuals);
    double theta_ = as<double>(theta);
    int num_genes_ = as<int>(num_genes_per_locus);

    if(gbr_ < 0.0)
        stop("'gbr' must be a positive number or 0.0");
    if(gbr_ < gdr_)
        stop("'gbr' must be greater than 'gdr'");
    if(numLoci < 1)
        stop("'num_loci' must be greater than or equal to 1");
    if(lgtr_ < 0.0)
        stop("'lgtr' must be a positive number or 0.0");
    if(gdr_ < 0.0)
        stop("'gdr' must be greater than or equal to 0.0");
    if(theta_ <= 0.0)
        stop("'theta' must be greater than 0.0.");
    if(num_genes_ < 1)
        stop("'num_genes_per_locus' must be greater than or equal to 1");
    if(num_sampled_individuals_ < 1)
        stop("'num_sampled_individuals' must be greater than or equal to 1");
    if(strcmp(species_tree_.attr("class"), "phylo") != 0)
        stop("species_tree must be an object of class phylo'.");
    SpeciesTree* specTree = new SpeciesTree(species_tree_);
    return sim_locus_tree_gene_tree(specTree,
                          gbr_,
                          gdr_,
                          lgtr_,
                          numLoci,
                          theta_,
                          num_sampled_individuals_,
                          num_genes_);
}

