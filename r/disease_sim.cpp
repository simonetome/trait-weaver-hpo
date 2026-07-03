#include <Rcpp.h>
using namespace Rcpp;


// [[Rcpp::export]]
NumericMatrix disease_similarity_matrix_cpp(List pheno_idx_list, NumericMatrix term_term_mat) {
  
  // how many diseases
  int n = pheno_idx_list.size();  
  NumericMatrix sim_matrix(n, n); 
  
  double t_t_sim;
  double cur_max;
  
  // how many HP_term for d1,d2   
  int ni,mj;
  // cumulative sums for directional distance terms
  double sum1, sum2;
  
  for (int i = 0; i < n; i++) {
    // list of annotation indexes for disease[i]
    // disease[i] = d1
    IntegerVector indexes_d1 = pheno_idx_list[i];
      
    ni = indexes_d1.size();
    
    for (int j = i; j < n; j++) {
      
      IntegerVector indexes_d2 = pheno_idx_list[j];
      mj = indexes_d2.size();
      
      // cumulative sums for d1,d2 distance term 
      sum1 = 0.0; 
      sum2 = 0.0;
      
      // cur_max over d2 for each term in d1
      for (int x = 0; x < ni; x++) {
        
        cur_max = R_NegInf;
        
        // index (C-converted) for HP_term x
        int ii = indexes_d1[x] - 1;
        
        for (int y = 0; y < mj; y++) {
          
          t_t_sim = term_term_mat(ii, indexes_d2[y] - 1);
          if (t_t_sim > cur_max) cur_max = t_t_sim;
        }
        sum1 += cur_max;
      }
      
      // do the same in the other direction d2 -> d1
      for (int y = 0; y < mj; y++) {
        
        cur_max = R_NegInf;
        
        // index (C-converted) for HP_term x
        int jj = indexes_d2[y] - 1;
        
        for (int x = 0; x < ni; x++) {
          
          t_t_sim = term_term_mat(indexes_d1[x] - 1, jj);
          if (t_t_sim > cur_max) cur_max = t_t_sim;
        }
        sum2 += cur_max;
      }
      
      
      double s = 0.5 * (sum1 / ni + sum2 / mj);
      sim_matrix(i, j) = s;
      sim_matrix(j, i) = s;
    }
  }
  
  return sim_matrix;
}















