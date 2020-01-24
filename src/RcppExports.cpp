// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

// treeducken
int treeducken(std::string params_file);
RcppExport SEXP _treeducken_treeducken(SEXP params_fileSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< std::string >::type params_file(params_fileSEXP);
    rcpp_result_gen = Rcpp::wrap(treeducken(params_file));
    return rcpp_result_gen;
END_RCPP
}
// sim_sptree_bdp
Rcpp::List sim_sptree_bdp(SEXP sbr_, SEXP sdr_, SEXP numbsim_, SEXP n_tips_);
RcppExport SEXP _treeducken_sim_sptree_bdp(SEXP sbr_SEXP, SEXP sdr_SEXP, SEXP numbsim_SEXP, SEXP n_tips_SEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< SEXP >::type sbr_(sbr_SEXP);
    Rcpp::traits::input_parameter< SEXP >::type sdr_(sdr_SEXP);
    Rcpp::traits::input_parameter< SEXP >::type numbsim_(numbsim_SEXP);
    Rcpp::traits::input_parameter< SEXP >::type n_tips_(n_tips_SEXP);
    rcpp_result_gen = Rcpp::wrap(sim_sptree_bdp(sbr_, sdr_, numbsim_, n_tips_));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_treeducken_treeducken", (DL_FUNC) &_treeducken_treeducken, 1},
    {"_treeducken_sim_sptree_bdp", (DL_FUNC) &_treeducken_sim_sptree_bdp, 4},
    {NULL, NULL, 0}
};

RcppExport void R_init_treeducken(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
